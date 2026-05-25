import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request permissions for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Request Android 13+ permission explicitly
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    // Initialize local notifications for foreground messages
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Create Android Notification Channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Handle navigation here if needed
    });
  }

  /// Starts listening to the Firestore 'notifications' collection for the current user.
  /// This acts as a fallback/mock for real push notifications when Cloud Functions are not yet set up.
  void startForegroundNotificationListener(String userId) {
    _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _showLocalNotificationFromData(
              title: data['title'] ?? 'Notification',
              body: data['body'] ?? '',
              payload: data['data']?.toString() ?? '',
            );
            
            // Mark as 'processed' so it doesn't show again
            change.doc.reference.update({'status': 'processed'});
          }
        }
      }
    });
  }

  Future<void> _showLocalNotificationFromData({
    required String title,
    required String body,
    required String payload,
  }) async {
    debugPrint('Attempting to show local notification: $title - $body');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> saveTokenToFirestore(String userId) async {
    String? token = await getToken();
    if (token != null) {
      await _firestore.collection('fcm_tokens').doc(userId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM Token saved for user: $userId');
    }
  }

  // This method would ideally be called from a Cloud Function
  // But for this project, we might need a way to trigger it
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // For now, we add to a 'notifications' collection which a Cloud Function 
      // should listen to. This is the recommended "client-side trigger" pattern.
      await _firestore.collection('notifications').add({
        'recipientId': recipientId,
        'title': title,
        'body': body,
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Notification record created for: $recipientId');
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'package:homeo_ocaus/core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    debugPrint("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: kIsWeb ? const FirebaseOptions(
      apiKey: "AIzaSyAteRekm_YdYUhm4dhHvgwXY4gam_3OywM",
      authDomain: "homeo-ocaus.firebaseapp.com",
      projectId: "homeo-ocaus",
      storageBucket: "homeo-ocaus.firebasestorage.app",
      messagingSenderId: "1098453998984",
      appId: "1:1098453998984:web:00d077893bbf71a7756e3d",
      measurementId: "G-KL8BK59BW5",
    ) : null,
  );

  if (!kIsWeb) {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Notification Service
    await NotificationService().initialize();
  }

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  runApp(
    const ProviderScope(
      child: HomeoApp(),
    ),
  );
}

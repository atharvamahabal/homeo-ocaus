import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'package:homeo_ocaus/core/services/notification_service.dart';
import 'package:homeo_ocaus/core/utils/dummy_data_tool.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Dummy Data (Uncomment to insert test data on app start)
  // await DummyDataTool.insertTestData();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  runApp(
    const ProviderScope(
      child: HomeoApp(),
    ),
  );
}

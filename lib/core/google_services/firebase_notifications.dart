import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../routes/app_routes.dart';
import '../routes/navigator_key_provider.dart';

/// Provider for NotificationService (Riverpod)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return NotificationService(navigatorKey: navigatorKey);
});

class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  NotificationService({required this.navigatorKey}) {
    _initLocalNotifications();
  }

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Request notification permission
  Future<void> requestedNotificationPermission() async {
    await Permission.notification.request();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("✅ User granted notification permission");
    } else {
      debugPrint("❌ Notification permission denied");
    }
  }

  /// Get FCM token
  Future<String?> getDeviceToken() async {
    String? token = await messaging.getToken();
    debugPrint("📱 FCM Token: $token");
    return token;
  }

  /// Init local notifications
  void _initLocalNotifications() {
    const androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosInit = DarwinInitializationSettings();

    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        handleMassage(RemoteMessage(data: {"navigate": "bottomNavigationPage"}));
      },
    );

    // Create Android channel
    const channel = AndroidNotificationChannel(
      "high_importance_channel",
      "High Importance Notifications",
      description: "This channel is used for important notifications",
      importance: Importance.high,
    );

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Listen for foreground messages
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("📩 Foreground Notification: ${message.notification?.title}");

      if (Platform.isAndroid) {
        showNotification(message);
      }
    });
  }

  /// Show local notification
  Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: "data",
    );
  }

  /// Background & terminated messages
  Future<void> setupInteractMassage() async {
    // Background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMassage(message);
    });

    // Terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleMassage(message);
      }
    });
  }

  /// Navigate on notification tap
  Future<void> handleMassage(RemoteMessage message) async {
    navigatorKey.currentState?.pushNamed(AppRoutes.notificationScreen);
  }
}

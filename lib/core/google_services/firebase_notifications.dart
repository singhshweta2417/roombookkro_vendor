import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
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
    try {
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
    } catch (e) {
      debugPrint("⚠️ Error requesting notification permission: $e");
    }
  }

  /// Get FCM token with retry logic and error handling
  Future<String?> getDeviceToken({int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        String? token = await messaging.getToken().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Token retrieval timeout');
          },
        );

        if (token != null) {
          debugPrint("📱 FCM Token: $token");
          return token;
        }

        debugPrint("⚠️ Token is null, attempt ${attempt + 1}/$maxRetries");
      } on FirebaseException catch (e) {
        debugPrint("🔥 Firebase Error (attempt ${attempt + 1}/$maxRetries): ${e.code} - ${e.message}");

        if (e.code == 'unavailable' || e.message?.contains('SERVICE_NOT_AVAILABLE') == true) {
          debugPrint("⚠️ FCM service unavailable. This might be due to:");
          debugPrint("   - No internet connection");
          debugPrint("   - Google Play Services outdated/unavailable");
          debugPrint("   - Temporary Firebase service issue");
        }
      } catch (e) {
        debugPrint("❌ Error getting FCM token (attempt ${attempt + 1}/$maxRetries): $e");
      }

      // Wait before retry (exponential backoff)
      if (attempt < maxRetries - 1) {
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
      }
    }

    debugPrint("⚠️ Failed to get FCM token after $maxRetries attempts. Continuing without token.");
    return null;
  }

  /// Get token without blocking (for non-critical operations)
  Future<String?> getDeviceTokenSafe() async {
    try {
      return await getDeviceToken(maxRetries: 1).timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint("⚠️ Safe token retrieval failed: $e");
      return null;
    }
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

  /// Check if FCM is available
  Future<bool> isFCMAvailable() async {
    try {
      final token = await messaging.getToken().timeout(
        const Duration(seconds: 3),
      );
      return token != null;
    } catch (e) {
      return false;
    }
  }
}
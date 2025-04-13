import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppFirebaseService {
  AppFirebaseService._();

  static final AppFirebaseService instance = AppFirebaseService._();
  factory AppFirebaseService() => instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize Firebase and Notification services
  Future<void> initialize() async {
    await requestPermission();
    await _setupForegroundNotificationHandler();
    await _setupBackgroundMessageHandler();

    // Get FCM Token
    String? token = await getFcmToken();
    log("FCM Token: $token");
  }

  /// Request notification permissions (iOS & Web)
  Future<void> requestPermission() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      log("Notification Permission Status: ${settings.authorizationStatus}");
    } catch (e) {
      log("Error requesting notification permissions: $e");
    }
  }

  /// Get FCM Token for Android, iOS, and Web
  Future<String?> getFcmToken({int maxRetries = 3}) async {
    try {
      return kIsWeb
          ? await _firebaseMessaging.getToken(
              vapidKey:
                  'BElSUkxBnFsd2zVZZSBoeWZxuJAPHCxvITuFvVlWSN7fEaLvMI4AnlO6m0JQbOAy2QuJyL8Ca_kH8DZaowgU7Ww',
            )
          : await _firebaseMessaging.getToken();
    } catch (e) {
      if (maxRetries > 0) {
        log("Error getting FCM token we will retry after 5 secs : $e");
        await Future.delayed(const Duration(seconds: 5));
        return getFcmToken(maxRetries: maxRetries - 1);
      } else {
        log("Error getting FCM token: $e");

        return null;
      }
    }
  }

  /// Handle foreground messages
  Future<void> _setupForegroundNotificationHandler() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Foreground message received: ${message.notification?.title}");
      AppNotificationService.instance.showLocalNotification(message);
    });
  }

  /// Handle background and terminated state messages
  Future<void> _setupBackgroundMessageHandler() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification opened from background: ${message.notification?.title}");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }
}

/// Background message handler
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  log("Background message received: ${message.notification?.title}");
}

class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService instance = AppNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Local Notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(initSettings);
  }

  /// Show Local Notification when app is in foreground
  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.high,
        priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.show(
        0,
        message.notification?.title ?? "New Notification",
        message.notification?.body ?? "You have a new message",
        details,
      );
    } catch (e) {
      log("Error displaying local notification: $e");
    }
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:offline_test_app/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();
  factory FirebaseService() {
    return instance;
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize Firebase and request notification permissions.
  Future<void> initialize() async {
    // Request permission for iOS
    await requestPermission();

    // Get and print FCM Token
    String? token = await getFcmToken();
    print("FCM Token: $token");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("New message received: ${message.notification?.title}");
    });
  }

  /// Request notification permissions (iOS & Web)
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Notification Permission Status: ${settings.authorizationStatus}");
  }

  /// Get FCM Token for Android, iOS, and Web
  Future<String?> getFcmToken() async {
    try {
      if (kIsWeb) {
        return await _firebaseMessaging.getToken(
            vapidKey:
                'BElSUkxBnFsd2zVZZSBoeWZxuJAPHCxvITuFvVlWSN7fEaLvMI4AnlO6m0JQbOAy2QuJyL8Ca_kH8DZaowgU7Ww');
      }
      print("fetching non web token :");
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }
}

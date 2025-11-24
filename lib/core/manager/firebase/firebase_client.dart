import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseClient {
  static final firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> handleBackgroundMessage(RemoteMessage? message) async {
    if (message == null) return;
    debugPrint('--> Handling a background message: ${message.messageId}');
  }

  static Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    debugPrint('--> Handling a message: ${message.messageId}');
  }

  static Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  static Future<String> getFcmToken() async {
    final fcmToken = await firebaseMessaging.getToken();
    return fcmToken.toString();
  }

  static Future<void> initFirebaseMessaging() async {
    await firebaseMessaging.requestPermission();
    // final fcmToken = await firebaseMessaging.getToken();

    // debugPrint('--> FCM Token: $fcmToken');
    await initPushNotifications();
  }
}

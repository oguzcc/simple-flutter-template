import 'package:daisy/core/manager/notification/local_notification_handler.dart';
import 'package:daisy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background / terminated FCM handler.
///
/// Must be a top-level (or static) function with the @pragma annotation so
/// the engine can resolve it after isolate restart. Keep it lightweight —
/// no UI state, no Bloc, no router access.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The background isolate is fresh; ensure Firebase is up.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // For data-only messages on Android we still want to surface something
  // to the user; for notification-bearing messages the system tray handles
  // display, so avoid double-showing.
  final notification = message.notification;
  if (notification == null) {
    final title = (message.data['title'] as String?) ?? '';
    final body = message.data['body'] as String?;
    if (title.isEmpty && (body == null || body.isEmpty)) return;
    await LocalNotificationHandler.instance.show(
      title: title.isEmpty ? 'Notification' : title,
      body: body,
      payload: _encodePayload(message.data),
    );
  }
  debugPrint('[fcm:bg] ${message.messageId}');
}

String? _encodePayload(Map<String, dynamic> data) {
  if (data.isEmpty) return null;
  return data.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent('${e.value}')}')
      .join('&');
}

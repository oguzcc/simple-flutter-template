import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler for taps that come in while the app is in the background.
/// Must be top-level so the engine can resolve it after isolate restart.
@pragma('vm:entry-point')
void onBackgroundLocalNotificationTap(NotificationResponse response) {
  debugPrint('[notifications] background tap payload=${response.payload}');
}

class LocalNotificationHandler {
  LocalNotificationHandler._();

  static final LocalNotificationHandler instance = LocalNotificationHandler._();

  /// Default FCM channel. Must match `default_notification_channel_id`
  /// declared in AndroidManifest.xml so that notification-only FCM messages
  /// also land here.
  static const AndroidNotificationChannel defaultChannel =
      AndroidNotificationChannel(
    'fcm_default_channel',
    'General Notifications',
    description: 'General notifications',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  int _idCounter = 0;
  bool _initialized = false;

  Future<void> Function(NotificationResponse response)? onTap;

  Future<void> init({
    Future<void> Function(NotificationResponse response)? onTap,
  }) async {
    if (_initialized) return;
    this.onTap = onTap;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleForegroundTap,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundLocalNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(defaultChannel);
    }

    _initialized = true;
  }

  Future<void> _handleForegroundTap(NotificationResponse response) async {
    await onTap?.call(response);
  }

  Future<void> show({
    required String title,
    String? body,
    String? payload,
    AndroidNotificationChannel? channel,
  }) async {
    if (!_initialized) await init();
    _idCounter++;

    final androidChannel = channel ?? defaultChannel;
    await _plugin.show(
      id: _idCounter,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: androidChannel.importance,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}

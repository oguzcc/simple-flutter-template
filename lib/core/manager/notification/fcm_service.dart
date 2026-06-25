import 'dart:async';
import 'dart:io';

import 'package:daisy/core/manager/notification/fcm_background_handler.dart';
import 'package:daisy/core/manager/notification/local_notification_handler.dart';
import 'package:daisy/data/notification/models/notification_action.dart';
import 'package:daisy/data/notification/notification_queue_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Single entry-point for Firebase Cloud Messaging.
///
/// Responsibilities:
///   * Request user permission (iOS / Android 13+).
///   * Register the top-level background handler.
///   * Configure foreground presentation options for iOS.
///   * Bridge incoming messages (foreground / opened / initial) into the
///     [NotificationQueueManager], so the rest of the app sees one stream.
///   * Display Android local notifications for foreground messages
///     (Android does not surface them automatically; iOS does via the
///     foreground presentation options).
///   * Expose token + token-refresh stream and topic helpers.
class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    LocalNotificationHandler? localNotifications,
    NotificationQueueManager? queue,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? LocalNotificationHandler.instance,
        _queue = queue ?? NotificationQueueManager.instance;

  final FirebaseMessaging _messaging;
  final LocalNotificationHandler _localNotifications;
  final NotificationQueueManager _queue;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  bool _initialized = false;

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Boots the service. Idempotent.
  Future<NotificationSettings> initialize() async {
    if (_initialized) {
      return _messaging.getNotificationSettings();
    }
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[fcm] permission=${settings.authorizationStatus}');

    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _localNotifications.init(onTap: _onLocalNotificationTap);

    _onMessageSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _onOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      await _enqueue(initial, fromTap: true);
    }

    return settings;
  }

  /// Returns the device FCM token, or null if APNS hasn't registered yet
  /// (common in the iOS simulator). Safe to call repeatedly.
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        final apns = await _messaging.getAPNSToken();
        if (apns == null) {
          debugPrint('[fcm] APNS token not ready (simulator?)');
          return null;
        }
      }
      return await _messaging.getToken();
    } on Object catch (e) {
      debugPrint('[fcm] getToken failed: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    _initialized = false;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[fcm:fg] ${message.messageId}');
    if (Platform.isAndroid) {
      final notification = message.notification;
      final title = notification?.title ?? (message.data['title'] as String?);
      final body = notification?.body ?? (message.data['body'] as String?);
      if (title != null && title.isNotEmpty) {
        await _localNotifications.show(
          title: title,
          body: body,
          payload: _encodePayload(message.data),
        );
      }
    }
    await _enqueue(message, fromTap: false);
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    debugPrint('[fcm:opened] ${message.messageId}');
    await _enqueue(message, fromTap: true);
  }

  Future<void> _enqueue(RemoteMessage message, {required bool fromTap}) async {
    final data = message.data;
    final title = message.notification?.title ?? (data['title'] as String?) ?? '';
    final body = message.notification?.body ?? (data['body'] as String?) ?? '';

    final type = fromTap
        ? _resolveActionType(data)
        : NotificationActionType.general;

    await _queue.enqueueNotificationAction(
      notificationId: message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      data: Map<String, dynamic>.from(data),
      type: type,
    );
  }

  NotificationActionType _resolveActionType(Map<String, dynamic> data) {
    if (data['url'] is String && (data['url'] as String).isNotEmpty) {
      return NotificationActionType.deepLink;
    }
    if (data['route'] is String && (data['route'] as String).isNotEmpty) {
      return NotificationActionType.navigation;
    }
    return NotificationActionType.general;
  }

  Future<void> _onLocalNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final data = _decodePayload(payload);
    final type = _resolveActionType(data);
    await _queue.enqueueNotificationAction(
      notificationId: 'local-${response.id ?? DateTime.now().microsecondsSinceEpoch}',
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      data: data,
      type: type,
    );
  }

  String? _encodePayload(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    return data.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent('${e.value}')}')
        .join('&');
  }

  Map<String, dynamic> _decodePayload(String payload) {
    final result = <String, dynamic>{};
    for (final pair in payload.split('&')) {
      final idx = pair.indexOf('=');
      if (idx < 0) continue;
      final key = Uri.decodeComponent(pair.substring(0, idx));
      final value = Uri.decodeComponent(pair.substring(idx + 1));
      result[key] = value;
    }
    return result;
  }
}

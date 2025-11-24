import 'dart:developer' as developer;

import 'package:daisy/data/notification/models/notification_action.dart';
import 'package:daisy/data/notification/notification_queue_manager.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal notification service
class OneSignalService {
  OneSignalService._();
  static final OneSignalService instance = OneSignalService._();

  final NotificationQueueManager _queueManager =
      NotificationQueueManager.instance;
  bool _isInitialized = false;
  String? _playerId;

  /// Initializes OneSignal with app ID
  Future<void> initialize({required String appId}) async {
    try {
      developer.log('Initializing OneSignal with app ID: $appId');

      // Initialize OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(appId);

      // Set up notification handlers
      _setupNotificationHandlers();

      // Request permission (iOS)
      await OneSignal.Notifications.requestPermission(true);

      _isInitialized = true;
      developer.log('OneSignal initialized successfully');
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Failed to initialize OneSignal',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets up notification click and received handlers
  void _setupNotificationHandlers() {
    // Handle notification opened (clicked)
    OneSignal.Notifications.addClickListener(_onNotificationOpened);

    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener(
      _onNotificationWillDisplay,
    );

    // Handle subscription changes
    OneSignal.User.pushSubscription.addObserver(_onSubscriptionChanged);
  }

  /// Handles notification click events
  void _onNotificationOpened(OSNotificationClickEvent event) {
    developer.log('Notification clicked: ${event.notification.notificationId}');

    final notification = event.notification;
    final additionalData = notification.additionalData ?? {};

    // Queue the notification action
    _queueManager.enqueueNotificationAction(
      notificationId: notification.notificationId ?? '',
      title: notification.title ?? '',
      body: notification.body ?? '',
      data: {
        ...additionalData,
        'launchUrl': notification.launchUrl,
        'actionId': event.result.actionId,
      },
      type: _determineActionType(additionalData),
    );
  }

  /// Handles notifications displayed in foreground
  void _onNotificationWillDisplay(OSNotificationWillDisplayEvent event) {
    developer.log(
      'Notification received in foreground: '
      '${event.notification.notificationId}',
    );

    // You can modify the notification or prevent it from showing
    event.notification.display();
  }

  /// Handles subscription changes
  void _onSubscriptionChanged(OSPushSubscriptionChangedState state) {
    developer.log('Subscription changed: ${state.current.id != null}');

    if (state.current.id != null) {
      _playerId = state.current.id;
      developer.log('Player ID: $_playerId');
    }
  }

  /// Determines the action type based on additional data
  NotificationActionType _determineActionType(Map<String, dynamic> data) {
    if (data.containsKey('deep_link') || data.containsKey('url')) {
      return NotificationActionType.deepLink;
    }
    if (data.containsKey('screen') || data.containsKey('route')) {
      return NotificationActionType.navigation;
    }
    return NotificationActionType.general;
  }

  /// Sets user ID for personalized notifications
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, cannot set user ID');
      return;
    }

    try {
      await OneSignal.login(userId);
      developer.log('User ID set: $userId');
    } on Exception catch (e) {
      developer.log('Failed to set user ID: $e');
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, cannot logout');
      return;
    }

    try {
      await OneSignal.logout();
      _playerId = null;
      developer.log('User logged out from OneSignal');
    } on Exception catch (e) {
      developer.log('Failed to logout from OneSignal: $e');
    }
  }

  /// Sets user tags for segmentation
  Future<void> setTags(Map<String, String> tags) async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, cannot set tags');
      return;
    }

    try {
      await OneSignal.User.addTags(tags);
      developer.log('Tags set: $tags');
    } on Exception catch (e) {
      developer.log('Failed to set tags: $e');
    }
  }

  /// Removes user tags
  Future<void> removeTags(List<String> keys) async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, cannot remove tags');
      return;
    }

    try {
      await OneSignal.User.removeTags(keys);
      developer.log('Tags removed: $keys');
    } on Exception catch (e) {
      developer.log('Failed to remove tags: $e');
    }
  }

  /// Gets current subscription status
  bool get isSubscribed {
    if (!_isInitialized) return false;
    return OneSignal.User.pushSubscription.id != null;
  }

  /// Gets current player ID
  String? get playerId => _playerId;

  /// Gets initialization status
  bool get isInitialized => _isInitialized;

  /// Triggers opt-in for push notifications
  Future<void> optIn() async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, cannot opt in');
      return;
    }

    try {
      await OneSignal.User.pushSubscription.optIn();
      developer.log('User opted in for push notifications');
    } on Exception catch (e) {
      developer.log('Failed to opt in: $e');
    }
  }

  /// Triggers opt-out for push notifications
  Future<void> optOut() async {
    if (!_isInitialized) {
      developer.log('OneSignal not initialized, cannot opt out');
      return;
    }

    try {
      await OneSignal.User.pushSubscription.optOut();
      developer.log('User opted out from push notifications');
    } on Exception catch (e) {
      developer.log('Failed to opt out: $e');
    }
  }

  /// Sends a test notification (useful for debugging)
  Future<void> sendTestNotification() async {
    if (!_isInitialized || _playerId == null) {
      developer.log('Cannot send test notification: not properly initialized');
      return;
    }

    developer.log('Test notification functionality would be implemented here');
    // Note: Actual notification sending requires server-side implementation
    // This is just a placeholder for client-side testing preparation
  }
}

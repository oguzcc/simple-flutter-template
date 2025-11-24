import 'dart:async';
import 'dart:developer' as developer;

import 'package:daisy/data/notification/models/notification_action.dart';

/// Manages notification actions during app initialization
/// Queues notifications received before app is fully ready
class NotificationQueueManager {
  NotificationQueueManager._();
  static final NotificationQueueManager instance = NotificationQueueManager._();
  final List<NotificationAction> _pendingActions = [];
  bool _isAppReady = false;
  Completer<void>? _appReadyCompleter;
  
  /// Marks the app as ready to process notifications
  void markAppAsReady() {
    developer.log('App marked as ready for notifications');
    _isAppReady = true;
    _appReadyCompleter?.complete();
    _processPendingActions();
  }
  
  /// Marks the app as not ready (useful for restart scenarios)
  void markAppAsNotReady() {
    developer.log('App marked as not ready for notifications');
    _isAppReady = false;
    _appReadyCompleter = null;
  }
  
  /// Enqueues a notification action to be processed when app is ready
  Future<void> enqueueNotificationAction({
    required String notificationId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationActionType type = NotificationActionType.general,
  }) async {
    final action = NotificationAction(
      notificationId: notificationId,
      title: title,
      body: body,
      data: data ?? {},
      type: type,
      timestamp: DateTime.now(),
    );
    
    developer.log(
      'Enqueuing notification action: ${action.notificationId}, '
      'App ready: $_isAppReady',
    );
    
    if (_isAppReady) {
      await _executeNotificationAction(action);
    } else {
      _pendingActions.add(action);
      await _waitForAppReady();
    }
  }
  
  /// Waits for the app to be ready before processing notifications
  Future<void> _waitForAppReady() async {
    if (_isAppReady) return;
    
    _appReadyCompleter ??= Completer<void>();
    await _appReadyCompleter!.future;
  }
  
  /// Processes all pending notification actions
  void _processPendingActions() {
    if (_pendingActions.isEmpty) {
      developer.log('No pending notification actions to process');
      return;
    }
    
    developer.log(
      'Processing ${_pendingActions.length} pending notification actions',
    );
    
    for (final action in _pendingActions) {
      _executeNotificationAction(action);
    }
    
    _pendingActions.clear();
  }
  
  /// Executes a notification action
  Future<void> _executeNotificationAction(NotificationAction action) async {
    try {
      developer.log('Executing notification action: ${action.notificationId}');
      
      switch (action.type) {
        case NotificationActionType.deepLink:
          await _handleDeepLinkAction(action);
        case NotificationActionType.navigation:
          await _handleNavigationAction(action);
        case NotificationActionType.general:
          await _handleGeneralAction(action);
      }
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Error executing notification action: ${action.notificationId}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Handles deep link notifications
  Future<void> _handleDeepLinkAction(NotificationAction action) async {
    final url = action.data['url'] as String?;
    if (url != null) {
      // TODO(dev): Implement deep link handling
      developer.log('Deep link action: $url');
    }
  }
  
  /// Handles navigation notifications
  Future<void> _handleNavigationAction(NotificationAction action) async {
    final route = action.data['route'] as String?;
    if (route != null) {
      // TODO(dev): Implement navigation handling
      developer.log('Navigation action: $route');
    }
  }
  
  /// Handles general notifications
  Future<void> _handleGeneralAction(NotificationAction action) async {
    // Show in-app notification or other general handling
    developer.log('General notification action: ${action.title}');
  }
  
  /// Clears all pending actions (useful for testing or reset scenarios)
  void clearPendingActions() {
    developer.log(
      'Clearing ${_pendingActions.length} pending notification actions',
    );
    _pendingActions.clear();
  }
  
  /// Gets the count of pending actions
  int get pendingActionsCount => _pendingActions.length;
  
  /// Checks if app is ready to process notifications
  bool get isAppReady => _isAppReady;
}

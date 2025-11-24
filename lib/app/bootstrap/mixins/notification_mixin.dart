part of '../../bootstrap.dart';

/// Mixin for Notification services initialization
mixin _NotificationMixin {
  /// Initialize notification services
  Future<void> initializeNotifications() async {
    log('🔔 Initializing Notification Services...');
    
    // Initialize OneSignal if API key is available
    final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
    if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
      await OneSignalService.instance.initialize(appId: oneSignalAppId);
      log('✅ OneSignal initialized with app ID');
    } else {
      log('⚠️ OneSignal not configured - missing ONESIGNAL_APP_ID');
    }
    
    // Mark app as ready for notification processing
    NotificationQueueManager.instance.markAppAsReady();
    log('✅ Notification queue manager ready');
  }
}

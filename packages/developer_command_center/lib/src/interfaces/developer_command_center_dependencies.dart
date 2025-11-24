// Abstract interfaces for external dependencies

/// Analytics client interface for tracking events
abstract class AnalyticsClientInterface {
  void logWidgetTap({
    required String widgetId,
    required String widgetType,
    Map<String, Object>? extraData,
  });
  
  void logButtonTap({
    required String buttonId,
    required String buttonText,
    String? buttonType,
    Map<String, Object>? extraData,
  });
  
  void logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object>? extraData,
  });
  
  void logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  });
  
  void logTimingEvent({
    required String name,
    required Duration duration,
    String? category,
    String? variable,
  });
  
  // Additional methods for dashboard analytics
  Future<Map<String, int>> getMostTappedWidgets();
  Future<Map<String, Duration>> getMostVisitedScreens();
  Future<Map<String, dynamic>> analyzeNavigationPattern();
  Future<Map<String, Map<String, int>>> getAllHeatmapData();
  
  // Funnel tracking
  void logFunnelStep({
    required String funnelName,
    required String stepName,
    Map<String, Object>? extraData,
  });
}

/// OneSignal service interface for push notifications
abstract class OneSignalServiceInterface {
  Future<String?> getUserId();
  Future<String?> getPushToken();
  Future<bool> getOptedIn();
  Future<Map<String, dynamic>> getDiagnostics();
  Future<void> sendNotification();
  Future<void> clearBadgeCount();
  Future<void> toggleOptIn();
}

/// Dio client interface for HTTP requests
abstract class DioClientInterface {
  String get token;
}

/// App flavor interface for environment configuration
abstract class AppFlavorInterface {
  String get name;
  bool get isProduction;
  bool get isDevelopment;
  bool get isStaging;
}

/// Notification queue manager interface
abstract class NotificationQueueManagerInterface {
  Map<String, dynamic> getQueueStatus();
  Map<String, dynamic> getQueueStats();
  void clearQueue();
  void pauseQueue();
  void resumeQueue();
}

/// Notification handler interface
abstract class NotificationHandlerInterface {
  Map<String, dynamic> getHandlerStatus();
  void restartHandler();
  void stopHandler();
}

/// Network logger enhanced interface
abstract class NetworkLoggerEnhancedInterface {
  int get totalLogsCount;
  void openAdvancedLogViewer();
  void clearLogs();
  void exportLogs();
  
  // Debug logging callback support
  static void Function(String)? _debugLogCallback;
  static void setDebugLogCallback(void Function(String) callback) {
    _debugLogCallback = callback;
  }
  static void clearDebugLogCallback() {
    _debugLogCallback = null;
  }
  static void debugLog(String message) {
    _debugLogCallback?.call(message);
  }
}

/// All dependencies container
class DeveloperCommandCenterDependencies {
  final AnalyticsClientInterface analyticsClient;
  final OneSignalServiceInterface? oneSignalService;
  final DioClientInterface? dioClient;
  final AppFlavorInterface? appFlavor;
  final NotificationQueueManagerInterface? notificationQueueManager;
  final NotificationHandlerInterface? notificationHandler;
  final NetworkLoggerEnhancedInterface? networkLogger;

  const DeveloperCommandCenterDependencies({
    required this.analyticsClient,
    this.oneSignalService,
    this.dioClient,
    this.appFlavor,
    this.notificationQueueManager,
    this.notificationHandler,
    this.networkLogger,
  });
}
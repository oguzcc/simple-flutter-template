import 'package:developer_command_center/developer_command_center.dart';
import 'package:flutter/foundation.dart';

class DaisyAnalyticsClient implements AnalyticsClientInterface {
  final Map<String, int> _tappedWidgets = {};
  final Map<String, Duration> _visitedScreens = {};
  final Map<String, DateTime> _screenStartTimes = {};
  final Map<String, dynamic> _navigationPattern = {};
  final Map<String, Map<String, int>> _heatmapData = {};

  @override
  void logWidgetTap({
    required String widgetId,
    required String widgetType,
    Map<String, Object>? extraData,
  }) {
    _tappedWidgets[widgetId] = (_tappedWidgets[widgetId] ?? 0) + 1;
    debugPrint(
        'Widget tapped: $widgetId ($widgetType) - Count: ${_tappedWidgets[widgetId]}',
    );
  }

  @override
  void logButtonTap({
    required String buttonId,
    required String buttonText,
    String? buttonType,
    Map<String, Object>? extraData,
  }) {
    _tappedWidgets[buttonId] = (_tappedWidgets[buttonId] ?? 0) + 1;
    debugPrint(
        'Button tapped: $buttonId ($buttonText) - Count: ${_tappedWidgets[buttonId]}',
    );
  }

  @override
  void logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object>? extraData,
  }) {
    // Start tracking screen time
    _screenStartTimes[screenName] = DateTime.now();
    debugPrint('Screen viewed: $screenName');
  }

  @override
  void logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) {
    debugPrint('Custom event: $eventName with parameters: $parameters');
  }

  @override
  void logTimingEvent({
    required String name,
    required Duration duration,
    String? category,
    String? variable,
  }) {
    debugPrint('Timing event: $name - ${duration.inMilliseconds}ms');
  }

  @override
  Future<Map<String, int>> getMostTappedWidgets() async {
    return Map.from(_tappedWidgets);
  }

  @override
  Future<Map<String, Duration>> getMostVisitedScreens() async {
    return Map.from(_visitedScreens);
  }

  @override
  Future<Map<String, dynamic>> analyzeNavigationPattern() async {
    return Map.from(_navigationPattern);
  }

  @override
  Future<Map<String, Map<String, int>>> getAllHeatmapData() async {
    return Map.from(_heatmapData);
  }

  @override
  void logFunnelStep({
    required String funnelName,
    required String stepName,
    Map<String, Object>? extraData,
  }) {
    debugPrint('Funnel step: $funnelName -> $stepName');
  }

  void endScreenView(String screenName) {
    final startTime = _screenStartTimes[screenName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _visitedScreens[screenName] = 
          (_visitedScreens[screenName] ?? Duration.zero) + duration;
      _screenStartTimes.remove(screenName);
    }
  }

  void addMockData() {
    _tappedWidgets.addAll({
      'LoginButton': 156,
      'ProfileImage': 89,
      'NavigationDrawer': 67,
      'SearchBar': 45,
      'LogoutButton': 23,
    });

    _visitedScreens.addAll({
      'Home': const Duration(minutes: 45),
      'Profile': const Duration(minutes: 23),
      'Settings': const Duration(minutes: 12),
      'About': const Duration(minutes: 8),
    });
  }
}
import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:flutter/material.dart';

/// Analytics Mixin for easy event tracking
///
/// Provides convenient methods for tracking common events across the app.
/// Usage: Mix this into your StatefulWidget State classes or Cubit classes.
///
/// Example:
/// ```dart
/// class MyScreenState extends State<MyScreen> with AnalyticsMixin {
///   @override
///   void initState() {
///     super.initState();
///     trackScreenView('MyScreen');
///   }
/// }
/// ```
mixin AnalyticsMixin {
  /// Get analytics service instance
  AnalyticsService get _analytics => AnalyticsService.instance;

  /// Track screen view automatically
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackScreenView(screenName, properties: properties);
  }

  /// Track custom event with properties
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(eventName, properties: properties);
  }

  /// Track button tap
  Future<void> trackButtonTap(
    String buttonName, {
    String? screenName,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'button_tap',
      properties: {
        'button_name': buttonName,
        'screen_name': ?screenName,
        ...?properties,
      },
    );
  }

  /// Track navigation event
  Future<void> trackNavigation(
    String fromScreen,
    String toScreen, {
    String? trigger,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'navigation',
      properties: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
        'trigger': ?trigger,
        ...?properties,
      },
    );
  }

  /// Track form submission
  Future<void> trackFormSubmission(
    String formName, {
    bool? success,
    String? errorMessage,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'form_submission',
      properties: {
        'form_name': formName,
        'success': ?success,
        'error_message': ?errorMessage,
        ...?properties,
      },
    );
  }

  /// Track search query
  Future<void> trackSearch(
    String query, {
    int? resultCount,
    String? category,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'search',
      properties: {
        'query': query,
        'result_count': ?resultCount,
        'category': ?category,
        ...?properties,
      },
    );
  }

  /// Track share action
  Future<void> trackShare(
    String contentType,
    String contentId, {
    String? method,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'share',
      properties: {
        'content_type': contentType,
        'content_id': contentId,
        'method': ?method,
        ...?properties,
      },
    );
  }

  /// Track error event
  Future<void> trackError(
    String errorType,
    String errorMessage, {
    String? screenName,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'error',
      properties: {
        'error_type': errorType,
        'error_message': errorMessage,
        'screen_name': ?screenName,
        ...?properties,
      },
    );
  }

  /// Track user sign in
  Future<void> trackSignIn(
    String method, {
    bool? success,
    String? errorCode,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackSignIn(method);

    // Track additional details
    if (success != null || errorCode != null) {
      await trackEvent(
        'sign_in_result',
        properties: {
          'method': method,
          'success': ?success,
          'error_code': ?errorCode,
          ...?properties,
        },
      );
    }
  }

  /// Track user sign up
  Future<void> trackSignUp(
    String method, {
    bool? success,
    String? errorCode,
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackSignUp(method);

    // Track additional details
    if (success != null || errorCode != null) {
      await trackEvent(
        'sign_up_result',
        properties: {
          'method': method,
          'success': ?success,
          'error_code': ?errorCode,
          ...?properties,
        },
      );
    }
  }

  /// Track user sign out
  Future<void> trackSignOut({
    String? reason,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'sign_out',
      properties: {'reason': ?reason, ...?properties},
    );
  }

  /// Track onboarding step
  Future<void> trackOnboardingStep(
    int stepNumber,
    String stepName, {
    String? action, // 'viewed', 'completed', 'skipped'
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'onboarding_step',
      properties: {
        'step_number': stepNumber,
        'step_name': stepName,
        'action': ?action,
        ...?properties,
      },
    );
  }

  /// Track app lifecycle events
  Future<void> trackAppLifecycle(
    AppLifecycleState state, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'app_lifecycle',
      properties: {'state': state.name, ...?properties},
    );
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(
    String featureName, {
    String? action, // 'accessed', 'used', 'completed'
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'feature_usage',
      properties: {
        'feature_name': featureName,
        'action': ?action,
        ...?properties,
      },
    );
  }

  /// Track performance metrics
  Future<void> trackPerformance(
    String metricName,
    double value, {
    String? unit,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'performance',
      properties: {
        'metric_name': metricName,
        'value': value,
        'unit': ?unit,
        ...?properties,
      },
    );
  }

  /// Track engagement metrics
  Future<void> trackEngagement(
    String engagementType, {
    double? duration,
    int? count,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'engagement',
      properties: {
        'engagement_type': engagementType,
        'duration': ?duration,
        'count': ?count,
        ...?properties,
      },
    );
  }
}

/// Analytics Mixin specifically for StatefulWidgets
///
/// Automatically tracks screen view and navigation events
mixin ScreenAnalyticsMixin<T extends StatefulWidget> on State<T> {
  /// Screen name for analytics (override this in your widget)
  String get screenName =>
      T.toString().replaceAll('State', '').replaceAll('_', '');

  /// Analytics service instance
  AnalyticsService get _analytics => AnalyticsService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analytics.trackScreenView(screenName);
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    _analytics.trackEvent(
      'app_lifecycle',
      properties: {'state': state.name, 'screen': screenName},
    );
  }

  /// Track when user leaves this screen
  void trackScreenExit(String toScreen) {
    _analytics.trackEvent(
      'screen_exit',
      properties: {'from_screen': screenName, 'to_screen': toScreen},
    );
  }

  /// Track custom screen-specific event
  Future<void> trackScreenEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.trackEvent(
      eventName,
      properties: {'screen_name': screenName, ...?properties},
    );
  }
}

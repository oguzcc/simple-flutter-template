import 'dart:async';

import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryClient {
  static late AnalyticsService _analytics;
  static bool _isInitialized = false;

  static Future<void> init({
    required String dsn,
    FutureOr<void> Function()? appRunner,
  }) async {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = dsn
          ..tracesSampleRate = 1.0
          ..debug = kDebugMode
          ..beforeSend = _beforeSend;
      },
      appRunner: appRunner,
    );
    
    _analytics = AnalyticsService.instance;
    _isInitialized = true;
  }

  /// Filter and enrich events before sending to Sentry
  static SentryEvent? _beforeSend(SentryEvent event, Hint hint) {
    // Add correlation ID for analytics tracking
    final correlationId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Track error in analytics with correlation
    if (_isInitialized) {
      _analytics.trackEvent('sentry_error_captured', properties: {
        'correlation_id': correlationId,
        'error_type': event.throwable?.runtimeType.toString() ?? 'unknown',
        'level': event.level?.name ?? 'error',
      });
    }
    
    return event;
  }

  static Future<void> func(VoidCallback func) async {
    try {
      func();
    } on Exception catch (exception, stackTrace) {
      debugPrint('SentryClient.captureException: $exception');
      await _captureWithCorrelation(exception, stackTrace);
    }
  }

  static Future<T> funcWithReturnValue<T>(T Function() func) async {
    try {
      return func();
    } on Exception catch (exception, stackTrace) {
      debugPrint('SentryClient.captureException: $exception');
      await _captureWithCorrelation(exception, stackTrace);
      rethrow;
    }
  }

  /// Capture exception with analytics correlation
  static Future<void> _captureWithCorrelation(
    dynamic exception,
    StackTrace stackTrace,
  ) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }

  /// Add breadcrumb for user action tracking
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  /// Set user context
  static void setUserContext({
    String? userId,
    String? email,
    Map<String, dynamic>? extras,
  }) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
        data: extras,
      ));
    });
  }

  /// Clear user context
  static void clearUserContext() {
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}

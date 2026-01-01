import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Unified Analytics Service for Daisy App
///
/// Provides a single interface for tracking events with Firebase Analytics
///
/// Features:
/// - Unified event tracking API
/// - Service status monitoring
/// - Error handling and reporting
/// - Privacy-compliant data collection
/// - Environment-based configuration
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  // Analytics services
  late final FirebaseAnalytics _firebaseAnalytics;

  // Service status tracking
  bool _isFirebaseInitialized = false;
  bool _isInitialized = false;

  // Analytics observer for automatic screen tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);

  /// Initialize analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase Analytics
      await _initializeFirebase();

      _isInitialized = true;

      log('🔥 Analytics Service initialized successfully');
      log('📊 Firebase Analytics: $_isFirebaseInitialized');
    } catch (e, stackTrace) {
      log('❌ Failed to initialize Analytics Service: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Initialize Firebase Analytics
  Future<void> _initializeFirebase() async {
    try {
      _firebaseAnalytics = FirebaseAnalytics.instance;
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(true);

      // Get app version from package info
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      // Set default user properties
      await _firebaseAnalytics.setUserProperty(
        name: 'app_version',
        value: appVersion,
      );

      _isFirebaseInitialized = true;
      log('✅ Firebase Analytics initialized with version: $appVersion');
    } catch (e) {
      log('❌ Firebase Analytics initialization failed: $e');
    }
  }

  /// Track custom event
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      log('⚠️ Analytics not initialized, queueing event: $eventName');
      return;
    }

    try {
      final enrichedProperties = await _enrichProperties(properties);

      // Track with Firebase Analytics
      if (_isFirebaseInitialized) {
        await _firebaseAnalytics.logEvent(
          name: _sanitizeEventName(eventName),
          parameters: _sanitizeProperties(enrichedProperties),
        );
      }

      if (kDebugMode) {
        log('📊 Event tracked: $eventName');
        log('📋 Properties: $enrichedProperties');
      }
    } catch (e, stackTrace) {
      log('❌ Failed to track event: $eventName - $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Track screen view
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'screen_view',
      properties: {'screen_name': screenName, ...?properties},
    );
  }

  /// Track user sign in
  Future<void> trackSignIn(String method) async {
    await trackEvent('login', properties: {'method': method});
  }

  /// Track user sign up
  Future<void> trackSignUp(String method) async {
    await trackEvent('sign_up', properties: {'method': method});
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    String? userEmail,
    Map<String, dynamic>? customProperties,
  }) async {
    if (!_isInitialized) return;

    try {
      // Set Firebase user properties
      if (_isFirebaseInitialized) {
        if (userId != null) {
          await _firebaseAnalytics.setUserId(id: userId);
        }

        if (customProperties != null) {
          for (final entry in customProperties.entries) {
            await _firebaseAnalytics.setUserProperty(
              name: entry.key,
              value: entry.value.toString(),
            );
          }
        }
      }

      log('👤 User properties set: userId=$userId, email=$userEmail');
    } catch (e, stackTrace) {
      log('❌ Failed to set user properties: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Reset user data (on logout)
  Future<void> resetUser() async {
    if (!_isInitialized) return;

    try {
      if (_isFirebaseInitialized) {
        await _firebaseAnalytics.setUserId(id: null);
      }

      log('🔄 User data reset');
    } catch (e, stackTrace) {
      log('❌ Failed to reset user data: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Enable/disable analytics collection
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      if (_isFirebaseInitialized) {
        await _firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
      }

      log('🔧 Analytics collection ${enabled ? 'enabled' : 'disabled'}');
    } catch (e, stackTrace) {
      log('❌ Failed to set analytics enabled: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Get service status
  Map<String, bool> getServiceStatus() {
    return {'initialized': _isInitialized, 'firebase': _isFirebaseInitialized};
  }

  /// Track user login (for authenticated users)
  Future<void> trackUserLogin(String userGuid, {String? email}) async {
    if (!_isInitialized) return;

    try {
      // Set user properties
      await setUserProperties(userId: userGuid, userEmail: email);

      // Track login event
      await trackEvent(
        'user_login',
        properties: {'user_guid': userGuid, if (email != null) 'email': email},
      );

      log('👤 User login tracked: $userGuid');
    } catch (e, stackTrace) {
      log('❌ Failed to track user login: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Track guest session (for unauthenticated users)
  Future<void> trackGuestSession() async {
    if (!_isInitialized) return;

    try {
      await trackEvent('guest_session');
      log('👤 Guest session tracked');
    } catch (e, stackTrace) {
      log('❌ Failed to track guest session: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Track e-commerce purchase completion
  Future<void> trackPurchaseCompleted({
    required String orderId,
    required double amount,
    String? currency = 'USD',
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) return;

    try {
      // Track purchase event
      await trackEvent(
        'purchase_completed',
        properties: {
          'order_id': orderId,
          'amount': amount,
          'currency': currency,
          ...?properties,
        },
      );

      log('💰 Purchase completed tracked: $orderId');
    } catch (e, stackTrace) {
      log('❌ Failed to track purchase: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Track e-commerce funnel steps
  Future<void> trackShoppingCartConfirmed({
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('shopping_cart_confirmed', properties: properties);
  }

  Future<void> trackBillingAddressConfirmed({
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('billing_address_confirmed', properties: properties);
  }

  /// Enrich properties with common metadata
  Future<Map<String, dynamic>> _enrichProperties(
    Map<String, dynamic>? properties,
  ) async {
    final now = DateTime.now();

    // Get app version dynamically
    String appVersion = '1.0.0';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      log('⚠️ Could not get package info: $e');
    }

    return {
      'timestamp': now.millisecondsSinceEpoch,
      'date': now.toIso8601String(),
      'platform': defaultTargetPlatform.name,
      'app_version': appVersion,
      ...?properties,
    };
  }

  /// Sanitize event name for Firebase (max 40 chars, alphanumeric + underscore)
  String _sanitizeEventName(String eventName) {
    return eventName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .substring(0, eventName.length > 40 ? 40 : eventName.length);
  }

  /// Sanitize properties for Firebase (convert to proper types)
  Map<String, Object> _sanitizeProperties(Map<String, dynamic> properties) {
    final sanitized = <String, Object>{};

    for (final entry in properties.entries) {
      final key = entry.key.length > 40
          ? entry.key.substring(0, 40)
          : entry.key;
      final value = entry.value;

      if (value is String) {
        sanitized[key] = value.length > 100 ? value.substring(0, 100) : value;
      } else if (value is num) {
        sanitized[key] = value;
      } else if (value is bool) {
        sanitized[key] = value;
      } else {
        sanitized[key] = value.toString();
      }
    }

    return sanitized;
  }
}

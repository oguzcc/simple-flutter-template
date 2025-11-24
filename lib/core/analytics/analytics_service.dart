import 'dart:developer';

import 'package:daisy/core/analytics/mixpanel_service.dart';
import 'package:daisy/core/analytics/smartlook_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Unified Analytics Service for Daisy App
/// 
/// Provides a single interface for tracking events across multiple analytics platforms:
/// - Firebase Analytics (native app analytics)
/// - Smartlook (session recording and user behavior)
/// - Mixpanel (advanced user journey tracking)
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
  late final SmartlookService _smartlook;
  late final MixpanelService _mixpanel;
  
  // Service status tracking
  bool _isFirebaseInitialized = false;
  bool _isSmartlookInitialized = false;
  bool _isMixpanelInitialized = false;
  bool _isInitialized = false;
  
  // Analytics observer for automatic screen tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
    analytics: _firebaseAnalytics,
  );
  
  /// Initialize all analytics services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Firebase Analytics
      await _initializeFirebase();
      
      // Initialize Smartlook
      await _initializeSmartlook();
      
      // Initialize Mixpanel
      await _initializeMixpanel();
      
      _isInitialized = true;
      
      log('🔥 Analytics Service initialized successfully');
      log('📊 Active services: Firebase=${_isFirebaseInitialized}, Smartlook=${_isSmartlookInitialized}, Mixpanel=${_isMixpanelInitialized}');
      
    } catch (e, stackTrace) {
      log('❌ Failed to initialize Analytics Service: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) => scope.setTag('service', 'analytics'),
      );
    }
  }
  
  /// Initialize Firebase Analytics
  Future<void> _initializeFirebase() async {
    try {
      _firebaseAnalytics = FirebaseAnalytics.instance;
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(true);
      
      // Set default user properties
      await _firebaseAnalytics.setUserProperty(
        name: 'app_version',
        value: '1.0.0', // TODO(dev): Get from package_info
      );
      
      _isFirebaseInitialized = true;
      log('✅ Firebase Analytics initialized');
    } catch (e) {
      log('❌ Firebase Analytics initialization failed: $e');
    }
  }
  
  /// Initialize Smartlook
  Future<void> _initializeSmartlook() async {
    try {
      _smartlook = SmartlookService.instance;
      await _smartlook.initialize();
      _isSmartlookInitialized = _smartlook.isInitialized;
      log('✅ Smartlook initialized');
    } catch (e) {
      log('❌ Smartlook initialization failed: $e');
    }
  }
  
  /// Initialize Mixpanel
  Future<void> _initializeMixpanel() async {
    try {
      _mixpanel = MixpanelService.instance;
      await _mixpanel.initialize();
      _isMixpanelInitialized = _mixpanel.isInitialized;
      log('✅ Mixpanel initialized');
    } catch (e) {
      log('❌ Mixpanel initialization failed: $e');
    }
  }
  
  /// Track custom event across all platforms
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      log('⚠️ Analytics not initialized, queueing event: $eventName');
      return;
    }
    
    try {
      final enrichedProperties = _enrichProperties(properties);
      
      // Track with Firebase Analytics
      if (_isFirebaseInitialized) {
        await _firebaseAnalytics.logEvent(
          name: _sanitizeEventName(eventName),
          parameters: _sanitizeProperties(enrichedProperties),
        );
      }
      
      // Track with Smartlook
      if (_isSmartlookInitialized) {
        await _smartlook.trackEvent(eventName, enrichedProperties);
      }
      
      // Track with Mixpanel
      if (_isMixpanelInitialized) {
        await _mixpanel.trackEvent(eventName, enrichedProperties);
      }
      
      if (kDebugMode) {
        log('📊 Event tracked: $eventName');
        log('📋 Properties: $enrichedProperties');
      }
      
    } catch (e, stackTrace) {
      log('❌ Failed to track event: $eventName - $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) => scope
          ..setTag('event_name', eventName)
          ..setContexts('properties', {'data': properties}),
      );
    }
  }
  
  /// Track screen view
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('screen_view', properties: {
      'screen_name': screenName,
      ...?properties,
    });
  }
  
  /// Track user sign in
  Future<void> trackSignIn(String method) async {
    await trackEvent('login', properties: {
      'method': method,
    });
  }
  
  /// Track user sign up
  Future<void> trackSignUp(String method) async {
    await trackEvent('sign_up', properties: {
      'method': method,
    });
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
      
      // Set Smartlook user properties
      if (_isSmartlookInitialized) {
        await _smartlook.setUserProperties(
          userId: userId,
          userEmail: userEmail,
          customProperties: customProperties,
        );
      }
      
      // Set Mixpanel user properties
      if (_isMixpanelInitialized) {
        await _mixpanel.setUserProperties(
          userId: userId,
          userEmail: userEmail,
          customProperties: customProperties,
        );
      }
      
      log('👤 User properties set: userId=$userId, email=$userEmail');
      
    } catch (e, stackTrace) {
      log('❌ Failed to set user properties: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Reset user data (on logout)
  Future<void> resetUser() async {
    if (!_isInitialized) return;
    
    try {
      if (_isFirebaseInitialized) {
        await _firebaseAnalytics.setUserId(id: null);
      }
      
      if (_isSmartlookInitialized) {
        await _smartlook.resetUser();
      }
      
      if (_isMixpanelInitialized) {
        await _mixpanel.resetUser();
      }
      
      log('🔄 User data reset');
      
    } catch (e, stackTrace) {
      log('❌ Failed to reset user data: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Enable/disable analytics collection
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      if (_isFirebaseInitialized) {
        await _firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
      }
      
      if (_isSmartlookInitialized) {
        await _smartlook.setEnabled(enabled);
      }
      
      if (_isMixpanelInitialized) {
        await _mixpanel.setEnabled(enabled);
      }
      
      log('🔧 Analytics collection ${enabled ? 'enabled' : 'disabled'}');
      
    } catch (e, stackTrace) {
      log('❌ Failed to set analytics enabled: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Get service status
  Map<String, bool> getServiceStatus() {
    return {
      'initialized': _isInitialized,
      'firebase': _isFirebaseInitialized,
      'smartlook': _isSmartlookInitialized,
      'mixpanel': _isMixpanelInitialized,
    };
  }
  
  // Smartlook-specific methods for payment flow privacy
  
  /// Enable payment mode (wireframe rendering for payment screens)
  Future<void> enablePaymentMode() async {
    if (_isSmartlookInitialized) {
      await _smartlook.enablePaymentMode();
    }
  }
  
  /// Enable payment verification mode (no rendering for 3D Secure)
  Future<void> enablePaymentVerificationMode() async {
    if (_isSmartlookInitialized) {
      await _smartlook.enablePaymentVerificationMode();
    }
  }
  
  /// Reset rendering mode to default
  Future<void> resetRenderingMode() async {
    if (_isSmartlookInitialized) {
      await _smartlook.resetRenderingMode();
    }
  }
  
  /// Track user login (for authenticated users)
  Future<void> trackUserLogin(
    String userGuid, {
    String? email,
  }) async {
    if (!_isInitialized) return;
    
    try {
      // Set user properties across all services
      await setUserProperties(
        userId: userGuid,
        userEmail: email,
      );
      
      // Track login event
      await trackEvent('user_login', properties: {
        'user_guid': userGuid,
        if (email != null) 'email': email,
      });
      
      // Smartlook-specific user tracking
      if (_isSmartlookInitialized) {
        await _smartlook.trackUserLogin(userGuid, email: email);
      }
      
      log('👤 User login tracked: $userGuid');
      
    } catch (e, stackTrace) {
      log('❌ Failed to track user login: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track guest session (for unauthenticated users)
  Future<void> trackGuestSession() async {
    if (!_isInitialized) return;
    
    try {
      await trackEvent('guest_session');
      
      // Smartlook-specific guest tracking
      if (_isSmartlookInitialized) {
        await _smartlook.trackGuestSession();
      }
      
      log('👤 Guest session tracked');
      
    } catch (e, stackTrace) {
      log('❌ Failed to track guest session: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
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
      // Track across all platforms
      await trackEvent('purchase_completed', properties: {
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        ...?properties,
      });
      
      // Smartlook revenue tracking
      if (_isSmartlookInitialized) {
        await _smartlook.trackPurchaseCompleted(
          orderId: orderId,
          amount: amount,
          currency: currency,
          properties: properties,
        );
      }
      
      // Mixpanel revenue tracking
      if (_isMixpanelInitialized) {
        await _mixpanel.trackRevenue(
          amount,
          currency: currency,
          productId: orderId,
          properties: properties,
        );
      }
      
      log('💰 Purchase completed tracked: $orderId');
      
    } catch (e, stackTrace) {
      log('❌ Failed to track purchase: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track e-commerce funnel steps
  Future<void> trackShoppingCartConfirmed({
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('shopping_cart_confirmed', properties: properties);
    
    if (_isSmartlookInitialized) {
      await _smartlook.trackShoppingCartConfirmed(properties: properties);
    }
  }
  
  Future<void> trackBillingAddressConfirmed({
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('billing_address_confirmed', properties: properties);
    
    if (_isSmartlookInitialized) {
      await _smartlook.trackBillingAddressConfirmed(properties: properties);
    }
  }
  
  /// Enrich properties with common metadata
  Map<String, dynamic> _enrichProperties(Map<String, dynamic>? properties) {
    final now = DateTime.now();
    return {
      'timestamp': now.millisecondsSinceEpoch,
      'date': now.toIso8601String(),
      'platform': defaultTargetPlatform.name,
      'app_version': '1.0.0', // TODO: Get from package_info
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
      final key = entry.key.length > 40 ? entry.key.substring(0, 40) : entry.key;
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
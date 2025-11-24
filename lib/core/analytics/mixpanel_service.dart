import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Mixpanel Analytics Service for Daisy App
/// 
/// Provides advanced user journey tracking and cohort analysis.
/// Features:
/// - Event tracking with rich properties
/// - User profile management
/// - Funnel analysis
/// - A/B testing support
/// - Revenue tracking
class MixpanelService {
  MixpanelService._();
  
  static final MixpanelService _instance = MixpanelService._();
  static MixpanelService get instance => _instance;
  
  Mixpanel? _mixpanel;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  /// Initialize Mixpanel with project token from environment
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final projectToken = dotenv.env['MIXPANEL_PROJECT_TOKEN'];
      
      if (projectToken == null || projectToken.isEmpty) {
        log('⚠️ Mixpanel project token not found in environment');
        return;
      }
      
      _mixpanel = await Mixpanel.init(
        projectToken,
        trackAutomaticEvents: true,
      );
      
      // Set default super properties
      await _mixpanel!.registerSuperProperties({
        'app_version': '1.0.0', // TODO(dev): Get from package_info
        'platform': defaultTargetPlatform.name,
        'build_mode': kDebugMode ? 'debug' : 'release',
      });
      
      _isInitialized = true;
      log('✅ Mixpanel initialized successfully');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel initialization failed: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) => scope.setTag('service', 'mixpanel'),
      );
    }
  }
  
  /// Track custom event with properties
  Future<void> trackEvent(
    String eventName,
    Map<String, dynamic>? properties,
  ) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      await _mixpanel!.track(eventName, properties: properties);
      
      if (kDebugMode) {
        log('📈 Mixpanel event: $eventName');
      }
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel trackEvent failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Set user identification and properties
  Future<void> setUserProperties({
    String? userId,
    String? userEmail,
    Map<String, dynamic>? customProperties,
  }) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      // Identify user
      if (userId != null) {
        await _mixpanel!.identify(userId);
      }
      
      // Set user profile properties
      final properties = <String, dynamic>{};
      
      if (userEmail != null) {
        properties[r'$email'] = userEmail;
      }
      
      if (customProperties != null) {
        properties.addAll(customProperties);
      }
      
      if (properties.isNotEmpty) {
        for (final entry in properties.entries) {
          _mixpanel!.getPeople().set(entry.key, entry.value);
        }
      }
      
      log('👤 Mixpanel user properties set');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel setUserProperties failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Reset user data
  Future<void> resetUser() async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      await _mixpanel!.reset();
      log('🔄 Mixpanel user reset');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel resetUser failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Enable or disable tracking
  Future<void> setEnabled(bool enabled) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      if (enabled) {
        _mixpanel!.optInTracking();
      } else {
        _mixpanel!.optOutTracking();
      }
      
      log('📊 Mixpanel tracking ${enabled ? 'enabled' : 'disabled'}');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel setEnabled failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track revenue for purchase events
  Future<void> trackRevenue(
    double amount, {
    String? currency,
    String? productId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      _mixpanel!.getPeople().trackCharge(
        amount,
        properties: {
          if (currency != null) 'currency': currency,
          if (productId != null) 'product_id': productId,
          ...?properties,
        },
      );
      
      log('💰 Mixpanel revenue tracked: \$${amount.toStringAsFixed(2)}');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel trackRevenue failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Set user profile properties (one-time)
  Future<void> setUserProfileOnce(Map<String, dynamic> properties) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      for (final entry in properties.entries) {
        _mixpanel!.getPeople().setOnce(entry.key, entry.value);
      }
      log('👤 Mixpanel user profile set once');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel setUserProfileOnce failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Increment user profile property
  Future<void> incrementUserProperty(
    String property, [
    double value = 1.0,
  ]) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      _mixpanel!.getPeople().increment(property, value);
      log('📈 Mixpanel property incremented: $property += $value');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel incrementUserProperty failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Register super properties (sent with every event)
  Future<void> registerSuperProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      await _mixpanel!.registerSuperProperties(properties);
      log('⭐ Mixpanel super properties registered');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel registerSuperProperties failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Time an event (start timer)
  Future<void> timeEvent(String eventName) async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      _mixpanel!.timeEvent(eventName);
      log('⏱️ Mixpanel event timer started: $eventName');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel timeEvent failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Flush pending events
  Future<void> flush() async {
    if (!_isInitialized || _mixpanel == null) return;
    
    try {
      await _mixpanel!.flush();
      log('🔄 Mixpanel events flushed');
      
    } catch (e, stackTrace) {
      log('❌ Mixpanel flush failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
}
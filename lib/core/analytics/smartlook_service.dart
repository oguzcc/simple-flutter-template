import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_smartlook/flutter_Smartlook.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smartlook Analytics Service for Daisy App
/// 
/// Provides session recording and user behavior analytics.
/// Features:
/// - Session recording with privacy controls
/// - Custom event tracking with properties
/// - User identification and properties
/// - Privacy-compliant rendering modes
/// - Screen sensitivity configuration
class SmartlookService {
  SmartlookService._();
  
  static final SmartlookService _instance = SmartlookService._();
  static SmartlookService get instance => _instance;
  
  bool _isInitialized = false;
  
  // User management properties
  String? _currentUserId;
  static const String _userIdKey = 'smartlook_user_id';
  static const String _sessionCountKey = 'smartlook_session_count';
  static const String _lastSessionDateKey = 'smartlook_last_session_date';
  
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;
  
  /// Initialize Smartlook with API key from environment
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final apiKey = dotenv.env['SMARTLOOK_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        log('⚠️ Smartlook API key not found in environment');
        return;
      }
      
      // Configure Smartlook with setupAndStart
      final options = SetupOptionsBuilder(apiKey).build();
      await Smartlook.setupAndStartRecording(options);
      
      // Set rendering mode
      await Smartlook.setRenderingMode(
        kDebugMode 
          ? SmartlookRenderingMode.native 
          : SmartlookRenderingMode.wireframe,
      );
      
      // Send initial test event
      await trackEvent('app_startup', {
        'platform': defaultTargetPlatform.name,
        'debug_mode': kDebugMode,
      });
      
      // Set global event properties
      await Smartlook.setGlobalEventProperties({
        'app_version': 'TODO: Get from package_info',
        'platform': defaultTargetPlatform.name,
        'environment': kDebugMode ? 'debug' : 'release',
      }, false);
      
      // Initialize user management
      await _initializeUserManagement();
      
      _isInitialized = true;
      log('✅ Smartlook initialized successfully');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook initialization failed: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) => scope.setTag('service', 'smartlook'),
      );
    }
  }
  
  /// Track custom event with properties
  Future<void> trackEvent(
    String eventName,
    Map<String, dynamic>? properties,
  ) async {
    if (!_isInitialized) return;
    
    try {
            if (properties != null) {
        await Smartlook.trackCustomEvent(eventName, properties.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
      } else {
        await Smartlook.trackCustomEvent(eventName, <String, String>{});
      }
      
      if (kDebugMode) {
        log('📹 Smartlook event: $eventName');
      }
      
    } catch (e, stackTrace) {
      log('❌ Smartlook trackEvent failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Set user identification and properties
  Future<void> setUserProperties({
    String? userId,
    String? userEmail,
    Map<String, dynamic>? customProperties,
  }) async {
    if (!_isInitialized) return;
    
    try {
      // Set user identifier
      if (userId != null) {
        await Smartlook.setUserIdentifier(userId);
      }
      
      // Set user properties
      final properties = <String, String>{};
      if (userEmail != null) {
        properties['email'] = userEmail;
      }
      
      if (customProperties != null) {
        properties.addAll(
          customProperties.map((key, value) => MapEntry(key, value.toString())),
        );
      }
      
      // Set user properties through event tracking since direct API is unavailable
      if (properties.isNotEmpty) {
        await trackEvent('user_properties_updated', properties);
      }
      
      log('👤 Smartlook user properties set');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook setUserProperties failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track user login (for authenticated users)
  Future<void> trackUserLogin(
    String userGuid, {
    String? email,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await Smartlook.setUserIdentifier(userGuid);
      
      // User email tracked through events since direct user API is unavailable
      // Email will be included in the trackEvent call below
      
      await trackEvent('user_login', {
        'user_guid': userGuid,
        if (email != null) 'email': email,
      });
      
      log('👤 Smartlook user login tracked');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook trackUserLogin failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track guest session (for unauthenticated users)
  Future<void> trackGuestSession() async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.setUserIdentifier('guest_${DateTime.now().millisecondsSinceEpoch}');
      await trackEvent('guest_session', null);
      
      log('👤 Smartlook guest session tracked');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook trackGuestSession failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Reset user data
  Future<void> resetUser() async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.resetSession(false);
      log('🔄 Smartlook user reset');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook resetUser failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Enable or disable session recording
  Future<void> setEnabled(bool enabled) async {
    if (!_isInitialized) return;
    
    try {
      if (enabled) {
              await Smartlook.startRecording();
      } else {
              await Smartlook.stopRecording();
      }
      
      log('📹 Smartlook recording ${enabled ? 'started' : 'stopped'}');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook setEnabled failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Set rendering mode for privacy
  Future<void> setRenderingMode(SmartlookRenderingMode mode) async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.setRenderingMode(mode);
      log('🔧 Smartlook rendering mode set to: ${mode.toString()}');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook setRenderingMode failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Configure screen sensitivity for privacy
  Future<void> setSensitiveScreen(bool isSensitive) async {
    if (!_isInitialized) return;
    
    try {
      if (isSensitive) {
              await Smartlook.setRenderingMode(SmartlookRenderingMode.no_rendering);
      } else {
              await Smartlook.setRenderingMode(
          kDebugMode ? SmartlookRenderingMode.native : SmartlookRenderingMode.wireframe,
        );
      }
      
      log('🔒 Screen sensitivity set to: $isSensitive');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook setSensitiveScreen failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Start new session
  Future<void> startNewSession() async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.resetSession(false);
      log('🆕 Smartlook new session started');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook startNewSession failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Get session URL for debugging
  Future<String?> getSessionUrl() async {
    if (!_isInitialized) return null;
    
    try {
            final url = await Smartlook.getDashboardSessionUrl(false);
      return url;
      
    } catch (e, stackTrace) {
      log('❌ Smartlook getSessionUrl failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Enable payment mode (wireframe rendering for payment screens)
  Future<void> enablePaymentMode() async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.setRenderingMode(SmartlookRenderingMode.wireframe);
      log('💳 Smartlook payment mode enabled (wireframe)');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook enablePaymentMode failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Enable payment verification mode (no rendering for 3D Secure)
  Future<void> enablePaymentVerificationMode() async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.setRenderingMode(SmartlookRenderingMode.no_rendering);
      log('🔒 Smartlook payment verification mode enabled (no rendering)');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook enablePaymentVerificationMode failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Reset rendering mode to default (native)
  Future<void> resetRenderingMode() async {
    if (!_isInitialized) return;
    
    try {
            await Smartlook.setRenderingMode(
        kDebugMode 
          ? SmartlookRenderingMode.native 
          : SmartlookRenderingMode.wireframe,
      );
      log('🔄 Smartlook rendering mode reset to default');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook resetRenderingMode failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track purchase completion with revenue data
  Future<void> trackPurchaseCompleted({
    required String orderId,
    required double amount,
    String? currency = 'USD',
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) return;
    
    try {
      await trackEvent('PaymentConfirmed', {
        'order_id': orderId,
        'revenue': amount.toString(), // Key for Smartlook Revenue Insights
        'currency': currency ?? 'USD',
        ...?properties,
      });
      
      log('💰 Smartlook purchase tracked: $orderId - ${amount.toStringAsFixed(2)} $currency');
      
    } catch (e, stackTrace) {
      log('❌ Smartlook trackPurchaseCompleted failed: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
  
  /// Track e-commerce funnel events
  Future<void> trackShoppingCartConfirmed({
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('ShoppingCartConfirmed', properties);
  }
  
  Future<void> trackBillingAddressConfirmed({
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent('BillingAddressConfirmed', properties);
  }

  // User Management Methods

  /// Initialize user management system
  Future<void> _initializeUserManagement() async {
    try {
      await _loadStoredUserId();
      await _handleSessionStart();
      log('✅ Smartlook user management initialized');
    } catch (e) {
      log('❌ Failed to initialize user management: $e');
    }
  }

  /// Generate or retrieve existing anonymous user ID
  Future<void> _loadStoredUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString(_userIdKey);
      
      if (_currentUserId == null) {
        _currentUserId = _generateAnonymousUserId();
        await prefs.setString(_userIdKey, _currentUserId!);
        log('🆔 Generated new anonymous user ID: $_currentUserId');
      } else {
        log('🆔 Loaded existing user ID: $_currentUserId');
      }
    } catch (e) {
      log('❌ Failed to load stored user ID: $e');
      _currentUserId = _generateAnonymousUserId();
    }
  }

  /// Generate a unique anonymous user ID
  String _generateAnonymousUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(999999);
    return 'anonymous_${timestamp}_$random';
  }

  /// Handle session start logic
  Future<void> _handleSessionStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
      final newSessionCount = sessionCount + 1;
      
      await prefs.setInt(_sessionCountKey, newSessionCount);
      await prefs.setString(
        _lastSessionDateKey, 
        DateTime.now().toIso8601String(),
      );
      
      // Set user identifier in Smartlook
      if (_currentUserId != null) {
        await setUserProperties(
          userId: _currentUserId,
          customProperties: {
            'session_count': newSessionCount,
            'user_type': 'anonymous',
            'first_session': sessionCount == 0,
          },
        );
      }
      
      log('📊 Session started - Count: $newSessionCount');
    } catch (e) {
      log('❌ Failed to handle session start: $e');
    }
  }

  /// Set authenticated user
  Future<void> setAuthenticatedUser({
    required String userId,
    String? email,
    Map<String, dynamic>? userProperties,
  }) async {
    if (!_isInitialized) {
      log('⚠️ Smartlook not initialized');
      return;
    }
    
    try {
      _currentUserId = userId;
      
      // Store the authenticated user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      
      // Set user properties in Smartlook
      final properties = <String, dynamic>{
        'user_type': 'authenticated',
        'login_timestamp': DateTime.now().toIso8601String(),
        if (email != null) 'email': email,
        ...?userProperties,
      };
      
      await trackUserLogin(userId, email: email);
      await setUserProperties(
        userId: userId,
        userEmail: email,
        customProperties: properties,
      );
      
      // Track user login event
      await trackEvent('user_authenticated', {
        'user_id': userId,
        'previous_user_type': 'anonymous',
        if (email != null) 'email': email,
      });
      
      log('👤 Authenticated user set: $userId');
    } catch (e) {
      log('❌ Failed to set authenticated user: $e');
    }
  }

  /// Switch to guest user
  Future<void> setGuestUser() async {
    if (!_isInitialized) {
      log('⚠️ Smartlook not initialized');
      return;
    }
    
    try {
      // Generate new anonymous ID for guest
      _currentUserId = _generateAnonymousUserId();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, _currentUserId!);
      
      await trackGuestSession();
      await setUserProperties(
        userId: _currentUserId,
        customProperties: {
          'user_type': 'guest',
          'guest_session_start': DateTime.now().toIso8601String(),
        },
      );
      
      log('👤 Guest user set: $_currentUserId');
    } catch (e) {
      log('❌ Failed to set guest user: $e');
    }
  }

  /// Logout current user and reset to anonymous
  Future<void> logoutUser() async {
    if (!_isInitialized) {
      log('⚠️ Smartlook not initialized');
      return;
    }
    
    try {
      // Track logout event before resetting
      if (_currentUserId != null) {
        await trackEvent('user_logout', {
          'previous_user_id': _currentUserId,
        });
      }
      
      // Reset to new anonymous user
      _currentUserId = _generateAnonymousUserId();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, _currentUserId!);
      
      // Reset Smartlook user data
      await resetUser();
      
      // Set new anonymous user
      await setUserProperties(
        userId: _currentUserId,
        customProperties: {
          'user_type': 'anonymous',
          'session_reset': DateTime.now().toIso8601String(),
        },
      );
      
      log('🔄 User logged out, reset to anonymous: $_currentUserId');
    } catch (e) {
      log('❌ Failed to logout user: $e');
    }
  }

  /// Update user properties
  Future<void> updateUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized || _currentUserId == null) {
      log('⚠️ Smartlook not initialized or no current user');
      return;
    }
    
    try {
      await setUserProperties(
        userId: _currentUserId,
        customProperties: {
          ...properties,
          'last_property_update': DateTime.now().toIso8601String(),
        },
      );
      
      log('👤 User properties updated for: $_currentUserId');
    } catch (e) {
      log('❌ Failed to update user properties: $e');
    }
  }

  /// Track user journey milestone
  Future<void> trackUserJourney({
    required String milestone,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized || _currentUserId == null) {
      log('⚠️ Smartlook not initialized or no current user');
      return;
    }
    
    try {
      await trackEvent('user_journey_milestone', {
        'milestone': milestone,
        'user_id': _currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?properties,
      });
      
      log('🗺️ User journey milestone tracked: $milestone');
    } catch (e) {
      log('❌ Failed to track user journey: $e');
    }
  }

  /// Track user engagement metrics
  Future<void> trackUserEngagement({
    required String engagementType,
    required double duration,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized || _currentUserId == null) {
      log('⚠️ Smartlook not initialized or no current user');
      return;
    }
    
    try {
      await trackEvent('user_engagement', {
        'engagement_type': engagementType,
        'duration_seconds': duration,
        'user_id': _currentUserId,
        ...?properties,
      });
      
      log('📊 User engagement tracked: $engagementType (${duration}s)');
    } catch (e) {
      log('❌ Failed to track user engagement: $e');
    }
  }

  /// Get session statistics
  Future<Map<String, dynamic>> getSessionStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
      final lastSessionDate = prefs.getString(_lastSessionDateKey);
      
      return {
        'current_user_id': _currentUserId,
        'session_count': sessionCount,
        'last_session_date': lastSessionDate,
        'is_initialized': _isInitialized,
      };
    } catch (e) {
      log('❌ Failed to get session stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}

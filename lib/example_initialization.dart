// Example initialization code for verifying the integrated features
// This file demonstrates how to properly initialize all services

import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:daisy/core/analytics/mixins/search_analytics_mixin.dart';
import 'package:daisy/core/analytics/mixins/validation_analytics_mixin.dart';
import 'package:daisy/core/analytics/smartlook_service.dart';
import 'package:daisy/core/manager/remote/sentry_client.dart';
import 'package:daisy/data/notification/notification_queue_manager.dart';
import 'package:daisy/data/notification/one_signal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppInitializer {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Load environment variables
    await dotenv.load(fileName: '.env');
    
    // 2. Initialize Sentry for error tracking
    await SentryClient.init(
      dsn: dotenv.env['SENTRY_DSN'] ?? '',
      appRunner: () async {
        // App runner will be called after Sentry is initialized
      },
    );
    
    // 3. Initialize Analytics Service (includes Smartlook, Mixpanel, Firebase)
    await AnalyticsService.instance.initialize();
    
    // 4. Initialize OneSignal for push notifications
    final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
    if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
      await OneSignalService.instance.initialize(appId: oneSignalAppId);
    }
    
    // 5. Mark app as ready for notification processing
    NotificationQueueManager.instance.markAppAsReady();
    
    print('✅ All services initialized successfully!');
  }
  
  // Example usage of analytics mixins
  static void demonstrateAnalyticsMixins() {
    // Example of using search analytics
    final searchExample = _SearchExample();
    searchExample.performSearch('flutter widgets');
    
    // Example of using validation analytics
    final validationExample = _ValidationExample();
    validationExample.validateForm();
  }
  
  // Example of user management with Smartlook
  static Future<void> demonstrateUserManagement() async {
    final smartlook = SmartlookService.instance;
    
    // Set authenticated user
    await smartlook.setAuthenticatedUser(
      userId: 'user123',
      email: 'user@example.com',
      userProperties: {
        'plan': 'premium',
        'signupDate': DateTime.now().toIso8601String(),
      },
    );
    
    // Track user journey milestone
    await smartlook.trackUserJourney(
      milestone: 'completed_onboarding',
      properties: {
        'duration': 120,
        'skipped_steps': 0,
      },
    );
    
    // Track user engagement
    await smartlook.trackUserEngagement(
      engagementType: 'feature_usage',
      duration: 45.5,
      properties: {
        'feature': 'advanced_search',
      },
    );
    
    // Get session stats
    final stats = await smartlook.getSessionStats();
    print('Session stats: $stats');
  }
  
  // Example of notification handling
  static void demonstrateNotificationHandling() {
    final notificationManager = NotificationQueueManager.instance;
    final oneSignal = OneSignalService.instance;
    
    // Check if app is ready
    if (notificationManager.isAppReady) {
      print('App is ready to process notifications');
      print('Pending notifications: ${notificationManager.pendingActionsCount}');
    }
    
    // Set user for personalized notifications
    oneSignal.setUserId('user123');
    
    // Set tags for segmentation
    oneSignal.setTags({
      'subscription': 'premium',
      'interests': 'technology',
    });
  }
  
  // Example of error handling with Sentry correlation
  static Future<void> demonstrateErrorHandling() async {
    // Add breadcrumb for tracking
    SentryClient.addBreadcrumb(
      message: 'User clicked on purchase button',
      category: 'ui.click',
      data: {'button': 'purchase', 'product_id': 'prod123'},
    );
    
    // Execute with error handling
    await SentryClient.func(() {
      // This code is wrapped with error tracking
      print('Executing sensitive operation...');
      // If an error occurs here, it will be captured with correlation ID
    });
    
    // Set user context for error reports
    SentryClient.setUserContext(
      userId: 'user123',
      email: 'user@example.com',
      extras: {'subscription': 'premium'},
    );
  }
}

// Example class using SearchAnalyticsMixin
class _SearchExample with SearchAnalyticsMixin {
  void performSearch(String query) {
    trackSearchQuery(
      searchQuery: query,
      category: 'products',
      filters: {'price': 'low_to_high'},
    );
    
    // Simulate search results
    trackSearchResults(
      searchQuery: query,
      resultCount: 42,
      searchTime: 250.5,
      category: 'products',
    );
  }
}

// Example class using ValidationAnalyticsMixin
class _ValidationExample with ValidationAnalyticsMixin {
  void validateForm() {
    trackFormFieldFocus(
      formName: 'registration',
      fieldName: 'email',
    );
    
    trackFormValidationError(
      formName: 'registration',
      fieldName: 'email',
      errorType: 'invalid_format',
      errorMessage: 'Please enter a valid email',
    );
  }
}

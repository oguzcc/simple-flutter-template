// Analytics kullanım örnekleri

import 'package:flutter/material.dart';
import 'developer_command_center.dart';
import 'analytics_tap_wrapper.dart';
import 'interfaces/developer_command_center_dependencies.dart';

/// Analytics kullanım örnekleri
class AnalyticsUsageExamples {
  /// 1. Widget tap tracking örneği
  static Widget buildTappableWidget(AnalyticsClientInterface analyticsClient) {
    return AnalyticsTapWrapper(
      analyticsClient: analyticsClient,
      widgetId: 'home_card_1',
      widgetType: 'card',
      extraData: const {
        'card_title': 'Featured Article',
        'position': 'top',
      },
      onTap: () {
        // Normal işlemler
        debugPrint('Card tapped!');
      },
      child: const Card(
        child: ListTile(
          title: Text('Featured Article'),
          subtitle: Text('Tap to read more'),
        ),
      ),
    );
  }

  /// 2. Button tracking örneği
  static Widget buildTrackedButton(AnalyticsClientInterface analyticsClient) {
    return AnalyticsButtonWrapper(
      analyticsClient: analyticsClient,
      buttonId: 'create_invoice_btn',
      buttonText: 'Create Invoice',
      buttonType: 'primary',
      extraData: const {
        'screen': 'invoice_list',
        'user_type': 'premium',
      },
      onPressed: () {
        // Normal button işlemleri
        debugPrint('Creating invoice...');
      },
      child: const ElevatedButton(
        onPressed: null, // null çünkü wrapper handle ediyor
        child: Text('Create Invoice'),
      ),
    );
  }

  /// 3. Custom event logging örneği
  static void logCustomEventExample(AnalyticsClientInterface analyticsClient) {
    analyticsClient.logCustomEvent(
      eventName: 'feature_used',
      parameters: {
        'feature_name': 'search_filters',
        'filter_count': 3,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 4. Screen view tracking örneği
  static void showAnalyticsDashboardExample(BuildContext context, DeveloperCommandCenterDependencies dependencies) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeveloperCommandCenter(dependencies: dependencies),
      ),
    );
  }

  /// 5. Timing event örneği
  static void logTimingExample(AnalyticsClientInterface analyticsClient) {
    final stopwatch = Stopwatch()..start();
    // Bir işlem yap...
    stopwatch.stop();
    
    analyticsClient.logTimingEvent(
      name: 'data_loading',
      duration: stopwatch.elapsed,
      category: 'performance',
      variable: 'user_list',
    );
  }

  /// 6. User interaction tracking
  static void logUserInteractionExample(AnalyticsClientInterface analyticsClient) {
    analyticsClient.logCustomEvent(
      eventName: 'user_interaction',
      parameters: {
        'interaction_type': 'swipe',
        'screen': 'news_list',
        'direction': 'left_to_right',
        'item_position': 2,
      },
    );
  }

  /// 7. Navigation tracking
  static void trackNavigationExample(AnalyticsClientInterface analyticsClient) {
    analyticsClient.logScreenView(
      screenName: 'settings',
      screenClass: 'SettingsScreen',
      extraData: {
        'previous_screen': 'profile',
        'navigation_method': 'back_button',
      },
    );
  }

  /// 8. Funnel step tracking örneği
  static Widget buildFunnelStepWrapper(AnalyticsClientInterface analyticsClient) {
    return FunnelStepWrapper(
      analyticsClient: analyticsClient,
      funnelName: 'user_onboarding',
      stepName: 'profile_completion',
      extraData: const {
        'step_number': 3,
        'total_steps': 5,
      },
      child: const Text('Profile completion step'),
    );
  }
}
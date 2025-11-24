# Daisy Analytics System

A unified analytics system for tracking user behavior, app performance, and business metrics across multiple platforms.

## 📊 Analytics Services

### Integrated Services
- **Firebase Analytics**: Native app analytics and user behavior tracking
- **Smartlook**: Session recording and visual user behavior analysis  
- **Mixpanel**: Advanced user journey tracking and cohort analysis

## 🚀 Quick Start

### 1. Environment Configuration

Add your analytics API keys to environment files:

```env
# .env.development
SMARTLOOK_API_KEY=your-dev-smartlook-api-key
MIXPANEL_PROJECT_TOKEN=your-dev-mixpanel-token

# .env.staging  
SMARTLOOK_API_KEY=your-staging-smartlook-api-key
MIXPANEL_PROJECT_TOKEN=your-staging-mixpanel-token

# .env.production
SMARTLOOK_API_KEY=your-prod-smartlook-api-key
MIXPANEL_PROJECT_TOKEN=your-prod-mixpanel-token
```

### 2. Initialization

Analytics are automatically initialized in `bootstrap.dart`:

```dart
await AnalyticsService.instance.initialize();
```

### 3. Basic Usage

```dart
import 'package:daisy/core/analytics/analytics_service.dart';

// Track custom event
await AnalyticsService.instance.trackEvent('button_clicked', properties: {
  'button_name': 'Sign In',
  'screen': 'Login',
});

// Track screen view
await AnalyticsService.instance.trackScreenView('Home');

// Set user properties
await AnalyticsService.instance.setUserProperties(
  userId: 'user123',
  userEmail: 'user@example.com',
  customProperties: {
    'subscription_tier': 'premium',
    'onboarding_completed': true,
  },
);
```

## 🎯 Using Analytics Mixin

### For StatefulWidgets

```dart
import 'package:daisy/core/analytics/analytics_mixin.dart';

class MyScreenState extends State<MyScreen> with AnalyticsMixin {
  @override
  void initState() {
    super.initState();
    trackScreenView('MyScreen');
  }
  
  void _onButtonTapped() {
    trackButtonTap('submit_button', screenName: 'MyScreen');
  }
}
```

### For Automatic Screen Tracking

```dart
import 'package:daisy/core/analytics/analytics_mixin.dart';

class MyScreenState extends State<MyScreen> with ScreenAnalyticsMixin {
  @override
  String get screenName => 'My Screen';
  
  // Screen view is automatically tracked
  
  void _onFeatureUsed() {
    trackScreenEvent('feature_used', properties: {
      'feature_name': 'advanced_filter',
    });
  }
}
```

## 📈 Common Event Patterns

### Authentication Events

```dart
// Sign in
await trackSignIn('google', success: true);
await trackSignIn('apple', success: false, errorCode: 'user_cancelled');

// Sign up  
await trackSignUp('email', success: true);

// Sign out
await trackSignOut(reason: 'user_initiated');
```

### Navigation Events

```dart
await trackNavigation(
  'Home', 
  'Profile', 
  trigger: 'nav_button'
);
```

### User Interaction Events

```dart
// Button taps
await trackButtonTap('checkout_button', screenName: 'Cart');

// Form submissions
await trackFormSubmission(
  'contact_form',
  success: true,
);

// Search
await trackSearch(
  'flutter tutorials',
  resultCount: 25,
  category: 'education',
);

// Share actions
await trackShare('article', 'article_123', method: 'twitter');
```

### App Lifecycle Events

```dart
await trackAppLifecycle(AppLifecycleState.resumed);
```

### Performance Tracking

```dart
await trackPerformance('api_response_time', 1.2, unit: 'seconds');
await trackPerformance('app_startup_time', 850, unit: 'milliseconds');
```

### Engagement Metrics

```dart
await trackEngagement(
  'session_duration',
  duration: 180.5, // seconds
);

await trackEngagement(
  'feature_usage',
  count: 5,
);
```

### Error Tracking

```dart
await trackError(
  'api_error',
  'Failed to fetch user data',
  screenName: 'Profile',
  properties: {
    'error_code': 'E_NETWORK_TIMEOUT',
    'endpoint': '/api/user/profile',
  },
);
```

## 🔧 Advanced Configuration

### Service-Specific Configuration

#### Smartlook Privacy Settings

```dart
// Set rendering mode for sensitive screens
await SmartlookService.instance.setRenderingMode(RenderingMode.noRendering);

// Configure screen sensitivity
await SmartlookService.instance.setSensitiveScreen(true);
```

#### Mixpanel Revenue Tracking

```dart
// Track purchases
await MixpanelService.instance.trackRevenue(
  29.99,
  currency: 'USD',
  productId: 'premium_monthly',
);

// Set user profile properties
await MixpanelService.instance.setUserProfileOnce({
  'first_purchase_date': DateTime.now().toIso8601String(),
  'acquisition_channel': 'organic_search',
});
```

### Custom Event Properties

All events are automatically enriched with:

```json
{
  "timestamp": 1640995200000,
  "date": "2021-12-31T12:00:00.000Z",
  "platform": "iOS",
  "app_version": "1.0.0"
}
```

## 🎛️ Service Status

Check which analytics services are active:

```dart
final status = AnalyticsService.instance.getServiceStatus();
print('Firebase: ${status['firebase']}');
print('Smartlook: ${status['smartlook']}'); 
print('Mixpanel: ${status['mixpanel']}');
```

## 🔒 Privacy & Compliance

### Data Collection Controls

```dart
// Disable all analytics
await AnalyticsService.instance.setAnalyticsEnabled(false);

// Reset user data (GDPR compliance)
await AnalyticsService.instance.resetUser();
```

### Sensitive Screen Handling

For screens containing sensitive data (payment, personal info):

```dart
class PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    SmartlookService.instance.setSensitiveScreen(true);
  }
  
  @override
  void dispose() {
    SmartlookService.instance.setSensitiveScreen(false);
    super.dispose();
  }
}
```

## 🐛 Debugging

### Debug Mode Features

In debug mode, analytics events are logged to console:

```
📊 Event tracked: button_clicked
📋 Properties: {button_name: Sign In, screen: Login, timestamp: 1640995200000}
```

### Service Initialization Status

```
🔥 Analytics Service initialized successfully
📊 Active services: Firebase=true, Smartlook=true, Mixpanel=false
```

## 📝 Best Practices

### Event Naming
- Use snake_case: `button_clicked`, `screen_viewed`
- Be specific: `checkout_completed` not `action`
- Include context: `home_search_performed`

### Property Names
- Use consistent naming: `user_id`, `screen_name`, `feature_name`
- Include units: `duration_seconds`, `file_size_bytes`
- Avoid PII: Don't track emails, names, or sensitive data

### Performance
- Events are queued if analytics aren't initialized
- Avoid tracking in tight loops
- Use batch operations for bulk events

### Error Handling
- Analytics failures don't crash the app
- Errors are automatically reported to Sentry
- Events are queued during network outages

## 🔍 Analytics Dashboard Access

### Firebase Analytics
- Access: Firebase Console → Analytics
- Real-time data, user behavior flows, conversion funnels

### Smartlook
- Access: Smartlook Dashboard  
- Session recordings, heatmaps, user journey analysis

### Mixpanel  
- Access: Mixpanel Dashboard
- User segmentation, cohort analysis, A/B testing results

## 🎯 Common Use Cases

### User Onboarding Tracking
```dart
await trackOnboardingStep(1, 'welcome_screen', action: 'viewed');
await trackOnboardingStep(2, 'permissions', action: 'completed');
await trackOnboardingStep(3, 'profile_setup', action: 'skipped');
```

### Feature Adoption Tracking
```dart
await trackFeatureUsage('dark_mode', action: 'enabled');
await trackFeatureUsage('premium_feature', action: 'accessed');
```

### Conversion Funnel Tracking
```dart
// User journey through purchase funnel
await trackEvent('funnel_product_viewed', properties: {'product_id': '123'});
await trackEvent('funnel_add_to_cart', properties: {'product_id': '123'});
await trackEvent('funnel_checkout_started', properties: {'cart_value': 29.99});
await trackEvent('funnel_payment_completed', properties: {'order_id': 'ord_456'});
```

This analytics system provides comprehensive tracking while maintaining user privacy and app performance. All events are automatically enriched with context and can be easily filtered and analyzed across all three platforms.
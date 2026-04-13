/// RevenueCat purchase configuration with dummy credentials
///
/// ⚠️ WARNING: This file contains DUMMY credentials for development only!
/// Replace with actual RevenueCat credentials before production deployment.
///
/// For production setup:
/// 1. Create RevenueCat account at https://www.revenuecat.com
/// 2. Set up your app in RevenueCat dashboard
/// 3. Configure products, entitlements and paywall in RevenueCat dashboard
/// 4. Replace dummy values in this file
/// 5. Test purchases on physical devices
class PurchaseConfig {
  /// Dummy RevenueCat API Key
  ///
  /// ⚠️ PRODUCTION TODO: Replace with actual RevenueCat public API key
  /// Get this from: RevenueCat Dashboard > App Settings > API Keys
  static const String dummyRevenueCatApiKey =
      'pk_test_dummy_revenuecat_key_123456789';

  /// Entitlement IDs used by the app to check user access.
  ///
  /// ⚠️ PRODUCTION TODO: Replace values with actual entitlement identifiers
  /// configured in RevenueCat Dashboard > Entitlements.
  ///
  /// These IDs are read by [PurchaseService] to expose `hasPremium`,
  /// `hasPro` and `isAdFree` getters.
  static const Map<String, String> dummyEntitlements = {
    'premium': 'dummy_premium_entitlement',
    'pro': 'dummy_pro_entitlement',
    'ad_free': 'dummy_ad_free_entitlement',
  };

  /// Production readiness checklist
  static const List<String> productionChecklist = [
    '✅ Create RevenueCat account and project',
    '✅ Replace dummyRevenueCatApiKey with actual public API key',
    '✅ Create products in App Store Connect (iOS) / Google Play Console (Android)',
    '✅ Configure products, entitlements and paywall in RevenueCat Dashboard',
    '✅ Replace dummyEntitlements with actual entitlement IDs',
    '✅ Test purchases on physical devices',
    '✅ Configure webhooks for server-to-server notifications (optional)',
  ];

  /// Check if using dummy credentials (development mode)
  static bool get isDummyMode => dummyRevenueCatApiKey.contains('dummy');

  /// Get warning message for dummy mode
  static String get dummyModeWarning {
    if (isDummyMode) {
      return '''
⚠️ DEVELOPMENT MODE - DUMMY PURCHASE CREDENTIALS DETECTED

This app is using dummy RevenueCat credentials.
In-app purchases will not work properly until production credentials are configured.

Please complete the production checklist in PurchaseConfig class.
''';
    }
    return '';
  }
}

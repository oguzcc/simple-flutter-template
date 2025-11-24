/// RevenueCat purchase configuration with dummy credentials
/// 
/// ⚠️ WARNING: This file contains DUMMY credentials for development only!
/// Replace with actual RevenueCat credentials before production deployment.
/// 
/// For production setup:
/// 1. Create RevenueCat account at https://www.revenuecat.com
/// 2. Set up your app in RevenueCat dashboard
/// 3. Configure products in App Store Connect / Google Play Console
/// 4. Replace dummy values in this file
/// 5. Test purchases on physical devices
class PurchaseConfig {
  /// Dummy RevenueCat API Key
  /// 
  /// ⚠️ PRODUCTION TODO: Replace with actual RevenueCat public API key
  /// Get this from: RevenueCat Dashboard > App Settings > API Keys
  static const String dummyRevenueCatApiKey = 'pk_test_dummy_revenuecat_key_123456789';

  /// Dummy Product IDs
  /// 
  /// ⚠️ PRODUCTION TODO: Replace with actual product IDs from stores
  /// These should match your App Store Connect / Google Play Console products
  static const Map<String, String> dummyProductIds = {
    'premium_monthly': 'dummy_premium_monthly',
    'premium_yearly': 'dummy_premium_yearly', 
    'pro_lifetime': 'dummy_pro_lifetime',
    'remove_ads': 'dummy_remove_ads',
  };

  /// Dummy Entitlement IDs
  /// 
  /// ⚠️ PRODUCTION TODO: Replace with actual entitlement IDs from RevenueCat
  /// Configure these in RevenueCat Dashboard > Entitlements
  static const Map<String, String> dummyEntitlements = {
    'premium': 'dummy_premium_entitlement',
    'pro': 'dummy_pro_entitlement',
    'ad_free': 'dummy_ad_free_entitlement',
  };

  /// Dummy Offering IDs
  /// 
  /// ⚠️ PRODUCTION TODO: Replace with actual offering IDs from RevenueCat
  /// Configure these in RevenueCat Dashboard > Offerings
  static const String dummyDefaultOfferingId = 'dummy_default_offering';

  /// Production readiness checklist
  static const List<String> productionChecklist = [
    '✅ Create RevenueCat account and project',
    '✅ Replace dummyRevenueCatApiKey with actual public API key',
    '✅ Create products in App Store Connect (iOS) / Google Play Console (Android)',
    '✅ Configure products in RevenueCat Dashboard',
    '✅ Replace dummyProductIds with actual product IDs',
    '✅ Set up entitlements in RevenueCat Dashboard', 
    '✅ Replace dummyEntitlements with actual entitlement IDs',
    '✅ Configure offerings in RevenueCat Dashboard',
    '✅ Replace dummyDefaultOfferingId with actual offering ID',
    '✅ Test purchases on physical devices',
    '✅ Configure webhooks for server-to-server notifications (optional)',
    '✅ Set up analytics and attribution (optional)',
  ];

  /// Check if using dummy credentials (development mode)
  static bool get isDummyMode {
    return dummyRevenueCatApiKey.contains('dummy') || 
           dummyProductIds.values.any((id) => id.contains('dummy'));
  }

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

  /// Purchase-related error messages
  static const Map<String, String> errorMessages = {
    'user-cancelled': 'Purchase was cancelled by user',
    'payment-pending': 'Payment is pending. Please wait.',
    'invalid-credentials': 'Invalid purchase credentials. Please contact support.',
    'network-error': 'Network connection failed. Please check your internet.',
    'store-problem': 'App Store/Play Store is not available. Please try again later.',
    'not-allowed-to-make-payments': 'This device is not allowed to make payments.',
    'invalid-purchase': 'Invalid purchase. Please try again.',
    'missing-receipt-file': 'Purchase receipt not found. Please restore purchases.',
    'product-not-available': 'This product is not available for purchase.',
    'purchase-not-allowed': 'Purchase not allowed on this device.',
    'receipt-already-in-use': 'This receipt has already been used.',
    'invalid-receipt': 'Invalid receipt. Please contact support.',
    'missing-receipt': 'Receipt not found. Please restore purchases.',
    'invalid-app-user-id': 'Invalid user ID. Please sign in again.',
    'offline-connection': 'No internet connection. Please connect and try again.',
    'unknown': 'An unexpected error occurred. Please try again.',
  };

  /// Get user-friendly error message
  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? errorMessages['unknown']!;
  }

  /// Premium features list (for UI display)
  static const List<String> premiumFeatures = [
    '🚀 Unlimited usage',
    '📊 Advanced analytics', 
    '🎨 Premium themes',
    '☁️ Cloud backup',
    '📱 Priority support',
    '🔒 Enhanced security',
    '📈 Export features',
    '🎯 Advanced customization',
  ];

  /// Pro features list (for UI display)
  static const List<String> proFeatures = [
    '✨ All Premium features',
    '🤖 AI-powered tools',
    '📊 Business analytics',
    '👥 Team collaboration',
    '🔌 API access',
    '📋 Advanced reporting',
    '🎛️ Admin controls',
    '🔄 Bulk operations',
  ];

  /// Get features for entitlement
  static List<String> getFeaturesForEntitlement(String entitlementId) {
    switch (entitlementId) {
      case 'premium':
        return premiumFeatures;
      case 'pro':
        return [...premiumFeatures, ...proFeatures];
      case 'ad_free':
        return ['🚫 No advertisements'];
      default:
        return [];
    }
  }
}

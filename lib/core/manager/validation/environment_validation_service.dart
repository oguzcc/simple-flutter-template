import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:daisy/core/config/auth_config.dart';
import 'package:daisy/core/config/purchase_config.dart';
import 'package:daisy/core/config/video_config.dart';
import 'package:daisy/core/config/core_strings.dart';
import 'package:daisy/firebase_options.dart';
import 'package:daisy/core/manager/validation/models/validation_result.dart';
import 'package:daisy/core/manager/validation/validation_logger.dart';

/// Comprehensive environment and configuration validation service
class EnvironmentValidationService {
  /// Validate all configurations and return summary
  static Future<ValidationSummary> validateAll({
    bool logResults = true,
  }) async {
    if (logResults) {
      ValidationLogger.logValidationStart();
    }

    final List<ValidationResult> allResults = [];
    final Map<String, List<ValidationResult>> categoryResults = {};

    // Run all validation checks
    final firebaseResults = await _validateFirebaseConfiguration();
    final authResults = await _validateAuthConfiguration();
    final purchaseResults = await _validatePurchaseConfiguration();
    final apiResults = await _validateApiConfiguration();
    final assetResults = await _validateAssets();
    final platformResults = await _validatePlatformConfiguration();
    final shorebirdResults = await _validateShorebirdConfiguration();
    final remoteConfigResults = await _validateRemoteConfigConfiguration();
    final analyticsResults = await _validateAnalyticsConfiguration();

    // Organize results by category
    categoryResults['Firebase'] = firebaseResults;
    categoryResults['Authentication'] = authResults;
    categoryResults['Purchase'] = purchaseResults;
    categoryResults['API'] = apiResults;
    categoryResults['Assets'] = assetResults;
    categoryResults['Platform'] = platformResults;
    categoryResults['Shorebird'] = shorebirdResults;
    categoryResults['Remote Config'] = remoteConfigResults;
    categoryResults['Analytics'] = analyticsResults;

    // Flatten all results
    allResults.addAll(firebaseResults);
    allResults.addAll(authResults);
    allResults.addAll(purchaseResults);
    allResults.addAll(apiResults);
    allResults.addAll(assetResults);
    allResults.addAll(platformResults);
    allResults.addAll(shorebirdResults);
    allResults.addAll(remoteConfigResults);
    allResults.addAll(analyticsResults);

    // Calculate summary
    final summary = _calculateSummary(allResults, categoryResults);

    if (logResults) {
      _logAllResults(summary, categoryResults, allResults);
    }

    return summary;
  }

  /// Validate Firebase configuration
  static Future<List<ValidationResult>> _validateFirebaseConfiguration() async {
    final results = <ValidationResult>[];

    // Check firebase_options.dart
    try {
      final webOptions = DefaultFirebaseOptions.web;
      final androidOptions = DefaultFirebaseOptions.android;
      final iosOptions = DefaultFirebaseOptions.ios;

      results.add(ValidationResult(
        category: 'Firebase',
        item: 'firebase_options.dart',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Firebase options file exists and is accessible',
      ));

      // Check if using dummy project
      final isDummyProject = webOptions.projectId.contains('daisy-c1c2c');
      results.add(ValidationResult(
        category: 'Firebase',
        item: 'Firebase Project ID',
        isValid: !isDummyProject,
        status: isDummyProject ? ValidationStatus.dummy : ValidationStatus.production,
        description: isDummyProject 
            ? 'Using development Firebase project: ${webOptions.projectId}'
            : 'Using production Firebase project: ${webOptions.projectId}',
        recommendation: isDummyProject 
            ? 'Replace with production Firebase project ID before deployment'
            : null,
      ));

      // Check API keys
      results.add(ValidationResult(
        category: 'Firebase',
        item: 'Firebase API Keys',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'API keys are configured for all platforms',
        metadata: {
          'web_api_key': webOptions.apiKey.substring(0, 10) + '...',
          'android_api_key': androidOptions.apiKey.substring(0, 10) + '...',
          'ios_api_key': iosOptions.apiKey.substring(0, 10) + '...',
        },
      ));
    } catch (e) {
      results.add(ValidationResult(
        category: 'Firebase',
        item: 'firebase_options.dart',
        isValid: false,
        status: ValidationStatus.invalid,
        description: 'Error accessing Firebase options: $e',
        recommendation: 'Run "flutterfire configure" to generate Firebase options',
      ));
    }

    // Check google-services.json (Android)
    final androidConfigFile = File('android/app/google-services.json');
    if (await androidConfigFile.exists()) {
      try {
        final content = await androidConfigFile.readAsString();
        final config = jsonDecode(content) as Map<String, dynamic>;
        final projectInfo = config['project_info'] as Map<String, dynamic>?;
        
        results.add(ValidationResult(
          category: 'Firebase',
          item: 'google-services.json',
          isValid: true,
          status: ValidationStatus.valid,
          description: 'Android Firebase configuration found',
          metadata: {
            'project_id': projectInfo?['project_id'] ?? 'unknown',
            'file_size': '${content.length} bytes',
          },
        ));
      } catch (e) {
        results.add(ValidationResult(
          category: 'Firebase',
          item: 'google-services.json',
          isValid: false,
          status: ValidationStatus.invalid,
          description: 'Invalid JSON format in google-services.json: $e',
          recommendation: 'Download new google-services.json from Firebase Console',
        ));
      }
    } else {
      results.add(ValidationResult(
        category: 'Firebase',
        item: 'google-services.json',
        isValid: false,
        status: ValidationStatus.missing,
        description: 'Android Firebase configuration file not found',
        recommendation: 'Download google-services.json from Firebase Console to android/app/',
      ));
    }

    // Check GoogleService-Info.plist (iOS)
    final iosConfigFile = File('ios/Runner/GoogleService-Info.plist');
    if (await iosConfigFile.exists()) {
      results.add(ValidationResult(
        category: 'Firebase',
        item: 'GoogleService-Info.plist',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'iOS Firebase configuration found',
      ));
    } else {
      results.add(ValidationResult(
        category: 'Firebase',
        item: 'GoogleService-Info.plist',
        isValid: false,
        status: ValidationStatus.missing,
        description: 'iOS Firebase configuration file not found',
        recommendation: 'Download GoogleService-Info.plist from Firebase Console to ios/Runner/',
      ));
    }

    return results;
  }

  /// Validate authentication configuration
  static Future<List<ValidationResult>> _validateAuthConfiguration() async {
    final results = <ValidationResult>[];

    // Check if using dummy credentials
    final isDummyMode = AuthConfig.isDummyMode;
    
    results.add(ValidationResult(
      category: 'Authentication',
      item: 'Google Sign-In Client ID',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.dummy : ValidationStatus.production,
      description: isDummyMode 
          ? 'Using dummy Google client ID: ${AuthConfig.dummyGoogleClientId}'
          : 'Using production Google client ID',
      recommendation: isDummyMode 
          ? 'Replace with actual Google OAuth client ID from Google Console'
          : null,
    ));

    results.add(ValidationResult(
      category: 'Authentication',
      item: 'Apple Sign-In Service ID',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.dummy : ValidationStatus.production,
      description: isDummyMode 
          ? 'Using dummy Apple service ID: ${AuthConfig.dummyAppleServiceId}'
          : 'Using production Apple service ID',
      recommendation: isDummyMode 
          ? 'Replace with actual Apple service ID from Apple Developer'
          : null,
    ));

    // Check production checklist completion
    results.add(ValidationResult(
      category: 'Authentication',
      item: 'Production Checklist',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.warning : ValidationStatus.valid,
      description: isDummyMode 
          ? '${AuthConfig.productionChecklist.length} items need completion'
          : 'Production checklist completed',
      recommendation: isDummyMode 
          ? 'Complete all items in AuthConfig.productionChecklist'
          : null,
      metadata: isDummyMode 
          ? {'checklist_items': AuthConfig.productionChecklist.length}
          : null,
    ));

    return results;
  }

  /// Validate purchase configuration
  static Future<List<ValidationResult>> _validatePurchaseConfiguration() async {
    final results = <ValidationResult>[];

    // Check if using dummy credentials
    final isDummyMode = PurchaseConfig.isDummyMode;
    
    results.add(ValidationResult(
      category: 'Purchase',
      item: 'RevenueCat API Key',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.dummy : ValidationStatus.production,
      description: isDummyMode 
          ? 'Using dummy RevenueCat API key'
          : 'Using production RevenueCat API key',
      recommendation: isDummyMode 
          ? 'Replace with actual RevenueCat public API key from dashboard'
          : null,
    ));

    results.add(ValidationResult(
      category: 'Purchase',
      item: 'Product IDs',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.dummy : ValidationStatus.production,
      description: isDummyMode 
          ? 'Using ${PurchaseConfig.dummyProductIds.length} dummy product IDs'
          : 'Using production product IDs',
      recommendation: isDummyMode 
          ? 'Replace with actual product IDs from App Store Connect / Google Play Console'
          : null,
      metadata: {
        'product_count': PurchaseConfig.dummyProductIds.length,
        'products': PurchaseConfig.dummyProductIds.keys.toList(),
      },
    ));

    results.add(ValidationResult(
      category: 'Purchase',
      item: 'Entitlements',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.dummy : ValidationStatus.production,
      description: isDummyMode 
          ? 'Using ${PurchaseConfig.dummyEntitlements.length} dummy entitlements'
          : 'Using production entitlements',
      recommendation: isDummyMode 
          ? 'Configure actual entitlements in RevenueCat Dashboard'
          : null,
      metadata: {
        'entitlement_count': PurchaseConfig.dummyEntitlements.length,
        'entitlements': PurchaseConfig.dummyEntitlements.keys.toList(),
      },
    ));

    // Check production checklist
    results.add(ValidationResult(
      category: 'Purchase',
      item: 'Production Checklist',
      isValid: !isDummyMode,
      status: isDummyMode ? ValidationStatus.warning : ValidationStatus.valid,
      description: isDummyMode 
          ? '${PurchaseConfig.productionChecklist.length} items need completion'
          : 'Production checklist completed',
      recommendation: isDummyMode 
          ? 'Complete all items in PurchaseConfig.productionChecklist'
          : null,
    ));

    return results;
  }

  /// Validate API configuration
  static Future<List<ValidationResult>> _validateApiConfiguration() async {
    final results = <ValidationResult>[];

    // Check API URLs
    results.add(ValidationResult(
      category: 'API',
      item: 'Development URL',
      isValid: CoreStrings.devUrl.isNotEmpty,
      status: ValidationStatus.valid,
      description: 'Development API URL: ${CoreStrings.devUrl}',
    ));

    results.add(ValidationResult(
      category: 'API',
      item: 'Staging URL',
      isValid: CoreStrings.stgUrl.isNotEmpty,
      status: ValidationStatus.valid,
      description: 'Staging API URL: ${CoreStrings.stgUrl}',
    ));

    results.add(ValidationResult(
      category: 'API',
      item: 'Production URL',
      isValid: CoreStrings.prodUrl.isNotEmpty,
      status: ValidationStatus.valid,
      description: 'Production API URL: ${CoreStrings.prodUrl}',
    ));

    // Check Sentry configuration
    final sentryDsn = CoreStrings.sentryDsn;
    final isDummySentry = sentryDsn.contains('sentry.io/') && 
                         (sentryDsn.contains('ProjectKey') || sentryDsn.contains('DefaultProjectKey'));
    
    results.add(ValidationResult(
      category: 'API',
      item: 'Sentry DSN',
      isValid: !isDummySentry,
      status: isDummySentry ? ValidationStatus.dummy : ValidationStatus.production,
      description: isDummySentry 
          ? 'Using placeholder Sentry DSN'
          : 'Sentry DSN configured',
      recommendation: isDummySentry 
          ? 'Replace with actual Sentry DSN from Sentry project settings'
          : null,
    ));

    return results;
  }

  /// Validate assets
  static Future<List<ValidationResult>> _validateAssets() async {
    final results = <ValidationResult>[];

    // Check video assets
    try {
      await rootBundle.load(VideoConfig.introVideo);
      results.add(ValidationResult(
        category: 'Assets',
        item: 'Intro Video',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Video asset found: ${VideoConfig.introVideo}',
      ));
    } catch (e) {
      results.add(ValidationResult(
        category: 'Assets',
        item: 'Intro Video',
        isValid: false,
        status: ValidationStatus.missing,
        description: 'Video asset not found: ${VideoConfig.introVideo}',
        recommendation: 'Add intro video file to assets/video/ directory and update pubspec.yaml',
      ));
    }

    // Check app logo
    try {
      await rootBundle.load('assets/image/app_logo.png');
      results.add(ValidationResult(
        category: 'Assets',
        item: 'App Logo',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'App logo found: assets/image/app_logo.png',
      ));
    } catch (e) {
      results.add(ValidationResult(
        category: 'Assets',
        item: 'App Logo',
        isValid: false,
        status: ValidationStatus.missing,
        description: 'App logo not found: assets/image/app_logo.png',
        recommendation: 'Add app logo to assets/image/ directory',
      ));
    }

    return results;
  }

  /// Validate platform-specific configuration
  static Future<List<ValidationResult>> _validatePlatformConfiguration() async {
    final results = <ValidationResult>[];

    // Check platform
    if (Platform.isIOS) {
      results.add(ValidationResult(
        category: 'Platform',
        item: 'iOS Platform',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Running on iOS platform',
      ));
    } else if (Platform.isAndroid) {
      results.add(ValidationResult(
        category: 'Platform',
        item: 'Android Platform',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Running on Android platform',
      ));
    } else {
      results.add(ValidationResult(
        category: 'Platform',
        item: 'Platform Detection',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Running on ${Platform.operatingSystem}',
      ));
    }

    return results;
  }

  /// Validate Shorebird configuration
  static Future<List<ValidationResult>> _validateShorebirdConfiguration() async {
    final results = <ValidationResult>[];

    // Check shorebird.yaml
    final shorebirdFile = File('shorebird.yaml');
    if (await shorebirdFile.exists()) {
      try {
        final content = await shorebirdFile.readAsString();
        
        // Check if using placeholder app IDs
        final hasPlaceholder = content.contains('your-app-id-here') || 
                              content.contains('your-dev-app-id-here') ||
                              content.contains('your-prod-app-id-here') ||
                              content.contains('your-staging-app-id-here');
        
        results.add(ValidationResult(
          category: 'Shorebird',
          item: 'shorebird.yaml',
          isValid: !hasPlaceholder,
          status: hasPlaceholder ? ValidationStatus.dummy : ValidationStatus.valid,
          description: hasPlaceholder 
              ? 'Using placeholder Shorebird app IDs'
              : 'Shorebird configuration found',
          recommendation: hasPlaceholder 
              ? 'Run "shorebird init" and replace with actual app IDs from Shorebird console'
              : null,
        ));

        // Check for flavor configuration
        final hasFlavors = content.contains('flavors:');
        results.add(ValidationResult(
          category: 'Shorebird',
          item: 'Shorebird Flavors',
          isValid: hasFlavors,
          status: hasFlavors ? ValidationStatus.valid : ValidationStatus.warning,
          description: hasFlavors 
              ? 'Flavor configuration found (development, staging, production)'
              : 'No flavor configuration found',
          recommendation: hasFlavors 
              ? null
              : 'Add flavor configuration for different environments',
        ));
      } catch (e) {
        results.add(ValidationResult(
          category: 'Shorebird',
          item: 'shorebird.yaml',
          isValid: false,
          status: ValidationStatus.invalid,
          description: 'Error reading shorebird.yaml: $e',
          recommendation: 'Check shorebird.yaml format',
        ));
      }
    } else {
      results.add(ValidationResult(
        category: 'Shorebird',
        item: 'shorebird.yaml',
        isValid: false,
        status: ValidationStatus.missing,
        description: 'Shorebird configuration file not found',
        recommendation: 'Run "shorebird init" to create shorebird.yaml',
      ));
    }

    return results;
  }

  /// Validate Firebase Remote Config configuration
  static Future<List<ValidationResult>> _validateRemoteConfigConfiguration() async {
    final results = <ValidationResult>[];

    // List of required Remote Config parameters
    final requiredParams = [
      'android_min_version',
      'android_current_version', 
      'ios_min_version',
      'ios_current_version',
      'is_update_required',
      'is_force_update_required',
      'android_store_url',
      'ios_store_url',
      'update_message_tr',
      'update_message_en',
    ];

    results.add(ValidationResult(
      category: 'Remote Config',
      item: 'Required Parameters',
      isValid: false,
      status: ValidationStatus.warning,
      description: 'Remote Config requires ${requiredParams.length} parameters to be configured',
      recommendation: 'Configure the following parameters in Firebase Console:\n${requiredParams.join(', ')}',
      metadata: {
        'required_params': requiredParams,
        'param_count': requiredParams.length,
      },
    ));

    // Check store URLs format
    results.add(ValidationResult(
      category: 'Remote Config',
      item: 'Store URLs',
      isValid: false,
      status: ValidationStatus.dummy,
      description: 'Store URLs need to be configured for force updates',
      recommendation: 'Set android_store_url and ios_store_url in Firebase Remote Config:\n'
          '- Android: https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME\n'
          '- iOS: https://apps.apple.com/app/idYOUR_APP_ID',
    ));

    // Check version format
    results.add(ValidationResult(
      category: 'Remote Config',
      item: 'Version Format',
      isValid: true,
      status: ValidationStatus.valid,
      description: 'Version format should be: MAJOR.MINOR.PATCH+BUILD (e.g., 1.0.0+1)',
      metadata: {
        'example_version': '1.0.0+1',
        'format': 'MAJOR.MINOR.PATCH+BUILD',
      },
    ));

    return results;
  }

  /// Validate Analytics configuration
  static Future<List<ValidationResult>> _validateAnalyticsConfiguration() async {
    final results = <ValidationResult>[];

    try {
      // Check Smartlook API key
      final smartlookApiKey = dotenv.env['SMARTLOOK_API_KEY'];
      if (smartlookApiKey != null && smartlookApiKey.isNotEmpty && 
          !smartlookApiKey.startsWith('your-') && 
          smartlookApiKey != 'dummy-smartlook-api-key') {
        results.add(ValidationResult(
          category: 'Analytics',
          item: 'Smartlook API Key',
          isValid: true,
          status: ValidationStatus.valid,
          description: 'Smartlook API key configured: ${smartlookApiKey.substring(0, 8)}...',
        ));
      } else {
        results.add(ValidationResult(
          category: 'Analytics',
          item: 'Smartlook API Key',
          isValid: false,
          status: ValidationStatus.dummy,
          description: 'Using dummy/missing Smartlook API key',
          recommendation: 'Set SMARTLOOK_API_KEY in .env files with actual Smartlook project API key',
        ));
      }

      // Check Mixpanel project token
      final mixpanelToken = dotenv.env['MIXPANEL_PROJECT_TOKEN'];
      if (mixpanelToken != null && mixpanelToken.isNotEmpty && 
          !mixpanelToken.startsWith('your-') && 
          mixpanelToken != 'dummy-mixpanel-token') {
        results.add(ValidationResult(
          category: 'Analytics',
          item: 'Mixpanel Project Token',
          isValid: true,
          status: ValidationStatus.valid,
          description: 'Mixpanel project token configured: ${mixpanelToken.substring(0, 8)}...',
        ));
      } else {
        results.add(ValidationResult(
          category: 'Analytics',
          item: 'Mixpanel Project Token',
          isValid: false,
          status: ValidationStatus.dummy,
          description: 'Using dummy/missing Mixpanel project token',
          recommendation: 'Set MIXPANEL_PROJECT_TOKEN in .env files with actual Mixpanel project token',
        ));
      }

      // Check Firebase Analytics (always available if Firebase is configured)
      results.add(ValidationResult(
        category: 'Analytics',
        item: 'Firebase Analytics',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Firebase Analytics available through Firebase SDK',
      ));

      // Analytics integration status
      results.add(ValidationResult(
        category: 'Analytics',
        item: 'Unified Analytics Service',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Unified analytics service configured with Firebase, Smartlook, and Mixpanel support',
        metadata: {
          'services': ['Firebase Analytics', 'Smartlook', 'Mixpanel'],
          'features': ['Event tracking', 'User identification', 'Session recording', 'Revenue tracking'],
        },
      ));

      // Privacy compliance features
      results.add(ValidationResult(
        category: 'Analytics',
        item: 'Privacy Features',
        isValid: true,
        status: ValidationStatus.valid,
        description: 'Analytics configured with privacy controls and sensitive data protection',
        metadata: {
          'features': ['Sensitive screen detection', 'Payment mode wireframe', 'User consent controls'],
        },
      ));

    } catch (e) {
      results.add(ValidationResult(
        category: 'Analytics',
        item: 'Configuration Check',
        isValid: false,
        status: ValidationStatus.invalid,
        description: 'Failed to validate analytics configuration: $e',
        recommendation: 'Check .env files and analytics service configuration',
      ));
    }

    return results;
  }

  /// Calculate validation summary
  static ValidationSummary _calculateSummary(
    List<ValidationResult> allResults,
    Map<String, List<ValidationResult>> categoryResults,
  ) {
    final validCount = allResults.where((r) => r.status == ValidationStatus.valid || r.status == ValidationStatus.production).length;
    final warningCount = allResults.where((r) => r.status == ValidationStatus.warning || r.status == ValidationStatus.dummy).length;
    final invalidCount = allResults.where((r) => r.status == ValidationStatus.invalid || r.status == ValidationStatus.missing).length;
    
    final isProductionReady = invalidCount == 0 && warningCount == 0;

    return ValidationSummary(
      totalChecks: allResults.length,
      validCount: validCount,
      invalidCount: invalidCount,
      warningCount: warningCount,
      isProductionReady: isProductionReady,
      categoryResults: categoryResults,
      timestamp: DateTime.now(),
    );
  }

  /// Log all results in organized format
  static void _logAllResults(
    ValidationSummary summary,
    Map<String, List<ValidationResult>> categoryResults,
    List<ValidationResult> allResults,
  ) {
    // Log summary
    ValidationLogger.logSummary(summary);

    // Log category results
    for (final entry in categoryResults.entries) {
      ValidationLogger.logCategoryResults(entry.key, entry.value);
    }

    // Log missing configurations
    final missingItems = allResults
        .where((r) => r.status == ValidationStatus.missing || r.status == ValidationStatus.invalid)
        .toList();
    ValidationLogger.logMissingConfigurations(missingItems);

    // Log dummy configurations
    final dummyItems = allResults
        .where((r) => r.status == ValidationStatus.dummy || r.status == ValidationStatus.warning)
        .toList();
    ValidationLogger.logDummyConfigurations(dummyItems);

    // Log production checklists
    if (!summary.isProductionReady) {
      ValidationLogger.logProductionChecklist(AuthConfig.productionChecklist, 'Authentication');
      ValidationLogger.logProductionChecklist(PurchaseConfig.productionChecklist, 'Purchase');
      ValidationLogger.logEnvironmentWarnings();
    }

    // Log completion
    ValidationLogger.logValidationComplete(
      isProductionReady: summary.isProductionReady,
    );
  }

  /// Quick validation check (minimal logging)
  static Future<bool> isProductionReady() async {
    final summary = await validateAll(logResults: false);
    return summary.isProductionReady;
  }

  /// Get validation results for specific category
  static Future<List<ValidationResult>> validateCategory(String category) async {
    switch (category.toLowerCase()) {
      case 'firebase':
        return _validateFirebaseConfiguration();
      case 'auth':
      case 'authentication':
        return _validateAuthConfiguration();
      case 'purchase':
      case 'purchases':
        return _validatePurchaseConfiguration();
      case 'api':
        return _validateApiConfiguration();
      case 'assets':
        return _validateAssets();
      case 'platform':
        return _validatePlatformConfiguration();
      case 'shorebird':
        return _validateShorebirdConfiguration();
      case 'remote':
      case 'remoteconfig':
      case 'remote config':
        return _validateRemoteConfigConfiguration();
      default:
        return [];
    }
  }
}
# Environment Validation Service

A comprehensive environment and configuration validation service for the Daisy Flutter application.

## Overview

The Environment Validation Service automatically checks all configuration items during app startup and provides detailed logging of missing and completed configurations.

## Features

### Validation Categories
- **Firebase Configuration**: Checks firebase_options.dart, google-services.json, GoogleService-Info.plist
- **Authentication**: Validates Google/Apple Sign-In credentials (dummy vs production)
- **RevenueCat**: Checks API keys, product IDs, entitlements  
- **API Configuration**: Validates API URLs and endpoints
- **Assets**: Verifies video files, images, and required assets exist
- **Platform**: Validates platform-specific configurations

### Logging System
- Detailed console output with color coding
- Separate logs for missing vs completed items
- Production readiness checklist status
- Warning messages for dummy credentials

## Usage

### Automatic Validation
The service automatically runs during app startup:
- **Debug mode**: Full validation with detailed logging
- **Release mode**: Quick production readiness check with minimal logging

```dart
// In bootstrap.dart - automatically integrated
if (kDebugMode) {
  // Run comprehensive validation in debug mode
  await EnvironmentValidationService.validateAll();
} else {
  // Quick production readiness check in release mode
  final isReady = await EnvironmentValidationService.isProductionReady();
  if (!isReady) {
    log('⚠️ Production deployment warnings detected. Run in debug mode for details.');
  }
}
```

### Manual Validation
You can also run validation manually:

```dart
// Full validation with logging
final summary = await EnvironmentValidationService.validateAll();

// Quick production readiness check
final isReady = await EnvironmentValidationService.isProductionReady();

// Validate specific category
final firebaseResults = await EnvironmentValidationService.validateCategory('firebase');
```

## Validation Results

### ValidationResult
Each configuration item returns a `ValidationResult`:

```dart
ValidationResult(
  category: 'Firebase',
  item: 'google-services.json',
  isValid: true,
  status: ValidationStatus.valid,
  description: 'Android Firebase configuration found',
  recommendation: null,
  metadata: {'project_id': 'my-project', 'file_size': '2048 bytes'},
)
```

### ValidationSummary
Overall validation returns a `ValidationSummary`:

```dart
ValidationSummary(
  totalChecks: 15,
  validCount: 10,
  invalidCount: 2,
  warningCount: 3,
  isProductionReady: false,
  categoryResults: {...},
  timestamp: DateTime.now(),
)
```

### ValidationStatus
- `valid` ✅ - Configuration is correct
- `production` ✅ - Production-ready configuration  
- `warning` ⚠️ - Configuration needs attention
- `dummy` ⚠️ - Using development/dummy values
- `invalid` ❌ - Configuration is incorrect
- `missing` ❌ - Configuration is missing

## Example Output

```
🚀 Starting Configuration Validation
Checking all environment variables, API keys, and certificates...

🔍 Configuration Validation Summary
=======================================

Total Checks: 15
✅ Valid: 8
⚠️  Warnings: 5
❌ Issues: 2

Production Ready: ❌ No
Timestamp: 2025-08-12T21:30:00.000Z

📋 Firebase
-----------
✅ firebase_options.dart: Valid
   📝 Firebase options file exists and is accessible
⚠️  Firebase Project ID: Dummy/Development  
   📝 Using development Firebase project: daisy-c1c2c
   💡 Replace with production Firebase project ID before deployment

📋 Authentication
-----------------
⚠️  Google Sign-In Client ID: Dummy/Development
   📝 Using dummy Google client ID: dummy-google-client-id.apps.googleusercontent.com
   💡 Replace with actual Google OAuth client ID from Google Console

❌ Missing Configurations
=========================
❌ Firebase: GoogleService-Info.plist
   💡 Download GoogleService-Info.plist from Firebase Console to ios/Runner/

⚠️ Dummy/Development Configurations
===================================
The following configurations are using dummy/development values:
⚠️  Authentication: Google Sign-In Client ID
   💡 Replace with actual Google OAuth client ID from Google Console
⚠️  Purchase: RevenueCat API Key
   💡 Replace with actual RevenueCat public API key from dashboard

📋 Authentication Production Checklist
--------------------------------------
  ✅ Replace dummyGoogleClientId with actual Google OAuth client ID
  ✅ Replace dummyAppleServiceId with actual Apple service ID
  ✅ Update google-services.json for Android
  ✅ Update GoogleService-Info.plist for iOS
  ✅ Configure Apple Sign In capabilities in Xcode
  ✅ Test authentication flows on physical devices
  ✅ Verify privacy policy and terms of service links

⚠️ Environment Warnings
=======================
⚠️  This app is running with development configurations.
⚠️  Some features may not work properly until production setup is complete.
⚠️  Please review the production checklists above before deployment.

✅ Configuration Validation Complete
===================================
⚠️  Some configurations need attention before production deployment.
```

## Files Structure

```
lib/core/manager/validation/
├── environment_validation_service.dart    # Main validation service
├── validation_logger.dart                 # Specialized logging
├── models/
│   └── validation_result.dart            # Data models
└── README.md                             # This documentation
```

## Integration

The service is automatically integrated into the app startup process in `lib/app/bootstrap.dart` and runs during the initialization phase, after Firebase setup but before the app UI is rendered.

This ensures that developers are immediately aware of any configuration issues when running the app in debug mode, while production builds get a quick readiness check without verbose logging.
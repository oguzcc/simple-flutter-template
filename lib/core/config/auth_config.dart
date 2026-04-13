/// Authentication configuration with dummy credentials
/// 
/// ⚠️ WARNING: This file contains DUMMY credentials for development only!
/// Replace with actual credentials before production deployment.
/// 
/// For production setup:
/// 1. Create Google OAuth client ID in Google Console
/// 2. Configure Apple Sign In service ID in Apple Developer
/// 3. Update Firebase configuration files
/// 4. Replace dummy values in this file
class AuthConfig {
  /// Dummy Google Sign In client ID
  /// 
  /// ⚠️ PRODUCTION TODO: Replace with actual Google OAuth client ID
  /// Format: 'xxxxx.apps.googleusercontent.com'
  static const String dummyGoogleClientId = 'dummy-google-client-id.apps.googleusercontent.com';

  /// Dummy Apple Sign In service ID
  /// 
  /// ⚠️ PRODUCTION TODO: Replace with actual Apple service ID
  /// Format: 'com.yourcompany.yourapp.signin'
  static const String dummyAppleServiceId = 'com.example.daisy.signin';

  /// Production readiness checklist
  static const List<String> productionChecklist = [
    '✅ Replace dummyGoogleClientId with actual Google OAuth client ID',
    '✅ Replace dummyAppleServiceId with actual Apple service ID',
    '✅ Update google-services.json for Android',
    '✅ Update GoogleService-Info.plist for iOS', 
    '✅ Configure Apple Sign In capabilities in Xcode',
    '✅ Test authentication flows on physical devices',
    '✅ Verify privacy policy and terms of service links',
  ];

  /// Check if using dummy credentials (development mode)
  static bool get isDummyMode {
    return dummyGoogleClientId.contains('dummy') || 
           dummyAppleServiceId.contains('dummy');
  }

  /// Get warning message for dummy mode
  static String get dummyModeWarning {
    if (isDummyMode) {
      return '''
⚠️ DEVELOPMENT MODE - DUMMY CREDENTIALS DETECTED
      
This app is using dummy authentication credentials.
Social login will not work properly until production credentials are configured.

Please complete the production checklist in AuthConfig class.
''';
    }
    return '';
  }
}

/// Extension to provide auth-related constants
extension AuthConstants on AuthConfig {
  /// Default error messages for authentication failures
  static const Map<String, String> errorMessages = {
    'user-cancelled': 'Login was cancelled by user',
    'network-error': 'Network connection failed. Please check your internet.',
    'invalid-credential': 'Invalid login credentials. Please try again.',
    'account-exists-with-different-credential': 'An account already exists with this email using a different sign-in method.',
    'operation-not-allowed': 'This sign-in method is not enabled. Please contact support.',
    'user-disabled': 'This account has been disabled. Please contact support.',
    'too-many-requests': 'Too many failed attempts. Please try again later.',
    'unknown': 'An unexpected error occurred. Please try again.',
  };
  
  /// Get user-friendly error message
  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? errorMessages['unknown']!;
  }
}

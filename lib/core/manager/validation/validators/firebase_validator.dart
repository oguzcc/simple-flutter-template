import 'dart:convert';
import 'dart:io';

import 'package:daisy/core/manager/validation/models/validation_result.dart';
import 'package:daisy/firebase_options.dart';

class FirebaseValidator {
  const FirebaseValidator._();

  static Future<List<ValidationResult>> validate() async {
    final results = <ValidationResult>[];

    // Check firebase_options.dart
    try {
      const webOptions = DefaultFirebaseOptions.web;
      const androidOptions = DefaultFirebaseOptions.android;
      const iosOptions = DefaultFirebaseOptions.ios;

      results.add(
        const ValidationResult(
          category: 'Firebase',
          item: 'firebase_options.dart',
          isValid: true,
          status: ValidationStatus.valid,
          description: 'Firebase options file exists and is accessible',
        ),
      );

      final isDummyProject = webOptions.projectId.contains('daisy-c1c2c');
      results.add(
        ValidationResult(
          category: 'Firebase',
          item: 'Firebase Project ID',
          isValid: !isDummyProject,
          status: isDummyProject
              ? ValidationStatus.dummy
              : ValidationStatus.production,
          description: isDummyProject
              ? 'Using development Firebase project: ${webOptions.projectId}'
              : 'Using production Firebase project: ${webOptions.projectId}',
          recommendation: isDummyProject
              ? 'Replace with production Firebase project ID before deployment'
              : null,
        ),
      );

      results.add(
        ValidationResult(
          category: 'Firebase',
          item: 'Firebase API Keys',
          isValid: true,
          status: ValidationStatus.valid,
          description: 'API keys are configured for all platforms',
          metadata: {
            'web_api_key': '${webOptions.apiKey.substring(0, 10)}...',
            'android_api_key': '${androidOptions.apiKey.substring(0, 10)}...',
            'ios_api_key': '${iosOptions.apiKey.substring(0, 10)}...',
          },
        ),
      );
    } catch (e) {
      results.add(
        ValidationResult(
          category: 'Firebase',
          item: 'firebase_options.dart',
          isValid: false,
          status: ValidationStatus.invalid,
          description: 'Error accessing Firebase options: $e',
          recommendation:
              'Run "flutterfire configure" to generate Firebase options',
        ),
      );
    }

    // Check google-services.json (Android)
    final androidConfigFile = File('android/app/google-services.json');
    if (androidConfigFile.existsSync()) {
      try {
        final content = await androidConfigFile.readAsString();
        final config = jsonDecode(content) as Map<String, dynamic>;
        final projectInfo = config['project_info'] as Map<String, dynamic>?;

        results.add(
          ValidationResult(
            category: 'Firebase',
            item: 'google-services.json',
            isValid: true,
            status: ValidationStatus.valid,
            description: 'Android Firebase configuration found',
            metadata: {
              'project_id': projectInfo?['project_id'] ?? 'unknown',
              'file_size': '${content.length} bytes',
            },
          ),
        );
      } catch (e) {
        results.add(
          ValidationResult(
            category: 'Firebase',
            item: 'google-services.json',
            isValid: false,
            status: ValidationStatus.invalid,
            description: 'Invalid JSON format in google-services.json: $e',
            recommendation:
                'Download new google-services.json from Firebase Console',
          ),
        );
      }
    } else {
      results.add(
        const ValidationResult(
          category: 'Firebase',
          item: 'google-services.json',
          isValid: false,
          status: ValidationStatus.missing,
          description: 'Android Firebase configuration file not found',
          recommendation:
              'Download google-services.json from Firebase Console to android/app/',
        ),
      );
    }

    // Check GoogleService-Info.plist (iOS)
    final iosConfigFile = File('ios/Runner/GoogleService-Info.plist');
    if (iosConfigFile.existsSync()) {
      results.add(
        const ValidationResult(
          category: 'Firebase',
          item: 'GoogleService-Info.plist',
          isValid: true,
          status: ValidationStatus.valid,
          description: 'iOS Firebase configuration found',
        ),
      );
    } else {
      results.add(
        const ValidationResult(
          category: 'Firebase',
          item: 'GoogleService-Info.plist',
          isValid: false,
          status: ValidationStatus.missing,
          description: 'iOS Firebase configuration file not found',
          recommendation:
              'Download GoogleService-Info.plist from Firebase Console to ios/Runner/',
        ),
      );
    }

    return results;
  }
}

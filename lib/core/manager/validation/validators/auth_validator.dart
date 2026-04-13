import 'package:daisy/core/config/auth_config.dart';
import 'package:daisy/core/manager/validation/models/validation_result.dart';

class AuthValidator {
  const AuthValidator._();

  static Future<List<ValidationResult>> validate() async {
    final results = <ValidationResult>[];
    final isDummyMode = AuthConfig.isDummyMode;

    results.add(
      ValidationResult(
        category: 'Authentication',
        item: 'Google Sign-In Client ID',
        isValid: !isDummyMode,
        status: isDummyMode
            ? ValidationStatus.dummy
            : ValidationStatus.production,
        description: isDummyMode
            ? 'Using dummy Google client ID: ${AuthConfig.dummyGoogleClientId}'
            : 'Using production Google client ID',
        recommendation: isDummyMode
            ? 'Replace with actual Google OAuth client ID from Google Console'
            : null,
      ),
    );

    results.add(
      ValidationResult(
        category: 'Authentication',
        item: 'Apple Sign-In Service ID',
        isValid: !isDummyMode,
        status: isDummyMode
            ? ValidationStatus.dummy
            : ValidationStatus.production,
        description: isDummyMode
            ? 'Using dummy Apple service ID: ${AuthConfig.dummyAppleServiceId}'
            : 'Using production Apple service ID',
        recommendation: isDummyMode
            ? 'Replace with actual Apple service ID from Apple Developer'
            : null,
      ),
    );

    results.add(
      ValidationResult(
        category: 'Authentication',
        item: 'Production Checklist',
        isValid: !isDummyMode,
        status:
            isDummyMode ? ValidationStatus.warning : ValidationStatus.valid,
        description: isDummyMode
            ? '${AuthConfig.productionChecklist.length} items need completion'
            : 'Production checklist completed',
        recommendation: isDummyMode
            ? 'Complete all items in AuthConfig.productionChecklist'
            : null,
        metadata: isDummyMode
            ? {'checklist_items': AuthConfig.productionChecklist.length}
            : null,
      ),
    );

    return results;
  }
}

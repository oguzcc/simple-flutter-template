import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation_result.freezed.dart';
part 'validation_result.g.dart';

/// Validation result for individual configuration item
@freezed
class ValidationResult with _$ValidationResult {
  const factory ValidationResult({
    required String category,
    required String item,
    required bool isValid,
    required ValidationStatus status,
    String? description,
    String? recommendation,
    Map<String, dynamic>? metadata,
  }) = _ValidationResult;

  factory ValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultFromJson(json);
}

/// Overall validation summary
@freezed
class ValidationSummary with _$ValidationSummary {
  const factory ValidationSummary({
    required int totalChecks,
    required int validCount,
    required int invalidCount,
    required int warningCount,
    required bool isProductionReady,
    required Map<String, List<ValidationResult>> categoryResults,
    required DateTime timestamp,
  }) = _ValidationSummary;

  factory ValidationSummary.fromJson(Map<String, dynamic> json) =>
      _$ValidationSummaryFromJson(json);
}

/// Validation status enum
enum ValidationStatus {
  valid,
  invalid,
  warning,
  missing,
  dummy,
  production,
}

/// Extension for validation status helpers
extension ValidationStatusX on ValidationStatus {
  /// Get color code for console output
  String get colorCode {
    switch (this) {
      case ValidationStatus.valid:
      case ValidationStatus.production:
        return '\x1B[32m'; // Green
      case ValidationStatus.warning:
      case ValidationStatus.dummy:
        return '\x1B[33m'; // Yellow
      case ValidationStatus.invalid:
      case ValidationStatus.missing:
        return '\x1B[31m'; // Red
    }
  }

  /// Get status icon
  String get icon {
    switch (this) {
      case ValidationStatus.valid:
      case ValidationStatus.production:
        return '✅';
      case ValidationStatus.warning:
      case ValidationStatus.dummy:
        return '⚠️';
      case ValidationStatus.invalid:
      case ValidationStatus.missing:
        return '❌';
    }
  }

  /// Get human-readable description
  String get description {
    switch (this) {
      case ValidationStatus.valid:
        return 'Valid';
      case ValidationStatus.invalid:
        return 'Invalid';
      case ValidationStatus.warning:
        return 'Warning';
      case ValidationStatus.missing:
        return 'Missing';
      case ValidationStatus.dummy:
        return 'Dummy/Development';
      case ValidationStatus.production:
        return 'Production Ready';
    }
  }
}

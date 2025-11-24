import 'package:equatable/equatable.dart';

/// Validation result for individual configuration item
class ValidationResult extends Equatable {
  const ValidationResult({
    required this.category,
    required this.item,
    required this.isValid,
    required this.status,
    this.description,
    this.recommendation,
    this.metadata,
  });

  final String category;
  final String item;
  final bool isValid;
  final ValidationStatus status;
  final String? description;
  final String? recommendation;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
        category,
        item,
        isValid,
        status,
        description,
        recommendation,
        metadata,
      ];

  ValidationResult copyWith({
    String? category,
    String? item,
    bool? isValid,
    ValidationStatus? status,
    String? description,
    String? recommendation,
    Map<String, dynamic>? metadata,
  }) {
    return ValidationResult(
      category: category ?? this.category,
      item: item ?? this.item,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      metadata: metadata ?? this.metadata,
    );
  }

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      category: json['category'] as String,
      item: json['item'] as String,
      isValid: json['isValid'] as bool,
      status: ValidationStatus.values.byName(json['status'] as String),
      description: json['description'] as String?,
      recommendation: json['recommendation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'item': item,
      'isValid': isValid,
      'status': status.name,
      if (description != null) 'description': description,
      if (recommendation != null) 'recommendation': recommendation,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Overall validation summary
class ValidationSummary extends Equatable {
  const ValidationSummary({
    required this.totalChecks,
    required this.validCount,
    required this.invalidCount,
    required this.warningCount,
    required this.isProductionReady,
    required this.categoryResults,
    required this.timestamp,
  });

  final int totalChecks;
  final int validCount;
  final int invalidCount;
  final int warningCount;
  final bool isProductionReady;
  final Map<String, List<ValidationResult>> categoryResults;
  final DateTime timestamp;

  @override
  List<Object?> get props => [
        totalChecks,
        validCount,
        invalidCount,
        warningCount,
        isProductionReady,
        categoryResults,
        timestamp,
      ];

  ValidationSummary copyWith({
    int? totalChecks,
    int? validCount,
    int? invalidCount,
    int? warningCount,
    bool? isProductionReady,
    Map<String, List<ValidationResult>>? categoryResults,
    DateTime? timestamp,
  }) {
    return ValidationSummary(
      totalChecks: totalChecks ?? this.totalChecks,
      validCount: validCount ?? this.validCount,
      invalidCount: invalidCount ?? this.invalidCount,
      warningCount: warningCount ?? this.warningCount,
      isProductionReady: isProductionReady ?? this.isProductionReady,
      categoryResults: categoryResults ?? this.categoryResults,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ValidationSummary.fromJson(Map<String, dynamic> json) {
    return ValidationSummary(
      totalChecks: json['totalChecks'] as int,
      validCount: json['validCount'] as int,
      invalidCount: json['invalidCount'] as int,
      warningCount: json['warningCount'] as int,
      isProductionReady: json['isProductionReady'] as bool,
      categoryResults: (json['categoryResults'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((e) => ValidationResult.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalChecks': totalChecks,
      'validCount': validCount,
      'invalidCount': invalidCount,
      'warningCount': warningCount,
      'isProductionReady': isProductionReady,
      'categoryResults': categoryResults.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'timestamp': timestamp.toIso8601String(),
    };
  }
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

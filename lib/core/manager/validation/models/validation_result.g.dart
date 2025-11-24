// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ValidationResultImpl _$$ValidationResultImplFromJson(
  Map<String, dynamic> json,
) => _$ValidationResultImpl(
  category: json['category'] as String,
  item: json['item'] as String,
  isValid: json['isValid'] as bool,
  status: $enumDecode(_$ValidationStatusEnumMap, json['status']),
  description: json['description'] as String?,
  recommendation: json['recommendation'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ValidationResultImplToJson(
  _$ValidationResultImpl instance,
) => <String, dynamic>{
  'category': instance.category,
  'item': instance.item,
  'isValid': instance.isValid,
  'status': _$ValidationStatusEnumMap[instance.status]!,
  'description': instance.description,
  'recommendation': instance.recommendation,
  'metadata': instance.metadata,
};

const _$ValidationStatusEnumMap = {
  ValidationStatus.valid: 'valid',
  ValidationStatus.invalid: 'invalid',
  ValidationStatus.warning: 'warning',
  ValidationStatus.missing: 'missing',
  ValidationStatus.dummy: 'dummy',
  ValidationStatus.production: 'production',
};

_$ValidationSummaryImpl _$$ValidationSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ValidationSummaryImpl(
  totalChecks: (json['totalChecks'] as num).toInt(),
  validCount: (json['validCount'] as num).toInt(),
  invalidCount: (json['invalidCount'] as num).toInt(),
  warningCount: (json['warningCount'] as num).toInt(),
  isProductionReady: json['isProductionReady'] as bool,
  categoryResults: (json['categoryResults'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => ValidationResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$ValidationSummaryImplToJson(
  _$ValidationSummaryImpl instance,
) => <String, dynamic>{
  'totalChecks': instance.totalChecks,
  'validCount': instance.validCount,
  'invalidCount': instance.invalidCount,
  'warningCount': instance.warningCount,
  'isProductionReady': instance.isProductionReady,
  'categoryResults': instance.categoryResults,
  'timestamp': instance.timestamp.toIso8601String(),
};

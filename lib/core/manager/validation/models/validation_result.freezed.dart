// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ValidationResult _$ValidationResultFromJson(Map<String, dynamic> json) {
  return _ValidationResult.fromJson(json);
}

/// @nodoc
mixin _$ValidationResult {
  String get category => throw _privateConstructorUsedError;
  String get item => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  ValidationStatus get status => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get recommendation => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ValidationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationResultCopyWith<ValidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationResultCopyWith<$Res> {
  factory $ValidationResultCopyWith(
    ValidationResult value,
    $Res Function(ValidationResult) then,
  ) = _$ValidationResultCopyWithImpl<$Res, ValidationResult>;
  @useResult
  $Res call({
    String category,
    String item,
    bool isValid,
    ValidationStatus status,
    String? description,
    String? recommendation,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ValidationResultCopyWithImpl<$Res, $Val extends ValidationResult>
    implements $ValidationResultCopyWith<$Res> {
  _$ValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? item = null,
    Object? isValid = null,
    Object? status = null,
    Object? description = freezed,
    Object? recommendation = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            item: null == item
                ? _value.item
                : item // ignore: cast_nullable_to_non_nullable
                      as String,
            isValid: null == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ValidationStatus,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            recommendation: freezed == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ValidationResultImplCopyWith<$Res>
    implements $ValidationResultCopyWith<$Res> {
  factory _$$ValidationResultImplCopyWith(
    _$ValidationResultImpl value,
    $Res Function(_$ValidationResultImpl) then,
  ) = __$$ValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String category,
    String item,
    bool isValid,
    ValidationStatus status,
    String? description,
    String? recommendation,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ValidationResultImplCopyWithImpl<$Res>
    extends _$ValidationResultCopyWithImpl<$Res, _$ValidationResultImpl>
    implements _$$ValidationResultImplCopyWith<$Res> {
  __$$ValidationResultImplCopyWithImpl(
    _$ValidationResultImpl _value,
    $Res Function(_$ValidationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? item = null,
    Object? isValid = null,
    Object? status = null,
    Object? description = freezed,
    Object? recommendation = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ValidationResultImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        item: null == item
            ? _value.item
            : item // ignore: cast_nullable_to_non_nullable
                  as String,
        isValid: null == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ValidationStatus,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        recommendation: freezed == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidationResultImpl implements _ValidationResult {
  const _$ValidationResultImpl({
    required this.category,
    required this.item,
    required this.isValid,
    required this.status,
    this.description,
    this.recommendation,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$ValidationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidationResultImplFromJson(json);

  @override
  final String category;
  @override
  final String item;
  @override
  final bool isValid;
  @override
  final ValidationStatus status;
  @override
  final String? description;
  @override
  final String? recommendation;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ValidationResult(category: $category, item: $item, isValid: $isValid, status: $status, description: $description, recommendation: $recommendation, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationResultImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    category,
    item,
    isValid,
    status,
    description,
    recommendation,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationResultImplCopyWith<_$ValidationResultImpl> get copyWith =>
      __$$ValidationResultImplCopyWithImpl<_$ValidationResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidationResultImplToJson(this);
  }
}

abstract class _ValidationResult implements ValidationResult {
  const factory _ValidationResult({
    required final String category,
    required final String item,
    required final bool isValid,
    required final ValidationStatus status,
    final String? description,
    final String? recommendation,
    final Map<String, dynamic>? metadata,
  }) = _$ValidationResultImpl;

  factory _ValidationResult.fromJson(Map<String, dynamic> json) =
      _$ValidationResultImpl.fromJson;

  @override
  String get category;
  @override
  String get item;
  @override
  bool get isValid;
  @override
  ValidationStatus get status;
  @override
  String? get description;
  @override
  String? get recommendation;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationResultImplCopyWith<_$ValidationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ValidationSummary _$ValidationSummaryFromJson(Map<String, dynamic> json) {
  return _ValidationSummary.fromJson(json);
}

/// @nodoc
mixin _$ValidationSummary {
  int get totalChecks => throw _privateConstructorUsedError;
  int get validCount => throw _privateConstructorUsedError;
  int get invalidCount => throw _privateConstructorUsedError;
  int get warningCount => throw _privateConstructorUsedError;
  bool get isProductionReady => throw _privateConstructorUsedError;
  Map<String, List<ValidationResult>> get categoryResults =>
      throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ValidationSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationSummaryCopyWith<ValidationSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationSummaryCopyWith<$Res> {
  factory $ValidationSummaryCopyWith(
    ValidationSummary value,
    $Res Function(ValidationSummary) then,
  ) = _$ValidationSummaryCopyWithImpl<$Res, ValidationSummary>;
  @useResult
  $Res call({
    int totalChecks,
    int validCount,
    int invalidCount,
    int warningCount,
    bool isProductionReady,
    Map<String, List<ValidationResult>> categoryResults,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ValidationSummaryCopyWithImpl<$Res, $Val extends ValidationSummary>
    implements $ValidationSummaryCopyWith<$Res> {
  _$ValidationSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalChecks = null,
    Object? validCount = null,
    Object? invalidCount = null,
    Object? warningCount = null,
    Object? isProductionReady = null,
    Object? categoryResults = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            totalChecks: null == totalChecks
                ? _value.totalChecks
                : totalChecks // ignore: cast_nullable_to_non_nullable
                      as int,
            validCount: null == validCount
                ? _value.validCount
                : validCount // ignore: cast_nullable_to_non_nullable
                      as int,
            invalidCount: null == invalidCount
                ? _value.invalidCount
                : invalidCount // ignore: cast_nullable_to_non_nullable
                      as int,
            warningCount: null == warningCount
                ? _value.warningCount
                : warningCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isProductionReady: null == isProductionReady
                ? _value.isProductionReady
                : isProductionReady // ignore: cast_nullable_to_non_nullable
                      as bool,
            categoryResults: null == categoryResults
                ? _value.categoryResults
                : categoryResults // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<ValidationResult>>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ValidationSummaryImplCopyWith<$Res>
    implements $ValidationSummaryCopyWith<$Res> {
  factory _$$ValidationSummaryImplCopyWith(
    _$ValidationSummaryImpl value,
    $Res Function(_$ValidationSummaryImpl) then,
  ) = __$$ValidationSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalChecks,
    int validCount,
    int invalidCount,
    int warningCount,
    bool isProductionReady,
    Map<String, List<ValidationResult>> categoryResults,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ValidationSummaryImplCopyWithImpl<$Res>
    extends _$ValidationSummaryCopyWithImpl<$Res, _$ValidationSummaryImpl>
    implements _$$ValidationSummaryImplCopyWith<$Res> {
  __$$ValidationSummaryImplCopyWithImpl(
    _$ValidationSummaryImpl _value,
    $Res Function(_$ValidationSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ValidationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalChecks = null,
    Object? validCount = null,
    Object? invalidCount = null,
    Object? warningCount = null,
    Object? isProductionReady = null,
    Object? categoryResults = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$ValidationSummaryImpl(
        totalChecks: null == totalChecks
            ? _value.totalChecks
            : totalChecks // ignore: cast_nullable_to_non_nullable
                  as int,
        validCount: null == validCount
            ? _value.validCount
            : validCount // ignore: cast_nullable_to_non_nullable
                  as int,
        invalidCount: null == invalidCount
            ? _value.invalidCount
            : invalidCount // ignore: cast_nullable_to_non_nullable
                  as int,
        warningCount: null == warningCount
            ? _value.warningCount
            : warningCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isProductionReady: null == isProductionReady
            ? _value.isProductionReady
            : isProductionReady // ignore: cast_nullable_to_non_nullable
                  as bool,
        categoryResults: null == categoryResults
            ? _value._categoryResults
            : categoryResults // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<ValidationResult>>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidationSummaryImpl implements _ValidationSummary {
  const _$ValidationSummaryImpl({
    required this.totalChecks,
    required this.validCount,
    required this.invalidCount,
    required this.warningCount,
    required this.isProductionReady,
    required final Map<String, List<ValidationResult>> categoryResults,
    required this.timestamp,
  }) : _categoryResults = categoryResults;

  factory _$ValidationSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidationSummaryImplFromJson(json);

  @override
  final int totalChecks;
  @override
  final int validCount;
  @override
  final int invalidCount;
  @override
  final int warningCount;
  @override
  final bool isProductionReady;
  final Map<String, List<ValidationResult>> _categoryResults;
  @override
  Map<String, List<ValidationResult>> get categoryResults {
    if (_categoryResults is EqualUnmodifiableMapView) return _categoryResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryResults);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ValidationSummary(totalChecks: $totalChecks, validCount: $validCount, invalidCount: $invalidCount, warningCount: $warningCount, isProductionReady: $isProductionReady, categoryResults: $categoryResults, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationSummaryImpl &&
            (identical(other.totalChecks, totalChecks) ||
                other.totalChecks == totalChecks) &&
            (identical(other.validCount, validCount) ||
                other.validCount == validCount) &&
            (identical(other.invalidCount, invalidCount) ||
                other.invalidCount == invalidCount) &&
            (identical(other.warningCount, warningCount) ||
                other.warningCount == warningCount) &&
            (identical(other.isProductionReady, isProductionReady) ||
                other.isProductionReady == isProductionReady) &&
            const DeepCollectionEquality().equals(
              other._categoryResults,
              _categoryResults,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalChecks,
    validCount,
    invalidCount,
    warningCount,
    isProductionReady,
    const DeepCollectionEquality().hash(_categoryResults),
    timestamp,
  );

  /// Create a copy of ValidationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationSummaryImplCopyWith<_$ValidationSummaryImpl> get copyWith =>
      __$$ValidationSummaryImplCopyWithImpl<_$ValidationSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidationSummaryImplToJson(this);
  }
}

abstract class _ValidationSummary implements ValidationSummary {
  const factory _ValidationSummary({
    required final int totalChecks,
    required final int validCount,
    required final int invalidCount,
    required final int warningCount,
    required final bool isProductionReady,
    required final Map<String, List<ValidationResult>> categoryResults,
    required final DateTime timestamp,
  }) = _$ValidationSummaryImpl;

  factory _ValidationSummary.fromJson(Map<String, dynamic> json) =
      _$ValidationSummaryImpl.fromJson;

  @override
  int get totalChecks;
  @override
  int get validCount;
  @override
  int get invalidCount;
  @override
  int get warningCount;
  @override
  bool get isProductionReady;
  @override
  Map<String, List<ValidationResult>> get categoryResults;
  @override
  DateTime get timestamp;

  /// Create a copy of ValidationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationSummaryImplCopyWith<_$ValidationSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

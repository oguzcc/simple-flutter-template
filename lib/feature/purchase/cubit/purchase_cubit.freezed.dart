// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PurchaseState {
  Status get status => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get purchaseInProgress => throw _privateConstructorUsedError;
  bool get lastPurchaseSuccess => throw _privateConstructorUsedError;
  List<Package> get availablePackages => throw _privateConstructorUsedError;
  CustomerInfo? get customerInfo => throw _privateConstructorUsedError;
  bool get hasPremium => throw _privateConstructorUsedError;
  bool get hasPro => throw _privateConstructorUsedError;
  bool get isAdFree => throw _privateConstructorUsedError;
  SubscriptionStatus get subscriptionStatus =>
      throw _privateConstructorUsedError;
  DateTime? get premiumExpirationDate => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseStateCopyWith<PurchaseState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseStateCopyWith<$Res> {
  factory $PurchaseStateCopyWith(
    PurchaseState value,
    $Res Function(PurchaseState) then,
  ) = _$PurchaseStateCopyWithImpl<$Res, PurchaseState>;
  @useResult
  $Res call({
    Status status,
    bool isInitialized,
    bool purchaseInProgress,
    bool lastPurchaseSuccess,
    List<Package> availablePackages,
    CustomerInfo? customerInfo,
    bool hasPremium,
    bool hasPro,
    bool isAdFree,
    SubscriptionStatus subscriptionStatus,
    DateTime? premiumExpirationDate,
    String? errorMessage,
  });
}

/// @nodoc
class _$PurchaseStateCopyWithImpl<$Res, $Val extends PurchaseState>
    implements $PurchaseStateCopyWith<$Res> {
  _$PurchaseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? isInitialized = null,
    Object? purchaseInProgress = null,
    Object? lastPurchaseSuccess = null,
    Object? availablePackages = null,
    Object? customerInfo = freezed,
    Object? hasPremium = null,
    Object? hasPro = null,
    Object? isAdFree = null,
    Object? subscriptionStatus = null,
    Object? premiumExpirationDate = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as Status,
            isInitialized: null == isInitialized
                ? _value.isInitialized
                : isInitialized // ignore: cast_nullable_to_non_nullable
                      as bool,
            purchaseInProgress: null == purchaseInProgress
                ? _value.purchaseInProgress
                : purchaseInProgress // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastPurchaseSuccess: null == lastPurchaseSuccess
                ? _value.lastPurchaseSuccess
                : lastPurchaseSuccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            availablePackages: null == availablePackages
                ? _value.availablePackages
                : availablePackages // ignore: cast_nullable_to_non_nullable
                      as List<Package>,
            customerInfo: freezed == customerInfo
                ? _value.customerInfo
                : customerInfo // ignore: cast_nullable_to_non_nullable
                      as CustomerInfo?,
            hasPremium: null == hasPremium
                ? _value.hasPremium
                : hasPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPro: null == hasPro
                ? _value.hasPro
                : hasPro // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAdFree: null == isAdFree
                ? _value.isAdFree
                : isAdFree // ignore: cast_nullable_to_non_nullable
                      as bool,
            subscriptionStatus: null == subscriptionStatus
                ? _value.subscriptionStatus
                : subscriptionStatus // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            premiumExpirationDate: freezed == premiumExpirationDate
                ? _value.premiumExpirationDate
                : premiumExpirationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PurchaseStateImplCopyWith<$Res>
    implements $PurchaseStateCopyWith<$Res> {
  factory _$$PurchaseStateImplCopyWith(
    _$PurchaseStateImpl value,
    $Res Function(_$PurchaseStateImpl) then,
  ) = __$$PurchaseStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Status status,
    bool isInitialized,
    bool purchaseInProgress,
    bool lastPurchaseSuccess,
    List<Package> availablePackages,
    CustomerInfo? customerInfo,
    bool hasPremium,
    bool hasPro,
    bool isAdFree,
    SubscriptionStatus subscriptionStatus,
    DateTime? premiumExpirationDate,
    String? errorMessage,
  });
}

/// @nodoc
class __$$PurchaseStateImplCopyWithImpl<$Res>
    extends _$PurchaseStateCopyWithImpl<$Res, _$PurchaseStateImpl>
    implements _$$PurchaseStateImplCopyWith<$Res> {
  __$$PurchaseStateImplCopyWithImpl(
    _$PurchaseStateImpl _value,
    $Res Function(_$PurchaseStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PurchaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? isInitialized = null,
    Object? purchaseInProgress = null,
    Object? lastPurchaseSuccess = null,
    Object? availablePackages = null,
    Object? customerInfo = freezed,
    Object? hasPremium = null,
    Object? hasPro = null,
    Object? isAdFree = null,
    Object? subscriptionStatus = null,
    Object? premiumExpirationDate = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$PurchaseStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as Status,
        isInitialized: null == isInitialized
            ? _value.isInitialized
            : isInitialized // ignore: cast_nullable_to_non_nullable
                  as bool,
        purchaseInProgress: null == purchaseInProgress
            ? _value.purchaseInProgress
            : purchaseInProgress // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastPurchaseSuccess: null == lastPurchaseSuccess
            ? _value.lastPurchaseSuccess
            : lastPurchaseSuccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        availablePackages: null == availablePackages
            ? _value._availablePackages
            : availablePackages // ignore: cast_nullable_to_non_nullable
                  as List<Package>,
        customerInfo: freezed == customerInfo
            ? _value.customerInfo
            : customerInfo // ignore: cast_nullable_to_non_nullable
                  as CustomerInfo?,
        hasPremium: null == hasPremium
            ? _value.hasPremium
            : hasPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPro: null == hasPro
            ? _value.hasPro
            : hasPro // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAdFree: null == isAdFree
            ? _value.isAdFree
            : isAdFree // ignore: cast_nullable_to_non_nullable
                  as bool,
        subscriptionStatus: null == subscriptionStatus
            ? _value.subscriptionStatus
            : subscriptionStatus // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        premiumExpirationDate: freezed == premiumExpirationDate
            ? _value.premiumExpirationDate
            : premiumExpirationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PurchaseStateImpl implements _PurchaseState {
  const _$PurchaseStateImpl({
    this.status = Status.initial,
    this.isInitialized = false,
    this.purchaseInProgress = false,
    this.lastPurchaseSuccess = false,
    final List<Package> availablePackages = const [],
    this.customerInfo,
    this.hasPremium = false,
    this.hasPro = false,
    this.isAdFree = false,
    this.subscriptionStatus = SubscriptionStatus.none,
    this.premiumExpirationDate,
    this.errorMessage,
  }) : _availablePackages = availablePackages;

  @override
  @JsonKey()
  final Status status;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool purchaseInProgress;
  @override
  @JsonKey()
  final bool lastPurchaseSuccess;
  final List<Package> _availablePackages;
  @override
  @JsonKey()
  List<Package> get availablePackages {
    if (_availablePackages is EqualUnmodifiableListView)
      return _availablePackages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availablePackages);
  }

  @override
  final CustomerInfo? customerInfo;
  @override
  @JsonKey()
  final bool hasPremium;
  @override
  @JsonKey()
  final bool hasPro;
  @override
  @JsonKey()
  final bool isAdFree;
  @override
  @JsonKey()
  final SubscriptionStatus subscriptionStatus;
  @override
  final DateTime? premiumExpirationDate;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PurchaseState(status: $status, isInitialized: $isInitialized, purchaseInProgress: $purchaseInProgress, lastPurchaseSuccess: $lastPurchaseSuccess, availablePackages: $availablePackages, customerInfo: $customerInfo, hasPremium: $hasPremium, hasPro: $hasPro, isAdFree: $isAdFree, subscriptionStatus: $subscriptionStatus, premiumExpirationDate: $premiumExpirationDate, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.purchaseInProgress, purchaseInProgress) ||
                other.purchaseInProgress == purchaseInProgress) &&
            (identical(other.lastPurchaseSuccess, lastPurchaseSuccess) ||
                other.lastPurchaseSuccess == lastPurchaseSuccess) &&
            const DeepCollectionEquality().equals(
              other._availablePackages,
              _availablePackages,
            ) &&
            (identical(other.customerInfo, customerInfo) ||
                other.customerInfo == customerInfo) &&
            (identical(other.hasPremium, hasPremium) ||
                other.hasPremium == hasPremium) &&
            (identical(other.hasPro, hasPro) || other.hasPro == hasPro) &&
            (identical(other.isAdFree, isAdFree) ||
                other.isAdFree == isAdFree) &&
            (identical(other.subscriptionStatus, subscriptionStatus) ||
                other.subscriptionStatus == subscriptionStatus) &&
            (identical(other.premiumExpirationDate, premiumExpirationDate) ||
                other.premiumExpirationDate == premiumExpirationDate) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    isInitialized,
    purchaseInProgress,
    lastPurchaseSuccess,
    const DeepCollectionEquality().hash(_availablePackages),
    customerInfo,
    hasPremium,
    hasPro,
    isAdFree,
    subscriptionStatus,
    premiumExpirationDate,
    errorMessage,
  );

  /// Create a copy of PurchaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseStateImplCopyWith<_$PurchaseStateImpl> get copyWith =>
      __$$PurchaseStateImplCopyWithImpl<_$PurchaseStateImpl>(this, _$identity);
}

abstract class _PurchaseState implements PurchaseState {
  const factory _PurchaseState({
    final Status status,
    final bool isInitialized,
    final bool purchaseInProgress,
    final bool lastPurchaseSuccess,
    final List<Package> availablePackages,
    final CustomerInfo? customerInfo,
    final bool hasPremium,
    final bool hasPro,
    final bool isAdFree,
    final SubscriptionStatus subscriptionStatus,
    final DateTime? premiumExpirationDate,
    final String? errorMessage,
  }) = _$PurchaseStateImpl;

  @override
  Status get status;
  @override
  bool get isInitialized;
  @override
  bool get purchaseInProgress;
  @override
  bool get lastPurchaseSuccess;
  @override
  List<Package> get availablePackages;
  @override
  CustomerInfo? get customerInfo;
  @override
  bool get hasPremium;
  @override
  bool get hasPro;
  @override
  bool get isAdFree;
  @override
  SubscriptionStatus get subscriptionStatus;
  @override
  DateTime? get premiumExpirationDate;
  @override
  String? get errorMessage;

  /// Create a copy of PurchaseState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseStateImplCopyWith<_$PurchaseStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthState {
  AuthStatus get authStatus => throw _privateConstructorUsedError;
  Status get status => throw _privateConstructorUsedError;
  AuthModel get authModel =>
      throw _privateConstructorUsedError; // New fields for social login
  User? get currentUser => throw _privateConstructorUsedError;
  LoginResponseModel? get socialLoginResult =>
      throw _privateConstructorUsedError;
  LoginType get loginType => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call({
    AuthStatus authStatus,
    Status status,
    AuthModel authModel,
    User? currentUser,
    LoginResponseModel? socialLoginResult,
    LoginType loginType,
    String? errorMessage,
  });

  $AuthModelCopyWith<$Res> get authModel;
  $LoginResponseModelCopyWith<$Res>? get socialLoginResult;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authStatus = null,
    Object? status = null,
    Object? authModel = null,
    Object? currentUser = freezed,
    Object? socialLoginResult = freezed,
    Object? loginType = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            authStatus: null == authStatus
                ? _value.authStatus
                : authStatus // ignore: cast_nullable_to_non_nullable
                      as AuthStatus,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as Status,
            authModel: null == authModel
                ? _value.authModel
                : authModel // ignore: cast_nullable_to_non_nullable
                      as AuthModel,
            currentUser: freezed == currentUser
                ? _value.currentUser
                : currentUser // ignore: cast_nullable_to_non_nullable
                      as User?,
            socialLoginResult: freezed == socialLoginResult
                ? _value.socialLoginResult
                : socialLoginResult // ignore: cast_nullable_to_non_nullable
                      as LoginResponseModel?,
            loginType: null == loginType
                ? _value.loginType
                : loginType // ignore: cast_nullable_to_non_nullable
                      as LoginType,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthModelCopyWith<$Res> get authModel {
    return $AuthModelCopyWith<$Res>(_value.authModel, (value) {
      return _then(_value.copyWith(authModel: value) as $Val);
    });
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LoginResponseModelCopyWith<$Res>? get socialLoginResult {
    if (_value.socialLoginResult == null) {
      return null;
    }

    return $LoginResponseModelCopyWith<$Res>(_value.socialLoginResult!, (
      value,
    ) {
      return _then(_value.copyWith(socialLoginResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
    _$AuthStateImpl value,
    $Res Function(_$AuthStateImpl) then,
  ) = __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AuthStatus authStatus,
    Status status,
    AuthModel authModel,
    User? currentUser,
    LoginResponseModel? socialLoginResult,
    LoginType loginType,
    String? errorMessage,
  });

  @override
  $AuthModelCopyWith<$Res> get authModel;
  @override
  $LoginResponseModelCopyWith<$Res>? get socialLoginResult;
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
    _$AuthStateImpl _value,
    $Res Function(_$AuthStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authStatus = null,
    Object? status = null,
    Object? authModel = null,
    Object? currentUser = freezed,
    Object? socialLoginResult = freezed,
    Object? loginType = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$AuthStateImpl(
        authStatus: null == authStatus
            ? _value.authStatus
            : authStatus // ignore: cast_nullable_to_non_nullable
                  as AuthStatus,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as Status,
        authModel: null == authModel
            ? _value.authModel
            : authModel // ignore: cast_nullable_to_non_nullable
                  as AuthModel,
        currentUser: freezed == currentUser
            ? _value.currentUser
            : currentUser // ignore: cast_nullable_to_non_nullable
                  as User?,
        socialLoginResult: freezed == socialLoginResult
            ? _value.socialLoginResult
            : socialLoginResult // ignore: cast_nullable_to_non_nullable
                  as LoginResponseModel?,
        loginType: null == loginType
            ? _value.loginType
            : loginType // ignore: cast_nullable_to_non_nullable
                  as LoginType,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AuthStateImpl implements _AuthState {
  const _$AuthStateImpl({
    this.authStatus = AuthStatus.initial,
    this.status = Status.initial,
    this.authModel = const AuthModel(),
    this.currentUser,
    this.socialLoginResult,
    this.loginType = LoginType.unknown,
    this.errorMessage,
  });

  @override
  @JsonKey()
  final AuthStatus authStatus;
  @override
  @JsonKey()
  final Status status;
  @override
  @JsonKey()
  final AuthModel authModel;
  // New fields for social login
  @override
  final User? currentUser;
  @override
  final LoginResponseModel? socialLoginResult;
  @override
  @JsonKey()
  final LoginType loginType;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AuthState(authStatus: $authStatus, status: $status, authModel: $authModel, currentUser: $currentUser, socialLoginResult: $socialLoginResult, loginType: $loginType, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.authStatus, authStatus) ||
                other.authStatus == authStatus) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.authModel, authModel) ||
                other.authModel == authModel) &&
            (identical(other.currentUser, currentUser) ||
                other.currentUser == currentUser) &&
            (identical(other.socialLoginResult, socialLoginResult) ||
                other.socialLoginResult == socialLoginResult) &&
            (identical(other.loginType, loginType) ||
                other.loginType == loginType) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    authStatus,
    status,
    authModel,
    currentUser,
    socialLoginResult,
    loginType,
    errorMessage,
  );

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);
}

abstract class _AuthState implements AuthState {
  const factory _AuthState({
    final AuthStatus authStatus,
    final Status status,
    final AuthModel authModel,
    final User? currentUser,
    final LoginResponseModel? socialLoginResult,
    final LoginType loginType,
    final String? errorMessage,
  }) = _$AuthStateImpl;

  @override
  AuthStatus get authStatus;
  @override
  Status get status;
  @override
  AuthModel get authModel; // New fields for social login
  @override
  User? get currentUser;
  @override
  LoginResponseModel? get socialLoginResult;
  @override
  LoginType get loginType;
  @override
  String? get errorMessage;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

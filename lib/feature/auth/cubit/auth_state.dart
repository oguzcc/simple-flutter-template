part of 'auth_cubit.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus authStatus,
    @Default(Status.initial) Status status,
    @Default(AuthModel()) AuthModel authModel,
    // New fields for social login
    User? currentUser,
    LoginResponseModel? socialLoginResult,
    @Default(LoginType.unknown) LoginType loginType,
    String? errorMessage,
  }) = _AuthState;
}

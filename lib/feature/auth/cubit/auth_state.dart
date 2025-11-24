part of 'auth_cubit.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.authStatus = AuthStatus.initial,
    this.status = Status.initial,
    this.authModel = const AuthModel(),
    this.currentUser,
    this.socialLoginResult,
    this.loginType = LoginType.unknown,
    this.errorMessage,
  });

  final AuthStatus authStatus;
  final Status status;
  final AuthModel authModel;
  final User? currentUser;
  final LoginResponseModel? socialLoginResult;
  final LoginType loginType;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        authStatus,
        status,
        authModel,
        currentUser,
        socialLoginResult,
        loginType,
        errorMessage,
      ];

  AuthState copyWith({
    AuthStatus? authStatus,
    Status? status,
    AuthModel? authModel,
    User? currentUser,
    LoginResponseModel? socialLoginResult,
    LoginType? loginType,
    String? errorMessage,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      status: status ?? this.status,
      authModel: authModel ?? this.authModel,
      currentUser: currentUser ?? this.currentUser,
      socialLoginResult: socialLoginResult ?? this.socialLoginResult,
      loginType: loginType ?? this.loginType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

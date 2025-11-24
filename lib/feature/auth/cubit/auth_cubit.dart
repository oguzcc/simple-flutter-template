import 'dart:developer';

import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:daisy/core/enum/common_enum.dart';
import 'package:daisy/core/manager/firebase/social_login_service.dart';
import 'package:daisy/data/dto/auth/req_sign_in_dto.dart';
import 'package:daisy/data/dto/auth/req_sign_up_dto.dart';
import 'package:daisy/data/model/auth/login_response_model.dart';
import 'package:daisy/data/model/auth_model.dart';
import 'package:daisy/data/service/auth_service.dart';
// New imports for social login
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

/// Enhanced Auth Cubit with social login capabilities
/// 
/// Features:
/// - Traditional email/password authentication
/// - Social login (Apple, Google, Anonymous)
/// - Firebase Auth state monitoring
/// - Comprehensive error handling
class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit(this._authService, this._socialLoginService) : super(const AuthState()) {
    log('🔧 AuthCubit constructor, current state: $state');
    _initializeAuthListener();
  }
  
  final IAuthService _authService;
  final SocialLoginService _socialLoginService;
  final AnalyticsService _analytics = AnalyticsService.instance;

  /// Initialize Firebase Auth state listener
  void _initializeAuthListener() {
    _socialLoginService.authStateChanges.listen((User? user) {
      // Development bypass durumunda Firebase listener'ı ignore et
      if (state.authStatus == AuthStatus.authenticated && 
          state.loginType == LoginType.anonymous && 
          user == null) {
        log('🔧 Ignoring Firebase null user - development bypass active');
        return;
      }
      
      if (user != null) {
        log('👤 User authenticated: ${user.uid}');
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          status: Status.success,
          currentUser: user,
          loginType: _socialLoginService.getCurrentLoginType(),
        ),);
      } else {
        log('👤 User signed out');
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          status: Status.initial,
          currentUser: null,
          loginType: LoginType.unknown,
          errorMessage: null,
        ),);
      }
    });
  }

  /// Check initial authentication state
  Future<void> authenticate() async {
    if (_socialLoginService.isSignedIn) {
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        currentUser: _socialLoginService.currentUser,
        loginType: _socialLoginService.getCurrentLoginType(),
      ),);
    } else {
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
    }
  }

  /// Traditional email/password sign in (existing functionality)
  Future<void> signIn(ReqSignInDto req) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));
    final res = await _authService.signIn(req);
    res.fold(
      (l) => emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Sign in failed. Please check your credentials.',
      ),),
      (r) => emit(state.copyWith(
        status: Status.success,
        authModel: r,
        authStatus: AuthStatus.authenticated,
      ),),
    );
  }

  /// Traditional email/password sign up (existing functionality)
  Future<void> signUp(ReqSignUpDto req) async {
    emit(state.copyWith(status: Status.loading, errorMessage: null));
    final res = await _authService.signUp(req);
    res.fold(
      (l) => emit(state.copyWith(
        status: Status.error,
        errorMessage: 'Sign up failed. Please try again.',
      ),),
      (r) => emit(state.copyWith(
        status: Status.success,
        authModel: r,
        authStatus: AuthStatus.authenticated,
      ),),
    );
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    emit(state.copyWith(
      status: Status.loading,
      authStatus: AuthStatus.authenticating,
      errorMessage: null,
    ),);

    try {
      final result = await _socialLoginService.signInWithApple();
      
      if (result.isSuccess) {
        log('✅ Apple sign in successful');
        
        // Track successful sign in
        await _analytics.trackSignIn('apple');
        
        emit(state.copyWith(
          status: Status.success,
          authStatus: AuthStatus.authenticated,
          socialLoginResult: result,
          loginType: LoginType.apple,
        ),);
      } else {
        log('❌ Apple sign in failed: ${result.message}');
        
        // Don't show error for user cancelled action
        if (result.errorCode != 'user-cancelled') {
          emit(state.copyWith(
            status: Status.error,
            authStatus: AuthStatus.unauthenticated,
            errorMessage: result.message,
            socialLoginResult: result,
          ),);
        } else {
          // User cancelled - return to initial state
          emit(state.copyWith(
            status: Status.initial,
            authStatus: AuthStatus.unauthenticated,
            socialLoginResult: result,
          ),);
        }
      }
    } catch (e) {
      log('❌ Unexpected error in Apple sign in: $e');
      emit(state.copyWith(
        status: Status.error,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ),);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(
      status: Status.loading,
      authStatus: AuthStatus.authenticating,
      errorMessage: null,
    ),);

    try {
      final result = await _socialLoginService.signInWithGoogle();
      
      if (result.isSuccess) {
        log('✅ Google sign in successful');
        
        // Track successful sign in
        await _analytics.trackSignIn('google');
        
        emit(state.copyWith(
          status: Status.success,
          authStatus: AuthStatus.authenticated,
          socialLoginResult: result,
          loginType: LoginType.google,
        ),);
      } else {
        log('❌ Google sign in failed: ${result.message}');
        
        // Don't show error for user cancelled action
        if (result.errorCode != 'user-cancelled') {
          emit(state.copyWith(
            status: Status.error,
            authStatus: AuthStatus.unauthenticated,
            errorMessage: result.message,
            socialLoginResult: result,
          ),);
        } else {
          // User cancelled - return to initial state
          emit(state.copyWith(
            status: Status.initial,
            authStatus: AuthStatus.unauthenticated,
            socialLoginResult: result,
          ),);
        }
      }
    } catch (e) {
      log('❌ Unexpected error in Google sign in: $e');
      emit(state.copyWith(
        status: Status.error,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ),);
    }
  }

  /// Sign in anonymously (as guest)
  Future<void> signInAnonymously() async {
    emit(state.copyWith(
      status: Status.loading,
      authStatus: AuthStatus.authenticating,
      errorMessage: null,
    ),);

    try {
      final result = await _socialLoginService.signInAnonymously();
      
      if (result.isSuccess) {
        log('✅ Anonymous sign in successful');
        
        // Track successful sign in
        await _analytics.trackSignIn('anonymous');
        
        emit(state.copyWith(
          status: Status.success,
          authStatus: AuthStatus.authenticated,
          socialLoginResult: result,
          loginType: LoginType.anonymous,
        ),);
      } else {
        log('❌ Anonymous sign in failed: ${result.message}');
        emit(state.copyWith(
          status: Status.error,
          authStatus: AuthStatus.unauthenticated,
          errorMessage: result.message,
          socialLoginResult: result,
        ),);
      }
    } catch (e) {
      log('❌ Unexpected error in anonymous sign in: $e');
      emit(state.copyWith(
        status: Status.error,
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ),);
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _socialLoginService.signOut();
      log('✅ Sign out successful');
      
      // Track sign out
      await _analytics.trackEvent('sign_out');
      
      // Reset user data in analytics
      await _analytics.resetUser();
      
      emit(state.copyWith(
        status: Status.initial,
        authStatus: AuthStatus.unauthenticated,
        authModel: const AuthModel(),
        currentUser: null,
        socialLoginResult: null,
        loginType: LoginType.unknown,
        errorMessage: null,
      ),);
    } catch (e) {
      log('❌ Error during sign out: $e');
      // Even if sign out fails, clear local state
      emit(state.copyWith(
        status: Status.initial,
        authStatus: AuthStatus.unauthenticated,
        authModel: const AuthModel(),
        currentUser: null,
        socialLoginResult: null,
        loginType: LoginType.unknown,
        errorMessage: null,
      ),);
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null, status: Status.initial));
  }

  /// Get current user display name
  String get userDisplayName {
    if (state.currentUser != null) {
      return state.currentUser!.displayName ?? 
             state.currentUser!.email ?? 
             'User';
    }
    
    if (state.socialLoginResult?.isSuccess ?? false) {
      return state.socialLoginResult!.displayName;
    }
    
    return 'Unknown User';
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state.authStatus == AuthStatus.authenticated;

  /// Check if using anonymous login
  bool get isAnonymous => state.loginType == LoginType.anonymous;

  /// Set development authenticated state (for bypass)
  void setDevAuthenticated() {
    log('🔧 Setting development authenticated state');
    emit(state.copyWith(
      authStatus: AuthStatus.authenticated,
      loginType: LoginType.anonymous,
      status: Status.success,
      errorMessage: null,
    ));
    log('✅ Development authenticated state set: ${state.authStatus}');
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    // Only persist authentication state, not temporary UI states
    final json = {
      'authStatus': state.authStatus.name,
      'loginType': state.loginType.name,
      // Don't persist currentUser or other Firebase objects
    };
    log('💾 Persisting auth state: $json');
    return json;
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final authStatusStr = json['authStatus']?.toString() ?? 'initial';
      final loginTypeStr = json['loginType']?.toString() ?? 'unknown';
      
      log('📁 Restoring auth state from storage: $json');
      final restoredState = AuthState(
        authStatus: AuthStatus.values.byName(authStatusStr),
        loginType: LoginType.values.byName(loginTypeStr),
        // Other fields will use default values
      );
      log('✅ Auth state restored: authStatus=${restoredState.authStatus}, loginType=${restoredState.loginType}');
      return restoredState;
    } on Exception catch (e) {
      log('❌ Failed to restore auth state: $e');
      // If there's an error, return null to use initial state
      return null;
    }
  }

  @override
  Future<void> close() {
    _socialLoginService.dispose();
    return super.close();
  }
}

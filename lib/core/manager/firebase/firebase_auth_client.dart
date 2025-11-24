import 'dart:developer';

import 'package:daisy/core/manager/firebase/model/res_social_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthException implements Exception {
  AuthException({required this.message, required this.code});
  final String message;
  final String code;
}

class AuthConfig {
  static const String successMessage = 'You have successfully Logged In';
  static const String unexpectedErrorMessage =
      'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String firebaseFailureMessage =
      'Firebase oturum açma işlemi başarısız oldu.';
}

class SocialLoginService {
  factory SocialLoginService() => _instance;
  SocialLoginService._internal();
  static final SocialLoginService _instance = SocialLoginService._internal();

  late FirebaseAuth firebaseAuth;

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Apple Login
  Future<ResSocialLogin> appleLogin() async {
    try {
      final appleCredential = await _getAppleCredential();
      final authCredential = _createAppleAuthCredential(appleCredential);
      final userCredential = await _signInWithFirebase(authCredential);

      return _createAppleSuccessResponse(userCredential.user, appleCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      return _handleAppleAuthError(e);
    } on PlatformException catch (e) {
      return ResSocialLogin(
        status: false,
        message: 'Sistem hatası: ${e.message}',
      );
    } catch (e) {
      return ResSocialLogin(
        status: false,
        message: AuthConfig.unexpectedErrorMessage,
      );
    }
  }

  Future<AuthorizationCredentialAppleID> _getAppleCredential() async {
    return SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
  }

  AuthCredential _createAppleAuthCredential(
    AuthorizationCredentialAppleID credential,
  ) {
    return OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );
  }

  Future<UserCredential> _signInWithFirebase(AuthCredential credential) async {
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  ResSocialLogin _createAppleSuccessResponse(
    User? user,
    AuthorizationCredentialAppleID appleCredential,
  ) {
    if (user != null) {
      return ResSocialLogin(
        message: AuthConfig.successMessage,
        status: true,
        loginType: LoginType.apple,
        emailAddress: user.email ?? '',
        socialId: user.uid,
        image: user.photoURL ?? '',
        name:
            '${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}'
                .trim(),
      );
    } else {
      return ResSocialLogin(
        status: false,
        message: AuthConfig.firebaseFailureMessage,
      );
    }
  }

  ResSocialLogin _handleAppleAuthError(
    SignInWithAppleAuthorizationException e,
  ) {
    String errorMessage;
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        errorMessage = 'Giriş işlemi iptal edildi.';
      case AuthorizationErrorCode.failed:
        errorMessage = 'Kimlik doğrulama başarısız oldu.';
      case AuthorizationErrorCode.invalidResponse:
        errorMessage = 'Geçersiz yanıt alındı.';
      case AuthorizationErrorCode.notHandled:
        errorMessage = 'İstek işlenemedi.';
      case AuthorizationErrorCode.unknown:
        errorMessage = 'Bilinmeyen bir hata oluştu.';
      case AuthorizationErrorCode.notInteractive:
        errorMessage = 'Apple ile giriş sırasında bir hata oluştu.';
      case AuthorizationErrorCode.credentialExport:
        errorMessage = 'Apple kimlik bilgisi dışa aktarma hatası.';
      default:
        errorMessage = 'Apple ile giriş sırasında bilinmeyen hata oluştu.';
    }
    return ResSocialLogin(status: false, message: errorMessage);
  }

  // Google Login
  Future<ResSocialLogin> googleLogin() async {
    try {
      await _ensureGoogleSignOut();
      final account = await _initializeAndSignIn();

      if (account == null) {
        throw AuthException(
          message: 'Google oturum açma işlemi iptal edildi.',
          code: 'GOOGLE_SIGN_IN_CANCELLED',
        );
      }

      final googleAuth = account.authentication;
      final credential = _createGoogleAuthCredential(googleAuth);
      final userCredential = await _signInWithFirebase(credential);

      return _createGoogleSuccessResponse(userCredential.user);
    } catch (e) {
      log('Error signing in with Google: $e');
      return ResSocialLogin(
        status: false,
        message: AuthConfig.unexpectedErrorMessage,
      );
    }
  }

  Future<void> _ensureGoogleSignOut() async {
    await _googleSignIn.signOut();
  }

  Future<GoogleSignInAccount?> _initializeAndSignIn() async {
    return _googleSignIn.authenticate();
  }

  AuthCredential _createGoogleAuthCredential(GoogleSignInAuthentication auth) {
    return GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );
  }

  ResSocialLogin _createGoogleSuccessResponse(User? user) {
    if (user != null) {
      log(user.email ?? '');
      return ResSocialLogin(
        message: AuthConfig.successMessage,
        status: true,
        loginType: LoginType.google,
        emailAddress: user.email ?? '',
        socialId: user.uid,
        image: user.photoURL ?? '',
        name: user.displayName ?? '',
      );
    } else {
      return ResSocialLogin(
        status: false,
        message: AuthConfig.firebaseFailureMessage,
      );
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}

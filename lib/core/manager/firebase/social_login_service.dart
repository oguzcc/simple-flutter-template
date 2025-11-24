import 'dart:developer';

import 'package:daisy/core/config/auth_config.dart';
import 'package:daisy/data/model/auth/login_response_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Comprehensive Social Login Service with production-ready error handling
/// 
/// Features:
/// - Apple Sign In with Firebase integration
/// - Google Sign In with Firebase integration  
/// - Anonymous Sign In
/// - Comprehensive error handling and logging
/// - Dummy credential warnings for development
/// - Production-ready architecture
class SocialLoginService {
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  
  /// Initialize Google Sign In with proper scopes
  Future<void> _initializeGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  /// Sign in with Apple
  /// 
  /// Handles complete Apple Sign In flow including:
  /// - Apple ID credential request
  /// - Firebase credential creation
  /// - Firebase authentication
  /// - Comprehensive error handling
  Future<LoginResponseModel> signInWithApple() async {
    try {
      // Development mode warning
      if (kDebugMode && AuthConfig.isDummyMode) {
        log('⚠️ Using dummy Apple credentials - login will fail in production');
        log(AuthConfig.dummyModeWarning);
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: kIsWeb 
          ? WebAuthenticationOptions(
              clientId: AuthConfig.dummyAppleServiceId,
              redirectUri: Uri.parse('https://your-domain.com/auth/callback'),
            )
          : null,
      );

      // Create Firebase credential from Apple credential
      final AuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Log successful authentication
        log('✅ Apple Sign In successful for user: ${user.uid}');
        
        return LoginResponseModel.success(
          emailAddress: user.email ?? '',
          socialId: user.uid,
          loginType: LoginType.apple,
          name: '${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}'.trim(),
          image: user.photoURL ?? '',
          message: 'Successfully signed in with Apple',
          metadata: {
            'provider': 'apple.com',
            'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        throw Exception('Firebase authentication failed - no user returned');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle Apple-specific errors
      String errorMessage;
      String errorCode;
      
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          errorMessage = 'Apple Sign In was cancelled';
          errorCode = 'user-cancelled';
        case AuthorizationErrorCode.failed:
          errorMessage = 'Apple Sign In failed';
          errorCode = 'apple-signin-failed';
        case AuthorizationErrorCode.invalidResponse:
          errorMessage = 'Invalid response from Apple';
          errorCode = 'invalid-response';
        case AuthorizationErrorCode.notHandled:
          errorMessage = 'Apple Sign In request not handled';
          errorCode = 'not-handled';
        case AuthorizationErrorCode.unknown:
          errorMessage = 'Unknown Apple Sign In error';
          errorCode = 'unknown';
        case AuthorizationErrorCode.notInteractive:
          errorMessage = 'Apple Sign In error: ${e.message}';
          errorCode = 'apple-signin-error';
        case AuthorizationErrorCode.credentialExport:
          errorMessage = 'Apple Sign In credential export error';
          errorCode = 'credential-export-error';
        case AuthorizationErrorCode.credentialImport:
          errorMessage = 'Apple Sign In credential import error';
          errorCode = 'credential-import-error';
        case AuthorizationErrorCode.matchedExcludedCredential:
          errorMessage = 'Apple Sign In matched excluded credential error';
          errorCode = 'matched-excluded-credential';
        default:
          errorMessage = 'Apple Sign In error: ${e.message}';
          errorCode = 'apple-signin-error';
      }
      
      log('❌ Apple Sign In error: $errorCode - $errorMessage');
      return LoginResponseModel.error(
        message: errorMessage,
        errorCode: errorCode,
        loginType: LoginType.apple,
      );
    } on PlatformException catch (e) {
      log('❌ Platform exception during Apple Sign In: ${e.message}');
      return LoginResponseModel.error(
        message: 'System error: ${e.message}',
        errorCode: 'platform-error',
        loginType: LoginType.apple,
      );
    } on FirebaseAuthException catch (e) {
      log('❌ Firebase Auth exception: ${e.code} - ${e.message}');
      return LoginResponseModel.error(
        message: AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
        loginType: LoginType.apple,
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error during Apple Sign In: $e');
      log('Stack trace: $stackTrace');
      return LoginResponseModel.error(
        message: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown',
        loginType: LoginType.apple,
      );
    }
  }

  /// Sign in with Google
  /// 
  /// Handles complete Google Sign In flow including:
  /// - Google account selection
  /// - Authentication token retrieval
  /// - Firebase credential creation
  /// - Firebase authentication
  Future<LoginResponseModel> signInWithGoogle() async {
    try {
      // Development mode warning
      if (kDebugMode && AuthConfig.isDummyMode) {
        log('⚠️ Using dummy Google credentials - login will fail in production');
        log(AuthConfig.dummyModeWarning);
      }

      // Initialize Google Sign In
      await _initializeGoogleSignIn();
      
      // Sign out from previous session to force account selection  
      await _googleSignIn.signOut();

      // Trigger Google Sign In flow
      final account = await _googleSignIn.authenticate();
      if (account == null) {
        log('ℹ️ Google Sign In was cancelled by user');
        return LoginResponseModel.error(
          message: 'Google Sign In was cancelled',
          errorCode: 'user-cancelled',
          loginType: LoginType.google,
        );
      }

      // Get authentication details (synchronous in v7.x)
      final googleAuth = account.authentication;

      // Create Firebase credential (v7.x only needs idToken)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        log('✅ Google Sign In successful for user: ${user.uid}');
        
        return LoginResponseModel.success(
          emailAddress: user.email ?? account.email,
          socialId: user.uid,
          loginType: LoginType.google,
          name: user.displayName ?? account.displayName ?? '',
          image: user.photoURL ?? account.photoUrl ?? '',
          message: 'Successfully signed in with Google',
          metadata: {
            'provider': 'google.com',
            'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
            'googleId': account.id,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        throw Exception('Firebase authentication failed - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      log('❌ Firebase Auth exception during Google Sign In: ${e.code} - ${e.message}');
      return LoginResponseModel.error(
        message: AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
        loginType: LoginType.google,
      );
    } on PlatformException catch (e) {
      log('❌ Platform exception during Google Sign In: ${e.message}');
      return LoginResponseModel.error(
        message: 'System error: ${e.message}',
        errorCode: 'platform-error',
        loginType: LoginType.google,
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error during Google Sign In: $e');
      log('Stack trace: $stackTrace');
      return LoginResponseModel.error(
        message: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown',
        loginType: LoginType.google,
      );
    }
  }

  /// Sign in anonymously
  /// 
  /// Creates an anonymous Firebase account for guest users
  Future<LoginResponseModel> signInAnonymously() async {
    try {
      log('ℹ️ Starting anonymous sign in');
      
      final userCredential =
          await FirebaseAuth.instance.signInAnonymously();
          
      final user = userCredential.user;
      if (user != null) {
        log('✅ Anonymous sign in successful for user: ${user.uid}');
        
        return LoginResponseModel.success(
          emailAddress: '',
          socialId: user.uid,
          loginType: LoginType.anonymous,
          name: 'Anonymous User',
          message: 'Successfully signed in as guest',
          metadata: {
            'provider': 'anonymous',
            'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        throw Exception('Firebase anonymous authentication failed - no user returned');
      }
    } on FirebaseAuthException catch (e) {
      log('❌ Firebase Auth exception during anonymous sign in: ${e.code} - ${e.message}');
      return LoginResponseModel.error(
        message: AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
        loginType: LoginType.anonymous,
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error during anonymous sign in: $e');
      log('Stack trace: $stackTrace');
      return LoginResponseModel.error(
        message: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown',
        loginType: LoginType.anonymous,
      );
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      log('ℹ️ Starting sign out process');
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      log('✅ Signed out from Google');
      
      log('✅ Sign out completed successfully');
    } catch (e) {
      log('❌ Error during sign out: $e');
      // Don't throw error for sign out failures - just log them
    }
  }

  /// Get current authenticated user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Check if user is currently signed in
  bool get isSignedIn => currentUser != null;

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  /// Get current login type based on Firebase user providers
  LoginType getCurrentLoginType() {
    final user = currentUser;
    if (user == null) return LoginType.unknown;
    
    if (user.isAnonymous) return LoginType.anonymous;
    
    for (final provider in user.providerData) {
      switch (provider.providerId) {
        case 'google.com':
          return LoginType.google;
        case 'apple.com':
          return LoginType.apple;
        case 'password':
          return LoginType.email;
        case 'facebook.com':
          return LoginType.facebook;
      }
    }
    
    return LoginType.unknown;
  }

  /// Dispose resources
  void dispose() {
    // Clean up any resources if needed
  }
}

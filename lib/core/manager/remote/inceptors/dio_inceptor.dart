import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandlerInceptor extends Interceptor {
  ErrorHandlerInceptor(this.dio, this.context);
  final Dio dio;
  final BuildContext context;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if the error message contains any of the specified keywords
    // if ([
    //   'auth',
    //   'otp',
    //   'verify',
    //   'jwt expired',
    // ].any(
    //   (path) =>
    //       (err.response?.data['message']?.contains(path) ?? false) as bool,
    // )) {
    //   // Perform logout and redirect to login page
    //   _handleLogout();

    //   return handler.resolve(err.response!);
    // }

    if (err.response?.statusCode == 401 ||
        err.response?.statusCode == 403 ||
        err.response?.statusCode == 404) {
      // Perform logout and redirect to login page
      _handleLogout();

      return handler.resolve(err.response!);
    }

    return super.onError(err, handler);
  }

  void _handleLogout() {
    try {
      // Implement logout logic when user is unauthorized
      // This typically happens when:
      // - Token has expired
      // - User session is invalid
      // - User has been logged out from another device

      // TODO: Inject AuthCubit or create a logout callback
      // For now, log the event - actual implementation needs:
      // 1. Clear local storage/cache
      // 2. Call AuthCubit.signOut() or similar
      // 3. Navigate to login screen
      // 4. Show appropriate error message to user

      // Example implementation (requires dependency injection):
      // final authCubit = GetIt.instance<AuthCubit>();
      // authCubit.signOut();
      // navigatorKey.currentState?.pushReplacementNamed('/login');

      debugPrint('⚠️ Logout triggered due to 401/403 authentication error');
      debugPrint('🔑 User needs to re-authenticate');
    } catch (e) {
      debugPrint('❌ Error handling logout: $e');
    }
  }
}

import 'package:daisy/core/manager/storage/secure_storage_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      const FlutterSecureStorage().delete(key: SecureKeys.token.name);
      // context.read<AuthCubit>().signOutWithRequest();
    } catch (e) {
      debugPrint('Error handling logout: $e');
    }
  }
}

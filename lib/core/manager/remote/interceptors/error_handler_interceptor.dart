import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef UnauthorizedHandler = Future<void> Function();

class ErrorHandlerInterceptor extends Interceptor {
  ErrorHandlerInterceptor({required this.onUnauthorized});

  final UnauthorizedHandler onUnauthorized;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    if (status == 401 || status == 403) {
      debugPrint('⚠️ Unauthorized ($status) — triggering logout');
      await onUnauthorized();
      if (err.response != null) {
        return handler.resolve(err.response!);
      }
    }

    return super.onError(err, handler);
  }
}

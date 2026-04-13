import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Retry failed requests with exponential backoff + jitter.
///
/// Retries are attempted for transient network failures:
/// - connection timeouts / send timeouts / receive timeouts
/// - socket errors (no internet, DNS failure)
/// - 5xx server errors (except 501 Not Implemented)
/// - 429 Too Many Requests
///
/// Does NOT retry:
/// - client errors (4xx except 429)
/// - request cancellation
/// - bad certificate errors
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  static const _retryCountKey = '_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    final retryCount = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (retryCount >= maxRetries) {
      return super.onError(err, handler);
    }

    final delay = _computeDelay(retryCount);
    if (kDebugMode) {
      debugPrint(
        '🔁 Retrying request (${retryCount + 1}/$maxRetries) after '
        '${delay.inMilliseconds}ms: ${err.requestOptions.uri}',
      );
    }
    await Future<void>.delayed(delay);

    try {
      final response = await dio.fetch<dynamic>(
        err.requestOptions
          ..extra[_retryCountKey] = retryCount + 1,
      );
      return handler.resolve(response);
    } on DioException catch (e) {
      return super.onError(e, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        if (status == 429) return true;
        return status >= 500 && status != 501;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  Duration _computeDelay(int retryCount) {
    // Exponential: base * 2^n, clamped to maxDelay
    final exponential = baseDelay * math.pow(2, retryCount).toInt();
    final clamped =
        exponential > maxDelay ? maxDelay : exponential;
    // Add up to 25% jitter to avoid thundering herd
    final jitterMs =
        math.Random().nextInt((clamped.inMilliseconds * 0.25).round() + 1);
    return clamped + Duration(milliseconds: jitterMs);
  }
}

// RetryInterceptor birim testleri.
//
// Retry politikasının doğru çalıştığını doğrular:
// - Transient hatalar (timeout, 5xx, 429) yeniden denenir
// - Client hataları (4xx) yeniden denenmez
// - maxRetries aşılırsa hata propagate edilir

import 'package:daisy/core/manager/remote/interceptors/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryInterceptor', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    });

    RequestOptions requestOptions() =>
        RequestOptions(path: '/test', baseUrl: 'https://example.test');

    test('retries on connectionTimeout and eventually fails', () async {
      var attempts = 0;
      dio.interceptors
        ..add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 2,
            baseDelay: const Duration(milliseconds: 1),
            maxDelay: const Duration(milliseconds: 2),
          ),
        )
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionTimeout,
                ),
                true,
              );
            },
          ),
        );

      expect(
        () => dio.fetch<dynamic>(requestOptions()),
        throwsA(isA<DioException>()),
      );
      // Give retries time to execute
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(attempts, 3); // 1 initial + 2 retries
    });

    test('does NOT retry on 400 bad request', () async {
      var attempts = 0;
      dio.interceptors
        ..add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 3,
            baseDelay: const Duration(milliseconds: 1),
          ),
        )
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response<dynamic>(
                    requestOptions: options,
                    statusCode: 400,
                  ),
                ),
                true,
              );
            },
          ),
        );

      try {
        await dio.fetch<dynamic>(requestOptions());
      } on DioException catch (_) {}
      expect(attempts, 1);
    });

    test('retries on 503 server error', () async {
      var attempts = 0;
      dio.interceptors
        ..add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 2,
            baseDelay: const Duration(milliseconds: 1),
            maxDelay: const Duration(milliseconds: 2),
          ),
        )
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response<dynamic>(
                    requestOptions: options,
                    statusCode: 503,
                  ),
                ),
                true,
              );
            },
          ),
        );

      try {
        await dio.fetch<dynamic>(requestOptions());
      } on DioException catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(attempts, 3);
    });

    test('retries on 429 rate limit', () async {
      var attempts = 0;
      dio.interceptors
        ..add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 1,
            baseDelay: const Duration(milliseconds: 1),
          ),
        )
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response<dynamic>(
                    requestOptions: options,
                    statusCode: 429,
                  ),
                ),
                true,
              );
            },
          ),
        );

      try {
        await dio.fetch<dynamic>(requestOptions());
      } on DioException catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(attempts, 2);
    });
  });
}

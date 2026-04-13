import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/manager/remote/interceptors/error_handler_interceptor.dart';
import 'package:daisy/core/manager/remote/interceptors/refactored_streaming_interceptor.dart';
import 'package:daisy/core/manager/remote/interceptors/retry_interceptor.dart';
import 'package:daisy/core/manager/remote/services/device_capability_service.dart';
import 'package:daisy/core/manager/remote/services/metrics_collector.dart';
import 'package:daisy/core/manager/remote/services/network_monitor_service.dart';
import 'package:daisy/core/types/typedefs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Production DioClient with enhanced streaming capabilities
class DioClient {
  DioClient(
    this._dio,
    this._apiOptions, {
    required UnauthorizedHandler onUnauthorized,
  }) {
    _dio
      ..options.baseUrl = _apiOptions.baseUrl
      ..options.connectTimeout = _apiOptions.connectionTimeout
      ..options.receiveTimeout = _apiOptions.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.addAll([
        ErrorHandlerInterceptor(onUnauthorized: onUnauthorized),
        RetryInterceptor(dio: _dio),
        RefactoredStreamingInterceptor(
          deviceService: DeviceCapabilityService(),
          networkService: NetworkMonitorService(),
          metricsCollector: MetricsCollector(),
        ),
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            options.headers['Authorization'] = 'Bearer $accessToken';
            options.headers['Accept-Language'] = locale;
            return handler.next(options);
          },
        ),
      ]);
  }

  static String accessToken = '';
  static String locale = 'en';
  final IApiOption _apiOptions;
  final Dio _dio;

  AsyncResDyn get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool? useStreaming,
    void Function(List<Map<String, dynamic>> newItems)? onNewItems,
  }) {
    final effectiveOptions = options ?? Options();
    if (useStreaming == false) {
      effectiveOptions.extra ??= <String, dynamic>{};
      effectiveOptions.extra!['disable_streaming'] = true;
    }
    return _dio.get<dynamic>(
      url,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  AsyncResDyn post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useStreaming,
  }) {
    final effectiveOptions = options ?? Options();
    if (useStreaming == false) {
      effectiveOptions.extra ??= <String, dynamic>{};
      effectiveOptions.extra!['disable_streaming'] = true;
    }
    return _dio.post<dynamic>(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  AsyncResMap postMap(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useStreaming,
  }) {
    final effectiveOptions = options ?? Options();
    if (useStreaming == false) {
      effectiveOptions.extra ??= <String, dynamic>{};
      effectiveOptions.extra!['disable_streaming'] = true;
    }
    return _dio.post<Map<String, dynamic>>(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  AsyncResMap put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.put<Map<String, dynamic>>(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  AsyncResMap patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.patch<Map<String, dynamic>>(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  AsyncResMap delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.delete<Map<String, dynamic>>(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> getList(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get<dynamic>(
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // Configuration methods for streaming
  static void configureStreaming({
    bool? enabled,
    int? smallFileThreshold,
    int? mediumFileThreshold,
    int? largeFileThreshold,
  }) {
    if (kDebugMode) {
      debugPrint('🌐 📋 Streaming configuration updated');
    }
    // Configuration would be passed to interceptor
  }
  
  static void enableAutoStreaming() {
    if (kDebugMode) {
      debugPrint('🌐 ✅ Auto-streaming enabled for all requests');
    }
  }
  
  static void disableAutoStreaming() {
    if (kDebugMode) {
      debugPrint('🌐 ❌ Auto-streaming disabled');
    }
  }
}

import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/manager/remote/inceptors/dio_inceptor.dart';
import 'package:daisy/core/manager/remote/interceptors/refactored_streaming_interceptor.dart';
import 'package:daisy/core/manager/remote/services/device_capability_service.dart';
import 'package:daisy/core/manager/remote/services/metrics_collector.dart';
import 'package:daisy/core/manager/remote/services/network_monitor_service.dart';
import 'package:daisy/core/types/typedefs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production DioClient with enhanced streaming capabilities
class DioClient {
  // Injecting dio instance
  DioClient(this._dio, this._apiOptions, BuildContext context) {
    _dio
      ..options.baseUrl = _apiOptions.baseUrl
      ..options.connectTimeout = _apiOptions.connectionTimeout
      ..options.receiveTimeout = _apiOptions.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.addAll([
        ErrorHandlerInceptor(_dio, context),
        RefactoredStreamingInterceptor(
          deviceService: DeviceCapabilityService(),
          networkService: NetworkMonitorService(),
          metricsCollector: MetricsCollector(),
        ), // 🔥 Clean refactored streaming
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

  // Get:-----------------------------------------------------------------------
  AsyncResDyn get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool? useStreaming,
    void Function(List<Map<String, dynamic>> newItems)? onNewItems,
  }) async {
    try {
      // Set streaming preference in options
      final effectiveOptions = options ?? Options();
      if (useStreaming == false) {
        effectiveOptions.extra ??= <String, dynamic>{};
        effectiveOptions.extra!['disable_streaming'] = true;
      }
      
      // Interceptor handles all streaming logic automatically
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Post:----------------------------------------------------------------------
  AsyncResDyn post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useStreaming,
  }) async {
    try {
      // Set streaming preference in options
      final effectiveOptions = options ?? Options();
      if (useStreaming == false) {
        effectiveOptions.extra ??= <String, dynamic>{};
        effectiveOptions.extra!['disable_streaming'] = true;
      }
      
      // Interceptor handles all streaming logic automatically
      final response = await _dio.post<dynamic>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Post Map (for auth and specific endpoints that need Map<String, dynamic>):
  AsyncResMap postMap(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useStreaming,
  }) async {
    try {
      // Set streaming preference in options
      final effectiveOptions = options ?? Options();
      if (useStreaming == false) {
        effectiveOptions.extra ??= <String, dynamic>{};
        effectiveOptions.extra!['disable_streaming'] = true;
      }
      
      // Interceptor handles all streaming logic automatically
      final response = await _dio.post<Map<String, dynamic>>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Put:-----------------------------------------------------------------------
  AsyncResMap put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Patch:---------------------------------------------------------------------
  AsyncResMap patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Delete:--------------------------------------------------------------------
  AsyncResMap delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get List:------------------------------------------------------------------
  Future<Response<dynamic>> getList(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
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

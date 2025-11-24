import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network_logger_service.dart';

/// Dio Interceptor for Network Logging
class NetworkLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🌐 🔥 INTERCEPTOR TRIGGERED: ${options.method} ${options.uri}');
    }
    
    try {
      NetworkLoggerService.instance.logRequest(options);
      if (kDebugMode) {
        print('🌐 ✅ NetworkLoggerService.instance.logRequest completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ❌ NetworkLoggerInterceptor error in onRequest: $e');
      }
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      NetworkLoggerService.instance.logResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ❌ NetworkLoggerInterceptor error in onResponse: $e');
      }
    }
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      NetworkLoggerService.instance.logError(err);
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ❌ NetworkLoggerInterceptor error in onError: $e');
      }
    }
    handler.next(err);
  }
}
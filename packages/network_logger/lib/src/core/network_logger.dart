import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'network_logger_service.dart';
import 'network_logger_overlay.dart';

/// Main NetworkLogger class for easy integration
class NetworkLogger {
  /// Initialize NetworkLogger with your app
  static void initialize(BuildContext context) {
    NetworkLoggerOverlay.attachTo(context);
  }
  
  /// Create a new Dio instance with NetworkLogger attached
  static Dio createDio({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    List<Interceptor>? interceptors,
    Map<String, dynamic>? headers,
  }) {
    return NetworkLoggerService.createDio(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      interceptors: interceptors,
      headers: headers,
    );
  }
  
  /// Attach NetworkLogger to existing Dio instance
  static void attachTo(Dio dio) {
    NetworkLoggerService.attachTo(dio);
  }
  
  /// Show network logs viewer
  static void showLogs(BuildContext context) {
    NetworkLoggerOverlay.showLogs(context);
  }
  
  /// Enable network logging
  static void enable() {
    NetworkLoggerService.instance.enable();
  }
  
  /// Disable network logging  
  static void disable() {
    NetworkLoggerService.instance.disable();
  }
  
  /// Clear all logs
  static void clearLogs() {
    NetworkLoggerService.instance.clearNetworkLogs();
  }
  
  /// Get logs count
  static int get logsCount => NetworkLoggerService.instance.networkLogsCount;
  
  /// Get all logs
  static List<dynamic> get logs => NetworkLoggerService.instance.networkLogs;
}
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/network_log_entry.dart';
import '../interceptors/network_logger_interceptor.dart';

/// Global Network Logger Service for HTTP request/response tracking
class NetworkLoggerService {
  static NetworkLoggerService? _instance;
  static NetworkLoggerService get instance {
    _instance ??= NetworkLoggerService._internal();
    return _instance!;
  }
  
  NetworkLoggerService._internal();
  
  // Configuration
  bool _isEnabled = true;
  Function(String)? _logCallback;
  
  // Network logs storage
  final List<NetworkLogEntry> _networkLogs = [];
  final int _maxLogs = 100;
  
  /// Network logging enabled status
  bool get isEnabled => _isEnabled;
  
  /// Gets all network logs
  List<NetworkLogEntry> get networkLogs => List.unmodifiable(_networkLogs);
  
  /// Gets network logs count
  int get networkLogsCount => _networkLogs.length;
  
  /// Creates a new Dio instance with NetworkLoggerInterceptor automatically attached
  static Dio createDio({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    List<Interceptor>? interceptors,
    Map<String, dynamic>? headers,
  }) {
    final dio = Dio();
    
    // Configure options
    if (baseUrl != null) dio.options.baseUrl = baseUrl;
    if (connectTimeout != null) dio.options.connectTimeout = connectTimeout;
    if (receiveTimeout != null) dio.options.receiveTimeout = receiveTimeout;
    if (headers != null) dio.options.headers.addAll(headers);
    
    // Add custom interceptors first
    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
    }
    
    // Always add NetworkLoggerInterceptor last
    dio.interceptors.add(NetworkLoggerInterceptor());
    
    if (kDebugMode) {
      debugPrint('🌐 NetworkLogger: New Dio created with ${dio.interceptors.length} interceptors');
    }
    
    return dio;
  }
  
  /// Attach NetworkLoggerInterceptor to existing Dio instance
  static void attachTo(Dio dio) {
    // Remove any existing NetworkLoggerInterceptor and add it LAST
    // This ensures it captures all headers added by other interceptors
    final hasLogger = dio.interceptors.any((i) => i is NetworkLoggerInterceptor);
    
    if (hasLogger) {
      // Remove existing and add it last
      dio.interceptors.removeWhere((i) => i is NetworkLoggerInterceptor);
      dio.interceptors.add(NetworkLoggerInterceptor());
      if (kDebugMode) {
        debugPrint('🌐 NetworkLogger: Moved to LAST position to capture all headers');
      }
    } else {
      // Add as last interceptor
      dio.interceptors.add(NetworkLoggerInterceptor());
      if (kDebugMode) {
        debugPrint('🌐 NetworkLogger: Attached LAST to capture all headers');
      }
    }
  }
  
  /// Enable network logging
  void enable() {
    _isEnabled = true;
    _log('🌐 ✅ Network logging ENABLED');
  }
  
  /// Disable network logging
  void disable() {
    _isEnabled = false;
    _log('🌐 ⛔ Network logging DISABLED');
  }
  
  /// Toggle network logging
  void toggle() {
    if (_isEnabled) {
      disable();
    } else {
      enable();
    }
  }
  
  /// Clear all network logs
  void clearNetworkLogs() {
    _networkLogs.clear();
    _log('🌐 🧹 Network logs cleared');
  }
  
  /// Set log callback for external logging
  void setLogCallback(Function(String) callback) {
    _logCallback = callback;
  }
  
  /// Clear log callback
  void clearLogCallback() {
    _logCallback = null;
  }
  
  /// Log HTTP Request
  void logRequest(RequestOptions options) {
    if (!_isEnabled) return;
    
    // Create and store structured log entry
    final logEntry = NetworkLogEntry.fromRequest(options);
    _addNetworkLog(logEntry);
    
    final method = options.method.toUpperCase();
    final uri = options.uri.toString();
    
    _log('🌐 ➡️ $method $uri');
    
    // Headers
    if (options.headers.isNotEmpty) {
      final filteredHeaders = _filterSensitiveHeaders(options.headers);
      if (filteredHeaders.isNotEmpty) {
        _log('🌐 📋 Headers: ${_formatHeaders(filteredHeaders)}');
      }
    }
    
    // Request body
    if (options.data != null) {
      final bodyPreview = _formatRequestBody(options.data);
      if (bodyPreview.isNotEmpty) {
        _log('🌐 📝 Body: $bodyPreview');
      }
    }
    
    // Query parameters
    if (options.queryParameters.isNotEmpty) {
      _log('🌐 🔍 Query: ${_formatQueryParams(options.queryParameters)}');
    }
  }
  
  /// Log HTTP Response
  void logResponse(Response response) {
    if (!_isEnabled) return;
    
    // Update structured log entry
    _updateNetworkLogWithResponse(response);
    
    final method = response.requestOptions.method.toUpperCase();
    final uri = response.requestOptions.uri.toString();
    final statusCode = response.statusCode ?? 0;
    final statusText = _getStatusText(statusCode);
    
    _log('🌐 ⬅️ $method $uri → $statusCode $statusText');
    
    // Response headers
    if (response.headers.map.isNotEmpty) {
      final contentType = response.headers.value('content-type');
      if (contentType != null) {
        _log('🌐 📄 Content-Type: $contentType');
      }
    }
    
    // Response body preview
    if (response.data != null) {
      final bodyPreview = _formatResponseBody(response.data);
      if (bodyPreview.isNotEmpty) {
        _log('🌐 📦 Response: $bodyPreview');
      }
    }
  }
  
  /// Log HTTP Error
  void logError(DioException error) {
    if (!_isEnabled) return;
    
    // Update structured log entry
    _updateNetworkLogWithError(error);
    
    final method = error.requestOptions.method.toUpperCase();
    final uri = error.requestOptions.uri.toString();
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        _log('🌐 ❌ $method $uri → Connection Timeout');
        break;
      case DioExceptionType.sendTimeout:
        _log('🌐 ❌ $method $uri → Send Timeout');
        break;
      case DioExceptionType.receiveTimeout:
        _log('🌐 ❌ $method $uri → Receive Timeout');
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final statusText = _getStatusText(statusCode);
        _log('🌐 ❌ $method $uri → $statusCode $statusText');
        break;
      case DioExceptionType.cancel:
        _log('🌐 ⚠️ $method $uri → Request Cancelled');
        break;
      case DioExceptionType.connectionError:
        _log('🌐 ❌ $method $uri → Connection Error');
        break;
      case DioExceptionType.unknown:
        _log('🌐 ❌ $method $uri → Unknown Error: ${error.message}');
        break;
      default:
        _log('🌐 ❌ $method $uri → ${error.type.toString()}');
    }
    
    // Error response body
    if (error.response?.data != null) {
      final errorBody = _formatResponseBody(error.response!.data);
      if (errorBody.isNotEmpty) {
        _log('🌐 💥 Error Details: $errorBody');
      }
    }
  }
  
  // Private helper methods
  
  void _addNetworkLog(NetworkLogEntry entry) {
    _networkLogs.add(entry); // Add to end (oldest first when displayed)
    if (_networkLogs.length > _maxLogs) {
      _networkLogs.removeAt(0); // Remove oldest
    }
  }
  
  void _updateNetworkLogWithResponse(Response response) {
    final requestHashCode = response.requestOptions.hashCode.abs().toString();
    final index = _networkLogs.indexWhere((log) => log.id.contains(requestHashCode));
    if (index >= 0) {
      _networkLogs[index] = _networkLogs[index].withResponse(response);
    }
  }
  
  void _updateNetworkLogWithError(DioException error) {
    final requestHashCode = error.requestOptions.hashCode.abs().toString();
    final index = _networkLogs.indexWhere((log) => log.id.contains(requestHashCode));
    if (index >= 0) {
      _networkLogs[index] = _networkLogs[index].withError(error);
    }
  }
  
  void _log(String message) {
    if (_logCallback != null) {
      _logCallback!(message);
    } else if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  Map<String, dynamic> _filterSensitiveHeaders(Map<String, dynamic> headers) {
    final sensitive = ['authorization', 'cookie', 'set-cookie', 'x-api-key', 'x-auth-token'];
    final filtered = <String, dynamic>{};
    
    headers.forEach((key, value) {
      if (sensitive.any((s) => key.toLowerCase().contains(s))) {
        filtered[key] = '***HIDDEN***';
      } else {
        filtered[key] = value;
      }
    });
    
    return filtered;
  }
  
  String _formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return '';
    return headers.entries.take(3).map((e) => '${e.key}=${e.value}').join(', ');
  }
  
  String _formatQueryParams(Map<String, dynamic> params) {
    if (params.isEmpty) return '';
    return params.entries.take(3).map((e) => '${e.key}=${e.value}').join('&');
  }
  
  String _formatRequestBody(dynamic data) {
    if (data == null) return '';
    
    try {
      final str = data.toString();
      if (str.length > 100) {
        return '${str.substring(0, 100)}... (${str.length} chars)';
      }
      return str;
    } catch (e) {
      return 'Binary/Complex data (${data.runtimeType})';
    }
  }
  
  String _formatResponseBody(dynamic data) {
    if (data == null) return '';
    
    try {
      final str = data.toString();
      if (str.length > 150) {
        return '${str.substring(0, 150)}... (${str.length} chars)';
      }
      return str;
    } catch (e) {
      return 'Binary/Complex data (${data.runtimeType})';
    }
  }
  
  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200: return 'OK';
      case 201: return 'Created';
      case 204: return 'No Content';
      case 400: return 'Bad Request';
      case 401: return 'Unauthorized';
      case 403: return 'Forbidden';
      case 404: return 'Not Found';
      case 405: return 'Method Not Allowed';
      case 500: return 'Internal Server Error';
      case 502: return 'Bad Gateway';
      case 503: return 'Service Unavailable';
      default: return statusCode >= 200 && statusCode < 300 ? 'Success' : 'Error';
    }
  }
}
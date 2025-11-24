import 'package:dio/dio.dart';

/// Network log entry model for detailed HTTP request/response tracking
class NetworkLogEntry {
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, dynamic> requestHeaders;
  final dynamic requestBody;
  final Map<String, dynamic>? queryParameters;
  
  // Response data
  int? statusCode;
  String? statusMessage;
  Map<String, dynamic>? responseHeaders;
  dynamic responseBody;
  
  // Timing
  DateTime? requestTime;
  DateTime? responseTime;
  Duration? duration;
  
  // Error info
  DioExceptionType? errorType;
  String? errorMessage;
  bool get hasError => errorType != null;
  bool get isCompleted => responseTime != null || hasError;
  
  // Request size (approximate)
  int? requestSize;
  int? responseSize;

  NetworkLogEntry({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    required this.requestHeaders,
    this.requestBody,
    this.queryParameters,
    this.statusCode,
    this.statusMessage,
    this.responseHeaders,
    this.responseBody,
    this.requestTime,
    this.responseTime,
    this.duration,
    this.errorType,
    this.errorMessage,
    this.requestSize,
    this.responseSize,
  });

  /// Creates a NetworkLogEntry from RequestOptions
  static NetworkLogEntry fromRequest(RequestOptions options) {
    final now = DateTime.now();
    final id = 'req_${now.millisecondsSinceEpoch}_${options.hashCode.abs()}';
    return NetworkLogEntry(
      id: id,
      timestamp: now,
      method: options.method.toUpperCase(),
      url: options.uri.toString(),
      requestHeaders: Map<String, dynamic>.from(options.headers),
      requestBody: options.data,
      queryParameters: options.queryParameters.isNotEmpty 
          ? Map<String, dynamic>.from(options.queryParameters) 
          : null,
      requestTime: now,
      requestSize: _calculateSize(options.data),
    );
  }

  /// Updates the entry with response data
  NetworkLogEntry withResponse(Response response) {
    final now = DateTime.now();
    return NetworkLogEntry(
      id: id,
      timestamp: timestamp,
      method: method,
      url: url,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      queryParameters: queryParameters,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      responseHeaders: response.headers.map.map((key, value) => MapEntry(key, value.join(', '))),
      responseBody: response.data,
      requestTime: requestTime,
      responseTime: now,
      duration: requestTime != null ? now.difference(requestTime!) : null,
      responseSize: _calculateSize(response.data),
      requestSize: requestSize,
    );
  }

  /// Updates the entry with error data
  NetworkLogEntry withError(DioException error) {
    final now = DateTime.now();
    return NetworkLogEntry(
      id: id,
      timestamp: timestamp,
      method: method,
      url: url,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      queryParameters: queryParameters,
      statusCode: error.response?.statusCode,
      statusMessage: error.response?.statusMessage,
      responseHeaders: error.response?.headers.map.map((key, value) => MapEntry(key, value.join(', '))),
      responseBody: error.response?.data,
      requestTime: requestTime,
      responseTime: now,
      duration: requestTime != null ? now.difference(requestTime!) : null,
      errorType: error.type,
      errorMessage: error.message,
      responseSize: _calculateSize(error.response?.data),
      requestSize: requestSize,
    );
  }

  /// Gets a short description for the log entry
  String get shortDescription {
    if (hasError) {
      return '$method $url → Error (${errorType?.name ?? 'Unknown'})';
    }
    if (statusCode != null) {
      return '$method $url → $statusCode';
    }
    return '$method $url → Pending';
  }

  /// Gets the host from URL
  String get host {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      // Truncate long hosts for display
      if (host.length > 30) {
        return '${host.substring(0, 27)}...';
      }
      return host;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Gets the path from URL
  String get path {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.isEmpty ? '/' : uri.path;
      // Truncate long paths for display
      if (path.length > 50) {
        return '${path.substring(0, 47)}...';
      }
      return path;
    } catch (e) {
      // Truncate long URLs
      if (url.length > 50) {
        return '${url.substring(0, 47)}...';
      }
      return url;
    }
  }

  /// Gets status color based on response
  String get statusColor {
    if (hasError) return 'red';
    if (statusCode == null) return 'orange';
    if (statusCode! >= 200 && statusCode! < 300) return 'green';
    if (statusCode! >= 300 && statusCode! < 400) return 'blue';
    if (statusCode! >= 400 && statusCode! < 500) return 'orange';
    return 'red';
  }

  /// Formats duration for display
  String get formattedDuration {
    if (duration == null) return '--';
    final ms = duration!.inMilliseconds;
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  /// Formats request/response size
  String formatSize(int? bytes) {
    if (bytes == null) return '--';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedRequestSize => formatSize(requestSize);
  String get formattedResponseSize => formatSize(responseSize);

  /// Generates curl command equivalent for this request
  String get curlCommand {
    final buffer = StringBuffer();
    buffer.write('curl -X $method');
    
    // Add headers
    requestHeaders.forEach((key, value) {
      if (key.toLowerCase() != 'content-length') {
        buffer.write(' \\\n  -H "$key: $value"');
      }
    });
    
    // Add request body
    if (requestBody != null) {
      String bodyString;
      try {
        bodyString = requestBody.toString();
        // Escape quotes in the body
        bodyString = bodyString.replaceAll('"', '\\"');
        buffer.write(' \\\n  -d "$bodyString"');
      } catch (e) {
        buffer.write(' \\\n  -d "[Complex data - ${requestBody.runtimeType}]"');
      }
    }
    
    // Add URL (at the end)
    buffer.write(' \\\n  "$url"');
    
    return buffer.toString();
  }

  /// Calculates approximate size of data
  static int? _calculateSize(dynamic data) {
    if (data == null) return null;
    try {
      return data.toString().length;
    } catch (e) {
      return null;
    }
  }
}
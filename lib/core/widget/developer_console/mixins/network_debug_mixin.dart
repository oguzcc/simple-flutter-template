import 'package:network_logger/network_logger.dart';

/// Mixin for network logger integration and debugging
mixin NetworkDebugMixin {
  /// Network logger service instance
  late NetworkLoggerService _networkLoggerService;
  
  /// Network logger enabled status
  bool _isNetworkLoggingEnabled = true;

  /// Get network logger enabled status
  bool get isNetworkLoggingEnabled => _isNetworkLoggingEnabled;
  
  /// Get network logs count
  int get networkLogsCount => _networkLoggerService.networkLogsCount;
  
  /// Get all network logs
  List<NetworkLogEntry> get networkLogs => _networkLoggerService.networkLogs;

  /// Initialize network debug functionality
  void initializeNetworkDebug() {
    _networkLoggerService = NetworkLoggerService.instance;
    _setupNetworkLogging();
  }

  /// Setup network logging
  void _setupNetworkLogging() {
    // Network logger is already initialized via dio interceptor
    // This mixin provides additional functionality for debugging
  }

  /// Enable network logging
  void enableNetworkLogging() {
    _isNetworkLoggingEnabled = true;
    // Note: The actual enabling is handled by the NetworkLoggerService
  }

  /// Disable network logging
  void disableNetworkLogging() {
    _isNetworkLoggingEnabled = false;
    // Note: The actual disabling is handled by the NetworkLoggerService
  }

  /// Get network statistics
  Map<String, dynamic> getNetworkStatistics() {
    final logs = _networkLoggerService.networkLogs;
    
    // Calculate statistics
    final totalRequests = logs.length;
    final successRequests = logs.where((log) => 
        log.statusCode != null && log.statusCode! >= 200 && log.statusCode! < 300
    ).length;
    final errorRequests = logs.where((log) => 
        log.statusCode != null && log.statusCode! >= 400
    ).length;
    final pendingRequests = logs.where((log) => !log.isCompleted).length;
    
    // Calculate average response time
    final completedLogs = logs.where((log) => 
        log.duration != null && log.isCompleted
    ).toList();
    
    final averageResponseTime = completedLogs.isNotEmpty
        ? completedLogs
            .map((log) => log.duration!.inMilliseconds)
            .reduce((a, b) => a + b) / completedLogs.length
        : 0.0;

    // Calculate data usage (approximate)
    int totalRequestSize = 0;
    int totalResponseSize = 0;
    
    for (final log in logs) {
      if (log.requestSize != null) {
        totalRequestSize += log.requestSize!;
      }
      if (log.responseSize != null) {
        totalResponseSize += log.responseSize!;
      }
    }

    return {
      'totalRequests': totalRequests,
      'successRequests': successRequests,
      'errorRequests': errorRequests,
      'pendingRequests': pendingRequests,
      'averageResponseTime': averageResponseTime,
      'totalRequestSize': totalRequestSize,
      'totalResponseSize': totalResponseSize,
      'totalDataUsage': totalRequestSize + totalResponseSize,
    };
  }

  /// Get request methods distribution
  Map<String, int> getRequestMethodsDistribution() {
    final logs = _networkLoggerService.networkLogs;
    final distribution = <String, int>{};
    
    for (final log in logs) {
      distribution[log.method] = (distribution[log.method] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get status codes distribution
  Map<String, int> getStatusCodesDistribution() {
    final logs = _networkLoggerService.networkLogs;
    final distribution = <String, int>{};
    
    for (final log in logs) {
      if (log.statusCode != null) {
        final statusGroup = '${(log.statusCode! / 100).floor()}xx';
        distribution[statusGroup] = (distribution[statusGroup] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  /// Get recent errors
  List<NetworkLogEntry> getRecentErrors({int limit = 10}) {
    final errorLogs = _networkLoggerService.networkLogs
        .where((log) => log.hasError || 
            (log.statusCode != null && log.statusCode! >= 400))
        .take(limit)
        .toList();
    
    return errorLogs;
  }

  /// Get slow requests (above threshold)
  List<NetworkLogEntry> getSlowRequests({
    Duration threshold = const Duration(seconds: 3),
    int limit = 10,
  }) {
    final slowLogs = _networkLoggerService.networkLogs
        .where((log) => 
            log.duration != null && log.duration! > threshold)
        .take(limit)
        .toList();
    
    return slowLogs;
  }

  /// Clear network logs
  void clearNetworkLogs() {
    _networkLoggerService.clearNetworkLogs();
  }

  /// Get network health status
  String getNetworkHealthStatus() {
    final stats = getNetworkStatistics();
    final totalRequests = stats['totalRequests'] as int;
    final errorRequests = stats['errorRequests'] as int;
    
    if (totalRequests == 0) {
      return 'No Data';
    }
    
    final errorRate = (errorRequests / totalRequests) * 100;
    
    if (errorRate < 5) {
      return 'Healthy';
    } else if (errorRate < 15) {
      return 'Warning';
    } else {
      return 'Critical';
    }
  }

  /// Get formatted network info for UI display
  List<String> getNetworkInfoStrings() {
    final stats = getNetworkStatistics();
    
    return [
      'Status: ${_isNetworkLoggingEnabled ? 'Enabled' : 'Disabled'}',
      'Total Requests: ${stats['totalRequests']}',
      'Success Rate: ${_calculateSuccessRate(stats).toStringAsFixed(1)}%',
      'Avg Response Time: ${(stats['averageResponseTime'] as double).toStringAsFixed(0)}ms',
      'Health: ${getNetworkHealthStatus()}',
    ];
  }

  /// Calculate success rate
  double _calculateSuccessRate(Map<String, dynamic> stats) {
    final totalRequests = stats['totalRequests'] as int;
    final successRequests = stats['successRequests'] as int;
    
    if (totalRequests == 0) return 0.0;
    return (successRequests / totalRequests) * 100;
  }

  /// Export network logs data
  Map<String, dynamic> exportNetworkData() {
    return {
      'statistics': getNetworkStatistics(),
      'methodsDistribution': getRequestMethodsDistribution(),
      'statusCodesDistribution': getStatusCodesDistribution(),
      'recentErrors': getRecentErrors().map((log) => {
        'url': log.url,
        'method': log.method,
        'statusCode': log.statusCode,
        'error': log.errorMessage,
        'timestamp': log.timestamp.toIso8601String(),
      }).toList(),
      'healthStatus': getNetworkHealthStatus(),
      'exportTimestamp': DateTime.now().toIso8601String(),
    };
  }
}
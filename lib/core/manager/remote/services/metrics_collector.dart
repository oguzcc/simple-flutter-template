import 'dart:async';

import 'package:flutter/foundation.dart';

/// Interface for thread-safe metrics collection
abstract class IMetricsCollector {
  Future<void> incrementCounter(String key);
  Future<void> recordProcessingTime(int milliseconds);
  Future<void> recordError(String category, String message);
  Future<Map<String, dynamic>> getMetrics();
  Future<void> resetMetrics();
}

/// Thread-safe metrics collector with proper synchronization
class MetricsCollector implements IMetricsCollector {
  MetricsCollector({
    this.maxProcessingTimeSamples = 1000,
    this.maxErrorHistory = 100,
  }) {
    // Initialize basic counters
    _counters.addAll({
      'total_requests': 0,
      'streamed_requests': 0,
      'fallback_requests': 0,
    });
  }

  final int maxProcessingTimeSamples;
  final int maxErrorHistory;

  // Thread-safe metrics using sequential completers
  final Map<String, int> _counters = {};
  final List<int> _processingTimes = [];
  final List<ErrorEntry> _errorHistory = [];

  // Synchronization using sequential completers (safer than Completer pattern)
  Completer<void>? _currentOperation;

  @override
  Future<void> incrementCounter(String key) async {
    await _synchronized(() {
      _counters[key] = (_counters[key] ?? 0) + 1;
    });
  }

  @override
  Future<void> recordProcessingTime(int milliseconds) async {
    await _synchronized(() {
      _processingTimes.add(milliseconds);
      
      // Keep only recent samples to prevent memory bloat
      if (_processingTimes.length > maxProcessingTimeSamples) {
        _processingTimes.removeRange(
          0, 
          _processingTimes.length - maxProcessingTimeSamples
        );
      }
    });
  }

  @override
  Future<void> recordError(String category, String message) async {
    await _synchronized(() {
      final error = ErrorEntry(
        timestamp: DateTime.now(),
        category: category,
        message: message,
      );
      
      _errorHistory.add(error);
      
      // Keep only recent errors
      if (_errorHistory.length > maxErrorHistory) {
        _errorHistory.removeRange(0, _errorHistory.length - maxErrorHistory);
      }
      
      // Also increment error counter
      final counterKey = 'errors_$category';
      _counters[counterKey] = (_counters[counterKey] ?? 0) + 1;
    });
  }

  @override
  Future<Map<String, dynamic>> getMetrics() async {
    return await _synchronized(() {
      final totalRequests = _counters['total_requests'] ?? 0;
      final streamedRequests = _counters['streamed_requests'] ?? 0;
      
      // Calculate processing time statistics
      double avgProcessingTime = 0;
      int p95ProcessingTime = 0;
      
      if (_processingTimes.isNotEmpty) {
        final sorted = List<int>.from(_processingTimes)..sort();
        avgProcessingTime = sorted.reduce((a, b) => a + b) / sorted.length;
        
        // Calculate 95th percentile
        final p95Index = ((sorted.length - 1) * 0.95).round();
        p95ProcessingTime = sorted[p95Index];
      }
      
      // Error rate calculation
      final totalErrors = _counters.entries
          .where((entry) => entry.key.startsWith('errors_'))
          .fold(0, (sum, entry) => sum + entry.value);
      
      final errorRate = totalRequests > 0 ? (totalErrors / totalRequests * 100) : 0;
      
      return {
        'counters': Map<String, int>.from(_counters),
        'performance': {
          'streaming_percentage': totalRequests > 0 
              ? ((streamedRequests / totalRequests) * 100).round() 
              : 0,
          'avg_processing_time_ms': avgProcessingTime.round(),
          'p95_processing_time_ms': p95ProcessingTime,
          'total_processing_samples': _processingTimes.length,
          'error_rate_percent': errorRate.round(),
        },
        'recent_errors': _errorHistory
            .take(10)
            .map((e) => {
                  'timestamp': e.timestamp.toIso8601String(),
                  'category': e.category,
                  'message': e.message,
                })
            .toList(),
        'error_summary': _getErrorSummary(),
        'metrics_info': {
          'max_processing_samples': maxProcessingTimeSamples,
          'max_error_history': maxErrorHistory,
          'current_processing_samples': _processingTimes.length,
          'current_error_count': _errorHistory.length,
        },
      };
    });
  }

  @override
  Future<void> resetMetrics() async {
    await _synchronized(() {
      _counters.clear();
      _processingTimes.clear();
      _errorHistory.clear();
      
      // Initialize basic counters
      _counters.addAll({
        'total_requests': 0,
        'streamed_requests': 0,
        'fallback_requests': 0,
      });
    });
  }

  Map<String, int> _getErrorSummary() {
    final summary = <String, int>{};
    for (final error in _errorHistory) {
      summary[error.category] = (summary[error.category] ?? 0) + 1;
    }
    return summary;
  }

  /// Thread-safe execution using sequential completers
  /// This pattern prevents race conditions without complex locking
  Future<T> _synchronized<T>(T Function() operation) async {
    // Wait for any pending operation to complete
    while (_currentOperation != null && !_currentOperation!.isCompleted) {
      await _currentOperation!.future;
    }
    
    // Create new operation completer
    final currentCompleter = Completer<void>();
    _currentOperation = currentCompleter;
    
    try {
      final result = operation();
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📊 Metrics operation failed: $e');
      }
      rethrow;
    } finally {
      // Complete the operation
      if (!currentCompleter.isCompleted) {
        currentCompleter.complete();
      }
    }
  }
}

/// Error entry for tracking error history
class ErrorEntry {
  const ErrorEntry({
    required this.timestamp,
    required this.category,
    required this.message,
  });

  final DateTime timestamp;
  final String category;
  final String message;

  @override
  String toString() => 
      '${timestamp.toIso8601String()}: [$category] $message';
}

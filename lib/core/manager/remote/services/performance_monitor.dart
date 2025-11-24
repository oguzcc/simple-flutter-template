import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Performance monitoring and health checking service
abstract interface class IPerformanceMonitor {
  /// Record a successful operation
  void recordSuccess(Duration duration, int bytesProcessed);
  
  /// Record a failed operation
  void recordFailure(Duration duration, String reason);
  
  /// Check system health
  HealthStatus getHealthStatus();
  
  /// Get performance metrics
  PerformanceMetrics getMetrics();
  
  /// Reset all metrics
  void reset();
}

/// Health status of the streaming system
class HealthStatus {
  const HealthStatus({
    required this.isHealthy,
    required this.score,
    required this.issues,
    required this.recommendations,
  });

  final bool isHealthy;
  final double score; // 0.0 to 1.0
  final List<String> issues;
  final List<String> recommendations;

  @override
  String toString() => 'HealthStatus(healthy: $isHealthy, score: $score)';
}

/// Performance metrics for analysis
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.averageProcessingTime,
    required this.averageThroughput,
    required this.p95ProcessingTime,
    required this.errorRate,
    required this.totalBytesProcessed,
  });

  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final Duration averageProcessingTime;
  final double averageThroughput; // bytes per second
  final Duration p95ProcessingTime;
  final double errorRate; // 0.0 to 1.0
  final int totalBytesProcessed;

  Map<String, dynamic> toJson() => {
    'total_operations': totalOperations,
    'successful_operations': successfulOperations,
    'failed_operations': failedOperations,
    'average_processing_time_ms': averageProcessingTime.inMilliseconds,
    'average_throughput_bps': averageThroughput,
    'p95_processing_time_ms': p95ProcessingTime.inMilliseconds,
    'error_rate': errorRate,
    'total_bytes_processed': totalBytesProcessed,
  };
}

/// Production performance monitor
class PerformanceMonitor implements IPerformanceMonitor {
  PerformanceMonitor({
    this.maxSamples = 1000,
    this.healthThreshold = 0.8,
  });

  final int maxSamples;
  final double healthThreshold;

  final List<Duration> _processingTimes = <Duration>[];
  final List<int> _bytesProcessed = <int>[];
  final List<String> _failureReasons = <String>[];
  
  int _totalOperations = 0;
  int _successfulOperations = 0;
  int _failedOperations = 0;
  int _totalBytesProcessed = 0;

  @override
  void recordSuccess(Duration duration, int bytesProcessed) {
    _totalOperations++;
    _successfulOperations++;
    _totalBytesProcessed += bytesProcessed;
    
    _processingTimes.add(duration);
    _bytesProcessed.add(bytesProcessed);
    
    _maintainSampleSize();
  }

  @override
  void recordFailure(Duration duration, String reason) {
    _totalOperations++;
    _failedOperations++;
    
    _processingTimes.add(duration);
    _failureReasons.add(reason);
    
    _maintainSampleSize();
  }

  @override
  HealthStatus getHealthStatus() {
    final metrics = getMetrics();
    final issues = <String>[];
    final recommendations = <String>[];
    
    // Calculate health score
    var score = 1.0;
    
    // Factor in error rate (heavily weighted)
    if (metrics.errorRate > 0.1) {
      score -= 0.4;
      issues.add('High error rate: ${(metrics.errorRate * 100).toStringAsFixed(1)}%');
      recommendations.add('Check network connectivity and device resources');
    }
    
    // Factor in processing time
    if (metrics.averageProcessingTime.inMilliseconds > 5000) {
      score -= 0.2;
      issues.add('Slow processing: ${metrics.averageProcessingTime.inSeconds}s average');
      recommendations.add('Consider reducing content size or improving device performance');
    }
    
    // Factor in throughput
    if (metrics.averageThroughput < 10000) { // Less than 10KB/s
      score -= 0.2;
      issues.add('Low throughput: ${(metrics.averageThroughput / 1024).toStringAsFixed(1)} KB/s');
      recommendations.add('Check network quality and streaming strategy');
    }
    
    // Factor in P95 latency
    if (metrics.p95ProcessingTime.inMilliseconds > 10000) {
      score -= 0.1;
      issues.add('High P95 latency: ${metrics.p95ProcessingTime.inSeconds}s');
      recommendations.add('Monitor for resource contention or memory pressure');
    }
    
    // Ensure score is within bounds
    score = math.max(0.0, math.min(1.0, score));
    
    final isHealthy = score >= healthThreshold && issues.isEmpty;
    
    return HealthStatus(
      isHealthy: isHealthy,
      score: score,
      issues: issues,
      recommendations: recommendations,
    );
  }

  @override
  PerformanceMetrics getMetrics() {
    if (_processingTimes.isEmpty) {
      return const PerformanceMetrics(
        totalOperations: 0,
        successfulOperations: 0,
        failedOperations: 0,
        averageProcessingTime: Duration.zero,
        averageThroughput: 0.0,
        p95ProcessingTime: Duration.zero,
        errorRate: 0.0,
        totalBytesProcessed: 0,
      );
    }

    // Calculate average processing time
    final totalMs = _processingTimes.fold<int>(
      0, 
      (sum, duration) => sum + duration.inMilliseconds,
    );
    final avgProcessingTime = Duration(
      milliseconds: (totalMs / _processingTimes.length).round(),
    );

    // Calculate P95 processing time
    final sortedTimes = [..._processingTimes]
      ..sort((a, b) => a.inMilliseconds.compareTo(b.inMilliseconds));
    final p95Index = ((sortedTimes.length - 1) * 0.95).round();
    final p95ProcessingTime = sortedTimes[p95Index];

    // Calculate throughput
    final totalProcessingSeconds = totalMs / 1000.0;
    final avgThroughput = totalProcessingSeconds > 0 
        ? _totalBytesProcessed / totalProcessingSeconds 
        : 0.0;

    // Calculate error rate
    final errorRate = _totalOperations > 0 
        ? _failedOperations / _totalOperations 
        : 0.0;

    return PerformanceMetrics(
      totalOperations: _totalOperations,
      successfulOperations: _successfulOperations,
      failedOperations: _failedOperations,
      averageProcessingTime: avgProcessingTime,
      averageThroughput: avgThroughput,
      p95ProcessingTime: p95ProcessingTime,
      errorRate: errorRate,
      totalBytesProcessed: _totalBytesProcessed,
    );
  }

  @override
  void reset() {
    _processingTimes.clear();
    _bytesProcessed.clear();
    _failureReasons.clear();
    _totalOperations = 0;
    _successfulOperations = 0;
    _failedOperations = 0;
    _totalBytesProcessed = 0;
  }

  void _maintainSampleSize() {
    if (_processingTimes.length > maxSamples) {
      _processingTimes.removeRange(0, _processingTimes.length - maxSamples);
    }
    if (_bytesProcessed.length > maxSamples) {
      _bytesProcessed.removeRange(0, _bytesProcessed.length - maxSamples);
    }
    if (_failureReasons.length > maxSamples) {
      _failureReasons.removeRange(0, _failureReasons.length - maxSamples);
    }
  }

  /// Get detailed diagnostics for troubleshooting
  Map<String, dynamic> getDiagnostics() {
    final metrics = getMetrics();
    final health = getHealthStatus();
    
    return {
      'health': {
        'is_healthy': health.isHealthy,
        'score': health.score,
        'issues': health.issues,
        'recommendations': health.recommendations,
      },
      'performance': metrics.toJson(),
      'failure_reasons': _getFailureReasonStats(),
      'sample_info': {
        'processing_time_samples': _processingTimes.length,
        'bytes_processed_samples': _bytesProcessed.length,
        'max_samples': maxSamples,
      },
    };
  }

  Map<String, int> _getFailureReasonStats() {
    final reasonCount = <String, int>{};
    for (final reason in _failureReasons) {
      reasonCount[reason] = (reasonCount[reason] ?? 0) + 1;
    }
    return reasonCount;
  }
}

/// No-op performance monitor for when monitoring is disabled
class NoOpPerformanceMonitor implements IPerformanceMonitor {
  @override
  void recordSuccess(Duration duration, int bytesProcessed) {}

  @override
  void recordFailure(Duration duration, String reason) {}

  @override
  HealthStatus getHealthStatus() => const HealthStatus(
    isHealthy: true,
    score: 1.0,
    issues: <String>[],
    recommendations: <String>[],
  );

  @override
  PerformanceMetrics getMetrics() => const PerformanceMetrics(
    totalOperations: 0,
    successfulOperations: 0,
    failedOperations: 0,
    averageProcessingTime: Duration.zero,
    averageThroughput: 0.0,
    p95ProcessingTime: Duration.zero,
    errorRate: 0.0,
    totalBytesProcessed: 0,
  );

  @override
  void reset() {}
}
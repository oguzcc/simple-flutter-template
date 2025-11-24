import 'dart:async';

import 'package:flutter/foundation.dart';

/// Structured error information for reporting
class StreamingError {
  const StreamingError({
    required this.type,
    required this.message,
    required this.timestamp,
    this.context,
    this.stackTrace,
    this.deviceInfo,
    this.networkInfo,
  });

  final StreamingErrorType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final StackTrace? stackTrace;
  final String? deviceInfo;
  final String? networkInfo;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
    'stack_trace': stackTrace?.toString(),
    'device_info': deviceInfo,
    'network_info': networkInfo,
  };

  @override
  String toString() => 'StreamingError(type: $type, message: $message)';
}

/// Types of streaming errors for categorization
enum StreamingErrorType {
  timeout,
  network,
  memory,
  decoding,
  circuitBreaker,
  deviceDetection,
  strategySelection,
  unknown,
}

/// Error reporting service interface
abstract interface class IErrorReporter {
  /// Report a streaming error
  Future<void> reportError(StreamingError error);
  
  /// Report a simple error with automatic categorization
  Future<void> reportSimpleError(
    String message, {
    StreamingErrorType? type,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  });
  
  /// Get recent errors for debugging
  List<StreamingError> getRecentErrors();
  
  /// Clear error history
  void clearErrors();
}

/// Production error reporter with structured logging
class ErrorReporter implements IErrorReporter {
  ErrorReporter({
    this.maxErrorHistory = 100,
    this.enableDebugLogging = kDebugMode,
  });

  final int maxErrorHistory;
  final bool enableDebugLogging;
  
  final List<StreamingError> _errorHistory = <StreamingError>[];

  @override
  Future<void> reportError(StreamingError error) async {
    // Add to history
    _errorHistory.add(error);
    
    // Maintain size limit
    if (_errorHistory.length > maxErrorHistory) {
      _errorHistory.removeRange(0, _errorHistory.length - maxErrorHistory);
    }

    // Debug logging
    if (enableDebugLogging) {
      debugPrint('🚨 Streaming Error: $error');
      if (error.context != null) {
        debugPrint('   Context: ${error.context}');
      }
    }

    // Here you could integrate with crash reporting services like:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // await _crashlyticsService.recordError(error);
  }

  @override
  Future<void> reportSimpleError(
    String message, {
    StreamingErrorType? type,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) async {
    final error = StreamingError(
      type: type ?? _categorizeError(message),
      message: message,
      timestamp: DateTime.now(),
      context: context,
      stackTrace: stackTrace,
    );
    
    await reportError(error);
  }

  @override
  List<StreamingError> getRecentErrors() => 
      List<StreamingError>.unmodifiable(_errorHistory);

  @override
  void clearErrors() => _errorHistory.clear();

  /// Automatic error categorization based on message content
  StreamingErrorType _categorizeError(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('timeout')) {
      return StreamingErrorType.timeout;
    } else if (lowerMessage.contains('network') || 
               lowerMessage.contains('socket')) {
      return StreamingErrorType.network;
    } else if (lowerMessage.contains('memory') || 
               lowerMessage.contains('buffer')) {
      return StreamingErrorType.memory;
    } else if (lowerMessage.contains('decode') || 
               lowerMessage.contains('json')) {
      return StreamingErrorType.decoding;
    } else if (lowerMessage.contains('circuit')) {
      return StreamingErrorType.circuitBreaker;
    } else if (lowerMessage.contains('device')) {
      return StreamingErrorType.deviceDetection;
    } else {
      return StreamingErrorType.unknown;
    }
  }

  /// Get error statistics for monitoring
  Map<String, dynamic> getErrorStatistics() {
    final typeCount = <StreamingErrorType, int>{};
    
    for (final error in _errorHistory) {
      typeCount[error.type] = (typeCount[error.type] ?? 0) + 1;
    }

    return {
      'total_errors': _errorHistory.length,
      'error_types': typeCount.map((k, v) => MapEntry(k.name, v)),
      'recent_errors': _errorHistory.take(5).map((e) => e.toJson()).toList(),
      'oldest_error': _errorHistory.isNotEmpty 
          ? _errorHistory.first.timestamp.toIso8601String()
          : null,
      'newest_error': _errorHistory.isNotEmpty 
          ? _errorHistory.last.timestamp.toIso8601String()
          : null,
    };
  }
}

/// No-op error reporter for when error reporting is disabled
class NoOpErrorReporter implements IErrorReporter {
  @override
  Future<void> reportError(StreamingError error) async {}

  @override
  Future<void> reportSimpleError(
    String message, {
    StreamingErrorType? type,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) async {}

  @override
  List<StreamingError> getRecentErrors() => const <StreamingError>[];

  @override
  void clearErrors() {}
}
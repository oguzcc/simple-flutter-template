import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Mixin for console log capture functionality
mixin ConsoleLogMixin {
  /// Stream controller for real-time log updates
  final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();
  
  /// List to store debug logs
  final List<String> _debugLogs = [];
  
  /// Maximum number of logs to keep in memory
  static const int _maxLogs = 100;
  
  /// Original debug print callback
  DebugPrintCallback? _originalDebugPrint;
  
  /// Stream subscription for log updates
  StreamSubscription<String>? _logSubscription;

  /// Get the log stream for listening to new logs
  Stream<String> get logStream => _logStreamController.stream;
  
  /// Get all debug logs
  List<String> get debugLogs => List.unmodifiable(_debugLogs);
  
  /// Get logs count
  int get logsCount => _debugLogs.length;

  /// Initialize console log capture
  void initializeConsoleCapture() {
    _setupConsoleCapture();
    
    // Setup stream listener for log updates
    _logSubscription = _logStreamController.stream.listen((logMessage) {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final logEntry = '[$timestamp] $logMessage';
      _debugLogs.insert(0, logEntry);
      
      // Limit logs to prevent memory issues
      if (_debugLogs.length > _maxLogs) {
        _debugLogs.removeLast();
      }
    });
    
    // Initial log
    addDebugLog('🚀 Console log capture initialized');
  }

  /// Setup console capture by overriding debugPrint
  void _setupConsoleCapture() {
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        _logStreamController.add('🖥️ $message');
      }
      _originalDebugPrint?.call(message, wrapWidth: wrapWidth);
    };

    developer.log(
      'Console capture initialized for Debug Console',
      name: 'ConsoleLogMixin',
    );
  }

  /// Restore original console capture
  void restoreConsoleCapture() {
    if (_originalDebugPrint != null) {
      debugPrint = _originalDebugPrint!;
    }
  }

  /// Add a debug log manually
  void addDebugLog(String message) {
    _logStreamController.add(message);
  }

  /// Clear all debug logs
  void clearDebugLogs() {
    _debugLogs.clear();
    addDebugLog('🧹 Console cleared');
  }

  /// Filter logs based on type
  List<String> getFilteredLogs(Set<String> filters) {
    if (filters.contains('all')) {
      return _debugLogs;
    }

    return _debugLogs.where((log) {
      final isSystemLog = log.contains('🖥️') || log.contains('🚀');
      final isConsoleLog = log.contains('🖥️');
      final isNetworkLog = log.contains('🌐');
      final isErrorLog = log.contains('❌');

      return (filters.contains('system') && isSystemLog) ||
          (filters.contains('console') && isConsoleLog) ||
          (filters.contains('network') && isNetworkLog) ||
          (filters.contains('error') && isErrorLog);
    }).toList();
  }

  /// Dispose console log capture
  void disposeConsoleCapture() {
    _logSubscription?.cancel();
    _logStreamController.close();
    restoreConsoleCapture();
  }
}
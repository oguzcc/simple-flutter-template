import 'package:flutter/material.dart';

/// Enum for different log types
enum LogType {
  system,
  console,
  network,
  error,
  warning,
  info,
}

/// Model for debug log entries
class DebugLogModel {
  /// Unique identifier for the log entry
  final String id;
  
  /// Log message content
  final String message;
  
  /// Timestamp when the log was created
  final DateTime timestamp;
  
  /// Type of the log
  final LogType type;
  
  /// Source component that generated the log
  final String? source;
  
  /// Additional metadata for the log
  final Map<String, dynamic>? metadata;
  
  /// Stack trace if available (for errors)
  final StackTrace? stackTrace;

  const DebugLogModel({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
    this.source,
    this.metadata,
    this.stackTrace,
  });

  /// Create a system log entry
  factory DebugLogModel.system(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return DebugLogModel(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      type: LogType.system,
      source: source,
      metadata: metadata,
    );
  }

  /// Create a console log entry
  factory DebugLogModel.console(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return DebugLogModel(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      type: LogType.console,
      source: source,
      metadata: metadata,
    );
  }

  /// Create a network log entry
  factory DebugLogModel.network(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return DebugLogModel(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      type: LogType.network,
      source: source,
      metadata: metadata,
    );
  }

  /// Create an error log entry
  factory DebugLogModel.error(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    return DebugLogModel(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      type: LogType.error,
      source: source,
      metadata: metadata,
      stackTrace: stackTrace,
    );
  }

  /// Create a warning log entry
  factory DebugLogModel.warning(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return DebugLogModel(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      type: LogType.warning,
      source: source,
      metadata: metadata,
    );
  }

  /// Create an info log entry
  factory DebugLogModel.info(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return DebugLogModel(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      type: LogType.info,
      source: source,
      metadata: metadata,
    );
  }

  /// Generate a unique ID for the log entry
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get formatted timestamp for display
  String get formattedTimestamp {
    return timestamp.toString().substring(11, 19);
  }

  /// Get full formatted timestamp
  String get fullFormattedTimestamp {
    return timestamp.toString();
  }

  /// Get log type icon
  IconData get icon {
    switch (type) {
      case LogType.system:
        return Icons.settings_outlined;
      case LogType.console:
        return Icons.terminal;
      case LogType.network:
        return Icons.wifi;
      case LogType.error:
        return Icons.error_outline;
      case LogType.warning:
        return Icons.warning_outlined;
      case LogType.info:
        return Icons.info_outline;
    }
  }

  /// Get log type color
  Color get color {
    switch (type) {
      case LogType.system:
        return const Color(0xFF10B981); // Green
      case LogType.console:
        return const Color(0xFF60A5FA); // Blue
      case LogType.network:
        return const Color(0xFF8B5CF6); // Purple
      case LogType.error:
        return const Color(0xFFEF4444); // Red
      case LogType.warning:
        return const Color(0xFFF59E0B); // Yellow
      case LogType.info:
        return const Color(0xFF94A3B8); // Gray
    }
  }

  /// Get log type display name
  String get typeName {
    switch (type) {
      case LogType.system:
        return 'System';
      case LogType.console:
        return 'Console';
      case LogType.network:
        return 'Network';
      case LogType.error:
        return 'Error';
      case LogType.warning:
        return 'Warning';
      case LogType.info:
        return 'Info';
    }
  }

  /// Get formatted log entry for display
  String get formattedEntry {
    final sourcePrefix = source != null ? '[$source] ' : '';
    return '[$formattedTimestamp] $sourcePrefix$message';
  }

  /// Check if log matches filter
  bool matchesFilter(Set<String> filters) {
    if (filters.contains('all')) {
      return true;
    }
    
    return filters.any((filter) {
      switch (filter) {
        case 'system':
          return type == LogType.system;
        case 'console':
          return type == LogType.console;
        case 'network':
          return type == LogType.network;
        case 'error':
          return type == LogType.error;
        case 'warning':
          return type == LogType.warning;
        case 'info':
          return type == LogType.info;
        default:
          return false;
      }
    });
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'source': source,
      'metadata': metadata,
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// Create from JSON
  factory DebugLogModel.fromJson(Map<String, dynamic> json) {
    return DebugLogModel(
      id: json['id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: LogType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LogType.info,
      ),
      source: json['source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'] != null 
          ? StackTrace.fromString(json['stackTrace'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DebugLogModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DebugLogModel(id: $id, message: $message, type: $type, timestamp: $timestamp)';
  }
}
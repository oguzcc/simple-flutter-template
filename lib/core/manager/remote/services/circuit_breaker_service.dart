import 'dart:async';

import 'package:flutter/foundation.dart';

/// Circuit breaker service interface
abstract interface class ICircuitBreakerService {
  /// Check if circuit breaker is open
  bool get isOpen;
  
  /// Record a successful operation
  void recordSuccess();
  
  /// Record a failed operation
  Future<void> recordFailure(String error);
  
  /// Get circuit breaker metrics
  Map<String, dynamic> getMetrics();
  
  /// Reset circuit breaker state
  void reset();
  
  /// Dispose resources
  void dispose();
}

/// Production circuit breaker implementation
class CircuitBreakerService implements ICircuitBreakerService {
  CircuitBreakerService({
    this.isEnabled = true,
    this.maxConsecutiveFailures = 5,
    this.timeout = const Duration(minutes: 1),
  }) {
    if (isEnabled) {
      _initializePeriodicReset();
    }
  }

  final bool isEnabled;
  final int maxConsecutiveFailures;
  final Duration timeout;
  
  int _consecutiveFailures = 0;
  DateTime? _openedAt;
  bool _isOpen = false;
  Timer? _resetTimer;

  @override
  bool get isOpen => isEnabled && _isOpen;

  @override
  void recordSuccess() {
    if (!isEnabled) return;
    
    _consecutiveFailures = 0;
    if (_isOpen) {
      reset();
    }
  }

  @override
  Future<void> recordFailure(String error) async {
    if (!isEnabled) return;
    
    _consecutiveFailures++;
    
    if (_consecutiveFailures >= maxConsecutiveFailures && !_isOpen) {
      await _openCircuitBreaker();
    }
  }

  @override
  Map<String, dynamic> getMetrics() {
    return {
      'enabled': isEnabled,
      'is_open': _isOpen,
      'consecutive_failures': _consecutiveFailures,
      'opened_at': _openedAt?.toIso8601String(),
      'max_failures_threshold': maxConsecutiveFailures,
      'timeout_minutes': timeout.inMinutes,
    };
  }

  @override
  void reset() {
    _isOpen = false;
    _openedAt = null;
    _consecutiveFailures = 0;
    
    if (kDebugMode) {
      debugPrint('✅ Circuit breaker reset');
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _resetTimer = null;
  }

  Future<void> _openCircuitBreaker() async {
    _isOpen = true;
    _openedAt = DateTime.now();
    
    if (kDebugMode) {
      debugPrint(
        '🚨 Circuit breaker opened after $_consecutiveFailures failures',
      );
    }
  }

  void _initializePeriodicReset() {
    _resetTimer = Timer.periodic(timeout, (_) {
      if (_isOpen && 
          _openedAt != null &&
          DateTime.now().difference(_openedAt!) > timeout) {
        reset();
      }
    });
  }
}

/// No-op circuit breaker for when disabled
class NoOpCircuitBreakerService implements ICircuitBreakerService {
  @override
  bool get isOpen => false;

  @override
  void recordSuccess() {}

  @override
  Future<void> recordFailure(String error) async {}

  @override
  Map<String, dynamic> getMetrics() => {'enabled': false};

  @override
  void reset() {}

  @override
  void dispose() {}
}
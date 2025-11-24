import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Interface for network monitoring
abstract class INetworkMonitorService {
  Future<List<ConnectivityResult>> getCurrentNetworkType();
  void clearCache();
  List<ConnectivityResult>? get cachedNetworkType;
}

/// Service for monitoring network connectivity with caching
class NetworkMonitorService implements INetworkMonitorService {
  NetworkMonitorService({
    this.cacheDuration = const Duration(seconds: 30),
  }) : _connectivity = Connectivity();

  final Duration cacheDuration;
  final Connectivity _connectivity;

  // Cache management
  List<ConnectivityResult>? _cachedNetworkType;
  DateTime? _lastCheck;

  @override
  Future<List<ConnectivityResult>> getCurrentNetworkType() async {
    // Return cached result if valid
    if (_isCacheValid()) {
      return _cachedNetworkType!;
    }

    try {
      final result = await _connectivity.checkConnectivity();
      _updateCache(result);
      return result;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('📶 Network detection failed: $e');
      }
      // Conservative fallback - assume WiFi
      const fallback = [ConnectivityResult.wifi];
      _updateCache(fallback);
      return fallback;
    }
  }

  @override
  void clearCache() {
    _cachedNetworkType = null;
    _lastCheck = null;
  }

  @override
  List<ConnectivityResult>? get cachedNetworkType => _cachedNetworkType;

  bool _isCacheValid() {
    return _cachedNetworkType != null &&
        _lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < cacheDuration;
  }

  void _updateCache(List<ConnectivityResult> networkType) {
    _cachedNetworkType = networkType;
    _lastCheck = DateTime.now();
  }
}

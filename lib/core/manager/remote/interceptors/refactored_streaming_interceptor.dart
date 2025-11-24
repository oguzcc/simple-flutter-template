import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:daisy/core/manager/remote/services/device_capability_service.dart';
import 'package:daisy/core/manager/remote/services/metrics_collector.dart';
import 'package:daisy/core/manager/remote/services/network_monitor_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Clean, lightweight streaming interceptor using service delegation
/// Total lines: ~200 (vs 1000+ in original)
class RefactoredStreamingInterceptor extends Interceptor {
  RefactoredStreamingInterceptor({
    required this.deviceService,
    required this.networkService,
    required this.metricsCollector,
    this.enableStreaming = true,
    this.smallFileThreshold = 100 * 1024,
    this.mediumFileThreshold = 1024 * 1024,
    this.maxBufferSize = 10 * 1024 * 1024,
    this.streamingTimeout = const Duration(seconds: 30),
  });

  // Services (dependency injection)
  final IDeviceCapabilityService deviceService;
  final INetworkMonitorService networkService;
  final IMetricsCollector metricsCollector;

  // Configuration
  final bool enableStreaming;
  final int smallFileThreshold;
  final int mediumFileThreshold;
  final int maxBufferSize;
  final Duration streamingTimeout;

  @override
  Future<void> onResponse(
      Response<dynamic> response,
      ResponseInterceptorHandler handler) async {
    
    await metricsCollector.incrementCounter('total_requests');

    if (!enableStreaming || !_shouldStream(response)) {
      handler.next(response);
      return;
    }

    try {
      final processedResponse = await _processStreamingResponse(response);
      await metricsCollector.incrementCounter('streamed_requests');
      handler.next(processedResponse);
    } on TimeoutException catch (e) {
      await metricsCollector.recordError('timeout', e.message ?? 'Unknown timeout');
      handler.next(response);
    } on Exception catch (e) {
      await metricsCollector.recordError('streaming', e.toString());
      await metricsCollector.incrementCounter('fallback_requests');
      handler.next(response);
    }
  }

  /// Simple streaming decision logic
  bool _shouldStream(Response<dynamic> response) {
    // Only stream ResponseBody responses
    if (response.data is! ResponseBody) return false;
    
    // Check if explicitly disabled
    if (response.requestOptions.extra['disable_streaming'] == true) {
      return false;
    }

    // Check content length
    final contentLength = _getContentLength(response.headers);
    if (contentLength > 0 && contentLength < smallFileThreshold) {
      return false; // Too small
    }

    // Check content type - don't stream media files
    final contentType = response.headers.value('content-type')?.toLowerCase() ?? '';
    if (contentType.contains('image/') || 
        contentType.contains('video/') ||
        contentType.contains('audio/')) {
      return false;
    }

    return true;
  }

  /// Process streaming response with timeout protection
  Future<Response<dynamic>> _processStreamingResponse(
      Response<dynamic> response) async {
    
    final stopwatch = Stopwatch()..start();
    final responseBody = response.data as ResponseBody;
    
    try {
      // Get context from services
      final deviceCapabilities = await deviceService.getDeviceCapabilities();
      final networkType = await networkService.getCurrentNetworkType();
      
      // Select processing strategy
      final contentLength = _getContentLength(response.headers);
      final strategy = _selectStrategy(contentLength, deviceCapabilities, networkType);
      
      // Process with timeout
      final bytes = await strategy(responseBody.stream, contentLength)
          .timeout(streamingTimeout);
      
      final decodedData = _decodeResponse(bytes, response.headers);
      
      stopwatch.stop();
      await metricsCollector.recordProcessingTime(stopwatch.elapsedMilliseconds);

      return Response<dynamic>(
        data: decodedData,
        headers: response.headers,
        requestOptions: response.requestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: {
          ...response.extra,
          'streaming_processed': true,
          'processing_time_ms': stopwatch.elapsedMilliseconds,
          'bytes_processed': bytes.length,
          'device_tier': deviceCapabilities.tier.name,
          'network_type': networkType.toString(),
        },
      );
    } finally {
      stopwatch.stop();
    }
  }

  /// Select optimal processing strategy based on context
  Future<Uint8List> Function(Stream<List<int>>, int) _selectStrategy(
    int contentLength,
    DeviceCapabilities device,
    List<ConnectivityResult> network,
  ) {
    // Calculate adaptive thresholds
    final adjustedSmallThreshold = _calculateThreshold(
      smallFileThreshold, device.tier, network);
    final adjustedMediumThreshold = _calculateThreshold(
      mediumFileThreshold, device.tier, network);

    if (contentLength <= adjustedSmallThreshold || 
        (contentLength <= 0 && device.isLowEndDevice)) {
      return _processSimple;
    } else if (contentLength <= adjustedMediumThreshold || contentLength <= 0) {
      return _processProgressive;
    } else {
      return _processWithLimits;
    }
  }

  /// Calculate adaptive threshold based on device and network
  int _calculateThreshold(
    int baseThreshold, 
    DeviceTier deviceTier, 
    List<ConnectivityResult> networkType,
  ) {
    var threshold = baseThreshold;

    // Device tier adjustment
    switch (deviceTier) {
      case DeviceTier.low:
        threshold = (threshold * 0.4).round();
      case DeviceTier.high:
        threshold = (threshold * 2.0).round();
      case DeviceTier.medium:
        break; // Use base value
    }

    // Network type adjustment
    if (networkType.contains(ConnectivityResult.mobile)) {
      threshold = (threshold * 0.6).round();
    } else if (networkType.contains(ConnectivityResult.ethernet)) {
      threshold = (threshold * 1.5).round();
    }

    return threshold;
  }

  /// Simple processing for small files
  Future<Uint8List> _processSimple(Stream<List<int>> stream, int contentLength) async {
    final chunks = <List<int>>[];
    var totalSize = 0;

    await for (final chunk in stream) {
      chunks.add(chunk);
      totalSize += chunk.length;
      if (totalSize > maxBufferSize) break;
    }

    return _combineChunks(chunks, totalSize);
  }

  /// Progressive processing with periodic yielding
  Future<Uint8List> _processProgressive(Stream<List<int>> stream, int contentLength) async {
    final buffer = <int>[];
    var totalSize = 0;
    var lastYield = DateTime.now();

    await for (final chunk in stream) {
      buffer.addAll(chunk);
      totalSize += chunk.length;

      // Yield periodically to prevent UI blocking
      final now = DateTime.now();
      if (now.difference(lastYield).inMilliseconds > 10) {
        await Future<void>.delayed(Duration.zero);
        lastYield = now;
      }

      if (totalSize > maxBufferSize) break;
    }

    return Uint8List.fromList(buffer);
  }

  /// Limited processing for large responses
  Future<Uint8List> _processWithLimits(Stream<List<int>> stream, int contentLength) async {
    final buffer = <int>[];
    var totalSize = 0;
    final limit = (maxBufferSize * 0.8).round(); // Conservative limit

    await for (final chunk in stream) {
      final remainingSpace = limit - totalSize;
      if (remainingSpace <= 0) break;

      if (chunk.length <= remainingSpace) {
        buffer.addAll(chunk);
        totalSize += chunk.length;
      } else {
        buffer.addAll(chunk.take(remainingSpace));
        break;
      }
    }

    return Uint8List.fromList(buffer);
  }

  /// Efficient chunk combination
  Uint8List _combineChunks(List<List<int>> chunks, int totalSize) {
    final result = Uint8List(totalSize);
    var offset = 0;
    
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    
    return result;
  }

  /// Decode response data with comprehensive content-type handling
  dynamic _decodeResponse(Uint8List bytes, Headers headers) {
    final contentType = headers.value('content-type')?.toLowerCase() ?? '';

    try {
      // JSON content
      if (contentType.contains('application/json') || 
          (contentType.isEmpty && _looksLikeJson(bytes))) {
        return json.decode(utf8.decode(bytes));
      }
      
      // Text content
      if (contentType.contains('text/') || 
          contentType.contains('application/xml')) {
        return utf8.decode(bytes);
      }
      
      // Binary content
      if (contentType.contains('image/') || 
          contentType.contains('video/') ||
          contentType.contains('application/octet-stream')) {
        return bytes;
      }
      
      // Default: try JSON first, fallback to text
      try {
        return json.decode(utf8.decode(bytes));
      } on Exception {
        return utf8.decode(bytes);
      }
      
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('🌊 Decoding failed: $e');
      }
      return String.fromCharCodes(bytes);
    }
  }

  /// Heuristic to detect JSON content
  bool _looksLikeJson(Uint8List bytes) {
    if (bytes.length < 2) return false;
    final first = bytes.first;
    final last = bytes.last;
    return (first == 123 && last == 125) || (first == 91 && last == 93);
  }

  int _getContentLength(Headers headers) {
    final contentLengthHeader = headers.value('content-length');
    return int.tryParse(contentLengthHeader ?? '') ?? 0;
  }

  /// Get metrics from collector
  Future<Map<String, dynamic>> getMetrics() => metricsCollector.getMetrics();

  /// Reset metrics
  Future<void> resetMetrics() => metricsCollector.resetMetrics();

  /// Clear service caches
  void clearCaches() {
    deviceService.clearCache();
    networkService.clearCache();
  }
}

import 'dart:convert';

import 'package:daisy/core/manager/remote/interceptors/refactored_streaming_interceptor.dart';
import 'package:daisy/core/manager/remote/services/device_capability_service.dart';
import 'package:daisy/core/manager/remote/services/metrics_collector.dart';
import 'package:daisy/core/manager/remote/services/network_monitor_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('RefactoredStreamingInterceptor Tests', () {
    late RefactoredStreamingInterceptor interceptor;
    late DeviceCapabilityService deviceService;
    late NetworkMonitorService networkService;
    late MetricsCollector metricsCollector;

    setUp(() {
      deviceService = DeviceCapabilityService();
      networkService = NetworkMonitorService();
      metricsCollector = MetricsCollector();
      interceptor = RefactoredStreamingInterceptor(
        deviceService: deviceService,
        networkService: networkService,
        metricsCollector: metricsCollector,
      );
    });

    tearDown(() async {
      interceptor.clearCaches();
      await interceptor.resetMetrics();
    });

    test('should create interceptor with default settings', () {
      expect(interceptor.enableStreaming, isTrue);
      expect(interceptor.smallFileThreshold, equals(100 * 1024)); // 100KB
      expect(interceptor.mediumFileThreshold, equals(1024 * 1024)); // 1MB
      expect(interceptor.maxBufferSize, equals(10 * 1024 * 1024)); // 10MB
      expect(interceptor.streamingTimeout, equals(const Duration(seconds: 30)));
    });

    test('should create interceptor with custom settings', () {
      final customInterceptor = RefactoredStreamingInterceptor(
        deviceService: deviceService,
        networkService: networkService,
        metricsCollector: metricsCollector,
        enableStreaming: false,
        smallFileThreshold: 50 * 1024,
        mediumFileThreshold: 512 * 1024,
        maxBufferSize: 5 * 1024 * 1024,
        streamingTimeout: const Duration(seconds: 15),
      );

      expect(customInterceptor.enableStreaming, isFalse);
      expect(customInterceptor.smallFileThreshold, equals(50 * 1024));
      expect(customInterceptor.mediumFileThreshold, equals(512 * 1024));
      expect(customInterceptor.maxBufferSize, equals(5 * 1024 * 1024));
      expect(customInterceptor.streamingTimeout, 
          equals(const Duration(seconds: 15)));
    });

    test('should provide metrics when enabled', () async {
      final metrics = await interceptor.getMetrics();
      
      expect(metrics, isA<Map<String, dynamic>>());
      expect(metrics['counters'], isA<Map<String, int>>());
      expect(metrics['performance'], isA<Map<String, dynamic>>());
      expect(metrics['recent_errors'], isA<List<dynamic>>());
      expect(metrics['error_summary'], isA<Map<String, int>>());
      expect(metrics['metrics_info'], isA<Map<String, dynamic>>());
    });

    test('should reset metrics correctly', () async {
      // Get initial metrics
      var metrics = await interceptor.getMetrics();
      final counters = metrics['counters'] as Map<String, dynamic>;
      expect(counters['total_requests'], equals(0));
      
      // Reset should work without error
      await interceptor.resetMetrics();
      
      // Metrics should still be zero
      metrics = await interceptor.getMetrics();
      final resetCounters = metrics['counters'] as Map<String, dynamic>;
      expect(resetCounters['total_requests'], equals(0));
    });

    test('should clear caches without error', () {
      expect(() => interceptor.clearCaches(), returnsNormally);
    });

    test('should handle basic response processing with mock data', () async {
      // Create a mock response that would not be streamed (non-ResponseBody)
      final mockResponse = Response<String>(
        data: 'test data',
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      final handler = MockResponseInterceptorHandler();
      
      // Should pass through non-ResponseBody responses
      await interceptor.onResponse(mockResponse, handler);
      expect(handler.nextCalled, isTrue);
      expect(handler.lastResponse, equals(mockResponse));
    });

    test('should respect disable_streaming option', () async {
      // Test that streaming can be explicitly disabled via options
      final testData = json.encode({'test': 'data'});
      final mockResponse = Response<ResponseBody>(
        data: ResponseBody(
          Stream.value(utf8.encode(testData)),
          200,
          headers: {'content-length': [testData.length.toString()]},
        ),
        statusCode: 200,
        requestOptions: RequestOptions(
          path: '/test',
          extra: {'disable_streaming': true},
        ),
      );

      final handler = MockResponseInterceptorHandler();
      await interceptor.onResponse(mockResponse, handler);

      // Should pass through without streaming when disabled
      expect(handler.nextCalled, isTrue);
      expect(handler.lastResponse, equals(mockResponse));
    });

    test('should handle streaming disabled interceptor', () async {
      final disabledInterceptor = RefactoredStreamingInterceptor(
        deviceService: deviceService,
        networkService: networkService,
        metricsCollector: metricsCollector,
        enableStreaming: false,
      );

      final testData = json.encode({'test': 'data'});
      final mockResponse = Response<ResponseBody>(
        data: ResponseBody(
          Stream.value(utf8.encode(testData)),
          200,
          headers: {'content-length': [testData.length.toString()]},
        ),
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

      final handler = MockResponseInterceptorHandler();
      await disabledInterceptor.onResponse(mockResponse, handler);

      // Should pass through when streaming is disabled
      expect(handler.nextCalled, isTrue);
      expect(handler.lastResponse, equals(mockResponse));
    });

    test('DeviceCapabilityService should work correctly', () async {
      final capabilities = await deviceService.getDeviceCapabilities();
      
      expect(capabilities, isA<DeviceCapabilities>());
      expect(capabilities.tier, isA<DeviceTier>());
      expect(capabilities.estimatedMemoryMB, greaterThan(0));
      expect(capabilities.processorCount, greaterThan(0));
      expect(capabilities.platform, isA<String>());
      expect(capabilities.model, isA<String>());
      expect(capabilities.isLowEndDevice, isA<bool>());
    });

    test('NetworkMonitorService should work correctly', () async {
      // Skip platform channel tests in unit test environment
      return;
    }, skip: 'Platform channels not available in unit tests');

    test('MetricsCollector should work correctly', () async {
      await metricsCollector.incrementCounter('test_counter');
      await metricsCollector.recordProcessingTime(100);
      await metricsCollector.recordError('test', 'test error');
      
      final metrics = await metricsCollector.getMetrics();
      final counters = metrics['counters'] as Map<String, dynamic>;
      final performance = metrics['performance'] as Map<String, dynamic>;
      final recentErrors = metrics['recent_errors'] as List<dynamic>;
      final errorSummary = metrics['error_summary'] as Map<String, dynamic>;
      
      expect(counters['test_counter'], equals(1));
      expect(performance['total_processing_samples'], equals(1));
      expect(recentErrors, hasLength(1));
      expect(errorSummary['test'], equals(1));
    });

    test('service caches should work correctly', () async {
      // First call should trigger detection
      await deviceService.getDeviceCapabilities();
      expect(deviceService.cachedCapabilities, isNotNull);
      
      // Clear caches
      interceptor.clearCaches();
      expect(deviceService.cachedCapabilities, isNull);
    });
  });
}

// Mock classes for testing
class MockResponseInterceptorHandler extends ResponseInterceptorHandler {
  bool nextCalled = false;
  Response<dynamic>? lastResponse;

  @override
  void next(Response<dynamic> response) {
    nextCalled = true;
    lastResponse = response;
  }
}

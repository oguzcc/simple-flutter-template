import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Interface for device capability detection
abstract class IDeviceCapabilityService {
  Future<DeviceCapabilities> getDeviceCapabilities();
  void clearCache();
  DeviceCapabilities? get cachedCapabilities;
}

/// Service responsible for detecting and caching device capabilities
class DeviceCapabilityService implements IDeviceCapabilityService {
  DeviceCapabilityService({
    this.cacheDuration = const Duration(minutes: 15),
  }) : _deviceInfo = DeviceInfoPlugin();

  final Duration cacheDuration;
  final DeviceInfoPlugin _deviceInfo;

  // Cache management
  DeviceCapabilities? _cachedCapabilities;
  DateTime? _lastDetection;

  @override
  Future<DeviceCapabilities> getDeviceCapabilities() async {
    // Return cached result if valid
    if (_isCacheValid()) {
      return _cachedCapabilities!;
    }

    try {
      final capabilities = await _detectDeviceCapabilities();
      _updateCache(capabilities);
      return capabilities;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('📱 Device detection failed: $e');
      }
      // Return conservative fallback
      final fallback = DeviceCapabilities.conservativeFallback();
      _updateCache(fallback);
      return fallback;
    }
  }

  @override
  void clearCache() {
    _cachedCapabilities = null;
    _lastDetection = null;
  }

  @override
  DeviceCapabilities? get cachedCapabilities => _cachedCapabilities;

  bool _isCacheValid() {
    return _cachedCapabilities != null &&
        _lastDetection != null &&
        DateTime.now().difference(_lastDetection!) < cacheDuration;
  }

  void _updateCache(DeviceCapabilities capabilities) {
    _cachedCapabilities = capabilities;
    _lastDetection = DateTime.now();
  }

  Future<DeviceCapabilities> _detectDeviceCapabilities() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return _analyzeAndroidDevice(androidInfo);
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return _analyzeIOSDevice(iosInfo);
    } else {
      return DeviceCapabilities.unknownPlatform();
    }
  }

  DeviceCapabilities _analyzeAndroidDevice(AndroidDeviceInfo info) {
    final sdkInt = info.version.sdkInt;
    final model = info.model.toLowerCase();
    final processorCount = Platform.numberOfProcessors;

    // Optimized pattern matching using Sets
    const highEndPatterns = {
      'pixel', 'galaxy s', 'oneplus', 'mi 1', 'mate', 'xperia 1', 'note'
    };
    const lowEndPatterns = {
      'go', 'lite', 'mini', 'budget', 'galaxy a1', 'galaxy a2', 'redmi'
    };

    var tier = DeviceTier.medium;
    var memoryEstimate = 4096; // 4GB default

    // SDK level analysis
    if (sdkInt < 23) {
      tier = DeviceTier.low;
      memoryEstimate = 2048;
    } else if (sdkInt >= 30) {
      tier = DeviceTier.high;
      memoryEstimate = 6144;
    }

    // Optimized model-based analysis
    if (highEndPatterns.any(model.contains)) {
      tier = DeviceTier.high;
      memoryEstimate = _max(memoryEstimate, 6144);
    } else if (lowEndPatterns.any(model.contains)) {
      tier = DeviceTier.low;
      memoryEstimate = _min(memoryEstimate, 2048);
    }

    // Processor count consideration
    if (processorCount <= 4) {
      tier = DeviceTier.values[_max(tier.index - 1, 0)];
    } else if (processorCount >= 8) {
      tier = DeviceTier.values[_min(tier.index + 1, DeviceTier.values.length - 1)];
    }

    return DeviceCapabilities(
      tier: tier,
      estimatedMemoryMB: memoryEstimate,
      processorCount: processorCount,
      platform: 'Android ${info.version.release}',
      model: info.model,
      isLowEndDevice: tier == DeviceTier.low,
    );
  }

  DeviceCapabilities _analyzeIOSDevice(IosDeviceInfo info) {
    final model = info.model.toLowerCase();
    final systemVersion = info.systemVersion;
    final processorCount = Platform.numberOfProcessors;
    
    var tier = DeviceTier.high; // iOS devices generally perform well
    var memoryEstimate = 4096;

    // Optimized iOS model patterns
    const highEndPatterns = {'pro', '15', '14', '13', 'ipad pro'};
    const mediumEndPatterns = {'se', '6', '7', '8', 'mini'};

    if (model.contains('iphone')) {
      if (highEndPatterns.any(model.contains)) {
        tier = DeviceTier.high;
        memoryEstimate = 6144;
      } else if (mediumEndPatterns.any(model.contains)) {
        tier = DeviceTier.medium;
        memoryEstimate = 3072;
      }
    } else if (model.contains('ipad')) {
      if (model.contains('pro')) {
        tier = DeviceTier.high;
        memoryEstimate = 8192;
      } else if (model.contains('mini')) {
        tier = DeviceTier.medium;
        memoryEstimate = 3072;
      }
    }

    // System version consideration
    final majorVersion = int.tryParse(systemVersion.split('.').first) ?? 0;
    if (majorVersion < 13) {
      tier = DeviceTier.values[_max(tier.index - 1, 0)];
    }

    return DeviceCapabilities(
      tier: tier,
      estimatedMemoryMB: memoryEstimate,
      processorCount: processorCount,
      platform: 'iOS $systemVersion',
      model: info.model,
      isLowEndDevice: tier == DeviceTier.low,
    );
  }

  int _max(int a, int b) => a > b ? a : b;
  int _min(int a, int b) => a < b ? a : b;
}

// Supporting classes
enum DeviceTier { low, medium, high }

class DeviceCapabilities {
  const DeviceCapabilities({
    required this.tier,
    required this.estimatedMemoryMB,
    required this.processorCount,
    required this.platform,
    required this.model,
    required this.isLowEndDevice,
  });

  final DeviceTier tier;
  final int estimatedMemoryMB;
  final int processorCount;
  final String platform;
  final String model;
  final bool isLowEndDevice;

  static DeviceCapabilities conservativeFallback() {
    return DeviceCapabilities(
      tier: DeviceTier.low,
      estimatedMemoryMB: 2048,
      processorCount: Platform.numberOfProcessors,
      platform: Platform.operatingSystem,
      model: 'Unknown',
      isLowEndDevice: true,
    );
  }

  static DeviceCapabilities unknownPlatform() {
    return DeviceCapabilities(
      tier: DeviceTier.medium,
      estimatedMemoryMB: 4096,
      processorCount: Platform.numberOfProcessors,
      platform: Platform.operatingSystem,
      model: 'Unknown',
      isLowEndDevice: false,
    );
  }

  @override
  String toString() => 'DeviceCapabilities('
      'tier: $tier, '
      'memory: ${estimatedMemoryMB}MB, '
      'cores: $processorCount, '
      'platform: $platform)';
}

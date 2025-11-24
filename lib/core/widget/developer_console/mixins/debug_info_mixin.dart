import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Mixin for system info collection and device debugging
mixin DebugInfoMixin {
  /// App version information
  String _appVersion = 'Unknown';
  String _appName = 'Unknown';
  String _packageName = 'Unknown';
  String _buildNumber = 'Unknown';
  
  /// Firebase information
  String _firebaseProjectId = 'Unknown';
  bool _firebaseInitialized = false;
  
  /// Device information
  String _platformName = 'Unknown';
  String _platformVersion = 'Unknown';
  bool _isDebugMode = kDebugMode;

  /// Get app version
  String get appVersion => _appVersion;
  
  /// Get app name
  String get appName => _appName;
  
  /// Get package name
  String get packageName => _packageName;
  
  /// Get build number
  String get buildNumber => _buildNumber;
  
  /// Get Firebase project ID
  String get firebaseProjectId => _firebaseProjectId;
  
  /// Get Firebase initialization status
  bool get firebaseInitialized => _firebaseInitialized;
  
  /// Get platform name
  String get platformName => _platformName;
  
  /// Get platform version
  String get platformVersion => _platformVersion;
  
  /// Get debug mode status
  bool get isDebugMode => _isDebugMode;

  /// Initialize debug info collection
  Future<void> initializeDebugInfo() async {
    await _loadPackageInfo();
    _loadFirebaseInfo();
    _loadPlatformInfo();
  }

  /// Load package information
  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  /// Load Firebase information
  void _loadFirebaseInfo() {
    try {
      _firebaseInitialized = Firebase.apps.isNotEmpty;
      if (_firebaseInitialized) {
        final app = Firebase.app();
        _firebaseProjectId = app.options.projectId ?? 'Unknown';
      }
    } catch (e) {
      debugPrint('Error loading Firebase info: $e');
      _firebaseInitialized = false;
    }
  }

  /// Load platform information
  void _loadPlatformInfo() {
    try {
      _platformName = Platform.operatingSystem;
      _platformVersion = Platform.operatingSystemVersion;
    } catch (e) {
      debugPrint('Error loading platform info: $e');
    }
  }

  /// Get comprehensive system information
  Map<String, dynamic> getSystemInfo() {
    return {
      'app': {
        'name': _appName,
        'version': _appVersion,
        'packageName': _packageName,
        'buildNumber': _buildNumber,
      },
      'platform': {
        'name': _platformName,
        'version': _platformVersion,
        'isDebugMode': _isDebugMode,
      },
      'firebase': {
        'initialized': _firebaseInitialized,
        'projectId': _firebaseProjectId,
      },
      'flutter': {
        'version': kDebugMode ? 'Debug' : 'Release',
        'debugMode': kDebugMode,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get app information as formatted strings for UI display
  List<String> getAppInfoStrings() {
    return [
      'App Name: $_appName',
      'Version: $_appVersion',
      'Build Number: $_buildNumber',
      'Package: $_packageName',
      'Debug Mode: ${_isDebugMode ? 'Enabled' : 'Disabled'}',
    ];
  }

  /// Get platform information as formatted strings for UI display
  List<String> getPlatformInfoStrings() {
    return [
      'Platform: $_platformName',
      'OS Version: $_platformVersion',
      'Debug Build: ${kDebugMode ? 'Yes' : 'No'}',
      'Profile Build: ${kProfileMode ? 'Yes' : 'No'}',
      'Release Build: ${kReleaseMode ? 'Yes' : 'No'}',
    ];
  }

  /// Get Firebase information as formatted strings for UI display
  List<String> getFirebaseInfoStrings() {
    return [
      'Initialized: ${_firebaseInitialized ? 'Yes' : 'No'}',
      'Project ID: $_firebaseProjectId',
      'Apps Count: ${Firebase.apps.length}',
    ];
  }

  /// Get memory information (basic)
  Map<String, String> getMemoryInfo() {
    // Note: This is limited on mobile platforms
    // More detailed memory info would require platform-specific implementations
    return {
      'Available': 'Platform Limited',
      'Used': 'Platform Limited',
      'Total': 'Platform Limited',
      'Note': 'Detailed memory info requires platform channels',
    };
  }

  /// Get network logger information
  Map<String, dynamic> getNetworkLoggerInfo() {
    return {
      'status': 'Enabled',
      'logsCount': 0, // This would be updated by network mixin
      'maxLogs': 100,
      'sensitiveHeadersFiltered': true,
    };
  }

  /// Refresh all debug information
  Future<void> refreshDebugInfo() async {
    await _loadPackageInfo();
    _loadFirebaseInfo();
    _loadPlatformInfo();
  }

  /// Export debug info for sharing or logging
  Map<String, dynamic> exportDebugInfo() {
    return {
      'deviceInfo': getSystemInfo(),
      'memoryInfo': getMemoryInfo(),
      'networkInfo': getNetworkLoggerInfo(),
      'exportTimestamp': DateTime.now().toIso8601String(),
    };
  }
}
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateManager {
  final _remoteConfig = FirebaseRemoteConfig.instance;
  
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await _remoteConfig.fetch();
      await _remoteConfig.activate();
    } catch (e, stackTrace) {
      debugPrint('❌ Remote config initialization failed: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<ForceUpdateStatus> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final platform = Platform.isAndroid ? 'android' : 'ios';
      debugPrint('🔍 Platform: $platform');
      debugPrint('📱 Current App Version: $currentVersion');

      // Model üzerinden değerleri alalım
      final config = ForceUpdateConfig(
        androidMinVersion: _remoteConfig.getString('android_min_version'),
        androidCurrentVersion: _remoteConfig.getString(
          'android_current_version',
        ),
        iosMinVersion: _remoteConfig.getString('ios_min_version'),
        iosCurrentVersion: _remoteConfig.getString('ios_current_version'),
        isUpdateRequired: _remoteConfig.getBool('is_update_required'),
        isForceUpdateRequired: _remoteConfig.getBool(
          'is_force_update_required',
        ),
        androidStoreUrl: _remoteConfig.getString('android_store_url'),
        iosStoreUrl: _remoteConfig.getString('ios_store_url'),
        updateMessageTr: _remoteConfig.getString('update_message_tr'),
        updateMessageEn: _remoteConfig.getString('update_message_en'),
      );

      debugPrint('⚙️ Remote Config Values:');
      debugPrint('Android Min Version: ${config.androidMinVersion}');
      debugPrint('Android Current Version: ${config.androidCurrentVersion}');
      debugPrint('iOS Min Version: ${config.iosMinVersion}');
      debugPrint('iOS Current Version: ${config.iosCurrentVersion}');
      debugPrint('Update Required: ${config.isUpdateRequired}');
      debugPrint('Force Update Required: ${config.isForceUpdateRequired}');

      final minVersion =
          platform == 'android'
              ? config.androidMinVersion
              : config.iosMinVersion;
      final currentRemoteVersion =
          platform == 'android'
              ? config.androidCurrentVersion
              : config.iosCurrentVersion;
      final storeUrl =
          platform == 'android' ? config.androidStoreUrl : config.iosStoreUrl;

      debugPrint('📊 Version Comparison:');
      debugPrint('Min Required Version: $minVersion');
      debugPrint('Current Remote Version: $currentRemoteVersion');

      // Versiyon kontrolü
      final needsUpdate = _isVersionLower(currentVersion, minVersion);
      debugPrint('🔄 Needs Update: $needsUpdate');

      final message =
          Platform.localeName.split('_')[0] == 'tr'
              ? config.updateMessageTr
              : config.updateMessageEn;

      if (needsUpdate) {
        return ForceUpdateStatus(
          required: config.isForceUpdateRequired,
          message: message,
          storeUrl: storeUrl,
        );
      }

      if (needsUpdate && config.isForceUpdateRequired) {
        return ForceUpdateStatus(
          required: true,
          message: message,
          storeUrl: storeUrl,
          isForceUpdate: true,
        );
      }

      // Güncelleme gerekmiyorsa
      debugPrint('✅ No Update Required');
      return ForceUpdateStatus(required: false);
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
      return ForceUpdateStatus(required: false);
    }
  }

  bool _isVersionLower(String currentVersion, String minVersion) {
    final currentParts = currentVersion.split('+');
    final minParts = minVersion.split('+');

    final currentVersionParts =
        currentParts[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final minVersionParts =
        minParts[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (currentVersionParts.length < minVersionParts.length) {
      currentVersionParts.add(0);
    }
    while (minVersionParts.length < currentVersionParts.length) {
      minVersionParts.add(0);
    }

    // Versiyon numaralarını karşılaştır (1.0.0)
    for (var i = 0; i < minVersionParts.length; i++) {
      if (currentVersionParts[i] < minVersionParts[i]) {
        return true;
      }
      if (currentVersionParts[i] > minVersionParts[i]) {
        return false;
      }
    }

    // Versiyon numaraları eşitse build numaralarını karşılaştır (+36)
    final currentBuild =
        int.tryParse(currentParts.length > 1 ? currentParts[1] : '0') ?? 0;
    final minBuild = int.tryParse(minParts.length > 1 ? minParts[1] : '0') ?? 0;

    // Build numarası küçükse güncelleme gerekli
    return currentBuild < minBuild;
  }
}

class ForceUpdateConfig {
  ForceUpdateConfig({
    required this.androidMinVersion,
    required this.androidCurrentVersion,
    required this.iosMinVersion,
    required this.iosCurrentVersion,
    required this.isUpdateRequired,
    required this.isForceUpdateRequired,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.updateMessageTr,
    required this.updateMessageEn,
  });

  final String androidMinVersion;
  final String androidCurrentVersion;
  final String iosMinVersion;
  final String iosCurrentVersion;
  final bool isUpdateRequired;
  final bool isForceUpdateRequired;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final String updateMessageTr;
  final String updateMessageEn;
}

class ForceUpdateStatus {
  ForceUpdateStatus({
    required this.required,
    this.message,
    this.storeUrl,
    this.isForceUpdate = false,
  });
  final bool required;
  final String? message;
  final String? storeUrl;
  final bool isForceUpdate;
}
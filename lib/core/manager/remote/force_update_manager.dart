import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateRequirement { none, optional, forced }

@immutable
class ForceUpdateResult {
  const ForceUpdateResult({
    required this.requirement,
    this.message,
    this.storeUrl,
  });

  const ForceUpdateResult.none()
      : requirement = UpdateRequirement.none,
        message = null,
        storeUrl = null;

  final UpdateRequirement requirement;
  final String? message;
  final String? storeUrl;

  bool get hasUpdate => requirement != UpdateRequirement.none;
  bool get isForced => requirement == UpdateRequirement.forced;
}

class ForceUpdateManager {
  ForceUpdateManager({
    FirebaseRemoteConfig? remoteConfig,
    PackageInfo? packageInfo,
  })  : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance,
        _packageInfoOverride = packageInfo;

  final FirebaseRemoteConfig _remoteConfig;
  final PackageInfo? _packageInfoOverride;
  bool _initialized = false;

  static const _kAndroidMinVersion = 'android_min_version';
  static const _kIosMinVersion = 'ios_min_version';
  static const _kIsForceUpdateRequired = 'is_force_update_required';
  static const _kAndroidStoreUrl = 'android_store_url';
  static const _kIosStoreUrl = 'ios_store_url';
  static const _kUpdateMessageTr = 'update_message_tr';
  static const _kUpdateMessageEn = 'update_message_en';

  Future<ForceUpdateResult> evaluate({String? languageCode}) async {
    await _ensureInitialized();
    try {
      final packageInfo =
          _packageInfoOverride ?? await PackageInfo.fromPlatform();

      final isAndroid = Platform.isAndroid;
      final minVersion = _remoteConfig
          .getString(isAndroid ? _kAndroidMinVersion : _kIosMinVersion);
      final storeUrl = _remoteConfig
          .getString(isAndroid ? _kAndroidStoreUrl : _kIosStoreUrl);

      if (minVersion.isEmpty || storeUrl.isEmpty) {
        return const ForceUpdateResult.none();
      }

      final needsUpdate = _isVersionLower(
        currentVersion: packageInfo.version,
        currentBuild: int.tryParse(packageInfo.buildNumber) ?? 0,
        minVersion: minVersion,
      );
      if (!needsUpdate) return const ForceUpdateResult.none();

      final isForced = _remoteConfig.getBool(_kIsForceUpdateRequired);
      return ForceUpdateResult(
        requirement:
            isForced ? UpdateRequirement.forced : UpdateRequirement.optional,
        message: _resolveMessage(languageCode),
        storeUrl: storeUrl,
      );
    } catch (e, stack) {
      debugPrint('ForceUpdateManager.evaluate failed: $e');
      debugPrint('$stack');
      return const ForceUpdateResult.none();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await _remoteConfig.setDefaults(const {
        _kAndroidMinVersion: '0.0.0',
        _kIosMinVersion: '0.0.0',
        _kIsForceUpdateRequired: false,
        _kAndroidStoreUrl: '',
        _kIosStoreUrl: '',
        _kUpdateMessageTr: '',
        _kUpdateMessageEn: '',
      });
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
      _initialized = true;
    } catch (e, stack) {
      debugPrint('ForceUpdateManager init failed: $e');
      debugPrint('$stack');
    }
  }

  String? _resolveMessage(String? languageCode) {
    final tr = _remoteConfig.getString(_kUpdateMessageTr);
    final en = _remoteConfig.getString(_kUpdateMessageEn);
    final code = (languageCode ?? 'en').toLowerCase();
    final message = code == 'tr' ? tr : en;
    return message.isEmpty ? null : message;
  }

  bool _isVersionLower({
    required String currentVersion,
    required int currentBuild,
    required String minVersion,
  }) {
    final minParts = minVersion.split('+');
    final currentNumbers = _toIntList(currentVersion.split('+').first);
    final minNumbers = _toIntList(minParts.first);

    final length = currentNumbers.length > minNumbers.length
        ? currentNumbers.length
        : minNumbers.length;
    while (currentNumbers.length < length) {
      currentNumbers.add(0);
    }
    while (minNumbers.length < length) {
      minNumbers.add(0);
    }

    for (var i = 0; i < length; i++) {
      if (currentNumbers[i] < minNumbers[i]) return true;
      if (currentNumbers[i] > minNumbers[i]) return false;
    }

    final minBuild =
        minParts.length > 1 ? int.tryParse(minParts[1]) ?? 0 : 0;
    return currentBuild < minBuild;
  }

  List<int> _toIntList(String version) {
    return version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }
}

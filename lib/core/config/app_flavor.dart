import 'package:daisy/core/config/api_options.dart';
import 'package:flutter/material.dart';

enum FlavorType { development, staging, production }

/// FlavorConfig to configure flavors
class AppFlavor {
  /// Factory constructor
  factory AppFlavor({
    Color color = Colors.red,
    BannerLocation location = BannerLocation.topStart,
    IApiOption? apiOptions,
    Map<String, dynamic> variables = const {},
    FlavorType? flavorType,
  }) {
    _instance = AppFlavor._internal(
      color,
      location,
      apiOptions,
      variables,
      flavorType,
    );

    return _instance!;
  }
  factory AppFlavor.instance() {
    _instance ??= AppFlavor();
    return _instance!;
  }

  /// Private constructor
  AppFlavor._internal(
    this.color,
    this.location,
    this.apiOptions,
    this.variables,
    this.flavorType,
  );

  /// Color of the banner
  final Color color;

  /// Flavor type
  final FlavorType? flavorType;

  /// Location of the banner
  final BannerLocation location;

  /// Variables are dynamic
  final Map<String, dynamic> variables;
  final IApiOption? apiOptions;

  /// Internal instance of FlavorConfig
  static AppFlavor? _instance;
}

import 'dart:async';
import 'dart:developer';

import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:daisy/core/config/app_flavor.dart';
import 'package:daisy/core/manager/firebase/firebase_client.dart';
import 'package:daisy/core/manager/validation/environment_validation_service.dart';
import 'package:daisy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'bootstrap/mixins/analytics_mixin.dart';
// Part files for mixins
part 'bootstrap/mixins/environment_mixin.dart';
part 'bootstrap/mixins/firebase_mixin.dart';
part 'bootstrap/mixins/system_ui_mixin.dart';

/// Main bootstrap class with initialization mixins
class _AppBootstrap
    with _EnvironmentMixin, _FirebaseMixin, _AnalyticsMixin, _SystemUIMixin {
  /// Main bootstrap method
  Future<void> run(FutureOr<Widget> Function() builder) async {
    // Initialize app
    await _initializeApp();

    // Setup system UI
    await setupSystemUI();

    // Run app
    runApp(await builder());
  }

  /// Initialize all app services
  Future<void> _initializeApp() async {
    // Ensure widget bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment configuration
    await loadEnvironment();

    // Initialize Firebase
    await initializeFirebase();

    // Initialize Analytics
    await initializeAnalytics();

    // Validate environment
    await validateEnvironment();
  }
}

/// Public bootstrap function
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  final bootstrapper = _AppBootstrap();
  await bootstrapper.run(builder);
}

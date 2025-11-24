import 'dart:async';
import 'dart:developer';

import 'package:daisy/app/listener.dart';
import 'package:daisy/app/locator.dart';
import 'package:daisy/app/provider.dart';
import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:daisy/core/bloc/bloc_observer.dart';
import 'package:daisy/core/config/app_flavor.dart';
import 'package:daisy/core/config/core_strings.dart';
import 'package:daisy/core/manager/local/language_manager.dart';
import 'package:daisy/core/manager/remote/sentry_client.dart';
import 'package:daisy/core/manager/validation/environment_validation_service.dart';
import 'package:daisy/data/notification/notification_queue_manager.dart';
import 'package:daisy/data/notification/one_signal_service.dart';
import 'package:daisy/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// Part files for mixins
part 'bootstrap/mixins/environment_mixin.dart';
part 'bootstrap/mixins/firebase_mixin.dart';
part 'bootstrap/mixins/analytics_mixin.dart';
part 'bootstrap/mixins/notification_mixin.dart';
part 'bootstrap/mixins/storage_mixin.dart';
part 'bootstrap/mixins/system_ui_mixin.dart';
part 'bootstrap/mixins/sentry_mixin.dart';

/// Main bootstrap class with initialization mixins
class _AppBootstrap
    with
        _EnvironmentMixin,
        _FirebaseMixin,
        _AnalyticsMixin,
        _NotificationMixin,
        _StorageMixin,
        _SystemUIMixin,
        _SentryMixin {
  
  /// Main bootstrap method
  Future<void> run(FutureOr<Widget> Function() builder) async {
    // Setup error handling
    await setupErrorHandling();
    
    // Initialize app
    await _initializeApp();
    
    // Setup system UI
    await setupSystemUI();
    
    // Run app with Sentry
    await runAppWithSentry(builder);
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
    
    // Initialize Notifications
    await initializeNotifications();
    
    // Initialize Storage
    await initializeStorage();
    
    // Validate environment
    await validateEnvironment();
  }
}

/// Public bootstrap function
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  final bootstrapper = _AppBootstrap();
  await bootstrapper.run(builder);
}

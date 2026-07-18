import 'dart:async';
import 'dart:developer';

import 'package:daisy/app/locator.dart';
import 'package:daisy/app/provider.dart';
import 'package:daisy/core/analytics/analytics_service.dart';
import 'package:daisy/core/config/app_flavor.dart';
import 'package:daisy/core/manager/local/language_manager.dart';
import 'package:daisy/core/manager/notification/fcm_service.dart';
import 'package:daisy/core/manager/validation/environment_validation_service.dart';
import 'package:daisy/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

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

    // Build the (unwrapped) app widget provided by the flavor entrypoint.
    final app = await builder();

    // Wrap the app centrally so every flavor gets the same tree:
    //   EasyLocalization > MultiRepositoryProvider > MultiBlocProvider > App
    //
    // Order matters: repository providers (services) must sit ABOVE the bloc
    // providers, because cubits read their dependencies via `context.read`
    // inside their `create` callbacks.
    final repositoryProviders = await locator();

    runApp(
      EasyLocalization(
        supportedLocales: LanguageManager.instance.supportedLocales,
        path: LanguageManager.instance.path,
        fallbackLocale: LanguageManager.instance.fallbackLocale,
        child: MultiRepositoryProvider(
          providers: repositoryProviders,
          child: MultiBlocProvider(
            providers: provider(),
            child: app,
          ),
        ),
      ),
    );
  }

  /// Initialize all app services
  Future<void> _initializeApp() async {
    // Ensure widget bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize EasyLocalization before the widget tree reads translations,
    // otherwise `context.locale` throws "Null check operator used on a null
    // value".
    await EasyLocalization.ensureInitialized();

    // Initialize HydratedBloc storage BEFORE any HydratedCubit is created
    // (AuthCubit, LangCubit, SettingsCubit, ...), otherwise their constructors
    // throw "StorageNotFound: Storage was accessed before it was initialized".
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path,
            ),
    );

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

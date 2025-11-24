part of '../../bootstrap.dart';

/// Mixin for Sentry error tracking and app runner
mixin _SentryMixin {
  /// Setup error handling
  Future<void> setupErrorHandling() async {
    // Setup Bloc observer
    Bloc.observer = const AppBlocObserver();
    
    // Setup Flutter error handler
    FlutterError.onError = (details) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    };
    
    log('✅ Error handling configured');
  }
  
  /// Run app with Sentry integration
  Future<void> runAppWithSentry(FutureOr<Widget> Function() builder) async {
    await SentryClient.init(
      dsn: CoreStrings.sentryDsn,
      appRunner: () async => runApp(
        EasyLocalization(
          path: LanguageManager.instance.path,
          supportedLocales: LanguageManager.instance.supportedLocales,
          useFallbackTranslations: true,
          startLocale: LanguageManager.instance.enLocale,
          fallbackLocale: LanguageManager.instance.fallbackLocale,
          child: MultiRepositoryProvider(
            providers: await locator(),
            child: MultiBlocProvider(
              providers: provider(),
              child: MultiBlocListener(
                listeners: listener(),
                child: await builder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

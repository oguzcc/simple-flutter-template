part of '../view/splash_screen.dart';

mixin _SplashMixin<T extends StatefulWidget> on State<T> {
  String? _appVersion;
  String? _buildNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _runStartupChecks);
    });
  }

  Future<void> _runStartupChecks() async {
    if (!mounted) return;

    final startTime = DateTime.now();
    final languageCode = context.locale.languageCode;
    final updateCubit = context.read<AppUpdateCubit>();

    await Future.wait([
      _fetchVersion(),
      updateCubit.check(languageCode: languageCode),
    ]);
    if (!mounted) return;

    final updateState = updateCubit.state;
    if (updateState.hasUpdate) {
      await _showUpdateDialog(updateState);
      if (updateState.isForced) return;
      if (!mounted) return;
    }

    // Keep splash visible for at least 3s total (2s pre-delay + 1s here).
    const minimumSplashDuration = Duration(seconds: 1);
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minimumSplashDuration) {
      await Future<void>.delayed(minimumSplashDuration - elapsed);
    }
    if (!mounted) return;

    await _initializeApp();
  }

  Future<void> _fetchVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (_) {
      // Version display is non-critical; fall back to hidden.
    }
  }

  void initSplash() {
    // Initialization happens in initState.
  }

  //* MARK: Uygulama başlatıldığında internet bağlantısını kontrol et
  // NOTE: This method is currently unused but kept for potential future use
  // If you want to add internet connectivity check before app initialization,
  // call this method from initState instead of _initializeApp directly
  // ignore: unused_element
  Future<void> _checkInternetConnection() async {
    if (!mounted) return;

    final connCubit = context.read<ConnCubit?>();

    if (connCubit == null) {
      if (kDebugMode) {
        debugPrint('ConnCubit is null. Cannot check connectivity.');
      }
      await _initializeApp();
      return;
    }

    final connectivity = await connCubit.hasConnection();

    if (!connectivity) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Bağlantı Hatası'),
            content: const Text('İnternet bağlantınızı kontrol ediniz.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _checkInternetConnection();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        );
        return;
      }
    } else {
      await _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    try {
      final authCubit = context.read<AuthCubit?>();
      final homeCubit = context.read<HomeCubit?>();

      if (homeCubit != null && authCubit != null && authCubit.isAuthenticated) {
        await Future.wait([homeCubit.fetchInitialData()]);
      }

      if (!mounted) return;
      final auth = context.read<AuthCubit?>();
      log('🔍 Splash checking auth state: ${auth?.state.authStatus}');

      if (auth != null && auth.state.authStatus == AuthStatus.authenticated) {
        log('✅ User authenticated, navigating to home');
        context.goNamed(Screens.home.name);
      } else {
        log('❌ User not authenticated, navigating to login');
        context.goNamed(Screens.enhancedLogin.name);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Ana veri yüklenirken hata oluştu: $e');
      }
      if (mounted) {
        log('⚠️ Error occurred, defaulting to login');
        context.goNamed(Screens.enhancedLogin.name);
      }
    }
  }

  Future<void> _showUpdateDialog(AppUpdateState status) {
    final isForceUpdate = status.isForced;
    final theme = Theme.of(context);

    return WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          hasSabGradient: false,
          topBarTitle: Text(
            (isForceUpdate
                    ? LocaleKeys.update_title
                    : LocaleKeys.update_titleOptional)
                .tr(),
            style: theme.textTheme.titleLarge,
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: isForceUpdate
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  status.message ?? LocaleKeys.update_messageDefault.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openStore(status.storeUrl),
                    child: Text(LocaleKeys.update_actionUpdate.tr()),
                  ),
                ),
                if (!isForceUpdate) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(LocaleKeys.update_actionLater.tr()),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
      barrierDismissible: !isForceUpdate,
    );
  }

  Future<void> _openStore(String? storeUrl) async {
    if (storeUrl == null || storeUrl.isEmpty) return;
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

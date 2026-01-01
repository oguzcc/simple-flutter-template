part of '../view/splash_screen.dart';

mixin _SplashMixin<T extends StatefulWidget> on State<T> {
  final _forceUpdateManager = ForceUpdateManager();

  String? _appVersion;
  String? _buildNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2 saniye default bekleme süresi ekle, sonra diğer işlemleri başlat
      Future.delayed(const Duration(seconds: 2), () {
        Future.wait([_fetchVersion(), _checkForceUpdateAndContinue()]);
      });
    });
  }

  Future<void> _fetchVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Hata durumunda değerler null kalır
    }
  }

  Future<void> _checkForceUpdateAndContinue() async {
    // Başlangıç zamanını kaydet (minimum süre kontrolü için)
    final startTime = DateTime.now();

    // Force update kontrolü
    await _forceUpdateManager.initialize();
    final updateStatus = await _forceUpdateManager.checkForUpdate();
    if (updateStatus.required && mounted) {
      _showUpdateDialog(updateStatus);
      return;
    }

    // Minimum 1 saniye daha bekle (başta zaten 2 saniye beklemiştik)
    const minimumSplashDuration = Duration(seconds: 1);
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < minimumSplashDuration) {
      await Future<void>.delayed(minimumSplashDuration - elapsedTime);
    }

    // Force update gerekmiyorsa devam et
    if (mounted) {
      await _initializeApp();
    }
  }

  void initSplash() {
    // Initialization happens in initState
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
        // Internet warning dialog göster
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
                  _checkInternetConnection(); // Tekrar dene
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
      // AuthCubit kontrolü ve authentication durumu
      final authCubit = context.read<AuthCubit?>();
      final homeCubit = context.read<HomeCubit?>();

      // Temel verileri yükle (sadece authenticated kullanıcılar için)
      if (homeCubit != null && authCubit != null && authCubit.isAuthenticated) {
        await Future.wait([homeCubit.fetchInitialData()]);
      }

      // if forceUpdate is required then return
      final isForceUpdate = await _forceUpdateManager.checkForUpdate();
      if (isForceUpdate.required) {
        return;
      }

      // Authentication durumuna göre yönlendirme yap
      if (mounted) {
        final authCubit = context.read<AuthCubit?>();
        log('🔍 Splash checking auth state: ${authCubit?.state.authStatus}');

        if (authCubit != null &&
            authCubit.state.authStatus == AuthStatus.authenticated) {
          log('✅ User authenticated, navigating to home');
          context.goNamed(Screens.home.name);
        } else {
          log('❌ User not authenticated, navigating to login');
          context.goNamed(Screens.enhancedLogin.name);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Ana veri yüklenirken hata oluştu: $e');
      }

      // Hata olsa bile navigasyona devam et - default olarak login'e git
      if (mounted) {
        log('⚠️ Error occurred, defaulting to login');
        context.goNamed(Screens.enhancedLogin.name);
      }
    }
  }

  void _showUpdateDialog(ForceUpdateStatus status) {
    final isForceUpdate = status.isForceUpdate;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          hasSabGradient: false,
          topBarTitle: Text(
            'Güncelleme Gerekli',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: isForceUpdate
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _initializeApp();
                  },
                  icon: const Icon(Icons.close),
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                status.message ??
                    'Uygulamanın yeni bir sürümü mevcut. Lütfen güncelleyin.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (status.storeUrl != null) {
                      await launchUrl(
                        Uri.parse(status.storeUrl!),
                        mode: LaunchMode.externalApplication,
                      );
                      exit(0);
                    }
                  },
                  child: const Text('Güncelle'),
                ),
              ),
              if (!isForceUpdate) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _initializeApp();
                    },
                    child: const Text('Güncelleme Yapmadan Devam Et'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      onModalDismissedWithBarrierTap: isForceUpdate
          ? null
          : () async {
              Navigator.of(context).pop();
              await _initializeApp();
            },
      barrierDismissible: !isForceUpdate,
    );
  }
}

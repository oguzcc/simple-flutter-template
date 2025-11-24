part of '../view/splash_screen.dart';

mixin _SplashMixin<T extends StatefulWidget> on State<T> {
  VideoPlayerController? _videoController;
  final _forceUpdateManager = ForceUpdateManager();
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  bool _shorebirdUpdateInProgress = false;
  bool _shorebirdUpdateError = false;

  String? _appVersion;
  String? _buildNumber;
  int? _shorebirdPatchNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Video player'ı başlat
      _initializeVideoPlayer();

      // 2 saniye default bekleme süresi ekle, sonra diğer işlemleri başlat
      Future.delayed(const Duration(seconds: 2), () {
        Future.wait([
          _fetchVersionAndPatch(),
          _checkShorebirdUpdateAndContinue(),
        ]);
      });
    });
  }

  Future<void> _fetchVersionAndPatch() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final shorebirdUpdater = ShorebirdUpdater();

      // Get current patch number
      final currentPatch = await shorebirdUpdater.readCurrentPatch();

      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _shorebirdPatchNumber = currentPatch?.number;
      });
    } catch (e) {
      // Hata durumunda değerler null kalır
    }
  }

  Future<void> _checkShorebirdUpdateAndContinue() async {
    // Başlangıç zamanını kaydet (minimum süre kontrolü için)
    final startTime = DateTime.now();

    if (kDebugMode) {
      // Debug modda güncelleme kontrolü yapma ama yine de minimum süre bekle
      debugPrint('Debug modda güncelleme kontrolü yapılmıyor.');

      // En az 1 saniye daha bekle (başta 2 saniye bekledik)
      const minimumSplashDuration = Duration(seconds: 1);
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime < minimumSplashDuration) {
        await Future<void>.delayed(minimumSplashDuration - elapsedTime);
      }

      await _initializeApp();
      return;
    }

    // Force update kontrolü
    await _forceUpdateManager.initialize();
    final updateStatus = await _forceUpdateManager.checkForUpdate();
    if (updateStatus.required && mounted) {
      _showUpdateDialog(updateStatus);
      return;
    }

    // Force update gerekmiyorsa shorebird patch kontrolü
    setState(() {
      _shorebirdUpdateInProgress = true;
      _shorebirdUpdateError = false;
    });
    try {
      final shorebirdUpdater = ShorebirdUpdater();

      // Shorebird her zaman mevcut kabul edilir

      final status = await shorebirdUpdater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        await shorebirdUpdater.update();
        // Güncelleme sonrası biraz bekle
        await Future<void>.delayed(const Duration(seconds: 2));
        setState(() {
          _shorebirdUpdateError = false; // Başarılı güncelleme sonrası hata yok
        });
        // Uygulamayı yeniden başlat gerekebilir
        return;
      } else {
        setState(() {
          _shorebirdUpdateError = false; // Güncel ise de hata yok
        });
      }
    } on UpdateException catch (error) {
      // Shorebird güncelleme hatası
      if (kDebugMode) {
        debugPrint(
          'Shorebird güncelleme hatası: ${error.message}',
        );
      }
      setState(() {
        _shorebirdUpdateError = true;
      });
    } catch (e, stackTrace) {
      // Diğer hatalar
      if (kDebugMode) {
        debugPrint('Shorebird güncellemede beklenmedik hata: $e');
      }
      setState(() {
        _shorebirdUpdateError = true;
      });

      // Shorebird güncelleme hatalarını Sentry'e gönder
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (p0) => p0.setContexts(
          'ShorebirdUpdate',
          {
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _shorebirdUpdateInProgress = false;
        });
      }
    }

    // Minimum 1 saniye daha bekle (başta zaten 2 saniye beklemiştik)
    const minimumSplashDuration = Duration(seconds: 1);
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < minimumSplashDuration) {
      await Future<void>.delayed(minimumSplashDuration - elapsedTime);
    }

    // Eğer shorebird update yoksa veya tamamlandıysa devam et
    if (mounted && !_shorebirdUpdateInProgress) {
      await _initializeApp();
    }
  }

  Future<bool> _shouldSkipVideo() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 24) return true;

      // isLowRamDevice özelliği her cihazda mevcut olmayabilir
      // Bu yüzden bu kontrolü basitleştiriyoruz
      return false;
    }
    return false;
  }

  Future<void> _initializeVideoPlayer() async {
    if (await _shouldSkipVideo()) {
      setState(() {
        _isVideoError = true;
      });
      return;
    }
    try {
      _videoController = VideoPlayerController.asset(
        'assets/videos/splash.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoController
          ?.initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isVideoInitialized = true;
                _isVideoError = false; // Ensure error state is reset
              });
              _videoController?.setVolume(0);
              _videoController?.setLooping(true);
              _videoController?.play();
            }
          })
          .catchError((Object e) {
            if (kDebugMode) {
              debugPrint('Video oynatılırken hata: $e');
            }
            _cleanupVideoController();
            if (mounted) {
              setState(() {
                _isVideoError = true;
              });
            }
          });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Video controller oluşturulurken hata: $e');
      }
      _cleanupVideoController();
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  void _cleanupVideoController() {
    try {
      _videoController?.pause();
      _videoController?.dispose();
      _videoController = null;
      _isVideoInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cleaning up video controller: $e');
      }
      _videoController = null;
      _isVideoInitialized = false;
    }
  }

  @override
  void dispose() {
    _cleanupVideoController();
    super.dispose();
  }

  void initSplash() {
    // Video player initState'de başlatılıyor
    // Connection check gerekirse buraya eklenebilir
  }

  //* MARK: Uygulama başlatıldığında internet bağlantısını kontrol et
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

      // Authentication durumunu kontrol et - HydratedCubit'ten gelen state kullan
      // authCubit.authenticate() çağırma çünkü Firebase kontrol ediyor
      // Development bypass için persist edilmiş state'i kullanmalıyız

      // Temel verileri yükle (sadece authenticated kullanıcılar için)
      if (homeCubit != null && authCubit != null && authCubit.isAuthenticated) {
        await Future.wait([
          homeCubit.fetchInitialData(),
        ]);
      }

      // Video controller temizle
      _cleanupVideoController();

      // if forceUpdate is required then return
      final isForceUpdate = await _forceUpdateManager.checkForUpdate();
      if (isForceUpdate.required) {
        return;
      }

      // Authentication durumuna göre yönlendirme yap
      if (mounted) {
        final authCubit = context.read<AuthCubit?>();
        log('🔍 Splash checking auth state: ${authCubit?.state.authStatus}');
        
        if (authCubit != null && authCubit.state.authStatus == AuthStatus.authenticated) {
          log('✅ User authenticated, navigating to home');
          context.goNamed(Screens.home.name);
        } else {
          log('❌ User not authenticated, navigating to login');
          context.goNamed(Screens.enhancedLogin.name);
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Ana veri yüklenirken hata oluştu: $e');
      }
      // Log error to Sentry for tracking
      await Sentry.captureException(e, stackTrace: stackTrace);

      // Hata olsa bile navigasyona devam et - default olarak login'e git
      if (mounted) {
        _cleanupVideoController();
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

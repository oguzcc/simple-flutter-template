import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:daisy/core/bloc/conn/conn_cubit.dart';
import 'package:daisy/core/manager/remote/force_update_manager.dart';
import 'package:daisy/feature/auth/cubit/auth_cubit.dart';
import 'package:daisy/feature/home/cubit/home_cubit.dart';
import 'package:daisy/router/router.dart';
import 'package:daisy/router/screens.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

part '../mixin/_splash_mixin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static final globalKey = GlobalKey<_SplashScreenState>();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with _SplashMixin, WidgetsBindingObserver {
  void restartSplash() {
    _cleanupVideoController();
    initSplash();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // initSplash mixin'de zaten çağrılıyor
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_videoController == null) return;

    if (state == AppLifecycleState.paused) {
      _videoController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoController?.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.status == HomeStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error'.tr() + ': ${state.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Video veya statik arkaplan
            if (_isVideoInitialized && _videoController != null)
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.2,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else if (_isVideoError)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Image.asset(
                      'assets/images/splash.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(
                          alpha: .15,
                        ),
                    Theme.of(context).colorScheme.primary.withValues(alpha: .45),
                  ],
                ),
              ),
            ),
            // Ana içerik
            SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Logo ve mesaj kısmı
                    if (!_shorebirdUpdateInProgress && !_shorebirdUpdateError)
                      const SizedBox(height: 24)
                    else
                      const SizedBox(height: 0),

                    // Logo ve alt mesaj - Shorebird update gösterilmiyorsa
                    if (!_shorebirdUpdateInProgress && !_shorebirdUpdateError)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome to Daisy',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .065,
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 24),

                    // Versiyon bilgisi ve shorebird update durumu
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_shorebirdUpdateInProgress)
                            Opacity(
                              opacity: 0.85,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white70,
                                      strokeWidth: 2.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Güncellemeler kontrol ediliyor...',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_shorebirdUpdateError)
                            Opacity(
                              opacity: 0.85,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent.withValues(alpha: .8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Güncelleme kontrolü sırasında hata',
                                    style: TextStyle(
                                      color: Colors.redAccent.withValues(alpha: .8),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Versiyon satırı (dinamik)
                          Text(
                            _appVersion == null
                                ? ''
                                : 'v$_appVersion+$_buildNumber'
                                    '${_shorebirdPatchNumber != null ? ' (patch: $_shorebirdPatchNumber)' : ''}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
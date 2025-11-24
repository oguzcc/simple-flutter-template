import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:daisy/core/bloc/conn/conn_cubit.dart';
import 'package:daisy/core/manager/remote/force_update_manager.dart';
import 'package:daisy/feature/auth/cubit/auth_cubit.dart';
import 'package:daisy/feature/home/cubit/home_cubit.dart';
import 'package:daisy/router/screens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

part '../mixin/_splash_mixin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static final globalKey = GlobalKey<_SplashScreenState>();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with _SplashMixin {
  void restartSplash() {
    initSplash();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.status == HomeStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${'error'.tr()}: ${state.errorMessage}'),
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
            // Statik arkaplan
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
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .15),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .45),
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
                    const SizedBox(height: 24),
                    // Logo ve alt mesaj
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
                    ),

                    // Versiyon bilgisi
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _appVersion == null
                            ? ''
                            : 'v$_appVersion+$_buildNumber',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
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

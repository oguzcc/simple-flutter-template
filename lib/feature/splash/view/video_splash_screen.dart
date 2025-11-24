import 'dart:async';

import 'package:daisy/feature/splash/cubit/video_splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Simple Video Splash Screen for app intro
class VideoSplashScreen extends StatelessWidget {
  const VideoSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoSplashCubit()..initialize(),
      child: const _VideoSplashView(),
    );
  }
}

class _VideoSplashView extends StatefulWidget {
  const _VideoSplashView();

  @override
  State<_VideoSplashView> createState() => _VideoSplashViewState();
}

class _VideoSplashViewState extends State<_VideoSplashView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ),);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<VideoSplashCubit, VideoSplashState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
              
              // Video Content
              _buildVideoContent(context, state),
              
              // Skip Button
              if (state.canShowSkipButton && 
                  state.status == VideoSplashStatus.playing)
                _buildSkipButton(context),
              
              // Progress Indicator
              if (state.status == VideoSplashStatus.playing)
                _buildProgressIndicator(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoContent(BuildContext context, VideoSplashState state) {
    final cubit = context.read<VideoSplashCubit>();
    
    switch (state.status) {
      case VideoSplashStatus.loading:
        return _buildLoadingState();
      
      case VideoSplashStatus.playing:
        if (cubit.videoController?.value.isInitialized ?? false) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: cubit.videoController!.value.size.width,
                  height: cubit.videoController!.value.size.height,
                  child: VideoPlayer(cubit.videoController!),
                ),
              ),
            ),
          );
        }
        return _buildLoadingState();
      
      case VideoSplashStatus.error:
        return _buildErrorState(state.errorMessage);
      
      case VideoSplashStatus.fallback:
        return _buildFallbackState();
      
      case VideoSplashStatus.completed:
      case VideoSplashStatus.skipped:
        return _buildCompletedState();
    }
  }

  Widget _buildSkipButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 24,
      child: GestureDetector(
        onTap: () => context.read<VideoSplashCubit>().skipVideo(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Atla',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.skip_next,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, VideoSplashState state) {
    final cubit = context.read<VideoSplashCubit>();
    
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: cubit.progressPercentage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Video yükleniyor...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white70,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Video oynatılamadı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToNextScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Devam Et',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: 120,
          ),
          SizedBox(height: 32),
          Text(
            'Hoş Geldiniz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Uygulamaya başlamak için dokunun',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, VideoSplashState state) {
    final cubit = context.read<VideoSplashCubit>();
    
    // Auto-navigate when video is completed or should proceed
    if (cubit.shouldProceed) {
      unawaited(
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _navigateToNextScreen(context);
          }
        }),
      );
    }
  }

  void _navigateToNextScreen(BuildContext context) {
    // Navigate to main app - customize this route as needed
    context.go('/home');
  }
}

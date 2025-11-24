import 'dart:async';
import 'dart:developer';

import 'package:daisy/core/config/video_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

part 'video_splash_cubit.freezed.dart';
part 'video_splash_state.dart';

/// Video Splash Cubit for managing intro video playback
/// 
/// Features:
/// - Video player initialization and control
/// - Skip functionality with smart timing
/// - First-time user detection
/// - Graceful fallback handling
/// - Progress tracking
/// - Auto-navigation after completion
class VideoSplashCubit extends Cubit<VideoSplashState> {
  VideoSplashCubit() : super(const VideoSplashState());

  VideoPlayerController? _videoController;
  Timer? _skipButtonTimer;
  Timer? _maxDurationTimer;
  StreamSubscription<void>? _videoListener;

  /// Initialize video splash screen
  Future<void> initialize() async {
    emit(state.copyWith(status: VideoSplashStatus.loading));

    try {
      // Check if user has seen the video before
      final hasSeenVideo = await _hasUserSeenVideo();
      
      if (hasSeenVideo && VideoConfig.autoSkipAfterFirstView) {
        log('ℹ️ User has seen video before, skipping...');
        emit(
          state.copyWith(
            status: VideoSplashStatus.skipped,
            hasSeenBefore: true,
          ),
        );
        return;
      }

      // Initialize video player
      await _initializeVideoPlayer();
      
    } catch (e) {
      log('❌ Error initializing video splash: $e');
      await _handleError(e.toString());
    }
  }

  /// Initialize the video player
  Future<void> _initializeVideoPlayer() async {
    try {
      log('🎥 Initializing video player...');
      
      _videoController = VideoPlayerController.asset(VideoConfig.introVideo);
      
      await _videoController!.initialize();
      
      // Set up video configuration
      await _videoController!.setVolume(VideoConfig.playerConfig.volume);
      await _videoController!.setLooping(VideoConfig.playerConfig.looping);
      
      // Listen to video completion
      _videoController!.addListener(_onVideoUpdate);
      
      emit(
        state.copyWith(
          status: VideoSplashStatus.playing,
          isInitialized: true,
          videoDuration: _videoController!.value.duration,
          canShowSkipButton: false,
        ),
      );

      // Start playback
      if (VideoConfig.playerConfig.autoPlay) {
        await _videoController!.play();
      }

      // Set up skip button timer
      _setupSkipButtonTimer();
      
      // Set up max duration safety timer
      _setupMaxDurationTimer();
      
      log('✅ Video player initialized and playing');
      
    } catch (e) {
      log('❌ Error initializing video player: $e');
      unawaited(_handleError('Failed to load video: $e'));
    }
  }

  /// Set up timer to show skip button
  void _setupSkipButtonTimer() {
    _skipButtonTimer = Timer(VideoConfig.skipButtonDelay, () {
      if (!isClosed && state.status == VideoSplashStatus.playing) {
        emit(state.copyWith(canShowSkipButton: true));
        log('ℹ️ Skip button now available');
      }
    });
  }

  /// Set up safety timer for maximum video duration
  void _setupMaxDurationTimer() {
    _maxDurationTimer = Timer(VideoConfig.maxVideoDuration, () {
      if (!isClosed && state.status == VideoSplashStatus.playing) {
        log('⏰ Video timeout reached, auto-completing');
        _completeVideo();
      }
    });
  }

  /// Listen to video player updates
  void _onVideoUpdate() {
    if (_videoController == null || isClosed) return;

    final value = _videoController!.value;
    
    // Update playback position
    emit(
      state.copyWith(
        currentPosition: value.position,
        isPlaying: value.isPlaying,
      ),
    );

    // Check if video completed
    if (value.position >= value.duration && value.duration > Duration.zero) {
      _completeVideo();
    }

    // Handle video errors
    if (value.hasError) {
      log('❌ Video playback error: ${value.errorDescription}');
      unawaited(_handleError(value.errorDescription ?? 'Video playback error'));
    }
  }

  /// Complete the video playback
  Future<void> _completeVideo() async {
    if (state.status == VideoSplashStatus.completed) return;
    
    log('✅ Video completed');
    
    emit(state.copyWith(status: VideoSplashStatus.completed));
    
    // Mark that user has seen the video
    await _markVideoAsSeen();
    
    // Clean up resources
    await _cleanup();
  }

  /// Skip the video
  Future<void> skipVideo() async {
    if (state.status != VideoSplashStatus.playing) return;
    
    log('⏭️ Video skipped by user');
    
    emit(state.copyWith(status: VideoSplashStatus.skipped));
    
    // Mark that user has seen the video (even if skipped)
    await _markVideoAsSeen();
    
    // Clean up resources
    await _cleanup();
  }

  /// Pause video playback
  Future<void> pauseVideo() async {
    if (_videoController?.value.isInitialized ?? false) {
      await _videoController!.pause();
      emit(state.copyWith(isPlaying: false));
    }
  }

  /// Resume video playback
  Future<void> resumeVideo() async {
    if (_videoController?.value.isInitialized ?? false) {
      await _videoController!.play();
      emit(state.copyWith(isPlaying: true));
    }
  }

  /// Handle video errors with fallback behavior
  Future<void> _handleError(String error) async {
    emit(
      state.copyWith(
        status: VideoSplashStatus.error,
        errorMessage: error,
      ),
    );

    // Execute fallback behavior
    switch (VideoConfig.fallbackBehavior.onError) {
      case VideoFallbackAction.showStaticSplash:
        emit(state.copyWith(status: VideoSplashStatus.fallback));
      case VideoFallbackAction.skipToNextScreen:
        emit(state.copyWith(status: VideoSplashStatus.skipped));
      case VideoFallbackAction.showErrorMessage:
        // Error message will be shown in UI
    }

    await _cleanup();
  }

  /// Check if user has seen the video before
  Future<bool> _hasUserSeenVideo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(VideoConfig.hasSeenVideoKey) ?? false;
    } catch (e) {
      log('⚠️ Error checking video seen status: $e');
      return false;
    }
  }

  /// Mark video as seen
  Future<void> _markVideoAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(VideoConfig.hasSeenVideoKey, true);
      log('ℹ️ Video marked as seen');
    } catch (e) {
      log('⚠️ Error marking video as seen: $e');
    }
  }

  /// Reset video seen status (for testing)
  Future<void> resetVideoSeenStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(VideoConfig.hasSeenVideoKey);
      log('ℹ️ Video seen status reset');
    } catch (e) {
      log('⚠️ Error resetting video seen status: $e');
    }
  }

  /// Get video player controller for UI
  VideoPlayerController? get videoController => _videoController;

  /// Get video progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (_videoController == null || 
        !_videoController!.value.isInitialized ||
        state.videoDuration == null ||
        state.videoDuration!.inMilliseconds == 0) {
      return 0;
    }

    final currentMs = state.currentPosition?.inMilliseconds ?? 0;
    final totalMs = state.videoDuration!.inMilliseconds;
    
    return (currentMs / totalMs).clamp(0, 1);
  }

  /// Get remaining time
  Duration get remainingTime {
    if (state.videoDuration == null || state.currentPosition == null) {
      return Duration.zero;
    }
    
    final remaining = state.videoDuration! - state.currentPosition!;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if video is ready to play
  bool get isVideoReady => 
      (_videoController?.value.isInitialized ?? false) && 
      state.status == VideoSplashStatus.playing;

  /// Check if video should proceed to next screen
  bool get shouldProceed => 
      state.status == VideoSplashStatus.completed ||
      state.status == VideoSplashStatus.skipped ||
      state.status == VideoSplashStatus.fallback;

  /// Clean up resources
  Future<void> _cleanup() async {
    _skipButtonTimer?.cancel();
    _maxDurationTimer?.cancel();
    _videoListener?.cancel();
    
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    
    log('🧹 Video splash resources cleaned up');
  }

  @override
  Future<void> close() {
    unawaited(_cleanup());
    return super.close();
  }
}

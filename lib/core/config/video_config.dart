/// Video configuration for splash and onboarding
class VideoConfig {
  /// Path to the intro video asset
  static const String introVideo = 'assets/video/intro_video.mp4';
  
  /// Maximum duration for the intro video (safety timeout)
  static const Duration maxVideoDuration = Duration(seconds: 30);
  
  /// Auto-skip video after first view for better UX
  static const bool autoSkipAfterFirstView = true;
  
  /// Cache key for storing whether user has seen the video
  static const String hasSeenVideoKey = 'has_seen_intro_video';
  
  /// Skip button delay (show skip button after this duration)
  static const Duration skipButtonDelay = Duration(seconds: 3);
  
  /// Video player configuration
  static const VideoPlayerConfig playerConfig = VideoPlayerConfig(
    autoPlay: true,
    looping: false,
    volume: 0.8,
    showControls: false,
  );
  
  /// Video fallback behavior
  static const VideoFallbackBehavior fallbackBehavior = VideoFallbackBehavior(
    onError: VideoFallbackAction.showStaticSplash,
    onTimeout: VideoFallbackAction.showStaticSplash,
    onAssetNotFound: VideoFallbackAction.showStaticSplash,
  );
}

/// Video player configuration
class VideoPlayerConfig {
  const VideoPlayerConfig({
    required this.autoPlay,
    required this.looping,
    required this.volume,
    required this.showControls,
  });
  
  final bool autoPlay;
  final bool looping;
  final double volume;
  final bool showControls;
}

/// Video fallback behavior configuration
class VideoFallbackBehavior {
  const VideoFallbackBehavior({
    required this.onError,
    required this.onTimeout,
    required this.onAssetNotFound,
  });
  
  final VideoFallbackAction onError;
  final VideoFallbackAction onTimeout;
  final VideoFallbackAction onAssetNotFound;
}

/// Actions to take when video fails
enum VideoFallbackAction {
  showStaticSplash,
  skipToNextScreen,
  showErrorMessage,
}



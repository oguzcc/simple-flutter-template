part of 'video_splash_cubit.dart';

@freezed
class VideoSplashState with _$VideoSplashState {
  const factory VideoSplashState({
    @Default(VideoSplashStatus.loading) VideoSplashStatus status,
    @Default(false) bool isInitialized,
    @Default(false) bool isPlaying,
    @Default(false) bool canShowSkipButton,
    @Default(false) bool hasSeenBefore,
    Duration? videoDuration,
    Duration? currentPosition,
    String? errorMessage,
  }) = _VideoSplashState;
}

/// Video splash status enum to avoid naming conflicts
enum VideoSplashStatus {
  loading,
  playing,
  completed,
  skipped,
  error,
  fallback,
}

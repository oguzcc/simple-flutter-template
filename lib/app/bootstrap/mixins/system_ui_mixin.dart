part of '../../bootstrap.dart';

/// Mixin for System UI configuration
mixin _SystemUIMixin {
  /// Setup system UI preferences
  Future<void> setupSystemUI() async {
    log('🎨 Configuring System UI...');
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );

    // Enable edge-to-edge mode
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    
    log('✅ System UI configured successfully');
  }
}

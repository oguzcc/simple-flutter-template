part of '../../bootstrap.dart';

/// Mixin for environment configuration
mixin _EnvironmentMixin {
  /// Load environment file based on current flavor
  Future<void> loadEnvironment() async {
    try {
      final flavor = AppFlavor.instance();
      String envFile = '.env'; // default

      // Determine environment file based on flavor
      if (flavor.flavorType == FlavorType.development) {
        envFile = '.env.development';
      } else if (flavor.flavorType == FlavorType.staging) {
        envFile = '.env.staging';
      } else if (flavor.flavorType == FlavorType.production) {
        envFile = '.env.production';
      }

      log('🔧 Loading environment file: $envFile');
      await dotenv.load(fileName: envFile);
      log('✅ Environment file loaded successfully');
    } on Exception catch (e) {
      log('⚠️ Error loading environment file: $e');
      // Fallback to default .env file
      try {
        log('🔄 Falling back to default .env file');
        await dotenv.load(fileName: '.env');
        log('✅ Default environment file loaded successfully');
      } on Exception catch (fallbackError) {
        log('❌ Failed to load any environment file: $fallbackError');
      }
    }
  }
  
  /// Validate environment configuration
  Future<void> validateEnvironment() async {
    // Validate environment configuration
    if (kDebugMode) {
      // Run comprehensive validation in debug mode
      await EnvironmentValidationService.validateAll();
    } else {
      // Quick production readiness check in release mode
      final isReady = await EnvironmentValidationService.isProductionReady();
      if (!isReady) {
        log('⚠️ Production deployment warnings detected. '
            'Run in debug mode for details.');
      }
    }
  }
}

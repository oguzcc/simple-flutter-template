part of '../../bootstrap.dart';

/// Mixin for Analytics services initialization
mixin _AnalyticsMixin {
  /// Initialize unified analytics service
  Future<void> initializeAnalytics() async {
    log('📊 Initializing Analytics Services...');
    await AnalyticsService.instance.initialize();
    log('✅ Analytics Services initialized successfully');
  }
}

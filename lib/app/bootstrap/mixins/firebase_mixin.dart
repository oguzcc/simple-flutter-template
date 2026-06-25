part of '../../bootstrap.dart';

/// Mixin for Firebase initialization
mixin _FirebaseMixin {
  /// Initialize Firebase services (core + FCM).
  Future<void> initializeFirebase() async {
    log('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('✅ Firebase initialized successfully');

    try {
      final fcm = FcmService();
      await fcm.initialize();

      // getToken can block on iOS until APNS registers; fire-and-forget so
      // the splash isn't held up (especially in the iOS Simulator).
      unawaited(
        fcm.getToken().then((token) {
          if (token == null) {
            log('📱 FCM token unavailable (APNS pending or denied)');
            return;
          }
          log('📱 FCM token: $token');
          // TODO(template): send token to your backend here.
        }),
      );
      fcm.onTokenRefresh.listen((token) {
        log('🔄 FCM token refreshed: $token');
        // TODO(template): push refreshed token to your backend.
      });
    } on Object catch (e) {
      log('⚠️ FCM initialization failed: $e');
    }
  }
}

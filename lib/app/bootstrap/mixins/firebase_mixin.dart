part of '../../bootstrap.dart';

/// Mixin for Firebase initialization
mixin _FirebaseMixin {
  /// Initialize Firebase services
  Future<void> initializeFirebase() async {
    log('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('✅ Firebase initialized successfully');
    
    // TODO: Uncomment when Firebase Messaging is configured
    // await FirebaseClient.initFirebaseMessaging();
    // final token = await FirebaseClient.getFcmToken();
    // log('FCM Token: $token');
  }
}

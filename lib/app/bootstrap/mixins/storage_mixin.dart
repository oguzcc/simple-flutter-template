part of '../../bootstrap.dart';

/// Mixin for Storage initialization (HydratedBloc, Hive, Localization)
mixin _StorageMixin {
  /// Initialize storage services
  Future<void> initializeStorage() async {
    log('💾 Initializing Storage Services...');
    
    // Initialize HydratedBloc storage
    final storageDir = await getApplicationDocumentsDirectory();
    log('📁 HydratedBloc storage directory: ${storageDir.path}');
    
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(storageDir.path),
    );
    
    log('✅ HydratedBloc storage initialized');
    
    // Initialize localization and Hive
    await EasyLocalization.ensureInitialized();
    await Hive.initFlutter();
    
    log('✅ Storage services initialized successfully');
  }
}

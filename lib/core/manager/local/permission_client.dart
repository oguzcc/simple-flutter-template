import 'package:permission_handler/permission_handler.dart';

class PermissionClient {
  PermissionClient._();
  static final PermissionClient _instance = PermissionClient._();
  static PermissionClient get instance => _instance;

  static Future<bool> checkCameraPermission() async =>
      Permission.camera.isGranted;

  static Future<bool> checkMicrophonePermission() async =>
      Permission.microphone.isGranted;

  static Future<bool> checkNotificationPermission() async =>
      Permission.notification.isGranted;

  ///Get camera and microphone permission status
  static Future<Map<Permission, PermissionStatus>>
      getCameraAndMicrophonePermissionStatus({bool openSettings = true}) async {
    final result = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (result[Permission.camera]!.isGranted &&
        result[Permission.microphone]!.isGranted) {
      // Eğer izinler verilmişse, direkt sonucu döndür
      return result;
    }

    // İzinler kalıcı olarak reddedildiyse ve ayarları açma isteği varsa
    if (openSettings &&
        (result[Permission.camera]!.isPermanentlyDenied ||
            result[Permission.microphone]!.isPermanentlyDenied)) {
      await openAppSettings();
    }

    return result;
  }

  /// Request camera and microphone permission
  static Future<Map<Permission, PermissionStatus>>
      requestCameraAndMicrophonePermission() async {
    final result = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return result;
  }

  // Static method to request notification permission
  static Future<bool> requestNotificationPermission() async {
    final result = await Permission.notification.request();
    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      // If permission is permanently denied, open app settings
      await openAppSettings();
      // return false;
    }
    return false;
  }
}

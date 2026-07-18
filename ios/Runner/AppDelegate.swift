import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // NOTE: Plugin registration moved to didInitializeImplicitFlutterEngine
    // below as part of the UIScene lifecycle migration. Under the scene
    // lifecycle the implicit FlutterEngine is created after this method runs,
    // so GeneratedPluginRegistrant must register against that engine's
    // registry rather than `self` here.

    // APNS registration. firebase_messaging also calls this on
    // requestPermission(), but registering up front lets the OS deliver
    // the device token to AppDelegate (swizzled by Firebase) regardless
    // of when Flutter requests permission.
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle: register plugins once the implicit FlutterEngine is
  // initialized. See https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // Handle URL callbacks for Google Sign-In
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }
}

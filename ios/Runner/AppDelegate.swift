import UIKit
import Flutter
import BackgroundTasks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register background task
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "dev.flutter.background.refresh", using: nil
    ) { task in
        // perform background work here
        task.setTaskCompleted(success: true)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

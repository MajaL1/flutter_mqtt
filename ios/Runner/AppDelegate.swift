import UIKit
import Flutter
import BackgroundTasks
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 🔑 THIS LINE IS REQUIRED
    UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)

    // Register background task
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: "dev.flutter.background.refresh",
      using: nil
    ) { task in
      task.setTaskCompleted(success: true)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // 🔔 THIS ENABLES FOREGROUND BANNERS
      if #available(iOS 14.0, *) {
        completionHandler([.banner, .sound, .badge])
    } else {
        // Fallback on earlier versions
    }
  }
}

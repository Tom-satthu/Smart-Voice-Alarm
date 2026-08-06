import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SvaLaunchAudit.noteAppDelegateDidFinish()
    SvaLaunchAudit.logBuildStampLine()
    SvaNotificationFanout.configureCategories()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    SvaLaunchAudit.noteFlutterEngineInit()
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    SvaLaunchAudit.notePluginRegister()
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SvaAlarmBridge") {
      SvaAlarmBridge.register(with: registrar)
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    SvaAlarmBridge.sharedHandleWillPresent(notification)
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .list])
    } else {
      completionHandler([.alert, .sound])
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    SvaAlarmBridge.sharedHandleDidReceive(response)
    completionHandler()
  }
}

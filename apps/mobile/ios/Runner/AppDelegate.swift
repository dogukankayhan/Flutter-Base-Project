import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.base.project/environment",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getEnvironmentConfig" {
        let infoPlist = Bundle.main.infoDictionary ?? [:]
        let appName = infoPlist["CFBundleDisplayName"] as? String ?? ""
        let baseUrl = infoPlist["BaseUrl"] as? String ?? ""
        let googleServerClientId = infoPlist["GoogleServerClientId"] as? String ?? ""
        result([
          "appName": appName,
          "baseUrl": baseUrl,
          "googleServerClientId": googleServerClientId
        ])
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Device Hardware Channel
    let hardwareChannel = FlutterMethodChannel(
      name: "com.base.project/device_hardware",
      binaryMessenger: controller.binaryMessenger
    )

    hardwareChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getDeviceHardwareInfo" {
        let manager = DeviceHardwareInfoManager.shared
        result(manager.getDeviceHardwareInfo())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Security Channel for Jailbreak Detection
    let securityChannel = FlutterMethodChannel(
      name: "com.base.project/security",
      binaryMessenger: controller.binaryMessenger
    )

    securityChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "isJailbroken" {
        result(JailbreakDetector.isJailbroken())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let actionId = response.actionIdentifier
    let userInfo = response.notification.request.content.userInfo
    let approvalId = userInfo["approval_id"] as? String ?? "unknown"

    if actionId == "action_approve" || actionId == "action_reject" {
      print("[Notification] Background action: \(actionId) approvalId: \(approvalId)")
    }

    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}

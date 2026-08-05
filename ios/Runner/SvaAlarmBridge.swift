import Flutter
import Foundation
import UIKit
import UserNotifications

/// MethodChannel bridge for iOS alarm fan-out (AlarmKit on 26+, notifications otherwise).
final class SvaAlarmBridge: NSObject, FlutterPlugin {
  private static let shared = SvaAlarmBridge()
  private var channel: FlutterMethodChannel?

  static func register(with registrar: FlutterPluginRegistrar) {
    register(withMessenger: registrar.messenger())
  }

  static func register(withMessenger messenger: FlutterBinaryMessenger) {
    let instance = SvaAlarmBridge.shared
    let channel = FlutterMethodChannel(
      name: SvaAlarmKeys.channelName,
      binaryMessenger: messenger
    )
    instance.channel = channel
    channel.setMethodCallHandler(instance.handle)
    SvaNotificationFanout.configureCategories()

    NotificationCenter.default.addObserver(
      instance,
      selector: #selector(instance.onPendingChallengeUpdated(_:)),
      name: Notification.Name("SvaPendingChallengeUpdated"),
      object: nil
    )
  }

  static func sharedHandleWillPresent(_ notification: UNNotification) {
    shared.openChallenge(from: notification.request.content.userInfo)
  }

  static func sharedHandleDidReceive(_ response: UNNotificationResponse) {
    shared.openChallenge(from: response.notification.request.content.userInfo)
  }

  @objc private func onPendingChallengeUpdated(_ note: Notification) {
    guard let info = note.userInfo else { return }
    channel?.invokeMethod("onOpenChallenge", arguments: info)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCapability":
      result(capability())
    case "requestAuthorization":
      Task {
        do {
          let status = try await requestAuth()
          result(status)
        } catch {
          result(FlutterError(code: "auth", message: error.localizedDescription, details: nil))
        }
      }
    case "renderSound":
      guard let args = call.arguments as? [String: Any],
            let fileName = args["fileName"] as? String
      else {
        result(FlutterError(code: "args", message: "fileName required", details: nil))
        return
      }
      Task {
        do {
          let out = try await SvaAudioRenderer.render(
            sourcePath: args["sourcePath"] as? String,
            assetKey: args["assetKey"] as? String,
            ttsText: args["ttsText"] as? String,
            ttsLocale: args["ttsLocale"] as? String,
            fileName: fileName,
            maxSeconds: (args["maxSeconds"] as? Double) ?? 20
          )
          result(out)
        } catch {
          result(FlutterError(code: "render", message: error.localizedDescription, details: nil))
        }
      }
    case "scheduleSegments":
      guard let args = call.arguments as? [String: Any],
            let rawSegments = args["segments"] as? [[String: Any]]
      else {
        result(FlutterError(code: "args", message: "segments required", details: nil))
        return
      }
      let title = (args["title"] as? String) ?? "Smart Voice Alarm"
      let body = (args["body"] as? String) ?? "Solve to stop"
      let segments = rawSegments.compactMap(Self.parseSegment)
      Task {
        do {
          try await schedule(segments: segments, title: title, body: body)
          result(true)
        } catch {
          result(FlutterError(code: "schedule", message: error.localizedDescription, details: nil))
        }
      }
    case "cancelParent":
      let parent = (call.arguments as? [String: Any])?["parentAlarmId"] as? String ?? ""
      cancelParent(parent)
      result(true)
    case "cancelOccurrence":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let occurrence = args?["occurrenceId"] as? String ?? ""
      cancelOccurrence(parent: parent, occurrence: occurrence)
      result(true)
    case "cancelChildren":
      let ids = (call.arguments as? [String: Any])?["childIds"] as? [String] ?? []
      cancelChildren(ids)
      result(true)
    case "consumePendingChallenge":
      if let pending = SvaPendingStore.consume() {
        result(pending.asDictionary)
      } else {
        result(nil)
      }
    case "peekPendingChallenge":
      if let pending = SvaPendingStore.peek() {
        result(pending.asDictionary)
      } else {
        result(nil)
      }
    case "cleanupOrphanSounds":
      let active = Set((call.arguments as? [String: Any])?["activeFileNames"] as? [String] ?? [])
      SvaAudioRenderer.cleanupOrphans(activeFileNames: active)
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func capability() -> [String: Any] {
    // Notification fan-out with Library/Sounds CAF files is the active path.
    // AlarmKit is stubbed until entitlements + intents are safe on device.
    return [
      "iosVersion": UIDevice.current.systemVersion,
      "usesAlarmKit": false,
      "alarmKitAuthorization": "unsupported",
      "supportsFullVoiceAlarm": true,
      "maxVoiceSeconds": 20,
      "maxVoiceSegments": 5,
      "maxRingtoneSegments": 2,
      "gapSeconds": 5,
    ]
  }

  private func requestAuth() async throws -> [String: Any] {
    let notif = try await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge])
    return [
      "notifications": notif,
      "alarmKitAuthorization": "unsupported",
      "usesAlarmKit": false,
    ]
  }

  private func schedule(segments: [SvaSegmentSpec], title: String, body: String) async throws {
    try await SvaNotificationFanout.schedule(segments: segments, title: title, body: body)
  }

  private func cancelParent(_ parent: String) {
    SvaNotificationFanout.cancelParent(parentAlarmId: parent)
  }

  private func cancelOccurrence(parent: String, occurrence: String) {
    SvaNotificationFanout.cancelOccurrence(parentAlarmId: parent, occurrenceId: occurrence)
  }

  private func cancelChildren(_ ids: [String]) {
    SvaNotificationFanout.cancel(childIds: ids)
  }

  private static func parseSegment(_ raw: [String: Any]) -> SvaSegmentSpec? {
    guard
      let parent = raw["parentAlarmId"] as? String,
      let occurrence = raw["occurrenceId"] as? String,
      let childId = raw["childId"] as? String
    else { return nil }

    let start: Int64
    if let n = raw["startAtMillis"] as? NSNumber {
      start = n.int64Value
    } else if let i = raw["startAtMillis"] as? Int {
      start = Int64(i)
    } else if let d = raw["startAtMillis"] as? Double {
      start = Int64(d)
    } else {
      return nil
    }

    let index: Int
    if let n = raw["segmentIndex"] as? NSNumber {
      index = n.intValue
    } else if let i = raw["segmentIndex"] as? Int {
      index = i
    } else {
      index = 0
    }

    let duration: Int
    if let n = raw["durationMs"] as? NSNumber {
      duration = n.intValue
    } else if let i = raw["durationMs"] as? Int {
      duration = i
    } else {
      duration = 0
    }

    return SvaSegmentSpec(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      segmentIndex: index,
      childId: childId,
      startAtMillis: start,
      soundFileName: (raw["soundFileName"] as? String) ?? "",
      label: (raw["label"] as? String) ?? "",
      durationMs: duration
    )
  }

  private func openChallenge(from userInfo: [AnyHashable: Any]) {
    var dict: [String: Any] = [:]
    for (k, v) in userInfo {
      if let key = k as? String { dict[key] = v }
    }
    guard var challenge = SvaPendingChallenge.from(dictionary: dict) else { return }
    challenge.openChallenge = true
    SvaPendingStore.save(challenge)
    channel?.invokeMethod("onOpenChallenge", arguments: challenge.asDictionary)
  }
}

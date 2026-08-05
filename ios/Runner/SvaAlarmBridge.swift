import Flutter
import Foundation
import UIKit
import UserNotifications

/// MethodChannel bridge for iOS alarm fan-out (notification schedule path).
final class SvaAlarmBridge: NSObject, FlutterPlugin {
  private static let shared = SvaAlarmBridge()
  private var channel: FlutterMethodChannel?
  private let audioQueue = DispatchQueue(label: "com.smartvoicealarm.bridge.audio")

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
    // Categories only — never render audio during plugin registration.
    SvaNotificationFanout.configureCategories()
  }

  static func sharedHandleWillPresent(_ notification: UNNotification) {
    shared.openChallenge(from: notification.request.content.userInfo)
  }

  static func sharedHandleDidReceive(_ response: UNNotificationResponse) {
    shared.openChallenge(from: response.notification.request.content.userInfo)
  }

  private func reply(_ result: @escaping FlutterResult, _ value: Any?) {
    DispatchQueue.main.async { result(value) }
  }

  private func replyError(
    _ result: @escaping FlutterResult,
    code: String,
    message: String,
    stage: String,
    sourceType: String? = nil,
    fileName: String? = nil
  ) {
    var details: [String: String] = ["stage": stage]
    if let sourceType { details["sourceType"] = sourceType }
    if let fileName { details["fileName"] = fileName }
    DispatchQueue.main.async {
      result(FlutterError(code: code, message: message, details: details))
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCapability":
      reply(result, capability())
    case "requestAuthorization":
      Task {
        do {
          let status = try await requestAuth()
          reply(result, status)
        } catch {
          replyError(
            result,
            code: "auth",
            message: error.localizedDescription,
            stage: "requestAuthorization"
          )
        }
      }
    case "renderSound":
      guard let args = call.arguments as? [String: Any],
            let fileName = args["fileName"] as? String
      else {
        replyError(result, code: "args", message: "fileName required", stage: "renderSound")
        return
      }
      let sourcePath = args["sourcePath"] as? String
      let assetKey = args["assetKey"] as? String
      let ttsText = args["ttsText"] as? String
      let ttsLocale = args["ttsLocale"] as? String
      let maxSeconds = (args["maxSeconds"] as? Double) ?? 20
      let sourceType: String = {
        if ttsText?.isEmpty == false { return "tts" }
        if sourcePath?.isEmpty == false { return "recording" }
        if assetKey?.isEmpty == false { return "asset" }
        return "unknown"
      }()
      audioQueue.async {
        Task {
          do {
            let out = try await SvaAudioRenderer.render(
              sourcePath: sourcePath,
              assetKey: assetKey,
              ttsText: ttsText,
              ttsLocale: ttsLocale,
              fileName: fileName,
              maxSeconds: maxSeconds
            )
            self.reply(result, out)
          } catch {
            self.replyError(
              result,
              code: "render",
              message: error.localizedDescription,
              stage: "renderSound",
              sourceType: sourceType,
              fileName: fileName
            )
          }
        }
      }
    case "scheduleSegments":
      guard let args = call.arguments as? [String: Any],
            let rawSegments = args["segments"] as? [[String: Any]]
      else {
        replyError(result, code: "args", message: "segments required", stage: "scheduleSegments")
        return
      }
      let title = (args["title"] as? String) ?? "Smart Voice Alarm"
      let body = (args["body"] as? String) ?? "Solve to stop"
      let segments = rawSegments.compactMap(Self.parseSegment)
      Task {
        do {
          try await schedule(segments: segments, title: title, body: body)
          self.reply(result, true)
        } catch {
          self.replyError(
            result,
            code: "schedule",
            message: error.localizedDescription,
            stage: "scheduleSegments"
          )
        }
      }
    case "cancelParent":
      let parent = (call.arguments as? [String: Any])?["parentAlarmId"] as? String ?? ""
      cancelParent(parent)
      reply(result, true)
    case "cancelParentExcept":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let keep = Set(args?["keepChildIds"] as? [String] ?? [])
      SvaNotificationFanout.cancelParentExcept(parentAlarmId: parent, keepChildIds: keep)
      reply(result, true)
    case "cancelOccurrence":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let occurrence = args?["occurrenceId"] as? String ?? ""
      cancelOccurrence(parent: parent, occurrence: occurrence)
      reply(result, true)
    case "cancelChildren":
      let ids = (call.arguments as? [String: Any])?["childIds"] as? [String] ?? []
      cancelChildren(ids)
      reply(result, true)
    case "consumePendingChallenge":
      if let pending = SvaPendingStore.consume() {
        reply(result, pending.asDictionary)
      } else {
        reply(result, nil)
      }
    case "peekPendingChallenge":
      if let pending = SvaPendingStore.peek() {
        reply(result, pending.asDictionary)
      } else {
        reply(result, nil)
      }
    case "cleanupOrphanSounds":
      let active = Set((call.arguments as? [String: Any])?["activeFileNames"] as? [String] ?? [])
      if active.isEmpty {
        NSLog("[SVA-Audio] cleanupOrphanSounds refused empty active set")
        reply(result, false)
      } else {
        SvaAudioRenderer.cleanupOrphans(activeFileNames: active)
        reply(result, true)
      }
    case "deleteSoundFile":
      let name = (call.arguments as? [String: Any])?["fileName"] as? String ?? ""
      SvaAudioRenderer.deleteSoundFile(name)
      reply(result, true)
    default:
      reply(result, FlutterMethodNotImplemented)
  }
  }

  private func capability() -> [String: Any] {
    // AlarmKit is stubbed — do not advertise full AlarmKit support.
    return [
      "iosVersion": UIDevice.current.systemVersion,
      "usesAlarmKit": false,
      "alarmKitAuthorization": "unsupported",
      "supportsFullVoiceAlarm": false,
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
    DispatchQueue.main.async {
      self.channel?.invokeMethod("onOpenChallenge", arguments: challenge.asDictionary)
    }
  }
}

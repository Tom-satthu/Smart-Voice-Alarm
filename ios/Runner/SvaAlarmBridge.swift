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
    SvaLaunchAudit.noteSvaBridgeRegister()
    let channel = FlutterMethodChannel(
      name: SvaAlarmKeys.channelName,
      binaryMessenger: messenger
    )
    instance.channel = channel
    channel.setMethodCallHandler(instance.handle)
    // Categories only — never render audio during plugin registration.
    SvaNotificationFanout.configureCategories()
    NotificationCenter.default.addObserver(
      forName: Notification.Name("SvaOpenChallenge"),
      object: nil,
      queue: .main
    ) { note in
      guard let info = note.userInfo as? [String: Any] else { return }
      instance.channel?.invokeMethod("onOpenChallenge", arguments: info)
    }
  }

  static func sharedHandleWillPresent(_ notification: UNNotification) {
    // Foreground delivery only presents the banner/sound.
    // Math Challenge opens on body tap or "Solve to stop" — not automatically.
    NSLog(
      "[SVA-Schedule] willPresent child=%@",
      notification.request.identifier
    )
  }

  static func sharedHandleDidReceive(_ response: UNNotificationResponse) {
    let action = response.actionIdentifier
    NSLog("[SVA-Challenge] actionIdentifier=%@", action)
    if action == UNNotificationDismissActionIdentifier {
      NSLog("[SVA-Challenge] dismiss — no challenge open")
      return
    }
    if action == UNNotificationDefaultActionIdentifier
      || action == SvaAlarmKeys.actionSolve
    {
      NSLog("[SVA-Challenge] openChallenge via action=%@", action)
      shared.openChallenge(from: response.notification.request.content.userInfo)
      return
    }
    NSLog("[SVA-Challenge] ignored notification action=%@", action)
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
      reply(result, SvaAlarmKitRuntime.passiveCapability())
    case "getBuildStamp":
      reply(result, SvaLaunchAudit.buildStampPayload())
    case "probeAlarmKitPassive":
      Task {
        let probe = await SvaAlarmKitRuntime.userInitiatedProbeAuthorization()
        self.reply(result, probe)
      }
    case "requestAuthorization":
      Task {
        do {
          // Save Alarm only — notifications + optional AlarmKit request in guarded flow.
          let status = try await requestAuth(includeAlarmKit: true)
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
    case "requestAlarmKitAuthorization":
      Task {
        let probe = await SvaAlarmKitRuntime.userInitiatedRequestAuthorization()
        reply(result, probe)
      }
    case "debugClearAlarmKitKillSwitch", "resetLegacyAlarmKitDiagnosticState":
      let clearUser = (call.arguments as? [String: Any])?["clearUserDisabled"] as? Bool ?? false
      SvaAlarmKitRuntime.resetLegacyDiagnosticState(clearUserDisabled: clearUser)
      reply(result, true)
    case "acknowledgePendingChallenge":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let occurrence = args?["occurrenceId"] as? String ?? ""
      reply(result, SvaPendingStore.acknowledge(parent: parent, occurrence: occurrence))
    case "clearPendingChallengeAfterSolve":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let occurrence = args?["occurrenceId"] as? String ?? ""
      SvaPendingStore.clearAfterSolve(parent: parent, occurrence: occurrence)
      reply(result, true)
    case "passiveAlarmKitDiagnostics":
      reply(result, SvaAlarmKitRuntime.passiveDiagnostics())
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
      let targetDuration = args["targetDurationSeconds"] as? Double
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
              maxSeconds: maxSeconds,
              targetDurationSeconds: targetDuration
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
    case "ensureSilenceSound":
      let seconds = (call.arguments as? [String: Any])?["seconds"] as? Double ?? 5
      let fileName = (call.arguments as? [String: Any])?["fileName"] as? String
        ?? SvaSilenceAudio.defaultFileName
      do {
        let out = try SvaSilenceAudio.ensure(fileName: fileName, seconds: seconds)
        reply(result, out)
      } catch {
        replyError(
          result,
          code: "silence",
          message: error.localizedDescription,
          stage: "ensureSilenceSound"
        )
      }
    case "measureTtsDuration":
      guard let args = call.arguments as? [String: Any],
            let text = args["text"] as? String,
            !text.isEmpty
      else {
        replyError(result, code: "args", message: "text required", stage: "measureTtsDuration")
        return
      }
      let locale = args["locale"] as? String
      let maxSeconds = (args["maxSeconds"] as? Double) ?? 20
      let fileName = "sva_tts_measure_\(UUID().uuidString).caf"
      audioQueue.async {
        Task {
          do {
            let out = try await SvaAudioRenderer.render(
              sourcePath: nil,
              assetKey: nil,
              ttsText: text,
              ttsLocale: locale,
              fileName: fileName,
              maxSeconds: maxSeconds + 5
            )
            SvaAudioRenderer.deleteSoundFile(fileName)
            let durationMs = (out["durationMs"] as? Int) ?? 0
            self.reply(result, [
              "ok": true,
              "durationMs": durationMs,
              "withinLimit": Double(durationMs) <= maxSeconds * 1000 + 250,
              "maxSeconds": maxSeconds,
            ])
          } catch {
            self.replyError(
              result,
              code: "tts_measure",
              message: error.localizedDescription,
              stage: "measureTtsDuration"
            )
          }
        }
      }
    case "markOccurrenceSolved":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let occurrence = args?["occurrenceId"] as? String ?? ""
      SvaOccurrenceStore.markSolved(parent: parent, occurrence: occurrence)
      SvaPendingStore.clearAfterSolve(parent: parent, occurrence: occurrence)
      reply(result, true)
    case "occurrenceDiagnostics":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let occurrence = args?["occurrenceId"] as? String ?? ""
      if let state = SvaOccurrenceStore.get(parent: parent, occurrence: occurrence) {
        reply(result, state.asDictionary)
      } else {
        reply(result, [
          "parentAlarmId": parent,
          "occurrenceId": occurrence,
          "solved": false,
          "occurrenceSolved": false,
        ])
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
      let backend = (args["backend"] as? String) ?? "notificationFanout"
      if let modeRaw = args["soundNameMode"] as? String,
         let mode = SvaAlarmKitSoundNameMode(rawValue: modeRaw)
      {
        SvaAlarmKitSoundNameMode.setPreferred(mode)
      }
      let occurrenceMeta = args["occurrenceMeta"] as? [String: Any]
      let segments = rawSegments.compactMap(Self.parseSegment)
      Task {
        do {
          let outcome = try await schedule(
            segments: segments,
            title: title,
            body: body,
            backend: backend,
            occurrenceMeta: occurrenceMeta
          )
          var dict = outcome
          if let last = SvaAlarmKitSoundStore.last() {
            dict["soundDiagnostics"] = last
          }
          self.reply(result, dict)
        } catch {
          self.replyError(
            result,
            code: "schedule",
            message: error.localizedDescription,
            stage: "scheduleSegments"
          )
        }
      }
    case "diagnoseSoundFile":
      let fileName = (call.arguments as? [String: Any])?["fileName"] as? String ?? ""
      let sourceType = (call.arguments as? [String: Any])?["sourceType"] as? String ?? "unknown"
      var diag = SvaAudioFileValidator.diagnoseRendered(
        fileName: fileName,
        sourceType: sourceType
      )
      let mode = SvaAlarmKitSoundNameMode.preferred
      diag.soundNameMode = mode.rawValue
      diag.alertSoundNameExact = SvaAlarmKitSoundResolver.alertSoundName(
        fileName: fileName,
        mode: mode
      )
      diag.logLine()
      SvaAlarmKitSoundStore.saveLast(diag)
      reply(result, diag.asDictionary)
    case "lastSoundDiagnostics":
      reply(result, SvaAlarmKitSoundStore.last() ?? [:])
    case "setAlarmKitSoundNameMode":
      let raw = (call.arguments as? [String: Any])?["mode"] as? String ?? ""
      guard let mode = SvaAlarmKitSoundNameMode(rawValue: raw) else {
        replyError(result, code: "args", message: "mode required", stage: "setAlarmKitSoundNameMode")
        return
      }
      SvaAlarmKitSoundNameMode.setPreferred(mode)
      reply(result, ["ok": true, "mode": mode.rawValue])
    case "getAlarmKitSoundNameMode":
      reply(result, [
        "mode": SvaAlarmKitSoundNameMode.preferred.rawValue,
      ])
    case "cancelParent":
      let parent = (call.arguments as? [String: Any])?["parentAlarmId"] as? String ?? ""
      cancelParent(parent)
      reply(result, true)
    case "cancelParentExcept":
      let args = call.arguments as? [String: Any]
      let parent = args?["parentAlarmId"] as? String ?? ""
      let keep = Set(args?["keepChildIds"] as? [String] ?? [])
      SvaNotificationFanout.cancelParentExcept(parentAlarmId: parent, keepChildIds: keep)
      SvaAlarmKitScheduler.cancelParentExcept(parentAlarmId: parent, keepChildIds: keep)
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
    case "alarmKitDiagnostics":
      reply(result, SvaAlarmKitScheduler.diagnostics())
    case "alarmKitStartupCounters":
      reply(result, [
        "authorizationStateReadCount": SvaAlarmKitRuntime.authorizationStateReadCount,
        "requestAuthorizationCount": SvaAlarmKitRuntime.requestAuthorizationCount,
        "scheduleCount": SvaAlarmKitRuntime.scheduleCount,
        "reconcileCount": SvaAlarmKitRuntime.reconcileCount,
      ])
    case "reconcileAlarmKit":
      SvaAlarmKitScheduler.reconcile()
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
    case "pendingRequestCount":
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        let count = requests.count
        NSLog("[SVA-Schedule] pendingRequestCount=%d", count)
        self.reply(result, count)
      }
    case "pendingRequestIdentifiers":
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        let ids = requests.map { $0.identifier }
        NSLog("[SVA-Schedule] pendingRequestIdentifiers count=%d", ids.count)
        self.reply(result, ids)
      }
    default:
      reply(result, FlutterMethodNotImplemented)
    }
  }

  private func requestAuth(includeAlarmKit: Bool) async throws -> [String: Any] {
    let notif = try await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge])
    var alarmKitAuth = SvaAlarmKitRuntime.cachedAuthorization
    var uses = false
    var supportsFull = false
    if includeAlarmKit,
       SvaAlarmKitRuntime.isVersionEligible,
       !SvaAlarmKitRuntime.isUserDisabled,
       !SvaAlarmKitRuntime.isDiagnosticForceDisabled
    {
      let probe = await SvaAlarmKitRuntime.userInitiatedRequestAuthorization()
      alarmKitAuth = probe["alarmKitAuthorization"] as? String ?? "unknown"
      uses = probe["usesAlarmKit"] as? Bool ?? false
      supportsFull = probe["supportsFullVoiceAlarm"] as? Bool ?? false
    }
    return [
      "notifications": notif,
      "alarmKitAuthorization": alarmKitAuth,
      "usesAlarmKit": uses,
      "supportsFullVoiceAlarm": supportsFull,
      "alarmKitDisabled": SvaAlarmKitRuntime.isUserDisabled
        || SvaAlarmKitRuntime.isDiagnosticForceDisabled,
    ]
  }

  private func schedule(
    segments: [SvaSegmentSpec],
    title: String,
    body: String,
    backend: String,
    occurrenceMeta: [String: Any]? = nil
  ) async throws -> [String: Any] {
    if backend == "alarmKit" {
      NSLog("[SVA-AlarmKit] backend=alarmKit")
      let outcome = try await SvaAlarmKitScheduler.schedule(segments: segments, title: title)
      if outcome.ok, let first = segments.first {
        Self.persistOccurrenceState(
          parent: first.parentAlarmId,
          occurrence: first.occurrenceId,
          segments: segments,
          meta: occurrenceMeta,
          solved: false
        )
        SvaAlarmKitUpdateObserver.shared.startIfNeeded()
      }
      return outcome.asDictionary
    }

    NSLog("[SVA-AlarmKit] backend=notificationFanout")
    try await SvaNotificationFanout.schedule(segments: segments, title: title, body: body)
    if let first = segments.first {
      Self.persistOccurrenceState(
        parent: first.parentAlarmId,
        occurrence: first.occurrenceId,
        segments: segments,
        meta: occurrenceMeta,
        solved: false
      )
    }
    return [
      "ok": true,
      "backend": "notificationFanout",
      "scheduledIds": segments.map(\.childId),
      "stage": "notification_schedule",
    ]
  }

  private static func persistOccurrenceState(
    parent: String,
    occurrence: String,
    segments: [SvaSegmentSpec],
    meta: [String: Any]?,
    solved: Bool
  ) {
    let audible = segments.filter { ($0.label) != "silence" }.count
    let silent = segments.count - audible
    let lastEnd: Double = {
      guard let last = segments.max(by: { $0.startAtMillis < $1.startAtMillis }) else { return 0 }
      return Double(last.startAtMillis) / 1000.0 + Double(last.durationMs) / 1000.0
    }()
    let state = SvaOccurrenceState(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      solved: solved,
      revision: (meta?["revision"] as? String) ?? "",
      rollingHorizonEnd: (meta?["rollingHorizonEnd"] as? Double) ?? lastEnd,
      cyclesScheduled: (meta?["cyclesScheduled"] as? Int)
        ?? (meta?["cyclesScheduled"] as? NSNumber)?.intValue
        ?? 1,
      childCount: (meta?["childCount"] as? Int) ?? segments.count,
      audibleChildCount: (meta?["audibleChildCount"] as? Int) ?? audible,
      silentChildCount: (meta?["silentChildCount"] as? Int) ?? silent,
      cycleDurationMs: (meta?["cycleDurationMs"] as? Int)
        ?? (meta?["cycleDurationMs"] as? NSNumber)?.intValue
        ?? 0,
      updatedAt: Date().timeIntervalSince1970
    )
    SvaOccurrenceStore.upsert(state)
  }

  private func cancelParent(_ parent: String) {
    SvaNotificationFanout.cancelParent(parentAlarmId: parent)
    SvaAlarmKitScheduler.cancelParent(parentAlarmId: parent)
  }

  private func cancelOccurrence(parent: String, occurrence: String) {
    SvaNotificationFanout.cancelOccurrence(parentAlarmId: parent, occurrenceId: occurrence)
    SvaAlarmKitScheduler.cancelOccurrence(parentAlarmId: parent, occurrenceId: occurrence)
  }

  private func cancelChildren(_ ids: [String]) {
    SvaNotificationFanout.cancel(childIds: ids)
    SvaAlarmKitScheduler.cancel(childIds: ids)
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
    guard var challenge = SvaPendingChallenge.from(dictionary: dict) else {
      NSLog("[SVA-Challenge] pendingSaved=false parseFailed")
      return
    }
    challenge.openChallenge = true
    SvaPendingStore.save(challenge)
    NSLog(
      "[SVA-Challenge] pendingSaved=true parent=%@ occurrence=%@",
      challenge.parentAlarmId,
      challenge.occurrenceId
    )
    DispatchQueue.main.async {
      self.channel?.invokeMethod("onOpenChallenge", arguments: challenge.asDictionary)
    }
  }
}

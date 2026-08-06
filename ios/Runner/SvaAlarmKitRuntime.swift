import Foundation
import UIKit

/// Launch-safe AlarmKit runtime gate, structured state, and call counters.
enum SvaAlarmKitRuntimeStatus: String {
  case versionIneligible
  case passive
  case notDetermined
  case authorized
  case denied
  case sessionFailure
  case diagnosticForceOff
  case userDisabled
}

enum SvaAlarmKitRuntime {
  // Legacy keys (migrated, not written for new failures)
  private static let legacyDisabledKey = "sva_alarmkit_disabled"
  private static let legacyDisabledReasonKey = "sva_alarmkit_disabled_reason"
  private static let legacyProbeSuccessKey = "sva_alarmkit_probe_success"

  // Persisted state
  private static let cachedAuthKey = "sva_alarmkit_cached_auth"
  private static let probeEverSucceededKey = "sva_alarmkit_probe_ever_succeeded"
  private static let userDisabledKey = "sva_alarmkit_user_disabled"
  private static let migrationDoneKey = "sva_alarmkit_state_migrated_v2"

  // Session-only (never persisted)
  private(set) static var sessionProbeFailed = false
  private(set) static var lastProbeError: String?
  private(set) static var lastScheduleError: String?

  static var authorizationStateReadCount = 0
  static var requestAuthorizationCount = 0
  static var scheduleCount = 0
  static var reconcileCount = 0

  static func resetCountersForTests() {
    authorizationStateReadCount = 0
    requestAuthorizationCount = 0
    scheduleCount = 0
    reconcileCount = 0
    sessionProbeFailed = false
    lastProbeError = nil
    lastScheduleError = nil
  }

  static func resetSessionStateForTests() {
    sessionProbeFailed = false
    lastProbeError = nil
    lastScheduleError = nil
  }

  // MARK: - Migration (idempotent, launch-safe)

  static func migrateLegacyStateIfNeeded() {
    let defaults = UserDefaults.standard
    if defaults.bool(forKey: migrationDoneKey) { return }

    if defaults.bool(forKey: legacyDisabledKey) {
      let reason = defaults.string(forKey: legacyDisabledReasonKey) ?? ""
      if reason.contains("authorization_denied") {
        defaults.set("denied", forKey: cachedAuthKey)
      } else if reason.contains("user_disabled") {
        defaults.set(true, forKey: userDisabledKey)
      } else {
        // probe/request/schedule failures — recover to passive, keep cached auth if any
        if defaults.string(forKey: cachedAuthKey) == "unavailable" {
          defaults.set("unknown", forKey: cachedAuthKey)
        }
      }
      defaults.set(false, forKey: legacyDisabledKey)
      defaults.removeObject(forKey: legacyDisabledReasonKey)
    }

    if defaults.object(forKey: probeEverSucceededKey) == nil,
       defaults.bool(forKey: legacyProbeSuccessKey)
    {
      defaults.set(true, forKey: probeEverSucceededKey)
    }
    defaults.removeObject(forKey: legacyProbeSuccessKey)

    defaults.set(true, forKey: migrationDoneKey)
    NSLog("[SVA-AlarmKit] legacy state migration complete")
  }

  // MARK: - Eligibility / persisted reads

  static var isVersionEligible: Bool {
    if #available(iOS 26.0, *) { return true }
    return false
  }

  static var frameworkLinked: Bool { isVersionEligible }

  static var isDiagnosticForceDisabled: Bool {
    if SvaBuildStampGenerated.alarmKitForceOff == "1" { return true }
    let raw = Bundle.main.object(forInfoDictionaryKey: "SVAAlarmKitForceOff")
    if let s = raw as? String { return s == "1" || s.lowercased() == "true" }
    if let b = raw as? Bool { return b }
    return false
  }

  static var isUserDisabled: Bool {
    migrateLegacyStateIfNeeded()
    return UserDefaults.standard.bool(forKey: userDisabledKey)
  }

  static var probeEverSucceeded: Bool {
    migrateLegacyStateIfNeeded()
    return UserDefaults.standard.bool(forKey: probeEverSucceededKey)
  }

  static var cachedAuthorization: String {
    migrateLegacyStateIfNeeded()
    return UserDefaults.standard.string(forKey: cachedAuthKey) ?? "unknown"
  }

  static var runtimeStatus: SvaAlarmKitRuntimeStatus {
    migrateLegacyStateIfNeeded()
    if !isVersionEligible { return .versionIneligible }
    if isDiagnosticForceDisabled { return .diagnosticForceOff }
    if isUserDisabled { return .userDisabled }
    if sessionProbeFailed { return .sessionFailure }
    switch cachedAuthorization {
    case "authorized": return probeEverSucceeded ? .authorized : .passive
    case "denied": return .denied
    case "notDetermined": return .notDetermined
    default: return .passive
    }
  }

  static var mayCallAlarmKitAPI: Bool {
    if isDiagnosticForceDisabled || isUserDisabled { return false }
    return isVersionEligible && probeEverSucceeded && cachedAuthorization == "authorized"
  }

  static func backendSelection() -> (backend: String, reason: String) {
    migrateLegacyStateIfNeeded()
    if !isVersionEligible {
      return ("notificationFanout", "version_ineligible")
    }
    if isDiagnosticForceDisabled {
      return ("notificationFanout", "diagnostic_force_off")
    }
    if isUserDisabled {
      return ("notificationFanout", "user_disabled")
    }
    if cachedAuthorization == "authorized" && probeEverSucceeded {
      return ("alarmKit", "authorized")
    }
    if cachedAuthorization == "denied" {
      return ("notificationFanout", "denied")
    }
    return ("notificationFanout", "needs_user_probe_or_authorization")
  }

  // MARK: - Passive capability (launch-safe, no AlarmKit API)

  static func passiveCapability() -> [String: Any] {
    migrateLegacyStateIfNeeded()
    let (backend, reason) = backendSelection()
    let runtimeEnabled = backend == "alarmKit"
    let cached = cachedAuthorization
    NSLog(
      "[SVA-AlarmKit] passive capability backend=%@ reason=%@ auth=%@ (no AlarmKit API)",
      backend, reason, cached
    )
    return [
      "iosVersion": UIDevice.current.systemVersion,
      "runtimeVersionEligible": isVersionEligible,
      "frameworkLinked": frameworkLinked,
      "cachedAuthorization": cached,
      "probeEverSucceeded": probeEverSucceeded,
      "userDisabled": isUserDisabled,
      "diagnosticForceOff": isDiagnosticForceDisabled,
      "sessionProbeFailed": sessionProbeFailed,
      "runtimeEnabled": runtimeEnabled,
      "runtimeStatus": runtimeStatus.rawValue,
      "selectedBackend": backend,
      "backendSelectionReason": reason,
      "lastProbeError": lastProbeError as Any,
      "lastScheduleError": lastScheduleError as Any,
      // Legacy-compatible fields for existing Dart parsers
      "usesAlarmKit": runtimeEnabled,
      "supportsFullVoiceAlarm": runtimeEnabled,
      "alarmKitAuthorization": cached,
      "alarmKitDisabled": isUserDisabled || isDiagnosticForceDisabled,
      "alarmKitRuntimeEnabled": runtimeEnabled,
      "alarmKitStartup": runtimeEnabled ? "enabled" : "passive",
      "alarmKitForceOff": isDiagnosticForceDisabled,
      "maxVoiceSeconds": 20,
      "maxVoiceSegments": 5,
      "maxRingtoneSegments": 2,
      "gapSeconds": 5,
    ]
  }

  static func passiveDiagnostics() -> [String: Any] {
    migrateLegacyStateIfNeeded()
    let mappings = SvaAlarmKitStore.load()
    let pending = SvaPendingStore.peek()
    let (backend, reason) = backendSelection()
    return [
      "passiveOnly": true,
      "runtimeVersionEligible": isVersionEligible,
      "frameworkLinked": frameworkLinked,
      "cachedAuthorization": cachedAuthorization,
      "probeEverSucceeded": probeEverSucceeded,
      "userDisabled": isUserDisabled,
      "diagnosticForceOff": isDiagnosticForceDisabled,
      "sessionProbeFailed": sessionProbeFailed,
      "runtimeStatus": runtimeStatus.rawValue,
      "selectedBackend": backend,
      "backendSelectionReason": reason,
      "lastProbeError": lastProbeError as Any,
      "lastScheduleError": lastScheduleError as Any,
      "authorizationStateReadCount": authorizationStateReadCount,
      "requestAuthorizationCount": requestAuthorizationCount,
      "scheduleCount": scheduleCount,
      "reconcileCount": reconcileCount,
      "mappingCount": mappings.count,
      "fanoutPendingCount": 0,
      "mappings": mappings.map { item -> [String: Any] in
        [
          "parentAlarmId": item.parentAlarmId,
          "occurrenceId": item.occurrenceId,
          "segmentIndex": item.segmentIndex,
          "childId": item.childId,
          "alarmId": item.alarmId,
          "soundFileName": item.soundFileName,
        ]
      },
      "pendingChallenge": pending?.asDictionary as Any,
      "authorization": cachedAuthorization,
      "soundNameMode": SvaAlarmKitSoundNameMode.preferred.rawValue,
      "lastSoundDiagnostics": SvaAlarmKitSoundStore.last() as Any,
    ]
  }

  // MARK: - User-initiated probe / request (Save Alarm / debug only)

  static func userInitiatedProbeAuthorization() async -> [String: Any] {
    migrateLegacyStateIfNeeded()
    if isDiagnosticForceDisabled {
      return probeResult(ok: false, auth: cachedAuthorization, error: "diagnostic_force_off")
    }
    guard isVersionEligible else {
      return probeResult(ok: false, auth: "unsupported", error: "ios_version_ineligible")
    }
    if isUserDisabled {
      return probeResult(ok: false, auth: cachedAuthorization, error: "user_disabled")
    }
    authorizationStateReadCount += 1
    do {
      let auth = try await SvaAlarmKitManager.sharedManaging.readAuthorizationStateSafely()
      UserDefaults.standard.set(auth, forKey: cachedAuthKey)
      sessionProbeFailed = false
      lastProbeError = nil
      if auth == "authorized" {
        markProbeSuccess(auth: auth)
      }
      NSLog("[SVA-AlarmKit] user probe auth=%@", auth)
      return probeResult(ok: true, auth: auth, error: nil)
    } catch {
      sessionProbeFailed = true
      lastProbeError = error.localizedDescription
      NSLog("[SVA-AlarmKit] user probe failed session-only: %@", lastProbeError ?? "")
      return probeResult(ok: false, auth: cachedAuthorization, error: error.localizedDescription)
    }
  }

  static func userInitiatedRequestAuthorization() async -> [String: Any] {
    migrateLegacyStateIfNeeded()
    if isDiagnosticForceDisabled {
      return probeResult(ok: false, auth: cachedAuthorization, error: "diagnostic_force_off")
    }
    guard isVersionEligible else {
      return probeResult(ok: false, auth: "unsupported", error: "ios_version_ineligible")
    }
    if isUserDisabled {
      return probeResult(ok: false, auth: cachedAuthorization, error: "user_disabled")
    }
    requestAuthorizationCount += 1
    do {
      let auth = try await SvaAlarmKitManager.sharedManaging.requestAuthorizationSafely()
      UserDefaults.standard.set(auth, forKey: cachedAuthKey)
      sessionProbeFailed = false
      lastProbeError = nil
      if auth == "authorized" {
        markProbeSuccess(auth: auth)
      } else if auth == "denied" {
        // Cache denied — fan-out fallback, no persistent lock
        UserDefaults.standard.set(false, forKey: probeEverSucceededKey)
      }
      NSLog("[SVA-AlarmKit] user request auth=%@", auth)
      return probeResult(
        ok: auth == "authorized",
        auth: auth,
        error: auth == "authorized" ? nil : "not_authorized"
      )
    } catch {
      sessionProbeFailed = true
      lastProbeError = error.localizedDescription
      NSLog("[SVA-AlarmKit] user request failed session-only: %@", lastProbeError ?? "")
      return probeResult(ok: false, auth: cachedAuthorization, error: error.localizedDescription)
    }
  }

  static func markProbeSuccess(auth: String) {
    UserDefaults.standard.set(auth, forKey: cachedAuthKey)
    UserDefaults.standard.set(true, forKey: probeEverSucceededKey)
    sessionProbeFailed = false
    lastProbeError = nil
    NSLog("[SVA-AlarmKit] probe success auth=%@", auth)
  }

  static func noteScheduleError(_ message: String) {
    lastScheduleError = message
  }

  /// Reset legacy/debug failure locks without touching AlarmKit or user data.
  static func resetLegacyDiagnosticState(clearUserDisabled: Bool = false) {
    migrateLegacyStateIfNeeded()
    UserDefaults.standard.set(false, forKey: legacyDisabledKey)
    UserDefaults.standard.removeObject(forKey: legacyDisabledReasonKey)
    sessionProbeFailed = false
    lastProbeError = nil
    lastScheduleError = nil
    if cachedAuthorization == "unavailable" {
      UserDefaults.standard.set("unknown", forKey: cachedAuthKey)
    }
    if clearUserDisabled {
      UserDefaults.standard.set(false, forKey: userDisabledKey)
    }
    NSLog("[SVA-AlarmKit] reset legacy diagnostic state clearUserDisabled=%@",
          clearUserDisabled ? "true" : "false")
  }

  /// Backward-compatible alias for debug bridge.
  static func debugClearKillSwitch() {
    resetLegacyDiagnosticState(clearUserDisabled: false)
  }

  static func setUserDisabled(_ disabled: Bool) {
    UserDefaults.standard.set(disabled, forKey: userDisabledKey)
  }

  private static func probeResult(ok: Bool, auth: String, error: String?) -> [String: Any] {
    let (backend, reason) = backendSelection()
    let runtimeEnabled = backend == "alarmKit"
    var out: [String: Any] = [
      "ok": ok,
      "alarmKitAuthorization": auth,
      "cachedAuthorization": auth,
      "probeEverSucceeded": probeEverSucceeded,
      "userDisabled": isUserDisabled,
      "sessionProbeFailed": sessionProbeFailed,
      "runtimeEnabled": runtimeEnabled,
      "selectedBackend": backend,
      "backendSelectionReason": reason,
      "usesAlarmKit": runtimeEnabled,
      "supportsFullVoiceAlarm": runtimeEnabled && auth == "authorized",
      "runtimeVersionEligible": isVersionEligible,
      "alarmKitDisabled": isUserDisabled || isDiagnosticForceDisabled,
      "alarmKitRuntimeEnabled": runtimeEnabled,
    ]
    if let error { out["error"] = error }
    if let lastProbeError { out["lastProbeError"] = lastProbeError }
    return out
  }
}

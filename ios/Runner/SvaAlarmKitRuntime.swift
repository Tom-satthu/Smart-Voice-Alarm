import Foundation
import UIKit

/// Launch-safe AlarmKit runtime gate, kill switch, and call counters.
///
/// Startup and passive `getCapability` must never touch AlarmKit APIs.
enum SvaAlarmKitRuntime {
  private static let disabledKey = "sva_alarmkit_disabled"
  private static let enabledKey = "sva_alarmkit_probe_success"
  private static let cachedAuthKey = "sva_alarmkit_cached_auth"
  private static let disabledReasonKey = "sva_alarmkit_disabled_reason"

  // MARK: - Test / audit counters (incremented only on explicit AlarmKit API use)

  static var authorizationStateReadCount = 0
  static var requestAuthorizationCount = 0
  static var scheduleCount = 0
  static var reconcileCount = 0

  static func resetCountersForTests() {
    authorizationStateReadCount = 0
    requestAuthorizationCount = 0
    scheduleCount = 0
    reconcileCount = 0
  }

  // MARK: - Eligibility / kill switch (UserDefaults only — no AlarmKit)

  static var isVersionEligible: Bool {
    if #available(iOS 26.0, *) { return true }
    return false
  }

  static var isKillSwitchActive: Bool {
    if isDiagnosticForceDisabled { return true }
    return UserDefaults.standard.bool(forKey: disabledKey)
  }

  /// R1 diagnostic isolation: force AlarmKit fully off for entire session.
  static var isDiagnosticForceDisabled: Bool {
    if SvaBuildStampGenerated.alarmKitForceOff == "1" { return true }
    let raw = Bundle.main.object(forInfoDictionaryKey: "SVAAlarmKitForceOff")
    if let s = raw as? String { return s == "1" || s.lowercased() == "true" }
    if let b = raw as? Bool { return b }
    return false
  }

  static var diagnosticAlarmKitStartupLabel: String {
    if isDiagnosticForceDisabled { return "disabled" }
    if isKillSwitchActive { return "disabled" }
    if isProbeSuccessful { return "enabled" }
    return "passive"
  }

  static var isProbeSuccessful: Bool {
    UserDefaults.standard.bool(forKey: enabledKey)
  }

  static var cachedAuthorization: String {
    UserDefaults.standard.string(forKey: cachedAuthKey) ?? "unknown"
  }

  /// True only after a prior user-initiated probe succeeded and kill switch is off.
  static var mayCallAlarmKitAPI: Bool {
    if isDiagnosticForceDisabled { return false }
    return isVersionEligible && isProbeSuccessful && !isKillSwitchActive
  }

  // MARK: - Passive capability (launch-safe)

  static func passiveCapability() -> [String: Any] {
    let disabled = isKillSwitchActive || isDiagnosticForceDisabled
    let probed = isProbeSuccessful && !isDiagnosticForceDisabled
    let cached = cachedAuthorization
    let uses = probed && !disabled && isVersionEligible
    let full = uses && cached == "authorized"
    NSLog(
      "[SVA-AlarmKit] passive capability eligible=%@ disabled=%@ probed=%@ auth=%@ (no AlarmKit API)",
      isVersionEligible ? "true" : "false",
      disabled ? "true" : "false",
      probed ? "true" : "false",
      cached
    )
    return [
      "iosVersion": UIDevice.current.systemVersion,
      "runtimeVersionEligible": isVersionEligible,
      "usesAlarmKit": uses,
      "supportsFullVoiceAlarm": full,
      "alarmKitAuthorization": disabled ? "unavailable" : cached,
      "alarmKitDisabled": disabled || isDiagnosticForceDisabled,
      "alarmKitRuntimeEnabled": uses,
      "alarmKitStartup": diagnosticAlarmKitStartupLabel,
      "alarmKitForceOff": isDiagnosticForceDisabled,
      "maxVoiceSeconds": 20,
      "maxVoiceSegments": 5,
      "maxRingtoneSegments": 2,
      "gapSeconds": 5,
    ]
  }

  static func passiveDiagnostics() -> [String: Any] {
    let mappings = SvaAlarmKitStore.load()
    let pending = SvaPendingStore.peek()
    return [
      "passiveOnly": true,
      "runtimeVersionEligible": isVersionEligible,
      "alarmKitDisabled": isKillSwitchActive,
      "alarmKitRuntimeEnabled": isProbeSuccessful && !isKillSwitchActive,
      "authorization": cachedAuthorization,
      "authorizationStateReadCount": authorizationStateReadCount,
      "requestAuthorizationCount": requestAuthorizationCount,
      "scheduleCount": scheduleCount,
      "reconcileCount": reconcileCount,
      "mappingCount": mappings.count,
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
    ]
  }

  // MARK: - User-initiated probe (Save Alarm / debug only)

  static func userInitiatedProbeAuthorization() async -> [String: Any] {
    if isDiagnosticForceDisabled {
      return probeResult(ok: false, auth: "unavailable", error: "diagnostic_force_off")
    }
    guard isVersionEligible else {
      return probeResult(ok: false, auth: "unavailable", error: "ios_version_ineligible")
    }
    if isKillSwitchActive {
      return probeResult(ok: false, auth: "unavailable", error: "alarmkit_disabled")
    }
    authorizationStateReadCount += 1
    do {
      let auth = try await SvaAlarmKitManager.sharedManaging.readAuthorizationStateSafely()
      UserDefaults.standard.set(auth, forKey: cachedAuthKey)
      NSLog("[SVA-AlarmKit] user probe auth=%@", auth)
      return probeResult(ok: true, auth: auth, error: nil)
    } catch {
      markDisabled(reason: "probe_read_failed: \(error.localizedDescription)", persistent: true)
      return probeResult(ok: false, auth: "unavailable", error: error.localizedDescription)
    }
  }

  static func userInitiatedRequestAuthorization() async -> [String: Any] {
    if isDiagnosticForceDisabled {
      return probeResult(ok: false, auth: "unavailable", error: "diagnostic_force_off")
    }
    guard isVersionEligible else {
      return probeResult(ok: false, auth: "unavailable", error: "ios_version_ineligible")
    }
    if isKillSwitchActive {
      return probeResult(ok: false, auth: "unavailable", error: "alarmkit_disabled")
    }
    requestAuthorizationCount += 1
    do {
      let auth = try await SvaAlarmKitManager.sharedManaging.requestAuthorizationSafely()
      if auth == "authorized" {
        markProbeSuccess(auth: auth)
      } else {
        UserDefaults.standard.set(auth, forKey: cachedAuthKey)
        if auth == "denied" {
          markDisabled(reason: "authorization_denied", persistent: true)
        }
      }
      NSLog("[SVA-AlarmKit] user request auth=%@", auth)
      return probeResult(ok: auth == "authorized", auth: auth, error: auth == "authorized" ? nil : "not_authorized")
    } catch {
      markDisabled(reason: "request_failed: \(error.localizedDescription)", persistent: true)
      return probeResult(ok: false, auth: "unavailable", error: error.localizedDescription)
    }
  }

  static func markDisabled(reason: String, persistent: Bool) {
    if persistent {
      UserDefaults.standard.set(true, forKey: disabledKey)
      UserDefaults.standard.set(reason, forKey: disabledReasonKey)
    }
    UserDefaults.standard.set(false, forKey: enabledKey)
    UserDefaults.standard.set("unavailable", forKey: cachedAuthKey)
    NSLog("[SVA-AlarmKit] disabled persistent=%@ reason=%@", persistent ? "true" : "false", reason)
  }

  static func markProbeSuccess(auth: String) {
    UserDefaults.standard.set(false, forKey: disabledKey)
    UserDefaults.standard.set(true, forKey: enabledKey)
    UserDefaults.standard.set(auth, forKey: cachedAuthKey)
    UserDefaults.standard.removeObject(forKey: disabledReasonKey)
    NSLog("[SVA-AlarmKit] probe success auth=%@", auth)
  }

  /// Debug-only: clear kill switch so user can retry probe manually.
  static func debugClearKillSwitch() {
    UserDefaults.standard.set(false, forKey: disabledKey)
    UserDefaults.standard.set(false, forKey: enabledKey)
    UserDefaults.standard.set("unknown", forKey: cachedAuthKey)
    UserDefaults.standard.removeObject(forKey: disabledReasonKey)
    NSLog("[SVA-AlarmKit] debug clear kill switch")
  }

  private static func probeResult(ok: Bool, auth: String, error: String?) -> [String: Any] {
    var out: [String: Any] = [
      "ok": ok,
      "alarmKitAuthorization": auth,
      "alarmKitDisabled": isKillSwitchActive,
      "alarmKitRuntimeEnabled": isProbeSuccessful && !isKillSwitchActive,
      "usesAlarmKit": isProbeSuccessful && !isKillSwitchActive && isVersionEligible,
      "supportsFullVoiceAlarm": isProbeSuccessful && !isKillSwitchActive && auth == "authorized",
      "runtimeVersionEligible": isVersionEligible,
    ]
    if let error { out["error"] = error }
    return out
  }
}

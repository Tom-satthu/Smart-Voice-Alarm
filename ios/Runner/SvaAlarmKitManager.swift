import Foundation
import UIKit

#if canImport(AlarmKit)
import AlarmKit
#endif
#if canImport(ActivityKit)
import ActivityKit
#endif
#if canImport(AppIntents)
import AppIntents
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Mapping

struct SvaAlarmKitMapping: Codable, Equatable {
  var parentAlarmId: String
  var occurrenceId: String
  var segmentIndex: Int
  var childId: String
  var alarmId: String
  var soundFileName: String
  var role: String
  var cycleIndex: Int
  var scheduledStartMs: Int64
  var expectedDurationMs: Int
  var recoveryGeneration: Int
  var alertingAt: Double
  var stoppedAt: Double

  init(
    parentAlarmId: String,
    occurrenceId: String,
    segmentIndex: Int,
    childId: String,
    alarmId: String,
    soundFileName: String,
    role: String = "voice",
    cycleIndex: Int = 0,
    scheduledStartMs: Int64 = 0,
    expectedDurationMs: Int = 0,
    recoveryGeneration: Int = 0,
    alertingAt: Double = 0,
    stoppedAt: Double = 0
  ) {
    self.parentAlarmId = parentAlarmId
    self.occurrenceId = occurrenceId
    self.segmentIndex = segmentIndex
    self.childId = childId
    self.alarmId = alarmId
    self.soundFileName = soundFileName
    self.role = role
    self.cycleIndex = cycleIndex
    self.scheduledStartMs = scheduledStartMs
    self.expectedDurationMs = expectedDurationMs
    self.recoveryGeneration = recoveryGeneration
    self.alertingAt = alertingAt
    self.stoppedAt = stoppedAt
  }

  enum CodingKeys: String, CodingKey {
    case parentAlarmId, occurrenceId, segmentIndex, childId, alarmId, soundFileName
    case role, cycleIndex, scheduledStartMs, expectedDurationMs, recoveryGeneration
    case alertingAt, stoppedAt
  }

  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    parentAlarmId = try c.decode(String.self, forKey: .parentAlarmId)
    occurrenceId = try c.decode(String.self, forKey: .occurrenceId)
    segmentIndex = try c.decode(Int.self, forKey: .segmentIndex)
    childId = try c.decode(String.self, forKey: .childId)
    alarmId = try c.decode(String.self, forKey: .alarmId)
    soundFileName = try c.decode(String.self, forKey: .soundFileName)
    role = try c.decodeIfPresent(String.self, forKey: .role) ?? "voice"
    cycleIndex = try c.decodeIfPresent(Int.self, forKey: .cycleIndex) ?? 0
    scheduledStartMs = try c.decodeIfPresent(Int64.self, forKey: .scheduledStartMs) ?? 0
    expectedDurationMs = try c.decodeIfPresent(Int.self, forKey: .expectedDurationMs) ?? 0
    recoveryGeneration = try c.decodeIfPresent(Int.self, forKey: .recoveryGeneration) ?? 0
    alertingAt = try c.decodeIfPresent(Double.self, forKey: .alertingAt) ?? 0
    stoppedAt = try c.decodeIfPresent(Double.self, forKey: .stoppedAt) ?? 0
  }
}

enum SvaAlarmKitStore {
  private static let key = "sva_alarmkit_child_map"
  private static var defaults: UserDefaults { UserDefaults.standard }

  static func load() -> [SvaAlarmKitMapping] {
    guard let data = defaults.data(forKey: key) else { return [] }
    return (try? JSONDecoder().decode([SvaAlarmKitMapping].self, from: data)) ?? []
  }

  static func save(_ items: [SvaAlarmKitMapping]) {
    if let data = try? JSONEncoder().encode(items) {
      defaults.set(data, forKey: key)
    }
  }

  static func upsert(_ items: [SvaAlarmKitMapping]) {
    var map = Dictionary(uniqueKeysWithValues: load().map {
      (SvaPendingStore.mapKey(parent: $0.parentAlarmId, occurrence: $0.occurrenceId, index: $0.segmentIndex), $0)
    })
    for item in items {
      let key = SvaPendingStore.mapKey(
        parent: item.parentAlarmId,
        occurrence: item.occurrenceId,
        index: item.segmentIndex
      )
      map[key] = item
    }
    save(Array(map.values))
  }

  static func remove(alarmIds: Set<String>) {
    save(load().filter { !alarmIds.contains($0.alarmId) })
  }

  static func remove(parentAlarmId: String) {
    save(load().filter { $0.parentAlarmId != parentAlarmId })
  }

  static func remove(parentAlarmId: String, occurrenceId: String) {
    save(load().filter {
      !($0.parentAlarmId == parentAlarmId && $0.occurrenceId == occurrenceId)
    })
  }

  static func removeParentExcept(parentAlarmId: String, keepAlarmIds: Set<String>) {
    let kept = load().filter {
      $0.parentAlarmId != parentAlarmId || keepAlarmIds.contains($0.alarmId)
    }
    save(kept)
  }
}

struct SvaAlarmKitScheduleOutcome {
  var ok: Bool
  var backend: String
  var scheduledIds: [String]
  var warningCode: String?
  var warningMessage: String?
  var errorCode: String?
  var errorMessage: String?
  var stage: String

  var asDictionary: [String: Any] {
    var out: [String: Any] = [
      "ok": ok,
      "backend": backend,
      "scheduledIds": scheduledIds,
      "stage": stage,
    ]
    if let warningCode { out["warningCode"] = warningCode }
    if let warningMessage { out["warningMessage"] = warningMessage }
    if let errorCode { out["errorCode"] = errorCode }
    if let errorMessage { out["errorMessage"] = errorMessage }
    return out
  }
}

// MARK: - Protocol + Fake (tests)

protocol SvaAlarmManaging: AnyObject {
  func readAuthorizationStateSafely() async throws -> String
  func requestAuthorizationSafely() async throws -> String
  func schedule(
    segments: [SvaSegmentSpec],
    title: String
  ) async throws -> SvaAlarmKitScheduleOutcome
  func cancel(alarmIds: [String])
  func cancelParent(parentAlarmId: String)
  func cancelOccurrence(parentAlarmId: String, occurrenceId: String)
  func cancelParentExcept(parentAlarmId: String, keepAlarmIds: Set<String>)
  func scheduledAlarmIds() -> [String]
  func reconcile()
}

/// In-memory fake used by XCTest — never touches AlarmKit symbols.
final class FakeSvaAlarmManager: SvaAlarmManaging {
  var authorizationState: String = "authorized"
  var scheduled: [String: SvaAlarmKitMapping] = [:]
  var shouldFailSchedule = false
  var failAfterCount: Int?

  func readAuthorizationStateSafely() async throws -> String {
    SvaAlarmKitRuntime.authorizationStateReadCount += 1
    return authorizationState
  }

  func requestAuthorizationSafely() async throws -> String {
    SvaAlarmKitRuntime.requestAuthorizationCount += 1
    if authorizationState == "notDetermined" {
      authorizationState = "authorized"
    }
    return authorizationState
  }

  func schedule(
    segments: [SvaSegmentSpec],
    title: String
  ) async throws -> SvaAlarmKitScheduleOutcome {
    SvaAlarmKitRuntime.scheduleCount += 1
    if shouldFailSchedule {
      return SvaAlarmKitScheduleOutcome(
        ok: false,
        backend: "alarmKit",
        scheduledIds: [],
        warningCode: nil,
        warningMessage: nil,
        errorCode: "alarmkit_schedule_failed",
        errorMessage: "fake failure",
        stage: "alarmkit_schedule"
      )
    }
    var created: [String] = []
    var warningCode: String?
    var warningMessage: String?
    for (offset, segment) in segments.enumerated() {
      if let failAfterCount, offset >= failAfterCount {
        // Rollback newly created.
        for id in created { scheduled.removeValue(forKey: id) }
        return SvaAlarmKitScheduleOutcome(
          ok: false,
          backend: "alarmKit",
          scheduledIds: [],
          warningCode: nil,
          warningMessage: nil,
          errorCode: "alarmkit_schedule_failed",
          errorMessage: "fake mid-transaction failure",
          stage: "alarmkit_schedule"
        )
      }
      let id = SvaAlarmKitManager.deterministicAlarmId(for: segment.childId).uuidString
      var sound = segment.soundFileName
      if sound.isEmpty {
        warningCode = "custom_sound_fallback"
        warningMessage = "Empty sound — using default AlarmKit sound"
      }
      let mapping = SvaAlarmKitMapping(
        parentAlarmId: segment.parentAlarmId,
        occurrenceId: segment.occurrenceId,
        segmentIndex: segment.segmentIndex,
        childId: segment.childId,
        alarmId: id,
        soundFileName: sound,
        role: segment.role,
        cycleIndex: segment.cycleIndex,
        scheduledStartMs: segment.startAtMillis,
        expectedDurationMs: segment.durationMs,
        recoveryGeneration: segment.recoveryGeneration
      )
      scheduled[id] = mapping
      created.append(id)
    }
    SvaAlarmKitStore.upsert(Array(scheduled.values))
    return SvaAlarmKitScheduleOutcome(
      ok: true,
      backend: "alarmKit",
      scheduledIds: created,
      warningCode: warningCode,
      warningMessage: warningMessage,
      errorCode: nil,
      errorMessage: nil,
      stage: "alarmkit_schedule"
    )
  }

  func cancel(alarmIds: [String]) {
    for id in alarmIds { scheduled.removeValue(forKey: id) }
    SvaAlarmKitStore.remove(alarmIds: Set(alarmIds))
  }

  func cancelParent(parentAlarmId: String) {
    let ids = scheduled.values.filter { $0.parentAlarmId == parentAlarmId }.map(\.alarmId)
    cancel(alarmIds: ids)
  }

  func cancelOccurrence(parentAlarmId: String, occurrenceId: String) {
    let ids = scheduled.values.filter {
      $0.parentAlarmId == parentAlarmId && $0.occurrenceId == occurrenceId
    }.map(\.alarmId)
    cancel(alarmIds: ids)
  }

  func cancelParentExcept(parentAlarmId: String, keepAlarmIds: Set<String>) {
    let drop = scheduled.values.filter {
      $0.parentAlarmId == parentAlarmId && !keepAlarmIds.contains($0.alarmId)
    }.map(\.alarmId)
    cancel(alarmIds: drop)
  }

  func scheduledAlarmIds() -> [String] {
    Array(scheduled.keys)
  }

  func reconcile() {
    SvaAlarmKitRuntime.reconcileCount += 1
  }
}

// MARK: - Production manager

enum SvaAlarmKitManager {
  /// Shared production coordinator. On iOS < 26 this never touches AlarmKit.
  static var sharedManaging: SvaAlarmManaging = ProductionAlarmKitCoordinator()

  static var isRuntimeAvailable: Bool {
    SvaAlarmKitRuntime.isVersionEligible
  }

  static func authorizationStateString() -> String {
    // Launch-safe: never touch AlarmKit here.
    SvaAlarmKitRuntime.cachedAuthorization
  }

  static func deterministicAlarmId(for childId: String) -> UUID {
    if let uuid = UUID(uuidString: childId) {
      return uuid
    }
    // Stable UUID from SHA-like bytes of the child id string.
    var bytes = [UInt8](repeating: 0, count: 16)
    let utf8 = Array(childId.utf8)
    for (i, b) in utf8.enumerated() {
      bytes[i % 16] ^= b
      bytes[(i * 7) % 16] = bytes[(i * 7) % 16] &+ b
    }
    bytes[6] = (bytes[6] & 0x0F) | 0x40
    bytes[8] = (bytes[8] & 0x3F) | 0x80
    return UUID(uuid: (
      bytes[0], bytes[1], bytes[2], bytes[3],
      bytes[4], bytes[5], bytes[6], bytes[7],
      bytes[8], bytes[9], bytes[10], bytes[11],
      bytes[12], bytes[13], bytes[14], bytes[15]
    ))
  }
}

/// Production coordinator — gates all AlarmKit symbol use behind runtime + availability.
final class ProductionAlarmKitCoordinator: SvaAlarmManaging {
  func readAuthorizationStateSafely() async throws -> String {
    if #available(iOS 26.0, *) {
      #if canImport(AlarmKit)
      return Self.mapAuth(AlarmManager.shared.authorizationState)
      #else
      return "unavailable"
      #endif
    }
    return "unavailable"
  }

  func requestAuthorizationSafely() async throws -> String {
    if #available(iOS 26.0, *) {
      #if canImport(AlarmKit)
      let state = try await AlarmManager.shared.requestAuthorization()
      let mapped = Self.mapAuth(state)
      NSLog("[SVA-AlarmKit] authorization=%@", mapped)
      return mapped
      #else
      return "unavailable"
      #endif
    }
    return "unavailable"
  }

  func schedule(
    segments: [SvaSegmentSpec],
    title: String
  ) async throws -> SvaAlarmKitScheduleOutcome {
    guard SvaAlarmKitRuntime.mayCallAlarmKitAPI else {
      return Self.unavailableOutcome()
    }
    SvaAlarmKitRuntime.scheduleCount += 1
    if #available(iOS 26.0, *) {
      #if canImport(AlarmKit)
      return try await scheduleOnAlarmKit(segments: segments, title: title)
      #else
      return Self.unavailableOutcome()
      #endif
    }
    return Self.unavailableOutcome()
  }

  func cancel(alarmIds: [String]) {
    if SvaAlarmKitRuntime.mayCallAlarmKitAPI, #available(iOS 26.0, *) {
      #if canImport(AlarmKit)
      for idString in alarmIds {
        guard let id = UUID(uuidString: idString) else { continue }
        do {
          try AlarmManager.shared.cancel(id: id)
        } catch {
          NSLog("[SVA-AlarmKit] cancel failed id=%@ err=%@", idString, "\(error)")
        }
      }
      #endif
    }
    SvaAlarmKitStore.remove(alarmIds: Set(alarmIds))
  }

  func cancelParent(parentAlarmId: String) {
    let ids = SvaAlarmKitStore.load()
      .filter { $0.parentAlarmId == parentAlarmId }
      .map(\.alarmId)
    cancel(alarmIds: ids)
    SvaAlarmKitStore.remove(parentAlarmId: parentAlarmId)
  }

  func cancelOccurrence(parentAlarmId: String, occurrenceId: String) {
    let ids = SvaAlarmKitStore.load()
      .filter { $0.parentAlarmId == parentAlarmId && $0.occurrenceId == occurrenceId }
      .map(\.alarmId)
    cancel(alarmIds: ids)
    SvaAlarmKitStore.remove(parentAlarmId: parentAlarmId, occurrenceId: occurrenceId)
  }

  func cancelParentExcept(parentAlarmId: String, keepAlarmIds: Set<String>) {
    let drop = SvaAlarmKitStore.load()
      .filter { $0.parentAlarmId == parentAlarmId && !keepAlarmIds.contains($0.alarmId) }
      .map(\.alarmId)
    cancel(alarmIds: drop)
    SvaAlarmKitStore.removeParentExcept(parentAlarmId: parentAlarmId, keepAlarmIds: keepAlarmIds)
  }

  func scheduledAlarmIds() -> [String] {
    guard SvaAlarmKitRuntime.mayCallAlarmKitAPI else {
      return SvaAlarmKitStore.load().map(\.alarmId)
    }
    if #available(iOS 26.0, *) {
      #if canImport(AlarmKit)
      do {
        return try AlarmManager.shared.alarms.map { $0.id.uuidString }
      } catch {
        NSLog("[SVA-AlarmKit] alarms query failed: %@", "\(error)")
      }
      #endif
    }
    return SvaAlarmKitStore.load().map(\.alarmId)
  }

  func reconcile() {
    guard SvaAlarmKitRuntime.mayCallAlarmKitAPI else { return }
    SvaAlarmKitRuntime.reconcileCount += 1
    if #available(iOS 26.0, *) {
      #if canImport(AlarmKit)
      let live: Set<String>
      do {
        live = Set(try AlarmManager.shared.alarms.map { $0.id.uuidString })
      } catch {
        NSLog("[SVA-AlarmKit] reconcile skipped: %@", "\(error)")
        return
      }
      let mapped = SvaAlarmKitStore.load()
      let stale = mapped.filter { !live.contains($0.alarmId) }
      if !stale.isEmpty {
        NSLog("[SVA-AlarmKit] reconcile drop stale=%d", stale.count)
        SvaAlarmKitStore.remove(alarmIds: Set(stale.map(\.alarmId)))
      }
      #endif
    }
  }

  // MARK: - iOS 26 helpers

  #if canImport(AlarmKit)
  @available(iOS 26.0, *)
  private func scheduleOnAlarmKit(
    segments: [SvaSegmentSpec],
    title: String
  ) async throws -> SvaAlarmKitScheduleOutcome {
    NSLog("[SVA-AlarmKit] backend=alarmKit segments=%d", segments.count)
    var created: [SvaAlarmKitMapping] = []
    var warningCode: String?
    var warningMessage: String?

    do {
      let soundMode = SvaAlarmKitSoundNameMode.preferred
      let isRecovery = segments.contains { $0.recoveryGeneration > 0 }

      struct ResolvedChild {
        let segment: SvaSegmentSpec
        let alarmId: UUID
        let sound: AlertConfiguration.AlertSound
        let diagnostics: SvaSoundDiagnostics
      }
      var resolved: [ResolvedChild] = []
      for segment in segments {
        let alarmId = SvaAlarmKitManager.deterministicAlarmId(for: segment.childId)
        let sourceType = Self.inferSourceType(
          fileName: segment.soundFileName,
          label: segment.label
        )
        let trimmed = segment.soundFileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let intentionalSystemDefault =
          trimmed.isEmpty
          && (segment.label == "system_default" || segment.role == "ringtone")
        let allowDefault = intentionalSystemDefault && !isRecovery
        let soundResult = SvaAlarmKitSoundResolver.resolve(
          fileName: segment.soundFileName,
          mode: soundMode,
          sourceType: sourceType,
          childId: segment.childId,
          segmentIndex: segment.segmentIndex,
          alarmKitId: alarmId.uuidString,
          allowDefaultFallback: allowDefault,
          updateSource: isRecovery ? "recovery" : "initial_schedule"
        )
        if let w = soundResult.diagnostics.warningCode {
          warningCode = w
          warningMessage = soundResult.diagnostics.warningMessage
        }
        NSLog(
          "[SVA-AlarmKit] sound file=%@ named=%@ mode=%@ usedDefault=%d requireCustom=%d",
          segment.soundFileName,
          soundResult.diagnostics.alertSoundNameExact,
          soundMode.rawValue,
          soundResult.diagnostics.usedDefault ? 1 : 0,
          soundResult.diagnostics.requireCustomSound ? 1 : 0
        )
        guard let sound = soundResult.sound else {
          return SvaAlarmKitScheduleOutcome(
            ok: false,
            backend: "alarmKit",
            scheduledIds: [],
            warningCode: soundResult.diagnostics.warningCode ?? warningCode,
            warningMessage: soundResult.diagnostics.warningMessage ?? warningMessage,
            errorCode: soundResult.diagnostics.warningCode ?? "custom_sound_invalid",
            errorMessage: soundResult.diagnostics.warningMessage
              ?? "Custom sound required — refused default fallback",
            stage: isRecovery ? "recovery_sound_resolve" : "alarmkit_sound_resolve"
          )
        }
        if soundResult.diagnostics.usedDefault && !allowDefault {
          return SvaAlarmKitScheduleOutcome(
            ok: false,
            backend: "alarmKit",
            scheduledIds: [],
            warningCode: "custom_sound_default_refused",
            warningMessage: "Resolver attempted default for custom child",
            errorCode: "custom_sound_default_refused",
            errorMessage: "Custom recovery/voice must not use .default",
            stage: isRecovery ? "recovery_sound_resolve" : "alarmkit_sound_resolve"
          )
        }
        resolved.append(
          ResolvedChild(
            segment: segment,
            alarmId: alarmId,
            sound: sound,
            diagnostics: soundResult.diagnostics
          )
        )
      }

      for item in resolved {
        let segment = item.segment
        let alarmId = item.alarmId
        NSLog(
          "[SVA-AlarmKit] schedule child=%@ index=%d id=%@",
          segment.childId,
          segment.segmentIndex,
          alarmId.uuidString
        )

        let fireDate = Date(timeIntervalSince1970: Double(segment.startAtMillis) / 1000.0)
        guard fireDate.timeIntervalSinceNow > 0.5 else {
          NSLog("[SVA-AlarmKit] skip past child=%@", segment.childId)
          continue
        }

        let stopIntent = SvaStopAlarmIntent(
          parentAlarmId: segment.parentAlarmId,
          occurrenceId: segment.occurrenceId,
          childId: segment.childId,
          segmentIndex: segment.segmentIndex,
          alarmKitId: alarmId.uuidString,
          scheduledTimestamp: Double(segment.startAtMillis) / 1000.0
        )
        let secondaryIntent = SvaSolveToStopIntent(
          parentAlarmId: segment.parentAlarmId,
          occurrenceId: segment.occurrenceId,
          childId: segment.childId,
          segmentIndex: segment.segmentIndex,
          alarmKitId: alarmId.uuidString,
          scheduledTimestamp: Double(segment.startAtMillis) / 1000.0
        )

        let stopButton = AlarmButton(
          text: "Stop",
          textColor: .white,
          systemImageName: "stop.circle"
        )
        let secondaryButton = AlarmButton(
          text: "Solve to stop",
          textColor: .white,
          systemImageName: "function"
        )
        let alert = AlarmPresentation.Alert(
          title: LocalizedStringResource(stringLiteral: title),
          stopButton: stopButton,
          secondaryButton: secondaryButton,
          secondaryButtonBehavior: .custom
        )
        let presentation = AlarmPresentation(alert: alert)
        let metadata = SvaAlarmMetadata(
          parentAlarmId: segment.parentAlarmId,
          occurrenceId: segment.occurrenceId,
          childId: segment.childId,
          segmentIndex: segment.segmentIndex
        )
        let attributes = AlarmAttributes(
          presentation: presentation,
          metadata: metadata,
          tintColor: Color.teal
        )
        let configuration = AlarmManager.AlarmConfiguration.alarm(
          schedule: .fixed(fireDate),
          attributes: attributes,
          stopIntent: stopIntent,
          secondaryIntent: secondaryIntent,
          sound: item.sound
        )
        _ = try await AlarmManager.shared.schedule(id: alarmId, configuration: configuration)
        var scheduledDiag = item.diagnostics
        scheduledDiag.scheduleOk = true
        SvaAlarmKitSoundStore.saveLast(scheduledDiag)
        created.append(
          SvaAlarmKitMapping(
            parentAlarmId: segment.parentAlarmId,
            occurrenceId: segment.occurrenceId,
            segmentIndex: segment.segmentIndex,
            childId: segment.childId,
            alarmId: alarmId.uuidString,
            soundFileName: segment.soundFileName,
            role: segment.role,
            cycleIndex: segment.cycleIndex,
            scheduledStartMs: segment.startAtMillis,
            expectedDurationMs: segment.durationMs,
            recoveryGeneration: segment.recoveryGeneration
          )
        )
      }

      if created.isEmpty {
        return SvaAlarmKitScheduleOutcome(
          ok: false,
          backend: "alarmKit",
          scheduledIds: [],
          warningCode: warningCode,
          warningMessage: warningMessage,
          errorCode: "alarmkit_no_future_segments",
          errorMessage: "No future AlarmKit segments could be scheduled",
          stage: "alarmkit_schedule"
        )
      }

      SvaAlarmKitStore.upsert(created)
      return SvaAlarmKitScheduleOutcome(
        ok: true,
        backend: "alarmKit",
        scheduledIds: created.map(\.alarmId),
        warningCode: warningCode,
        warningMessage: warningMessage,
        errorCode: nil,
        errorMessage: nil,
        stage: "alarmkit_schedule"
      )
    } catch {
      // Transaction rollback: cancel only newly created alarms; keep prior mapping.
      let newIds = created.map(\.alarmId)
      for idString in newIds {
        if let id = UUID(uuidString: idString) {
          try? AlarmManager.shared.cancel(id: id)
        }
      }
      NSLog("[SVA-AlarmKit] schedule failed rollback=%d err=%@", newIds.count, "\(error)")
      return SvaAlarmKitScheduleOutcome(
        ok: false,
        backend: "alarmKit",
        scheduledIds: [],
        warningCode: nil,
        warningMessage: nil,
        errorCode: "alarmkit_schedule_failed",
        errorMessage: error.localizedDescription,
        stage: "alarmkit_schedule"
      )
    }
  }

  @available(iOS 26.0, *)
  private static func mapAuth(_ state: AlarmManager.AuthorizationState) -> String {
    switch state {
    case .notDetermined: return "notDetermined"
    case .authorized: return "authorized"
    case .denied: return "denied"
    @unknown default: return "unavailable"
    }
  }

  private static func inferSourceType(fileName: String, label: String) -> String {
    let lower = label.lowercased()
    if lower.contains("system_default") || fileName.isEmpty { return "default" }
    if lower.contains("ringtone") || lower.contains("chime") || lower.contains("tone") {
      return "ringtone"
    }
    if lower.contains("tts") { return "tts" }
    if lower.contains("record") || lower.contains("voice") { return "recording" }
    if fileName.hasPrefix("sva_") { return "rendered" }
    return "unknown"
  }
  #endif

  private static func unavailableOutcome() -> SvaAlarmKitScheduleOutcome {
    SvaAlarmKitScheduleOutcome(
      ok: false,
      backend: "alarmKit",
      scheduledIds: [],
      warningCode: nil,
      warningMessage: nil,
      errorCode: "alarmkit_unavailable",
      errorMessage: "AlarmKit unavailable on this OS",
      stage: "alarmkit_schedule"
    )
  }
}

// MARK: - Metadata

#if canImport(AlarmKit)
@available(iOS 26.0, *)
struct SvaAlarmMetadata: AlarmMetadata {
  var parentAlarmId: String
  var occurrenceId: String
  var childId: String
  var segmentIndex: Int
}
#endif

import Foundation

/// Thin facade over [SvaAlarmKitManager] for MethodChannel call sites.
enum SvaAlarmKitScheduler {
  static func schedule(
    segments: [SvaSegmentSpec],
    title: String
  ) async throws -> SvaAlarmKitScheduleOutcome {
    guard SvaAlarmKitRuntime.mayCallAlarmKitAPI else {
      return unavailableOutcome(stage: "alarmkit_schedule")
    }
    return try await SvaAlarmKitManager.sharedManaging.schedule(segments: segments, title: title)
  }

  static func cancel(childIds: [String]) {
    let mapped = SvaAlarmKitStore.load()
    var alarmIds = Set(childIds)
    for item in mapped where childIds.contains(item.childId) || childIds.contains(item.alarmId) {
      alarmIds.insert(item.alarmId)
    }
    if SvaAlarmKitRuntime.mayCallAlarmKitAPI {
      SvaAlarmKitManager.sharedManaging.cancel(alarmIds: Array(alarmIds))
    } else {
      SvaAlarmKitStore.remove(alarmIds: alarmIds)
    }
  }

  static func cancelParent(parentAlarmId: String) {
    if SvaAlarmKitRuntime.mayCallAlarmKitAPI {
      SvaAlarmKitManager.sharedManaging.cancelParent(parentAlarmId: parentAlarmId)
    } else {
      SvaAlarmKitStore.remove(parentAlarmId: parentAlarmId)
    }
  }

  static func cancelOccurrence(parentAlarmId: String, occurrenceId: String) {
    if SvaAlarmKitRuntime.mayCallAlarmKitAPI {
      SvaAlarmKitManager.sharedManaging.cancelOccurrence(
        parentAlarmId: parentAlarmId,
        occurrenceId: occurrenceId
      )
    } else {
      SvaAlarmKitStore.remove(parentAlarmId: parentAlarmId, occurrenceId: occurrenceId)
    }
  }

  static func cancelParentExcept(parentAlarmId: String, keepChildIds: Set<String>) {
    let mapped = SvaAlarmKitStore.load()
    var keepAlarmIds = Set<String>()
    for item in mapped where item.parentAlarmId == parentAlarmId {
      if keepChildIds.contains(item.childId) || keepChildIds.contains(item.alarmId) {
        keepAlarmIds.insert(item.alarmId)
      }
    }
    keepAlarmIds.formUnion(keepChildIds)
    if SvaAlarmKitRuntime.mayCallAlarmKitAPI {
      SvaAlarmKitManager.sharedManaging.cancelParentExcept(
        parentAlarmId: parentAlarmId,
        keepAlarmIds: keepAlarmIds
      )
    } else {
      SvaAlarmKitStore.removeParentExcept(
        parentAlarmId: parentAlarmId,
        keepAlarmIds: keepAlarmIds
      )
    }
  }

  static func reconcile() {
    guard SvaAlarmKitRuntime.mayCallAlarmKitAPI else { return }
    SvaAlarmKitManager.sharedManaging.reconcile()
  }

  static func diagnostics() -> [String: Any] {
    SvaAlarmKitRuntime.passiveDiagnostics()
  }

  private static func unavailableOutcome(stage: String) -> SvaAlarmKitScheduleOutcome {
    SvaAlarmKitScheduleOutcome(
      ok: false,
      backend: "alarmKit",
      scheduledIds: [],
      warningCode: nil,
      warningMessage: nil,
      errorCode: "alarmkit_unavailable",
      errorMessage: "AlarmKit runtime not enabled",
      stage: stage
    )
  }
}

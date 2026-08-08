import Foundation

#if canImport(AlarmKit)
import AlarmKit
#endif

/// Observes AlarmKit updates and drives unsolved stop recovery (native-first).
enum SvaAlarmKitUpdateObserver {
  static let shared = SvaAlarmKitUpdateObserverBox()
}

final class SvaAlarmKitUpdateObserverBox {
  private var started = false
  private var task: Task<Void, Never>?
  private var lastKnownIds = Set<String>()
  private var lastStates: [String: String] = [:]

  func startIfNeeded() {
    guard !started else { return }
    started = true
    lastKnownIds = Set(SvaAlarmKitStore.load().map(\.alarmId))
    #if canImport(AlarmKit)
    if #available(iOS 26.0, *) {
      task = Task { await self.observe() }
      NSLog("[SVA-AlarmKit] alarmUpdates observer started known=%d", lastKnownIds.count)
    }
    #endif
  }

  #if canImport(AlarmKit)
  @available(iOS 26.0, *)
  private func observe() async {
    for await alarms in AlarmManager.shared.alarmUpdates {
      let now = Date().timeIntervalSince1970
      let currentIds = Set(alarms.map { $0.id.uuidString })
      var currentStates: [String: String] = [:]

      for alarm in alarms {
        let id = alarm.id.uuidString
        let stateDesc = String(describing: alarm.state)
        currentStates[id] = stateDesc
        if let mapping = SvaAlarmKitStore.load().first(where: { $0.alarmId == id || $0.childId == id }) {
          let prev = lastStates[id]
          if prev != stateDesc {
            NSLog(
              "[SVA-AlarmKit] childDiag parent=%@ occurrence=%@ child=%@ alarmKit=%@ cycle=%d seg=%d role=%@ scheduledStartMs=%lld expectedDurationMs=%d state=%@ prev=%@ solved=%d",
              mapping.parentAlarmId,
              mapping.occurrenceId,
              mapping.childId,
              mapping.alarmId,
              mapping.cycleIndex,
              mapping.segmentIndex,
              mapping.role,
              mapping.scheduledStartMs,
              mapping.expectedDurationMs,
              stateDesc,
              prev ?? "-",
              SvaOccurrenceStore.isSolved(parent: mapping.parentAlarmId, occurrence: mapping.occurrenceId) ? 1 : 0
            )
          }
          if stateDesc.lowercased().contains("alert") {
            var updated = mapping
            if updated.alertingAt <= 0 {
              updated.alertingAt = now
              SvaAlarmKitStore.upsert([updated])
            }
          }
        }
      }

      let removed = lastKnownIds.subtracting(currentIds)
      for id in removed {
        await handleRemoved(id: id, at: now, reason: "alarm_removed_from_updates")
      }

      // Some builds may keep the alarm but transition state text including "stopped".
      for (id, stateDesc) in currentStates {
        if stateDesc.lowercased().contains("stop") {
          await handleRemoved(id: id, at: now, reason: "state_\(stateDesc)")
        }
      }

      lastKnownIds = currentIds
      lastStates = currentStates
    }
  }

  @available(iOS 26.0, *)
  private func handleRemoved(id: String, at: Double, reason: String) async {
    let mappings = SvaAlarmKitStore.load()
    guard var mapping = mappings.first(where: { $0.alarmId == id || $0.childId == id })
    else { return }
    mapping.stoppedAt = at
    SvaAlarmKitStore.upsert([mapping])

    await SvaAlarmKitRecovery.handleChildStopped(
      parent: mapping.parentAlarmId,
      occurrence: mapping.occurrenceId,
      stoppedAlarmKitId: mapping.alarmId,
      childId: mapping.childId,
      role: mapping.role,
      scheduledStart: mapping.scheduledStartMs > 0
        ? Double(mapping.scheduledStartMs) / 1000.0
        : nil,
      expectedDurationMs: mapping.expectedDurationMs > 0 ? mapping.expectedDurationMs : nil,
      reason: reason
    )
  }
  #endif
}

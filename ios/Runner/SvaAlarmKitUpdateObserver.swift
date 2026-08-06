import Foundation

#if canImport(AlarmKit)
import AlarmKit
#endif

/// Observes AlarmKit alarm state updates for unsolved-occurrence recovery.
///
/// System Stop / physical buttons may silence the *current* child. This observer
/// never marks solved=true and never cancels future children. It only logs and
/// leaves room for rolling-window refill when the app is active.
enum SvaAlarmKitUpdateObserver {
  static let shared = SvaAlarmKitUpdateObserverBox()
}

final class SvaAlarmKitUpdateObserverBox {
  private var started = false
  private var task: Task<Void, Never>?

  func startIfNeeded() {
    guard !started else { return }
    started = true
    #if canImport(AlarmKit)
    if #available(iOS 26.0, *) {
      task = Task { await self.observe() }
      NSLog("[SVA-AlarmKit] alarmUpdates observer started")
    }
    #endif
  }

  #if canImport(AlarmKit)
  @available(iOS 26.0, *)
  private func observe() async {
    for await alarms in AlarmManager.shared.alarmUpdates {
      for alarm in alarms {
        handleAlarm(id: alarm.id.uuidString)
      }
    }
  }

  @available(iOS 26.0, *)
  private func handleAlarm(id: String) {
    let mappings = SvaAlarmKitStore.load()
    guard let mapping = mappings.first(where: { $0.alarmId == id || $0.childId == id })
    else { return }

    let solved = SvaOccurrenceStore.isSolved(
      parent: mapping.parentAlarmId,
      occurrence: mapping.occurrenceId
    )
    if solved {
      NSLog(
        "[SVA-AlarmKit] update ignored solved parent=%@ occurrence=%@ child=%@",
        mapping.parentAlarmId,
        mapping.occurrenceId,
        mapping.childId
      )
      return
    }

    // Do not cancel future children. Log for diagnostics / rolling refill only.
    NSLog(
      "[SVA-AlarmKit] update unsolved stopSource=systemState parent=%@ occurrence=%@ child=%@",
      mapping.parentAlarmId,
      mapping.occurrenceId,
      mapping.childId
    )
  }
  #endif
}

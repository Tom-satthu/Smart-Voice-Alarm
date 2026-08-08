import Foundation

/// Durable parent-level lifecycle barrier for AlarmKit races.
///
/// Toggle OFF / delete / occurrence complete bump [cancellationGeneration]
/// so in-flight recovery cannot recreate children after cancellation wins.
struct SvaParentLifecycleState: Codable, Equatable {
  var parentAlarmId: String
  var enabled: Bool
  var deleted: Bool
  var cancellationGeneration: Int
  var updatedAt: Double
  var reason: String

  var asDictionary: [String: Any] {
    [
      "parentAlarmId": parentAlarmId,
      "enabled": enabled,
      "deleted": deleted,
      "cancellationGeneration": cancellationGeneration,
      "updatedAt": updatedAt,
      "reason": reason,
    ]
  }

  static func empty(parent: String) -> SvaParentLifecycleState {
    SvaParentLifecycleState(
      parentAlarmId: parent,
      enabled: true,
      deleted: false,
      cancellationGeneration: 0,
      updatedAt: Date().timeIntervalSince1970,
      reason: ""
    )
  }
}

enum SvaParentLifecycleStore {
  private static let key = "sva_alarmkit_parent_lifecycle"
  private static var defaults: UserDefaults { .standard }

  static func loadAll() -> [SvaParentLifecycleState] {
    guard let data = defaults.data(forKey: key) else { return [] }
    return (try? JSONDecoder().decode([SvaParentLifecycleState].self, from: data)) ?? []
  }

  static func saveAll(_ items: [SvaParentLifecycleState]) {
    if let data = try? JSONEncoder().encode(items) {
      defaults.set(data, forKey: key)
    }
  }

  static func get(parent: String) -> SvaParentLifecycleState? {
    loadAll().first { $0.parentAlarmId == parent }
  }

  static func upsert(_ state: SvaParentLifecycleState) {
    var all = Dictionary(uniqueKeysWithValues: loadAll().map { ($0.parentAlarmId, $0) })
    all[state.parentAlarmId] = state
    saveAll(Array(all.values))
  }

  /// Increments cancellation generation and marks parent disabled/deleted.
  @discardableResult
  static func activateCancellation(
    parent: String,
    enabled: Bool,
    deleted: Bool,
    reason: String
  ) -> SvaParentLifecycleState {
    var state = get(parent: parent) ?? SvaParentLifecycleState.empty(parent: parent)
    state.enabled = enabled
    state.deleted = deleted
    state.cancellationGeneration += 1
    state.updatedAt = Date().timeIntervalSince1970
    state.reason = reason
    upsert(state)
    // Also bump every unsolved occurrence cancelGen so recovery mid-flight aborts.
    for var occ in SvaOccurrenceStore.loadAll() where occ.parentAlarmId == parent && !occ.solved {
      occ.cancellationGeneration += 1
      occ.updatedAt = Date().timeIntervalSince1970
      SvaOccurrenceStore.upsert(occ)
    }
    NSLog(
      "[SVA-AlarmKit] parentBarrier parent=%@ enabled=%d deleted=%d cancelGen=%d reason=%@",
      parent,
      enabled ? 1 : 0,
      deleted ? 1 : 0,
      state.cancellationGeneration,
      reason
    )
    return state
  }

  /// Clears disabled/deleted barriers when user toggles ON / re-schedules.
  static func clearDisabledBarrier(parent: String) {
    var state = get(parent: parent) ?? SvaParentLifecycleState.empty(parent: parent)
    state.enabled = true
    state.deleted = false
    state.updatedAt = Date().timeIntervalSince1970
    state.reason = "cleared_for_enable"
    // Keep generation (monotonic); do not reset.
    upsert(state)
  }

  static func isBlocked(parent: String) -> Bool {
    guard let state = get(parent: parent) else { return false }
    return state.deleted || !state.enabled
  }

  static func cancellationGeneration(parent: String) -> Int {
    get(parent: parent)?.cancellationGeneration ?? 0
  }

  static func allAsDictionary() -> [String: [String: Any]] {
    var out: [String: [String: Any]] = [:]
    for state in loadAll() {
      out[state.parentAlarmId] = state.asDictionary
    }
    return out
  }
}

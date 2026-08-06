import Foundation

/// Persisted AlarmKit occurrence lifecycle (solved vs rolling unsolved).
struct SvaOccurrenceState: Codable, Equatable {
  var parentAlarmId: String
  var occurrenceId: String
  var solved: Bool
  var revision: String
  var rollingHorizonEnd: Double
  var cyclesScheduled: Int
  var childCount: Int
  var audibleChildCount: Int
  var silentChildCount: Int
  var cycleDurationMs: Int
  var updatedAt: Double

  var asDictionary: [String: Any] {
    [
      "parentAlarmId": parentAlarmId,
      "occurrenceId": occurrenceId,
      "solved": solved,
      "revision": revision,
      "rollingHorizonEnd": rollingHorizonEnd,
      "cyclesScheduled": cyclesScheduled,
      "childCount": childCount,
      "audibleChildCount": audibleChildCount,
      "silentChildCount": silentChildCount,
      "cycleDurationMs": cycleDurationMs,
      "updatedAt": updatedAt,
      "occurrenceSolved": solved,
    ]
  }
}

enum SvaOccurrenceStore {
  private static let key = "sva_alarmkit_occurrence_states"
  private static var defaults: UserDefaults { .standard }

  private static func mapKey(parent: String, occurrence: String) -> String {
    "\(parent)|\(occurrence)"
  }

  static func loadAll() -> [SvaOccurrenceState] {
    guard let data = defaults.data(forKey: key) else { return [] }
    return (try? JSONDecoder().decode([SvaOccurrenceState].self, from: data)) ?? []
  }

  static func saveAll(_ items: [SvaOccurrenceState]) {
    if let data = try? JSONEncoder().encode(items) {
      defaults.set(data, forKey: key)
    }
  }

  static func upsert(_ state: SvaOccurrenceState) {
    var all = Dictionary(uniqueKeysWithValues: loadAll().map {
      (mapKey(parent: $0.parentAlarmId, occurrence: $0.occurrenceId), $0)
    })
    all[mapKey(parent: state.parentAlarmId, occurrence: state.occurrenceId)] = state
    saveAll(Array(all.values))
  }

  static func get(parent: String, occurrence: String) -> SvaOccurrenceState? {
    loadAll().first {
      $0.parentAlarmId == parent && $0.occurrenceId == occurrence
    }
  }

  static func isSolved(parent: String, occurrence: String) -> Bool {
    get(parent: parent, occurrence: occurrence)?.solved == true
  }

  static func markSolved(parent: String, occurrence: String) {
    var state = get(parent: parent, occurrence: occurrence) ?? SvaOccurrenceState(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      solved: true,
      revision: "",
      rollingHorizonEnd: 0,
      cyclesScheduled: 0,
      childCount: 0,
      audibleChildCount: 0,
      silentChildCount: 0,
      cycleDurationMs: 0,
      updatedAt: Date().timeIntervalSince1970
    )
    state.solved = true
    state.updatedAt = Date().timeIntervalSince1970
    upsert(state)
    NSLog(
      "[SVA-AlarmKit] occurrence solved parent=%@ occurrence=%@",
      parent,
      occurrence
    )
  }

  static func remove(parent: String, occurrence: String) {
    saveAll(loadAll().filter {
      !($0.parentAlarmId == parent && $0.occurrenceId == occurrence)
    })
  }
}

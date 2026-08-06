import Foundation

/// Shared payload keys for Flutter ↔ native alarm fan-out.
enum SvaAlarmKeys {
  static let suiteName = "group.com.smartvoicealarm.app"
  static let pendingChallenge = "sva_pending_challenge"
  static let childMap = "sva_child_alarm_map"
  static let categorySolve = "SVA_ALARM_SOLVE_CATEGORY"
  static let actionSolve = "SVA_SOLVE_TO_STOP"
  static let channelName = "com.smartvoicealarm.app/ios_alarms"
}

struct SvaPendingChallenge: Codable, Equatable {
  var parentAlarmId: String
  var occurrenceId: String
  var childId: String
  var segmentIndex: Int
  var scheduledTimestamp: Double
  var openChallenge: Bool

  var asDictionary: [String: Any] {
    [
      "parentAlarmId": parentAlarmId,
      "occurrenceId": occurrenceId,
      "childId": childId,
      "segmentIndex": segmentIndex,
      "scheduledTimestamp": scheduledTimestamp,
      "openChallenge": openChallenge,
    ]
  }

  static func from(dictionary: [String: Any]) -> SvaPendingChallenge? {
    guard let parentRaw = dictionary["parentAlarmId"],
          let occurrenceRaw = dictionary["occurrenceId"],
          let childRaw = dictionary["childId"]
    else {
      let keys = dictionary.keys.sorted().joined(separator: ",")
      NSLog("[SVA-Challenge] parseFailed missingFields keys=%@", keys)
      return nil
    }
    let parent = "\(parentRaw)".trimmingCharacters(in: .whitespacesAndNewlines)
    let occurrence = "\(occurrenceRaw)".trimmingCharacters(in: .whitespacesAndNewlines)
    let child = "\(childRaw)".trimmingCharacters(in: .whitespacesAndNewlines)
    guard !parent.isEmpty, !occurrence.isEmpty, !child.isEmpty else {
      NSLog("[SVA-Challenge] parseFailed empty parent/occurrence/child")
      return nil
    }
    return SvaPendingChallenge(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      childId: child,
      segmentIndex: intValue(dictionary["segmentIndex"]) ?? 0,
      scheduledTimestamp: doubleValue(dictionary["scheduledTimestamp"]) ?? 0,
      openChallenge: (dictionary["openChallenge"] as? Bool) ?? true
    )
  }

  private static func intValue(_ raw: Any?) -> Int? {
    if let n = raw as? NSNumber { return n.intValue }
    if let i = raw as? Int { return i }
    if let d = raw as? Double { return Int(d) }
    return nil
  }

  private static func doubleValue(_ raw: Any?) -> Double? {
    if let n = raw as? NSNumber { return n.doubleValue }
    if let d = raw as? Double { return d }
    if let i = raw as? Int { return Double(i) }
    return nil
  }
}

struct SvaSegmentSpec: Equatable {
  let parentAlarmId: String
  let occurrenceId: String
  let segmentIndex: Int
  let childId: String
  let startAtMillis: Int64
  let soundFileName: String
  let label: String
  let durationMs: Int
  let role: String
  let cycleIndex: Int
  let recoveryGeneration: Int

  init(
    parentAlarmId: String,
    occurrenceId: String,
    segmentIndex: Int,
    childId: String,
    startAtMillis: Int64,
    soundFileName: String,
    label: String,
    durationMs: Int,
    role: String = "voice",
    cycleIndex: Int = 0,
    recoveryGeneration: Int = 0
  ) {
    self.parentAlarmId = parentAlarmId
    self.occurrenceId = occurrenceId
    self.segmentIndex = segmentIndex
    self.childId = childId
    self.startAtMillis = startAtMillis
    self.soundFileName = soundFileName
    self.label = label
    self.durationMs = durationMs
    self.role = role
    self.cycleIndex = cycleIndex
    self.recoveryGeneration = recoveryGeneration
  }
}

enum SvaPendingStore {
  private static var defaults: UserDefaults { UserDefaults.standard }

  static func save(_ challenge: SvaPendingChallenge) {
    if let data = try? JSONEncoder().encode(challenge) {
      defaults.set(data, forKey: SvaAlarmKeys.pendingChallenge)
    }
  }

  static func peek() -> SvaPendingChallenge? {
    guard let data = defaults.data(forKey: SvaAlarmKeys.pendingChallenge) else { return nil }
    return try? JSONDecoder().decode(SvaPendingChallenge.self, from: data)
  }

  static func consume() -> SvaPendingChallenge? {
    let value = peek()
    defaults.removeObject(forKey: SvaAlarmKeys.pendingChallenge)
    return value
  }

  /// Remove pending only when Flutter confirms navigation for matching parent+occurrence.
  static func acknowledge(parent: String, occurrence: String) -> Bool {
    guard let pending = peek(),
          pending.parentAlarmId == parent,
          pending.occurrenceId == occurrence
    else {
      NSLog("[SVA-Challenge] acknowledge mismatch parent=%@ occurrence=%@", parent, occurrence)
      return false
    }
    defaults.removeObject(forKey: SvaAlarmKeys.pendingChallenge)
    NSLog("[SVA-Challenge] acknowledge ok parent=%@ occurrence=%@", parent, occurrence)
    return true
  }

  static func clearAfterSolve(parent: String, occurrence: String) {
    if let pending = peek(),
       pending.parentAlarmId == parent,
       pending.occurrenceId == occurrence
    {
      defaults.removeObject(forKey: SvaAlarmKeys.pendingChallenge)
      NSLog("[SVA-Challenge] cleared after solve parent=%@ occurrence=%@", parent, occurrence)
    }
  }

  /// Child UUID map keyed by "parent|occurrence|index"
  static func loadChildMap() -> [String: String] {
    (defaults.dictionary(forKey: SvaAlarmKeys.childMap) as? [String: String]) ?? [:]
  }

  static func saveChildMap(_ map: [String: String]) {
    defaults.set(map, forKey: SvaAlarmKeys.childMap)
  }

  static func mapKey(parent: String, occurrence: String, index: Int) -> String {
    "\(parent)|\(occurrence)|\(index)"
  }
}

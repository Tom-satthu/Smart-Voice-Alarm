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
    guard
      let parent = dictionary["parentAlarmId"] as? String,
      let occurrence = dictionary["occurrenceId"] as? String,
      let child = dictionary["childId"] as? String
    else { return nil }
    return SvaPendingChallenge(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      childId: child,
      segmentIndex: (dictionary["segmentIndex"] as? NSNumber)?.intValue
        ?? (dictionary["segmentIndex"] as? Int)
        ?? 0,
      scheduledTimestamp: (dictionary["scheduledTimestamp"] as? NSNumber)?.doubleValue
        ?? (dictionary["scheduledTimestamp"] as? Double)
        ?? 0,
      openChallenge: (dictionary["openChallenge"] as? Bool) ?? true
    )
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

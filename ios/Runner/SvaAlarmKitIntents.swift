import Foundation
#if canImport(AppIntents)
import AppIntents
#endif

#if canImport(AppIntents)

/// AlarmKit Stop button intent.
///
/// Stops only the child the user interacted with (system AlarmKit behavior).
/// Does **not** cancel remaining children of the occurrence, and does **not**
/// mark the parent dismissed. Opens the app into Math Challenge.
@available(iOS 26.0, *)
struct SvaStopAlarmIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Stop Alarm"
  static var description = IntentDescription(
    "Open Math Challenge without cancelling remaining segments"
  )
  static var openAppWhenRun: Bool = true
  static var isDiscoverable: Bool = false

  @Parameter(title: "Parent Alarm ID")
  var parentAlarmId: String

  @Parameter(title: "Occurrence ID")
  var occurrenceId: String

  @Parameter(title: "Child ID")
  var childId: String

  @Parameter(title: "Segment Index")
  var segmentIndex: Int

  @Parameter(title: "AlarmKit ID")
  var alarmKitId: String

  @Parameter(title: "Scheduled Timestamp")
  var scheduledTimestamp: Double

  init() {
    parentAlarmId = ""
    occurrenceId = ""
    childId = ""
    segmentIndex = 0
    alarmKitId = ""
    scheduledTimestamp = 0
  }

  init(
    parentAlarmId: String,
    occurrenceId: String,
    childId: String,
    segmentIndex: Int,
    alarmKitId: String,
    scheduledTimestamp: Double
  ) {
    self.parentAlarmId = parentAlarmId
    self.occurrenceId = occurrenceId
    self.childId = childId
    self.segmentIndex = segmentIndex
    self.alarmKitId = alarmKitId
    self.scheduledTimestamp = scheduledTimestamp
  }

  func perform() async throws -> some IntentResult {
    SvaAlarmChallengeRouter.recordPendingChallenge(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
      childId: childId,
      segmentIndex: segmentIndex,
      scheduledTimestamp: scheduledTimestamp,
      source: "stop"
    )
    return .result()
  }
}

/// Secondary AlarmKit action — same challenge semantics as Stop.
@available(iOS 26.0, *)
struct SvaSolveToStopIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Solve to stop"
  static var description = IntentDescription(
    "Open Math Challenge to stop remaining alarm segments"
  )
  static var openAppWhenRun: Bool = true
  static var isDiscoverable: Bool = false

  @Parameter(title: "Parent Alarm ID")
  var parentAlarmId: String

  @Parameter(title: "Occurrence ID")
  var occurrenceId: String

  @Parameter(title: "Child ID")
  var childId: String

  @Parameter(title: "Segment Index")
  var segmentIndex: Int

  @Parameter(title: "AlarmKit ID")
  var alarmKitId: String

  @Parameter(title: "Scheduled Timestamp")
  var scheduledTimestamp: Double

  init() {
    parentAlarmId = ""
    occurrenceId = ""
    childId = ""
    segmentIndex = 0
    alarmKitId = ""
    scheduledTimestamp = 0
  }

  init(
    parentAlarmId: String,
    occurrenceId: String,
    childId: String,
    segmentIndex: Int,
    alarmKitId: String,
    scheduledTimestamp: Double
  ) {
    self.parentAlarmId = parentAlarmId
    self.occurrenceId = occurrenceId
    self.childId = childId
    self.segmentIndex = segmentIndex
    self.alarmKitId = alarmKitId
    self.scheduledTimestamp = scheduledTimestamp
  }

  func perform() async throws -> some IntentResult {
    SvaAlarmChallengeRouter.recordPendingChallenge(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
      childId: childId,
      segmentIndex: segmentIndex,
      scheduledTimestamp: scheduledTimestamp,
      source: "solve"
    )
    return .result()
  }
}

#endif

enum SvaAlarmChallengeRouter {
  /// Idempotent pending challenge keyed by parent + occurrence.
  static func recordPendingChallenge(
    parentAlarmId: String,
    occurrenceId: String,
    childId: String,
    segmentIndex: Int,
    scheduledTimestamp: Double,
    source: String
  ) {
    if let existing = SvaPendingStore.peek(),
       existing.parentAlarmId == parentAlarmId,
       existing.occurrenceId == occurrenceId,
       existing.openChallenge
    {
      NSLog(
        "[SVA-AlarmKit] pending challenge idempotent parent=%@ occurrence=%@ source=%@",
        parentAlarmId,
        occurrenceId,
        source
      )
      return
    }
    let challenge = SvaPendingChallenge(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
      childId: childId,
      segmentIndex: segmentIndex,
      scheduledTimestamp: scheduledTimestamp,
      openChallenge: true
    )
    SvaPendingStore.save(challenge)
    NSLog(
      "[SVA-AlarmKit] pending challenge saved parent=%@ occurrence=%@ source=%@ (no occurrence cancel)",
      parentAlarmId,
      occurrenceId,
      source
    )
    DispatchQueue.main.async {
      NotificationCenter.default.post(
        name: Notification.Name("SvaOpenChallenge"),
        object: nil,
        userInfo: challenge.asDictionary
      )
    }
  }
}

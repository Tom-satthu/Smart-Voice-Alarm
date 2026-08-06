import Foundation

/// Thin facade over [SvaAlarmKitManager] for MethodChannel call sites.
enum SvaAlarmKitScheduler {
  static func authorizationState() -> String {
    SvaAlarmKitManager.authorizationStateString()
  }

  static func requestAuthorization() async throws -> String {
    try await SvaAlarmKitManager.sharedManaging.requestAuthorization()
  }

  static func schedule(
    segments: [SvaSegmentSpec],
    title: String
  ) async throws -> SvaAlarmKitScheduleOutcome {
    try await SvaAlarmKitManager.sharedManaging.schedule(segments: segments, title: title)
  }

  static func cancel(childIds: [String]) {
    // childIds for AlarmKit path are Alarm.ID UUID strings (or mapped via store).
    let mapped = SvaAlarmKitStore.load()
    var alarmIds = Set(childIds)
    for item in mapped where childIds.contains(item.childId) || childIds.contains(item.alarmId) {
      alarmIds.insert(item.alarmId)
    }
    SvaAlarmKitManager.sharedManaging.cancel(alarmIds: Array(alarmIds))
  }

  static func cancelParent(parentAlarmId: String) {
    SvaAlarmKitManager.sharedManaging.cancelParent(parentAlarmId: parentAlarmId)
  }

  static func cancelOccurrence(parentAlarmId: String, occurrenceId: String) {
    SvaAlarmKitManager.sharedManaging.cancelOccurrence(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId
    )
  }

  static func cancelParentExcept(parentAlarmId: String, keepChildIds: Set<String>) {
    let mapped = SvaAlarmKitStore.load()
    var keepAlarmIds = Set<String>()
    for item in mapped where item.parentAlarmId == parentAlarmId {
      if keepChildIds.contains(item.childId) || keepChildIds.contains(item.alarmId) {
        keepAlarmIds.insert(item.alarmId)
      }
    }
    // Also accept raw Alarm.ID strings in keep set.
    keepAlarmIds.formUnion(keepChildIds)
    SvaAlarmKitManager.sharedManaging.cancelParentExcept(
      parentAlarmId: parentAlarmId,
      keepAlarmIds: keepAlarmIds
    )
  }

  static func reconcile() {
    SvaAlarmKitManager.sharedManaging.reconcile()
  }

  static func diagnostics() -> [String: Any] {
    let mappings = SvaAlarmKitStore.load()
    let pending = SvaPendingStore.peek()
    return [
      "usesAlarmKitRuntime": SvaAlarmKitManager.isRuntimeAvailable,
      "authorization": authorizationState(),
      "scheduledAlarmKitIds": SvaAlarmKitManager.sharedManaging.scheduledAlarmIds(),
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
}

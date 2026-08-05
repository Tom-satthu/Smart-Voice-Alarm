import Foundation
import UserNotifications

enum SvaNotificationFanout {
  static let center = UNUserNotificationCenter.current()

  static func configureCategories() {
    let solve = UNNotificationAction(
      identifier: SvaAlarmKeys.actionSolve,
      title: "Solve to stop",
      options: [.foreground]
    )
    let category = UNNotificationCategory(
      identifier: SvaAlarmKeys.categorySolve,
      actions: [solve],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )
    center.setNotificationCategories([category])
  }

  static func schedule(segments: [SvaSegmentSpec], title: String, body: String) async throws {
    configureCategories()
    let settings = await center.notificationSettings()
    if settings.authorizationStatus == .notDetermined {
      _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    var scheduled = 0
    for segment in segments {
      let fireDate = Date(timeIntervalSince1970: Double(segment.startAtMillis) / 1000.0)
      let delay = fireDate.timeIntervalSinceNow
      guard delay > 0.5 else {
        NSLog("SVA skip past segment \(segment.childId) delay=\(delay)")
        continue
      }

      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      content.categoryIdentifier = SvaAlarmKeys.categorySolve
      content.sound = sound(named: segment.soundFileName)
      content.userInfo = [
        "parentAlarmId": segment.parentAlarmId,
        "occurrenceId": segment.occurrenceId,
        "childId": segment.childId,
        "segmentIndex": segment.segmentIndex,
        "scheduledTimestamp": Double(segment.startAtMillis) / 1000.0,
        "openChallenge": true,
      ]
      if #available(iOS 15.0, *) {
        content.interruptionLevel = .timeSensitive
      }

      // Calendar trigger is more reliable across device sleep than pure intervals.
      let comps = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute, .second],
        from: fireDate
      )
      let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
      let request = UNNotificationRequest(
        identifier: segment.childId,
        content: content,
        trigger: trigger
      )
      do {
        try await center.add(request)
        scheduled += 1
      } catch {
        NSLog("SVA schedule failed for \(segment.childId): \(error)")
        // Retry once with default system sound.
        content.sound = .default
        let fallback = UNNotificationRequest(
          identifier: segment.childId,
          content: content,
          trigger: trigger
        )
        try await center.add(fallback)
        scheduled += 1
      }

      var map = SvaPendingStore.loadChildMap()
      map[SvaPendingStore.mapKey(
        parent: segment.parentAlarmId,
        occurrence: segment.occurrenceId,
        index: segment.segmentIndex
      )] = segment.childId
      SvaPendingStore.saveChildMap(map)
    }

    if scheduled == 0 {
      throw NSError(
        domain: "SvaNotificationFanout",
        code: 422,
        userInfo: [NSLocalizedDescriptionKey: "No future alarm segments could be scheduled"]
      )
    }
    NSLog("SVA scheduled \(scheduled)/\(segments.count) notification segments")
  }

  static func cancel(childIds: [String]) {
    center.removePendingNotificationRequests(withIdentifiers: childIds)
    center.removeDeliveredNotifications(withIdentifiers: childIds)
  }

  static func cancelOccurrence(parentAlarmId: String, occurrenceId: String) {
    var map = SvaPendingStore.loadChildMap()
    let prefix = "\(parentAlarmId)|\(occurrenceId)|"
    var ids: [String] = []
    var removed: [String] = []
    for (key, childId) in map where key.hasPrefix(prefix) {
      ids.append(childId)
      removed.append(key)
    }
    cancel(childIds: ids)
    for key in removed { map.removeValue(forKey: key) }
    SvaPendingStore.saveChildMap(map)
  }

  static func cancelParent(parentAlarmId: String) {
    var map = SvaPendingStore.loadChildMap()
    let prefix = "\(parentAlarmId)|"
    var ids: [String] = []
    var removed: [String] = []
    for (key, childId) in map where key.hasPrefix(prefix) {
      ids.append(childId)
      removed.append(key)
    }
    cancel(childIds: ids)
    for key in removed { map.removeValue(forKey: key) }
    SvaPendingStore.saveChildMap(map)
  }

  private static func sound(named fileName: String) -> UNNotificationSound {
    let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return .default }
    let sounds = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
      .appendingPathComponent("Sounds", isDirectory: true)
      .appendingPathComponent(trimmed)
    if !FileManager.default.fileExists(atPath: sounds.path) {
      NSLog("SVA sound missing at \(sounds.path) — using default")
      return .default
    }
    return UNNotificationSound(named: UNNotificationSoundName(trimmed))
  }
}

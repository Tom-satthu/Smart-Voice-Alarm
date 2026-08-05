import Foundation

/// AlarmKit integration is intentionally stubbed for now.
///
/// Linking / registering AlarmKit + LiveActivityIntent previously caused
/// immediate launch crashes on device when entitlements were incomplete.
/// Voice alarms currently use notification fan-out (`SvaNotificationFanout`)
/// with pre-rendered CAF files in Library/Sounds.
///
/// Keep this type so MethodChannel capability / cancel call sites compile.
enum SvaAlarmKitScheduler {
  static func authorizationState() -> String { "unsupported" }

  static func requestAuthorization() async throws -> String { "unsupported" }

  static func schedule(segments: [SvaSegmentSpec], title: String) async throws {
    // No-op: notification fan-out is the active scheduler.
  }

  static func cancel(childIds: [String]) {}

  static func cancelParent(parentAlarmId: String) {}

  static func cancelOccurrence(parentAlarmId: String, occurrenceId: String) {}
}

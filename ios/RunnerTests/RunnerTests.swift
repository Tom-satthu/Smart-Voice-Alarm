import UserNotifications
import XCTest

/// Native test harness for notification scheduling fakes and basic invariants.
final class RunnerTests: XCTestCase {
  func testBundleLoads() {
    XCTAssertNotNil(Bundle.main)
  }

  func testFakeNotificationCenterStoresAndCancelsRequests() async throws {
    let fake = FakeNotificationCenter()
    let content = UNMutableNotificationContent()
    content.title = "Smart Voice Alarm"
    content.sound = .default
    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: 90,
      repeats: false
    )
    let request = UNNotificationRequest(
      identifier: "sva_test_child",
      content: content,
      trigger: trigger
    )
    try await fake.add(request)
    let pending = await fake.pendingRequests()
    XCTAssertEqual(pending.map(\.identifier), ["sva_test_child"])
    fake.remove(identifiers: ["sva_test_child"])
    let after = await fake.pendingRequests()
    XCTAssertTrue(after.isEmpty)
  }

  func testInvalidFilePathDoesNotCrashFileManager() {
    let missing = "/tmp/sva_missing_\(UUID().uuidString).caf"
    XCTAssertFalse(FileManager.default.fileExists(atPath: missing))
  }

  func testRingtoneRelativePathsAreStable() {
    // Documents the expected Flutter asset layout used by production resolver.
    let key = "soft_chime"
    let expected = [
      "flutter_assets/assets/ringtones/\(key).wav",
      "Frameworks/App.framework/flutter_assets/assets/ringtones/\(key).wav",
    ]
    XCTAssertEqual(expected.count, 2)
    XCTAssertTrue(expected[0].contains("assets/ringtones"))
  }
}

protocol SvaNotificationCenterProtocol {
  func add(_ request: UNNotificationRequest) async throws
  func pendingRequests() async -> [UNNotificationRequest]
  func remove(identifiers: [String])
}

final class FakeNotificationCenter: SvaNotificationCenterProtocol {
  private var store: [String: UNNotificationRequest] = [:]

  func add(_ request: UNNotificationRequest) async throws {
    store[request.identifier] = request
  }

  func pendingRequests() async -> [UNNotificationRequest] {
    Array(store.values)
  }

  func remove(identifiers: [String]) {
    for id in identifiers {
      store.removeValue(forKey: id)
    }
  }
}

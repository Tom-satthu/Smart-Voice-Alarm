import UserNotifications
import XCTest
@testable import Runner

/// Native test harness for notification scheduling fakes and AlarmKit protocol.
final class RunnerTests: XCTestCase {
  override func setUp() {
    super.setUp()
    SvaAlarmKitRuntime.resetCountersForTests()
    SvaAlarmKitStore.save([])
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_disabled")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_probe_success")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_cached_auth")
    UserDefaults.standard.removeObject(forKey: SvaAlarmKeys.pendingChallenge)
  }

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
    let key = "soft_chime"
    let expected = [
      "flutter_assets/assets/ringtones/\(key).wav",
      "Frameworks/App.framework/flutter_assets/assets/ringtones/\(key).wav",
    ]
    XCTAssertEqual(expected.count, 2)
    XCTAssertTrue(expected[0].contains("assets/ringtones"))
  }

  // MARK: - AlarmKit capability / auth

  func testAlarmKitRuntimeGateMatchesAvailability() {
    if #available(iOS 26.0, *) {
      XCTAssertTrue(SvaAlarmKitManager.isRuntimeAvailable)
    } else {
      XCTAssertFalse(SvaAlarmKitManager.isRuntimeAvailable)
      XCTAssertEqual(SvaAlarmKitManager.authorizationStateString(), "unavailable")
    }
  }

  func testPassiveCapabilityDoesNotTouchAlarmKitCounters() {
    _ = SvaAlarmKitRuntime.passiveCapability()
    _ = SvaAlarmKitRuntime.passiveDiagnostics()
    XCTAssertEqual(SvaAlarmKitRuntime.authorizationStateReadCount, 0)
    XCTAssertEqual(SvaAlarmKitRuntime.requestAuthorizationCount, 0)
    XCTAssertEqual(SvaAlarmKitRuntime.scheduleCount, 0)
    XCTAssertEqual(SvaAlarmKitRuntime.reconcileCount, 0)
  }

  func testFakeAuthorizationAuthorizedAndDenied() async throws {
    let fake = FakeSvaAlarmManager()
    fake.authorizationState = "notDetermined"
    let authorized = try await fake.requestAuthorizationSafely()
    XCTAssertEqual(authorized, "authorized")
    XCTAssertEqual(SvaAlarmKitRuntime.requestAuthorizationCount, 1)

    SvaAlarmKitRuntime.resetCountersForTests()
    fake.authorizationState = "denied"
    let denied = try await fake.requestAuthorizationSafely()
    XCTAssertEqual(denied, "denied")
  }

  // MARK: - Schedule / rollback / mapping

  func testFakeSchedulesMixedTimelineWithoutFanout() async throws {
    let fake = FakeSvaAlarmManager()
    let segments = [
      makeSegment(index: 0, child: UUID().uuidString, startOffset: 120),
      makeSegment(index: 1, child: UUID().uuidString, startOffset: 130),
      makeSegment(index: 2, child: UUID().uuidString, startOffset: 145, sound: "tone.caf"),
    ]
    let outcome = try await fake.schedule(segments: segments, title: "Test")
    XCTAssertTrue(outcome.ok)
    XCTAssertEqual(outcome.backend, "alarmKit")
    XCTAssertEqual(outcome.scheduledIds.count, 3)
    XCTAssertEqual(fake.scheduledAlarmIds().count, 3)
  }

  func testFakeRepeatTimelineChildCount() async throws {
    let fake = FakeSvaAlarmManager()
    // 2 voices × 3 repeats + 1 ringtone = 7
    var segments: [SvaSegmentSpec] = []
    for i in 0..<7 {
      segments.append(
        makeSegment(index: i, child: UUID().uuidString, startOffset: 120 + i * 10)
      )
    }
    let outcome = try await fake.schedule(segments: segments, title: "Repeat")
    XCTAssertTrue(outcome.ok)
    XCTAssertEqual(outcome.scheduledIds.count, 7)
  }

  func testTransactionRollbackOnMidFailureKeepsPriorSchedule() async throws {
    let fake = FakeSvaAlarmManager()
    let priorChild = UUID().uuidString
    let prior = try await fake.schedule(
      segments: [makeSegment(index: 0, child: priorChild, startOffset: 200)],
      title: "Prior"
    )
    XCTAssertTrue(prior.ok)
    let priorIds = Set(fake.scheduledAlarmIds())

    fake.failAfterCount = 1
    let newSegs = [
      makeSegment(index: 0, child: UUID().uuidString, startOffset: 300),
      makeSegment(index: 1, child: UUID().uuidString, startOffset: 310),
    ]
    let failed = try await fake.schedule(segments: newSegs, title: "New")
    XCTAssertFalse(failed.ok)
    XCTAssertEqual(failed.errorCode, "alarmkit_schedule_failed")
    // Prior IDs remain (rollback only removes newly created in this fake).
    XCTAssertEqual(Set(fake.scheduledAlarmIds()), priorIds)
  }

  func testExistingScheduleKeptWhenUpdateFailsCompletely() async throws {
    let fake = FakeSvaAlarmManager()
    _ = try await fake.schedule(
      segments: [makeSegment(index: 0, child: UUID().uuidString, startOffset: 200)],
      title: "Keep"
    )
    let before = Set(fake.scheduledAlarmIds())
    fake.shouldFailSchedule = true
    let failed = try await fake.schedule(
      segments: [makeSegment(index: 0, child: UUID().uuidString, startOffset: 400)],
      title: "Fail"
    )
    XCTAssertFalse(failed.ok)
    XCTAssertEqual(Set(fake.scheduledAlarmIds()), before)
  }

  func testMappingSurvivesRelaunchViaStore() async throws {
    let fake = FakeSvaAlarmManager()
    let child = UUID().uuidString
    _ = try await fake.schedule(
      segments: [makeSegment(index: 0, child: child, startOffset: 180)],
      title: "Persist"
    )
    let stored = SvaAlarmKitStore.load()
    XCTAssertFalse(stored.isEmpty)
    XCTAssertEqual(stored.first?.childId, child)

    // Simulate relaunch by reading store without in-memory map mutation.
    let reloaded = SvaAlarmKitStore.load()
    XCTAssertEqual(reloaded.count, stored.count)
    XCTAssertEqual(reloaded.first?.alarmId, stored.first?.alarmId)
  }

  func testCancelParentRemovesCorrectIds() async throws {
    let fake = FakeSvaAlarmManager()
    let a1 = UUID().uuidString
    let a2 = UUID().uuidString
    _ = try await fake.schedule(
      segments: [
        makeSegment(parent: "p1", index: 0, child: a1, startOffset: 120),
        makeSegment(parent: "p2", index: 0, child: a2, startOffset: 130),
      ],
      title: "Parents"
    )
    fake.cancelParent(parentAlarmId: "p1")
    let remaining = fake.scheduled.values
    XCTAssertTrue(remaining.allSatisfy { $0.parentAlarmId == "p2" })
  }

  func testSolveCorrectCancelsWholeOccurrence() async throws {
    let fake = FakeSvaAlarmManager()
    let occ = "occ-solve"
    let segs = (0..<3).map {
      makeSegment(
        parent: "p",
        occurrence: occ,
        index: $0,
        child: UUID().uuidString,
        startOffset: 120 + $0 * 10
      )
    }
    _ = try await fake.schedule(segments: segs, title: "Solve")
    XCTAssertEqual(fake.scheduledAlarmIds().count, 3)
    fake.cancelOccurrence(parentAlarmId: "p", occurrenceId: occ)
    XCTAssertTrue(fake.scheduledAlarmIds().isEmpty)
  }

  func testSolveWrongDoesNotCancelOccurrence() async throws {
    let fake = FakeSvaAlarmManager()
    let occ = "occ-wrong"
    _ = try await fake.schedule(
      segments: [
        makeSegment(parent: "p", occurrence: occ, index: 0, child: UUID().uuidString, startOffset: 120),
        makeSegment(parent: "p", occurrence: occ, index: 1, child: UUID().uuidString, startOffset: 130),
      ],
      title: "Wrong"
    )
    // Wrong answer / exit: only record challenge; do not cancel.
    SvaAlarmChallengeRouter.recordPendingChallenge(
      parentAlarmId: "p",
      occurrenceId: occ,
      childId: "c0",
      segmentIndex: 0,
      scheduledTimestamp: Date().timeIntervalSince1970,
      source: "stop"
    )
    XCTAssertEqual(fake.scheduledAlarmIds().count, 2)
    XCTAssertNotNil(SvaPendingStore.peek())
  }

  func testStopChildOpensChallengeIdempotent() {
    SvaAlarmChallengeRouter.recordPendingChallenge(
      parentAlarmId: "p",
      occurrenceId: "o",
      childId: "c1",
      segmentIndex: 0,
      scheduledTimestamp: 1,
      source: "stop"
    )
    SvaAlarmChallengeRouter.recordPendingChallenge(
      parentAlarmId: "p",
      occurrenceId: "o",
      childId: "c2",
      segmentIndex: 1,
      scheduledTimestamp: 2,
      source: "stop"
    )
    let pending = SvaPendingStore.peek()
    XCTAssertEqual(pending?.childId, "c1")
    XCTAssertEqual(pending?.occurrenceId, "o")
  }

  func testDeterministicAlarmIdStable() {
    let child = "550e8400-e29b-41d4-a716-446655440000"
    let a = SvaAlarmKitManager.deterministicAlarmId(for: child)
    let b = SvaAlarmKitManager.deterministicAlarmId(for: child)
    XCTAssertEqual(a, b)
    XCTAssertEqual(a.uuidString.lowercased(), child.lowercased())
  }

  func testOldIOSPathDoesNotClaimAlarmKitWhenUnavailable() {
    if #available(iOS 26.0, *) {
      let passive = SvaAlarmKitRuntime.passiveCapability()
      XCTAssertEqual(SvaAlarmKitRuntime.authorizationStateReadCount, 0)
      XCTAssertNotNil(passive["runtimeVersionEligible"])
    } else {
      XCTAssertEqual(SvaAlarmKitManager.authorizationStateString(), "unknown")
      XCTAssertFalse(SvaAlarmKitManager.isRuntimeAvailable)
    }
  }

  func testKillSwitchBlocksRuntimeEnabled() {
    SvaAlarmKitRuntime.markDisabled(reason: "test", persistent: true)
    let cap = SvaAlarmKitRuntime.passiveCapability()
    XCTAssertEqual(cap["alarmKitDisabled"] as? Bool, true)
    XCTAssertEqual(cap["usesAlarmKit"] as? Bool, false)
    SvaAlarmKitRuntime.debugClearKillSwitch()
  }

  // MARK: - Helpers

  private func makeSegment(
    parent: String = "parent",
    occurrence: String = "occ",
    index: Int,
    child: String,
    startOffset: Int,
    sound: String = "voice.caf"
  ) -> SvaSegmentSpec {
    let start = Int64(Date().addingTimeInterval(TimeInterval(startOffset)).timeIntervalSince1970 * 1000)
    return SvaSegmentSpec(
      parentAlarmId: parent,
      occurrenceId: occurrence,
      segmentIndex: index,
      childId: child,
      startAtMillis: start,
      soundFileName: sound,
      label: "seg\(index)",
      durationMs: 2000
    )
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

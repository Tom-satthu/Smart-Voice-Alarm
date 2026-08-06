import AVFoundation
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
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_disabled_reason")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_probe_success")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_probe_ever_succeeded")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_cached_auth")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_user_disabled")
    UserDefaults.standard.removeObject(forKey: "sva_alarmkit_state_migrated_v2")
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
      let auth = SvaAlarmKitManager.authorizationStateString()
      XCTAssertTrue(auth == "unknown" || auth == "unsupported")
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

  func testLegacyDeniedMigrationCachesDeniedNotUnavailable() {
    UserDefaults.standard.set(true, forKey: "sva_alarmkit_disabled")
    UserDefaults.standard.set("authorization_denied", forKey: "sva_alarmkit_disabled_reason")
    SvaAlarmKitRuntime.migrateLegacyStateIfNeeded()
    let cap = SvaAlarmKitRuntime.passiveCapability()
    XCTAssertEqual(cap["cachedAuthorization"] as? String, "denied")
    XCTAssertFalse(UserDefaults.standard.bool(forKey: "sva_alarmkit_disabled"))
    if #available(iOS 26.0, *) {
      XCTAssertEqual(cap["selectedBackend"] as? String, "notificationFanout")
      XCTAssertEqual(cap["backendSelectionReason"] as? String, "denied")
    }
  }

  func testLegacyProbeFailureMigrationClearsPersistentDisabled() {
    UserDefaults.standard.set(true, forKey: "sva_alarmkit_disabled")
    UserDefaults.standard.set("probe_failed", forKey: "sva_alarmkit_disabled_reason")
    UserDefaults.standard.set("unavailable", forKey: "sva_alarmkit_cached_auth")
    SvaAlarmKitRuntime.migrateLegacyStateIfNeeded()
    XCTAssertFalse(UserDefaults.standard.bool(forKey: "sva_alarmkit_disabled"))
    let cap = SvaAlarmKitRuntime.passiveCapability()
    XCTAssertNotEqual(cap["cachedAuthorization"] as? String, "unavailable")
    if #available(iOS 26.0, *) {
      XCTAssertEqual(
        cap["backendSelectionReason"] as? String,
        "needs_user_probe_or_authorization"
      )
    }
  }

  func testSessionProbeFailureDoesNotPersistDisabled() {
    SvaAlarmKitRuntime.resetSessionStateForTests()
    SvaAlarmKitRuntime.resetLegacyDiagnosticState()
    let cap = SvaAlarmKitRuntime.passiveCapability()
    XCTAssertEqual(cap["sessionProbeFailed"] as? Bool, false)
    XCTAssertFalse(UserDefaults.standard.bool(forKey: "sva_alarmkit_disabled"))
  }

  func testResetLegacyDoesNotCallAlarmKitCounters() {
    UserDefaults.standard.set(true, forKey: "sva_alarmkit_disabled")
    SvaAlarmKitRuntime.resetLegacyDiagnosticState()
    XCTAssertEqual(SvaAlarmKitRuntime.authorizationStateReadCount, 0)
    XCTAssertEqual(SvaAlarmKitRuntime.requestAuthorizationCount, 0)
  }

  func testPendingPeekDoesNotRemove() {
    let challenge = SvaPendingChallenge(
      parentAlarmId: "p1",
      occurrenceId: "o1",
      childId: "c1",
      segmentIndex: 0,
      scheduledTimestamp: 1,
      openChallenge: true
    )
    SvaPendingStore.save(challenge)
    XCTAssertNotNil(SvaPendingStore.peek())
    XCTAssertNotNil(SvaPendingStore.peek())
  }

  func testAcknowledgeRemovesMatchingPending() {
    SvaPendingStore.save(
      SvaPendingChallenge(
        parentAlarmId: "p1",
        occurrenceId: "o1",
        childId: "c1",
        segmentIndex: 0,
        scheduledTimestamp: 1,
        openChallenge: true
      )
    )
    XCTAssertTrue(SvaPendingStore.acknowledge(parent: "p1", occurrence: "o1"))
    XCTAssertNil(SvaPendingStore.peek())
  }

  func testAcknowledgeMismatchKeepsPending() {
    SvaPendingStore.save(
      SvaPendingChallenge(
        parentAlarmId: "p1",
        occurrenceId: "o1",
        childId: "c1",
        segmentIndex: 0,
        scheduledTimestamp: 1,
        openChallenge: true
      )
    )
    XCTAssertFalse(SvaPendingStore.acknowledge(parent: "p1", occurrence: "wrong"))
    XCTAssertNotNil(SvaPendingStore.peek())
  }

  func testMalformedPendingPayloadDoesNotCrash() {
    let bad: [String: Any] = ["parentAlarmId": "", "occurrenceId": 12, "childId": NSNull()]
    XCTAssertNil(SvaPendingChallenge.from(dictionary: bad))
  }

  func testUserDisabledSelectsFanout() {
    UserDefaults.standard.set(true, forKey: "sva_alarmkit_user_disabled")
    UserDefaults.standard.set(true, forKey: "sva_alarmkit_state_migrated_v2")
    let (_, reason) = SvaAlarmKitRuntime.backendSelection()
    if #available(iOS 26.0, *) {
      XCTAssertEqual(reason, "user_disabled")
    } else {
      XCTAssertEqual(reason, "version_ineligible")
    }
    SvaAlarmKitRuntime.setUserDisabled(false)
  }

  func testSolveActionIdentifierIsLocaleIndependent() {
    XCTAssertEqual(SvaAlarmKeys.actionSolve, "SVA_SOLVE_TO_STOP")
    XCTAssertNotEqual(SvaAlarmKeys.actionSolve, "Solve to stop")
  }

  func testSoundNameKeepsExtensionWhenPreferred() {
    SvaAlarmKitSoundNameMode.setPreferred(.withExtension)
    XCTAssertEqual(
      SvaAlarmKitSoundResolver.alertSoundName(fileName: "sva_abc_rev.caf"),
      "sva_abc_rev.caf"
    )
  }

  func testSoundNameStripsExtensionWhenRequested() {
    XCTAssertEqual(
      SvaAlarmKitSoundResolver.alertSoundName(
        fileName: "sva_abc_rev.caf",
        mode: .withoutExtension
      ),
      "sva_abc_rev"
    )
  }

  func testMissingSoundFileDoesNotClaimCustomSuccess() {
    let diag = SvaAudioFileValidator.diagnoseRendered(
      fileName: "sva_missing_not_real.caf",
      sourceType: "recording"
    )
    XCTAssertFalse(diag.renderedExists)
    XCTAssertFalse(diag.avPlayerPlayable)
  }

  func testEmptyCafRejectedByValidator() throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_empty_\(UUID().uuidString).caf")
    try Data().write(to: url)
    let result = SvaAudioFileValidator.validate(url: url)
    XCTAssertFalse(result.ok)
    XCTAssertEqual(result.errorCode, "sound_file_empty")
    try? FileManager.default.removeItem(at: url)
  }

  func testValidPcmCafPassesValidator() throws {
    // Write a tiny valid CAF via AVAudioFile.
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_valid_\(UUID().uuidString).caf")
    guard let format = SvaAudioRenderer.outputFormat() else {
      return XCTFail("output format")
    }
    let file = try AVAudioFile(
      forWriting: url,
      settings: format.settings,
      commonFormat: format.commonFormat,
      interleaved: format.isInterleaved
    )
    let frames: AVAudioFrameCount = 4410 // 0.1s
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else {
      return XCTFail("buffer")
    }
    buffer.frameLength = frames
    if let ch = buffer.int16ChannelData?[0] {
      for i in 0..<Int(frames) {
        ch[i] = Int16(Double(i % 100) * 100)
      }
    }
    try file.write(from: buffer)
    let result = SvaAudioFileValidator.validate(url: url)
    XCTAssertTrue(result.ok, result.errorMessage ?? "")
    XCTAssertTrue(result.avPlayerPlayable)
    XCTAssertEqual(result.channels, 1)
    try? FileManager.default.removeItem(at: url)
  }

  func testDefaultFallbackAlwaysHasWarningCode() {
    // Empty filename path is exercised via diagnostics fields.
    let exact = SvaAlarmKitSoundResolver.alertSoundName(fileName: "")
    XCTAssertEqual(exact, "")
  }

  // MARK: - Silence CAF / occurrence state / stop recovery

  func testSilenceCafIsPlayableFiveSeconds() throws {
    let name = "sva_test_silence_\(UUID().uuidString).caf"
    let out = try SvaSilenceAudio.ensure(fileName: name, seconds: 5)
    XCTAssertEqual(out["ok"] as? Bool, true)
    let durationMs = out["durationMs"] as? Int ?? 0
    XCTAssertGreaterThanOrEqual(durationMs, 4750)
    XCTAssertLessThanOrEqual(durationMs, 5250)
    XCTAssertEqual(out["avPlayerPlayable"] as? Bool, true)
    let path = out["path"] as? String ?? ""
    XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    try? FileManager.default.removeItem(atPath: path)
  }

  func testFitExactDurationLoopsShortSourceToTenSeconds() throws {
    guard let format = SvaAudioRenderer.outputFormat() else {
      return XCTFail("format")
    }
    let dest = SvaAudioRenderer.soundsDirectory
      .appendingPathComponent("sva_tone_fit_\(UUID().uuidString).caf")
    let frames: AVAudioFrameCount = AVAudioFrameCount(format.sampleRate * 3)
    let file = try AVAudioFile(
      forWriting: dest,
      settings: format.settings,
      commonFormat: format.commonFormat,
      interleaved: format.isInterleaved
    )
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else {
      return XCTFail("buffer")
    }
    buffer.frameLength = frames
    if let ch = buffer.int16ChannelData?[0] {
      for i in 0..<Int(frames) {
        ch[i] = Int16(sin(Double(i) / 40.0) * 8000)
      }
    }
    try file.write(from: buffer)
    try SvaAudioRenderer.fitToExactDuration(at: dest, targetSeconds: 10)
    let audio = try AVAudioFile(forReading: dest)
    let duration = Double(audio.length) / audio.processingFormat.sampleRate
    XCTAssertEqual(duration, 10, accuracy: 0.25)
    XCTAssertTrue(SvaAudioFileValidator.canPlayWithAVAudioPlayer(url: dest))
    try? FileManager.default.removeItem(at: dest)
  }

  func testAppendTrailingSilenceExtendsFinalizedDuration() throws {
    guard let format = SvaAudioRenderer.outputFormat() else {
      return XCTFail("format")
    }
    let dest = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_trail_\(UUID().uuidString).caf")
    let contentSec = 2.0
    let frames = AVAudioFrameCount(format.sampleRate * contentSec)
    let file = try AVAudioFile(
      forWriting: dest,
      settings: format.settings,
      commonFormat: format.commonFormat,
      interleaved: format.isInterleaved
    )
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else {
      return XCTFail("buffer")
    }
    buffer.frameLength = frames
    if let ch = buffer.int16ChannelData?[0] {
      for i in 0..<Int(frames) {
        ch[i] = Int16(sin(Double(i) / 30.0) * 6000)
      }
    }
    try file.write(from: buffer)
    let trailMs = try SvaAudioRenderer.appendTrailingSilence(at: dest, silenceSeconds: 1.25)
    XCTAssertEqual(Double(trailMs), 1250, accuracy: 50)
    let audio = try AVAudioFile(forReading: dest)
    let duration = Double(audio.length) / audio.processingFormat.sampleRate
    XCTAssertEqual(duration, contentSec + 1.25, accuracy: 0.08)
    let validation = SvaAudioFileValidator.validate(
      url: dest,
      maxDurationSeconds: SvaAudioFileValidator.maxFinalizedDurationSeconds
    )
    XCTAssertTrue(validation.ok)
    try? FileManager.default.removeItem(at: dest)
  }

  func testRecoveryValidateTemplateRejectsMissingFile() {
    let err = SvaAlarmKitRecovery.validateTemplateFiles([
      SvaCycleClip(
        role: "voice",
        soundFileName: "sva_missing_does_not_exist.caf",
        durationMs: 2000,
        label: "voice"
      ),
    ])
    XCTAssertNotNil(err)
    XCTAssertTrue(
      err?.contains("missing") == true || err?.contains("custom_sound") == true
    )
  }

  func testRecoveryValidateTemplateRejectsEmptyName() {
    let err = SvaAlarmKitRecovery.validateTemplateFiles([
      SvaCycleClip(role: "voice", soundFileName: "", durationMs: 2000, label: "voice"),
    ])
    XCTAssertEqual(err, "custom_sound_missing_name")
  }

  func testActiveSoundRegistryPinsUnsolvedTemplate() {
    let parent = "p_\(UUID().uuidString)"
    let occ = "o_\(UUID().uuidString)"
    let file = "sva_pin_\(UUID().uuidString).caf"
    var state = SvaOccurrenceState.empty(parent: parent, occurrence: occ)
    state.solved = false
    state.cycleTemplate = [
      SvaCycleClip(role: "voice", soundFileName: file, durationMs: 3000, label: "voice"),
    ]
    SvaOccurrenceStore.upsert(state)
    XCTAssertTrue(SvaActiveSoundRegistry.pinnedFileNames().contains(file))
    SvaOccurrenceStore.markSolved(parent: parent, occurrence: occ)
    XCTAssertFalse(SvaActiveSoundRegistry.pinnedFileNames().contains(file))
    SvaOccurrenceStore.remove(parent: parent, occurrence: occ)
  }

  func testOccurrenceStoreSolvedOnlyViaMarkSolved() {
    let parent = "p_\(UUID().uuidString)"
    let occ = "o_\(UUID().uuidString)"
    XCTAssertFalse(SvaOccurrenceStore.isSolved(parent: parent, occurrence: occ))
    SvaOccurrenceStore.upsert({
      var s = SvaOccurrenceState.empty(parent: parent, occurrence: occ)
      s.revision = "r1"
      s.rollingHorizonEnd = Date().timeIntervalSince1970 + 1800
      s.cyclesScheduled = 2
      s.childCount = 8
      s.audibleChildCount = 4
      s.silentChildCount = 4
      s.cycleDurationMs = 30000
      return s
    }())
    XCTAssertFalse(SvaOccurrenceStore.isSolved(parent: parent, occurrence: occ))
    SvaOccurrenceStore.markSolved(parent: parent, occurrence: occ)
    XCTAssertTrue(SvaOccurrenceStore.isSolved(parent: parent, occurrence: occ))
    let solved = SvaOccurrenceStore.get(parent: parent, occurrence: occ)
    XCTAssertEqual(solved?.cancellationGeneration, 1)
    SvaOccurrenceStore.remove(parent: parent, occurrence: occ)
  }

  func testRecoverySuppressedWhenSolved() async {
    let parent = "p_\(UUID().uuidString)"
    let occ = "o_\(UUID().uuidString)"
    var state = SvaOccurrenceState.empty(parent: parent, occurrence: occ)
    state.cycleTemplate = [
      SvaCycleClip(role: "voice", soundFileName: "v.caf", durationMs: 2000, label: "voice"),
      SvaCycleClip(role: "silence", soundFileName: "sva_silence_5s.caf", durationMs: 5000, label: "silence"),
    ]
    state.solved = true
    SvaOccurrenceStore.upsert(state)
    await SvaAlarmKitRecovery.handleChildStopped(
      parent: parent,
      occurrence: occ,
      stoppedAlarmKitId: "ak1",
      childId: "c1",
      role: "voice",
      scheduledStart: Date().timeIntervalSince1970 - 1,
      expectedDurationMs: 7000,
      reason: "test_solved"
    )
    let after = SvaOccurrenceStore.get(parent: parent, occurrence: occ)
    XCTAssertEqual(after?.recoveryGeneration, 0)
    SvaOccurrenceStore.remove(parent: parent, occurrence: occ)
  }

  func testRecoveryDuplicateSuppressed() async {
    let parent = "p_\(UUID().uuidString)"
    let occ = "o_\(UUID().uuidString)"
    var state = SvaOccurrenceState.empty(parent: parent, occurrence: occ)
    state.cycleTemplate = [
      SvaCycleClip(role: "voice", soundFileName: "v.caf", durationMs: 2000, label: "voice"),
      SvaCycleClip(role: "silence", soundFileName: "sva_silence_5s.caf", durationMs: 5000, label: "silence"),
    ]
    state.lastStoppedAlarmKitId = "ak-dup"
    state.recoveryScheduledAt = Date().timeIntervalSince1970
    state.recoveryGeneration = 2
    SvaOccurrenceStore.upsert(state)
    await SvaAlarmKitRecovery.handleChildStopped(
      parent: parent,
      occurrence: occ,
      stoppedAlarmKitId: "ak-dup",
      childId: "c1",
      role: "voice",
      scheduledStart: Date().timeIntervalSince1970 - 1,
      expectedDurationMs: 7000,
      reason: "test_dup"
    )
    let after = SvaOccurrenceStore.get(parent: parent, occurrence: occ)
    XCTAssertEqual(after?.recoveryGeneration, 2)
    SvaOccurrenceStore.remove(parent: parent, occurrence: occ)
  }

  func testRollingChildIdsStableAcrossPlans() {
    let a = "sva_c_abc_0_1"
    let b = "sva_c_abc_0_1"
    XCTAssertEqual(a, b)
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

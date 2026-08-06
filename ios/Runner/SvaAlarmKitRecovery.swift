import Foundation

#if canImport(AlarmKit)
import AlarmKit
#endif

/// Native-first unsolved stop recovery.
///
/// Restarts from voice 1 as soon as AlarmKit allows (min lead ~600ms).
/// Never marks solved. Solve always wins via cancellationGeneration.
/// Never schedules `.default` for custom voice/TTS/recording/ringtone/silence.
enum SvaAlarmKitRecovery {
  /// Soft minimum fire lead used after stop. Must stay > 0.5s skip gate.
  static let minScheduleLeadSeconds: TimeInterval = 0.6
  static let maxChildren = 64
  static let defaultGapMs = 5000
  static let trailingSilenceMs = 1250

  private static let lock = NSLock()
  private static var inFlightKeys = Set<String>()

  static func handleChildStopped(
    parent: String,
    occurrence: String,
    stoppedAlarmKitId: String,
    childId: String,
    role: String?,
    scheduledStart: Double?,
    expectedDurationMs: Int?,
    reason: String
  ) async {
    let requestAt = Date().timeIntervalSince1970
    NSLog(
      "[SVA-AlarmKit] stopRecovery request parent=%@ occurrence=%@ child=%@ alarmKit=%@ reason=%@ t=%.3f",
      parent,
      occurrence,
      childId,
      stoppedAlarmKitId,
      reason,
      requestAt
    )

    if SvaOccurrenceStore.isSolved(parent: parent, occurrence: occurrence) {
      NSLog("[SVA-AlarmKit] stopRecovery suppressed solved=true")
      return
    }

    // Ignore natural silence transitions / late removals.
    if role == "silence" {
      NSLog("[SVA-AlarmKit] stopRecovery ignore silence child")
      return
    }
    if let start = scheduledStart, let dur = expectedDurationMs, dur > 0 {
      let expectedEnd = start + Double(dur) / 1000.0
      // Premature stop only (within audible window, 300ms slack).
      if requestAt >= expectedEnd - 0.3 {
        NSLog(
          "[SVA-AlarmKit] stopRecovery ignore natural end expectedEnd=%.3f now=%.3f",
          expectedEnd,
          requestAt
        )
        return
      }
    }

    let dedupeKey = "\(parent)|\(occurrence)|\(stoppedAlarmKitId)"
    lock.lock()
    if inFlightKeys.contains(dedupeKey) {
      lock.unlock()
      NSLog("[SVA-AlarmKit] stopRecovery duplicate suppressed inFlight key=%@", dedupeKey)
      return
    }
    inFlightKeys.insert(dedupeKey)
    lock.unlock()
    defer {
      lock.lock()
      inFlightKeys.remove(dedupeKey)
      lock.unlock()
    }

    var state = SvaOccurrenceStore.get(parent: parent, occurrence: occurrence)
      ?? SvaOccurrenceState.empty(parent: parent, occurrence: occurrence)
    if state.solved {
      NSLog("[SVA-AlarmKit] stopRecovery aborted solved mid-flight")
      return
    }
    if state.lastStoppedAlarmKitId == stoppedAlarmKitId,
       state.recoveryScheduledAt > 0,
       requestAt - state.recoveryScheduledAt < 30
    {
      NSLog(
        "[SVA-AlarmKit] stopRecovery duplicate suppressed persisted lastStopped=%@",
        stoppedAlarmKitId
      )
      return
    }
    if state.cycleTemplate.isEmpty {
      // Fallback: reconstruct audible clips from live mappings.
      state.cycleTemplate = Self.templateFromMappings(parent: parent, occurrence: occurrence)
    }
    guard !state.cycleTemplate.isEmpty else {
      NSLog("[SVA-AlarmKit] stopRecovery failed no cycleTemplate")
      Self.persistRecoveryError(state: state, reason: "no_cycle_template")
      return
    }

    // Pre-validate every custom file — never schedule with .default.
    if let validationError = Self.validateTemplateFiles(state.cycleTemplate) {
      NSLog(
        "[SVA-AlarmKit] stopRecovery refused invalid custom sound code=%@",
        validationError
      )
      Self.persistRecoveryError(state: state, reason: validationError)
      return
    }

    let cancelGenAtStart = state.cancellationGeneration
    let generation = state.recoveryGeneration + 1
    let gapMs = state.gapMs > 0 ? state.gapMs : defaultGapMs
    let title = state.alarmTitle.isEmpty ? "Smart Voice Alarm" : state.alarmTitle

    let fireStart = Date().addingTimeInterval(minScheduleLeadSeconds)
    let segments = Self.buildRecoverySegments(
      parent: parent,
      occurrence: occurrence,
      template: state.cycleTemplate,
      start: fireStart,
      gapMs: gapMs,
      generation: generation
    )
    guard !segments.isEmpty else {
      NSLog("[SVA-AlarmKit] stopRecovery failed empty segments")
      Self.persistRecoveryError(state: state, reason: "empty_segments")
      return
    }

    // Capture old future IDs before scheduling replacement.
    let oldMappings = SvaAlarmKitStore.load().filter {
      $0.parentAlarmId == parent && $0.occurrenceId == occurrence
    }
    let oldAlarmIds = Set(oldMappings.map(\.alarmId))

    let scheduleAt = Date().timeIntervalSince1970
    let outcome: SvaAlarmKitScheduleOutcome
    do {
      outcome = try await SvaAlarmKitScheduler.schedule(segments: segments, title: title)
    } catch {
      NSLog("[SVA-AlarmKit] stopRecovery schedule error %@", error.localizedDescription)
      Self.persistRecoveryError(state: state, reason: "schedule_error:\(error.localizedDescription)")
      return
    }

    // Solve wins: if solved/cancelGen changed, cancel what we just made.
    if SvaOccurrenceStore.isSolved(parent: parent, occurrence: occurrence) {
      NSLog("[SVA-AlarmKit] stopRecovery aborted solve-won after schedule")
      if outcome.ok {
        SvaAlarmKitScheduler.cancel(childIds: outcome.scheduledIds)
      }
      return
    }
    let latest = SvaOccurrenceStore.get(parent: parent, occurrence: occurrence)
    if let latest, latest.cancellationGeneration != cancelGenAtStart {
      NSLog("[SVA-AlarmKit] stopRecovery aborted cancelGen changed")
      if outcome.ok {
        SvaAlarmKitScheduler.cancel(childIds: outcome.scheduledIds)
      }
      return
    }

    guard outcome.ok else {
      NSLog(
        "[SVA-AlarmKit] stopRecovery schedule failed code=%@ — keeping old future children",
        outcome.errorCode ?? "?"
      )
      var failed = state
      failed.recoveryReason = "schedule_failed:\(outcome.errorCode ?? "unknown")"
      failed.updatedAt = Date().timeIntervalSince1970
      SvaOccurrenceStore.upsert(failed)
      return
    }

    // Replace old future children only after successful custom recovery schedule.
    let keep = Set(outcome.scheduledIds)
    let drop = oldAlarmIds.subtracting(keep)
    if !drop.isEmpty {
      SvaAlarmKitScheduler.cancel(childIds: Array(drop))
    }

    let latencyMs = Int(((Date().timeIntervalSince1970) - requestAt) * 1000)
    var next = state
    next.recoveryGeneration = generation
    next.lastStoppedAlarmKitId = stoppedAlarmKitId
    next.recoveryScheduledAt = scheduleAt
    next.recoveryAlarmKitId = outcome.scheduledIds.first ?? ""
    next.recoveryReason = reason
    next.cyclesScheduled = max(1, segments.count / max(state.cycleTemplate.count, 1))
    next.childCount = outcome.scheduledIds.count
    next.audibleChildCount = segments.filter { $0.label != "silence" && ($0.role != "silence") }.count
    next.silentChildCount = segments.count - next.audibleChildCount
    next.rollingHorizonEnd = {
      guard let last = segments.max(by: { $0.startAtMillis < $1.startAtMillis }) else { return 0 }
      return Double(last.startAtMillis) / 1000.0 + Double(last.durationMs) / 1000.0
    }()
    next.updatedAt = Date().timeIntervalSince1970
    next.solved = false
    next.trailingSilenceMs = state.trailingSilenceMs > 0
      ? state.trailingSilenceMs
      : trailingSilenceMs
    SvaOccurrenceStore.upsert(next)

    NSLog(
      "[SVA-AlarmKit] stopRecovery scheduled gen=%d children=%d latencyMs=%d leadMs=%d reason=%@ usedDefault=0",
      generation,
      outcome.scheduledIds.count,
      latencyMs,
      Int(minScheduleLeadSeconds * 1000),
      reason
    )
  }

  private static func persistRecoveryError(state: SvaOccurrenceState, reason: String) {
    var failed = state
    failed.recoveryReason = reason
    failed.updatedAt = Date().timeIntervalSince1970
    SvaOccurrenceStore.upsert(failed)
  }

  /// Returns error code if any custom template file is not schedule-ready.
  static func validateTemplateFiles(_ template: [SvaCycleClip]) -> String? {
    for clip in template {
      let name = clip.soundFileName.trimmingCharacters(in: .whitespacesAndNewlines)
      if name.isEmpty {
        return "custom_sound_missing_name"
      }
      if !name.lowercased().hasSuffix(".caf") {
        return "custom_sound_extension_required"
      }
      let diag = SvaAudioFileValidator.diagnoseRendered(
        fileName: name,
        sourceType: clip.role
      )
      if !diag.renderedExists {
        return "custom_sound_missing:\(name)"
      }
      if diag.fileSize <= 0 {
        return "custom_sound_empty:\(name)"
      }
      if !diag.avPlayerPlayable {
        return "custom_sound_not_playable:\(name)"
      }
      if diag.warningCode != nil {
        return "\(diag.warningCode!):\(name)"
      }
    }
    return nil
  }

  private static func templateFromMappings(parent: String, occurrence: String) -> [SvaCycleClip] {
    let mapped = SvaAlarmKitStore.load()
      .filter { $0.parentAlarmId == parent && $0.occurrenceId == occurrence }
      .sorted { $0.segmentIndex < $1.segmentIndex }
    var clips: [SvaCycleClip] = []
    var seenSilenceAfterRingtone = false
    for m in mapped {
      let role = m.role.isEmpty
        ? (m.soundFileName.contains("silence") ? "silence" : "voice")
        : m.role
      if role == "silence", clips.isEmpty { continue }
      clips.append(
        SvaCycleClip(
          role: role,
          soundFileName: m.soundFileName,
          durationMs: m.expectedDurationMs > 0 ? m.expectedDurationMs : (role == "silence" ? defaultGapMs : 1000),
          label: role
        )
      )
      if role == "ringtone" { seenSilenceAfterRingtone = false }
      if role == "silence", clips.contains(where: { $0.role == "ringtone" }) {
        seenSilenceAfterRingtone = true
        break
      }
      if role == "silence",
         clips.filter({ $0.role == "voice" }).count >= 1,
         !clips.contains(where: { $0.role == "ringtone" }),
         clips.filter({ $0.role == "silence" }).count >= clips.filter({ $0.role == "voice" }).count
      {
        let voices = Set(clips.filter { $0.role == "voice" }.map(\.soundFileName))
        if clips.filter({ $0.role == "voice" }).count == voices.count,
           clips.filter({ $0.role == "silence" }).count == voices.count
        {
          break
        }
      }
      if clips.count >= 12 { break }
      _ = seenSilenceAfterRingtone
    }
    return clips
  }

  /// Timeline uses finalized CAF duration only — no extra planner padding.
  private static func buildRecoverySegments(
    parent: String,
    occurrence: String,
    template: [SvaCycleClip],
    start: Date,
    gapMs: Int,
    generation: Int
  ) -> [SvaSegmentSpec] {
    let perCycle = max(template.count, 1)
    let cycles = max(1, min(8, maxChildren / perCycle))
    var out: [SvaSegmentSpec] = []
    var cursor = start
    var index = 0
    for cycle in 0..<cycles {
      for clip in template {
        let role = clip.role
        let durationMs: Int = {
          if role == "silence" { return gapMs }
          if role == "ringtone" { return max(clip.durationMs, 1000) }
          return max(clip.durationMs, 1)
        }()
        let childId = "sva_r_\(generation)_\(cycle)_\(index)_\(role)"
        out.append(
          SvaSegmentSpec(
            parentAlarmId: parent,
            occurrenceId: occurrence,
            segmentIndex: index,
            childId: childId,
            startAtMillis: Int64(cursor.timeIntervalSince1970 * 1000),
            soundFileName: clip.soundFileName,
            label: clip.label,
            durationMs: durationMs,
            role: role,
            cycleIndex: cycle,
            recoveryGeneration: generation
          )
        )
        cursor = cursor.addingTimeInterval(Double(durationMs) / 1000.0)
        index += 1
      }
    }
    return out
  }
}

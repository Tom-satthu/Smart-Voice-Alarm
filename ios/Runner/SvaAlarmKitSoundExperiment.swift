import Foundation

#if canImport(AlarmKit)
import AlarmKit
#endif

/// Review-build only: schedule a one-shot AlarmKit custom-sound probe from
/// an existing Library/Sounds CAF when UserDefaults requests it.
enum SvaAlarmKitSoundExperiment {
  static let pendingModeKey = "sva_pending_sound_experiment_mode"
  static let pendingDelayKey = "sva_pending_sound_experiment_delay"
  static let pendingFileKey = "sva_pending_sound_experiment_file"

  /// Call once after plugin registration on review builds.
  static func runPendingIfNeeded() {
    let defaults = UserDefaults.standard
    guard let modeRaw = defaults.string(forKey: pendingModeKey),
          let mode = SvaAlarmKitSoundNameMode(rawValue: modeRaw)
    else { return }
    defaults.removeObject(forKey: pendingModeKey)
    let delay = defaults.double(forKey: pendingDelayKey)
    let seconds = delay > 5 ? delay : 45
    defaults.removeObject(forKey: pendingDelayKey)
    var fileName = defaults.string(forKey: pendingFileKey) ?? ""
    defaults.removeObject(forKey: pendingFileKey)
    if fileName.isEmpty {
      fileName = firstRenderedSoundFileName() ?? ""
    }
    guard !fileName.isEmpty else {
      NSLog("[SVA-SoundExp] no Library/Sounds CAF available")
      return
    }

    SvaAlarmKitSoundNameMode.setPreferred(mode)
    let diag = SvaAudioFileValidator.diagnoseRendered(
      fileName: fileName,
      sourceType: "recording"
    )
    var named = diag
    named.soundNameMode = mode.rawValue
    named.alertSoundNameExact = SvaAlarmKitSoundResolver.alertSoundName(
      fileName: fileName,
      mode: mode
    )
    named.logLine(prefix: "[SVA-SoundExp]")
    SvaAlarmKitSoundStore.saveLast(named)

    guard named.renderedExists, named.avPlayerPlayable else {
      NSLog("[SVA-SoundExp] refuse schedule — file invalid")
      return
    }

    Task {
      await scheduleProbe(fileName: fileName, mode: mode, delaySeconds: seconds)
    }
  }

  private static func firstRenderedSoundFileName() -> String? {
    let dir = SvaAudioRenderer.soundsDirectory
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: dir,
      includingPropertiesForKeys: [.fileSizeKey],
      options: [.skipsHiddenFiles]
    ) else { return nil }
    let cafs = files
      .filter { $0.pathExtension.lowercased() == "caf" && $0.lastPathComponent.hasPrefix("sva_") }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
    return cafs.first?.lastPathComponent
  }

  private static func scheduleProbe(
    fileName: String,
    mode: SvaAlarmKitSoundNameMode,
    delaySeconds: Double
  ) async {
    #if canImport(AlarmKit)
    guard #available(iOS 26.0, *) else {
      NSLog("[SVA-SoundExp] iOS < 26 — skip")
      return
    }
    SvaAlarmKitSoundNameMode.setPreferred(mode)
    // Ensure runtime can call AlarmKit for review probe.
    if !SvaAlarmKitRuntime.mayCallAlarmKitAPI {
      let probe = await SvaAlarmKitRuntime.userInitiatedProbeAuthorization()
      NSLog("[SVA-SoundExp] probe=%@", String(describing: probe["alarmKitAuthorization"]))
      if probe["alarmKitAuthorization"] as? String != "authorized" {
        let req = await SvaAlarmKitRuntime.userInitiatedRequestAuthorization()
        NSLog("[SVA-SoundExp] request=%@", String(describing: req["alarmKitAuthorization"]))
      }
    }
    guard SvaAlarmKitRuntime.mayCallAlarmKitAPI || SvaAlarmKitRuntime.cachedAuthorization == "authorized" else {
      NSLog("[SVA-SoundExp] AlarmKit not authorized — abort")
      return
    }
    // Temporarily allow schedule even if probeEverSucceeded was false.
    if !SvaAlarmKitRuntime.probeEverSucceeded {
      SvaAlarmKitRuntime.markProbeSuccess(auth: "authorized")
    }

    let start = Date().addingTimeInterval(delaySeconds)
    let child = UUID().uuidString
    let segment = SvaSegmentSpec(
      parentAlarmId: "sva-sound-exp",
      occurrenceId: "exp-\(mode.rawValue)",
      segmentIndex: 0,
      childId: child,
      startAtMillis: Int64(start.timeIntervalSince1970 * 1000),
      soundFileName: fileName,
      label: "recording",
      durationMs: 5000
    )
    NSLog(
      "[SVA-SoundExp] scheduling mode=%@ file=%@ named=%@ fireIn=%.0fs",
      mode.rawValue,
      fileName,
      SvaAlarmKitSoundResolver.alertSoundName(fileName: fileName, mode: mode),
      delaySeconds
    )
    do {
      let outcome = try await SvaAlarmKitManager.sharedManaging.schedule(
        segments: [segment],
        title: "Sound probe \(mode.rawValue)"
      )
      NSLog(
        "[SVA-SoundExp] schedule ok=%d warn=%@ ids=%d",
        outcome.ok ? 1 : 0,
        outcome.warningCode ?? "",
        outcome.scheduledIds.count
      )
    } catch {
      NSLog("[SVA-SoundExp] schedule error=%@", error.localizedDescription)
    }
    #else
    NSLog("[SVA-SoundExp] AlarmKit unavailable at compile time")
    #endif
  }
}

import AVFoundation
import Foundation

#if canImport(AlarmKit)
import AlarmKit
#endif
#if canImport(ActivityKit)
import ActivityKit
#endif

/// How AlarmKit receives custom sound names.
enum SvaAlarmKitSoundNameMode: String {
  /// Pass basename including extension, e.g. `voice.caf` (matches UNNotificationSound).
  case withExtension
  /// Pass basename without extension, e.g. `voice` (WWDC sample style).
  case withoutExtension

  static let defaultsKey = "sva_alarmkit_sound_name_mode"

  static var preferred: SvaAlarmKitSoundNameMode {
    let raw = UserDefaults.standard.string(forKey: defaultsKey) ?? ""
    return SvaAlarmKitSoundNameMode(rawValue: raw) ?? .withExtension
  }

  static func setPreferred(_ mode: SvaAlarmKitSoundNameMode) {
    UserDefaults.standard.set(mode.rawValue, forKey: defaultsKey)
    NSLog("[SVA-AlarmKit] soundNameMode preferred=%@", mode.rawValue)
  }
}

/// Privacy-safe custom-sound diagnostics (no speech/TTS text).
struct SvaSoundDiagnostics {
  var sourceType: String = "unknown"
  var originalSourceExists: Bool?
  var renderedFileName: String = ""
  var renderedPath: String = ""
  var renderedExists: Bool = false
  var fileSize: Int = 0
  var durationMs: Int = 0
  var sampleRate: Double = 0
  var channels: Int = 0
  var formatDescription: String = ""
  var avPlayerPlayable: Bool = false
  var alertSoundNameExact: String = ""
  var soundNameMode: String = ""
  var usedDefault: Bool = false
  var warningCode: String?
  var warningMessage: String?
  var backend: String = "alarmKit"
  var childId: String = ""
  var segmentIndex: Int = 0
  var alarmKitId: String = ""
  var scheduleOk: Bool?

  var asDictionary: [String: Any] {
    var out: [String: Any] = [
      "sourceType": sourceType,
      "renderedFileName": renderedFileName,
      "renderedPath": renderedPath,
      "renderedExists": renderedExists,
      "fileSize": fileSize,
      "durationMs": durationMs,
      "sampleRate": sampleRate,
      "channels": channels,
      "formatDescription": formatDescription,
      "avPlayerPlayable": avPlayerPlayable,
      "alertSoundNameExact": alertSoundNameExact,
      "soundNameMode": soundNameMode,
      "usedDefault": usedDefault,
      "backend": backend,
      "childId": childId,
      "segmentIndex": segmentIndex,
      "alarmKitId": alarmKitId,
    ]
    if let originalSourceExists { out["originalSourceExists"] = originalSourceExists }
    if let warningCode { out["warningCode"] = warningCode }
    if let warningMessage { out["warningMessage"] = warningMessage }
    if let scheduleOk { out["scheduleOk"] = scheduleOk }
    return out
  }

  func logLine(prefix: String = "[SVA-Sound]") {
    NSLog(
      "%@ type=%@ file=%@ exists=%d size=%d durMs=%d rate=%.0f ch=%d fmt=%@ playable=%d named=%@ mode=%@ default=%d warn=%@",
      prefix,
      sourceType,
      renderedFileName,
      renderedExists ? 1 : 0,
      fileSize,
      durationMs,
      sampleRate,
      channels,
      formatDescription,
      avPlayerPlayable ? 1 : 0,
      alertSoundNameExact,
      soundNameMode,
      usedDefault ? 1 : 0,
      warningCode ?? ""
    )
  }
}

enum SvaAlarmKitSoundStore {
  private static let lastKey = "sva_alarmkit_last_sound_diagnostics"
  private static let historyKey = "sva_alarmkit_sound_diagnostics_history"

  static func saveLast(_ diag: SvaSoundDiagnostics) {
    UserDefaults.standard.set(diag.asDictionary, forKey: lastKey)
    var history = UserDefaults.standard.array(forKey: historyKey) as? [[String: Any]] ?? []
    history.append(diag.asDictionary)
    if history.count > 20 {
      history = Array(history.suffix(20))
    }
    UserDefaults.standard.set(history, forKey: historyKey)
  }

  static func last() -> [String: Any]? {
    UserDefaults.standard.dictionary(forKey: lastKey)
  }

  static func history() -> [[String: Any]] {
    UserDefaults.standard.array(forKey: historyKey) as? [[String: Any]] ?? []
  }
}

/// Validates rendered CAF files before handing them to AlarmKit / notifications.
enum SvaAudioFileValidator {
  struct Result {
    var ok: Bool
    var exists: Bool
    var fileSize: Int
    var durationMs: Int
    var sampleRate: Double
    var channels: Int
    var formatDescription: String
    var avPlayerPlayable: Bool
    var errorCode: String?
    var errorMessage: String?

    var asDictionary: [String: Any] {
      var out: [String: Any] = [
        "ok": ok,
        "exists": exists,
        "fileSize": fileSize,
        "durationMs": durationMs,
        "sampleRate": sampleRate,
        "channels": channels,
        "formatDescription": formatDescription,
        "avPlayerPlayable": avPlayerPlayable,
      ]
      if let errorCode { out["errorCode"] = errorCode }
      if let errorMessage { out["errorMessage"] = errorMessage }
      return out
    }
  }

  /// Max AlarmKit / notification custom sound length we accept.
  static let maxDurationSeconds: Double = 20
  static let minDurationSeconds: Double = 0.05

  static func validate(url: URL) -> Result {
    var isDir: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
      && !isDir.boolValue
    guard exists else {
      return Result(
        ok: false,
        exists: false,
        fileSize: 0,
        durationMs: 0,
        sampleRate: 0,
        channels: 0,
        formatDescription: "",
        avPlayerPlayable: false,
        errorCode: "sound_file_missing",
        errorMessage: "Rendered sound file missing"
      )
    }

    let size = ((try? FileManager.default.attributesOfItem(atPath: url.path)[.size]
      as? NSNumber)?.intValue) ?? 0
    guard size > 0 else {
      return Result(
        ok: false,
        exists: true,
        fileSize: 0,
        durationMs: 0,
        sampleRate: 0,
        channels: 0,
        formatDescription: "",
        avPlayerPlayable: false,
        errorCode: "sound_file_empty",
        errorMessage: "Rendered sound file empty"
      )
    }

    do {
      let file = try AVAudioFile(forReading: url)
      let format = file.processingFormat
      let rate = format.sampleRate
      let channels = Int(format.channelCount)
      let duration = rate > 0 ? Double(file.length) / rate : 0
      let durationMs = Int((duration * 1000).rounded())
      let fmt = "\(format.commonFormat.rawValue)/\(Int(rate))Hz/\(channels)ch"
      guard file.length > 0, duration.isFinite, duration >= minDurationSeconds else {
        return Result(
          ok: false,
          exists: true,
          fileSize: size,
          durationMs: durationMs,
          sampleRate: rate,
          channels: channels,
          formatDescription: fmt,
          avPlayerPlayable: false,
          errorCode: "sound_duration_invalid",
          errorMessage: "Rendered duration invalid"
        )
      }
      guard duration <= maxDurationSeconds + 0.25 else {
        return Result(
          ok: false,
          exists: true,
          fileSize: size,
          durationMs: durationMs,
          sampleRate: rate,
          channels: channels,
          formatDescription: fmt,
          avPlayerPlayable: false,
          errorCode: "sound_duration_too_long",
          errorMessage: "Rendered sound exceeds 20s"
        )
      }
      guard channels == 1 || channels == 2 else {
        return Result(
          ok: false,
          exists: true,
          fileSize: size,
          durationMs: durationMs,
          sampleRate: rate,
          channels: channels,
          formatDescription: fmt,
          avPlayerPlayable: false,
          errorCode: "sound_channels_invalid",
          errorMessage: "Unsupported channel count"
        )
      }

      let playable = canPlayWithAVAudioPlayer(url: url)
      guard playable else {
        return Result(
          ok: false,
          exists: true,
          fileSize: size,
          durationMs: durationMs,
          sampleRate: rate,
          channels: channels,
          formatDescription: fmt,
          avPlayerPlayable: false,
          errorCode: "sound_not_playable",
          errorMessage: "AVAudioPlayer rejected file"
        )
      }

      return Result(
        ok: true,
        exists: true,
        fileSize: size,
        durationMs: durationMs,
        sampleRate: rate,
        channels: channels,
        formatDescription: fmt,
        avPlayerPlayable: true,
        errorCode: nil,
        errorMessage: nil
      )
    } catch {
      return Result(
        ok: false,
        exists: true,
        fileSize: size,
        durationMs: 0,
        sampleRate: 0,
        channels: 0,
        formatDescription: "",
        avPlayerPlayable: false,
        errorCode: "sound_caf_invalid",
        errorMessage: error.localizedDescription
      )
    }
  }

  static func canPlayWithAVAudioPlayer(url: URL) -> Bool {
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      return player.duration > 0 && player.prepareToPlay()
    } catch {
      NSLog("[SVA-Sound] AVAudioPlayer failed: %@", error.localizedDescription)
      return false
    }
  }

  /// Builds diagnostics for a file already in Library/Sounds.
  static func diagnoseRendered(
    fileName: String,
    sourceType: String = "unknown",
    originalSourceExists: Bool? = nil
  ) -> SvaSoundDiagnostics {
    var diag = SvaSoundDiagnostics()
    diag.sourceType = sourceType
    diag.originalSourceExists = originalSourceExists
    diag.renderedFileName = fileName
    let url = SvaAudioRenderer.soundsDirectory.appendingPathComponent(fileName)
    diag.renderedPath = url.path
    let validation = validate(url: url)
    diag.renderedExists = validation.exists
    diag.fileSize = validation.fileSize
    diag.durationMs = validation.durationMs
    diag.sampleRate = validation.sampleRate
    diag.channels = validation.channels
    diag.formatDescription = validation.formatDescription
    diag.avPlayerPlayable = validation.avPlayerPlayable
    if !validation.ok {
      diag.warningCode = validation.errorCode
      diag.warningMessage = validation.errorMessage
    }
    return diag
  }
}

enum SvaAlarmKitSoundResolver {
  /// Exact string that will be passed to AlertSound.named / logged for diagnostics.
  static func alertSoundName(
    fileName: String,
    mode: SvaAlarmKitSoundNameMode = .preferred
  ) -> String {
    let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return "" }
    switch mode {
    case .withExtension:
      return trimmed
    case .withoutExtension:
      let base = (trimmed as NSString).deletingPathExtension
      return base.isEmpty ? trimmed : base
    }
  }

  #if canImport(AlarmKit)
  @available(iOS 26.0, *)
  static func resolve(
    fileName: String,
    mode: SvaAlarmKitSoundNameMode = .preferred,
    sourceType: String = "unknown",
    childId: String = "",
    segmentIndex: Int = 0,
    alarmKitId: String = ""
  ) -> (
    sound: AlertConfiguration.AlertSound,
    diagnostics: SvaSoundDiagnostics
  ) {
    var diag = SvaAudioFileValidator.diagnoseRendered(
      fileName: fileName,
      sourceType: sourceType
    )
    diag.soundNameMode = mode.rawValue
    diag.childId = childId
    diag.segmentIndex = segmentIndex
    diag.alarmKitId = alarmKitId
    diag.backend = "alarmKit"

    let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      diag.usedDefault = true
      diag.alertSoundNameExact = ""
      diag.warningCode = "custom_sound_fallback"
      diag.warningMessage = "Missing sound file — using default AlarmKit sound"
      diag.logLine()
      SvaAlarmKitSoundStore.saveLast(diag)
      return (.default, diag)
    }

    if !diag.renderedExists || !diag.avPlayerPlayable {
      diag.usedDefault = true
      diag.alertSoundNameExact = ""
      if diag.warningCode == nil {
        diag.warningCode = "custom_sound_fallback"
        diag.warningMessage = "Custom sound invalid — using default AlarmKit sound"
      } else {
        // Keep validation code but mark fallback.
        diag.warningMessage = (diag.warningMessage ?? "") + " — using default AlarmKit sound"
      }
      diag.logLine()
      SvaAlarmKitSoundStore.saveLast(diag)
      return (.default, diag)
    }

    let exact = alertSoundName(fileName: trimmed, mode: mode)
    diag.alertSoundNameExact = exact
    diag.usedDefault = false
    diag.logLine()
    SvaAlarmKitSoundStore.saveLast(diag)
    return (.named(exact), diag)
  }
  #endif
}

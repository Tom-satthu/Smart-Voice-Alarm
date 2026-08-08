import Foundation

/// Render role for CAF materialization. Ringtone must not share the speech loudness path.
enum SvaAudioRenderRole: String {
  case speech
  case ringtone
  case silence

  static func parse(_ raw: String?) -> SvaAudioRenderRole {
    guard let raw, let role = SvaAudioRenderRole(rawValue: raw.lowercased()) else {
      return .speech
    }
    return role
  }
}

/// Ringtone-only processing constants (AlarmKit CAF content + trailing silence).
enum SvaRingtoneAudioConfig {
  /// Product ringtone content length before trailing silence.
  static let contentSeconds: Double = 10
  /// Trailing silence baked into CAF (matches voice/TTS R7).
  static let trailingSilenceSeconds: Double = 1.25
  /// Equal-power crossfade at each loop junction only.
  static let crossfadeMs: Double = 20
  /// Fade-out at end of content before trailing silence (inside 10s).
  static let fadeOutMs: Double = 15
  /// Short fade-in when source does not start near zero.
  static let fadeInMs: Double = 8
  /// Static peak ceiling ≈ -1 dBFS (whole-file gain only, never boost).
  static let peakLimitLinear: Float = 0.8912509
  static let sampleRate: Double = 44100
  /// Historical buggy convert chunk size (for regression metrics).
  static let legacyConvertChunkFrames: Int = 4096

  static var crossfadeFrames: Int {
    max(1, Int((crossfadeMs / 1000.0) * sampleRate))
  }

  static var fadeOutFrames: Int {
    max(1, Int((fadeOutMs / 1000.0) * sampleRate))
  }

  static var fadeInFrames: Int {
    max(1, Int((fadeInMs / 1000.0) * sampleRate))
  }

  static var contentFrames: Int {
    Int(contentSeconds * sampleRate)
  }
}

/// Debug / production ringtone processing stages.
enum SvaRingtoneProcessingMode: String {
  /// Resample only — no gain, loop, fade, or trailing silence.
  case passthrough
  /// Resample + loop to 10s — no gain/fade/trailing.
  case loopOnly
  /// Resample + static gain only — no loop/fade/trailing.
  case limiterOnly
  /// Production: static gain + loop/crossfade + fades + trailing silence.
  case final

  static func parse(_ raw: String?) -> SvaRingtoneProcessingMode {
    guard let raw, let mode = SvaRingtoneProcessingMode(rawValue: raw) else {
      return .final
    }
    return mode
  }
}

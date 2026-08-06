import AVFoundation
import Foundation

/// Generates a Linear PCM silence CAF for AlarmKit gap children.
enum SvaSilenceAudio {
  static let defaultFileName = "sva_silence_5s.caf"
  static let defaultSeconds: Double = 5

  /// Ensures a playable silence CAF exists in Library/Sounds.
  static func ensure(
    fileName: String = defaultFileName,
    seconds: Double = defaultSeconds
  ) throws -> [String: Any] {
    let dest = SvaAudioRenderer.soundsDirectory.appendingPathComponent(fileName)
    if FileManager.default.fileExists(atPath: dest.path) {
      // Do not use loudness-oriented validate() — silence is intentionally quiet.
      let expectedMs = Int((seconds * 1000).rounded())
      if let duration = try? measureDuration(url: dest),
         abs(Int((duration * 1000).rounded()) - expectedMs) <= 250,
         SvaAudioFileValidator.canPlayWithAVAudioPlayer(url: dest)
      {
        let attrs = try? FileManager.default.attributesOfItem(atPath: dest.path)
        let size = (attrs?[.size] as? NSNumber)?.intValue ?? 0
        return [
          "ok": true,
          "fileName": fileName,
          "path": dest.path,
          "durationMs": Int((duration * 1000).rounded()),
          "byteSize": size,
          "reused": true,
          "avPlayerPlayable": true,
        ]
      }
      try? FileManager.default.removeItem(at: dest)
    }

    guard let format = SvaAudioRenderer.outputFormat() else {
      throw NSError(
        domain: "SvaSilenceAudio",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Silence output format unavailable"]
      )
    }
    let frames = AVAudioFrameCount(seconds * format.sampleRate)
    guard frames > 0,
          let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)
    else {
      throw NSError(
        domain: "SvaSilenceAudio",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Unable to allocate silence buffer"]
      )
    }
    buffer.frameLength = frames
    if let ch = buffer.int16ChannelData?[0] {
      memset(ch, 0, Int(frames) * MemoryLayout<Int16>.size)
    }

    let file = try AVAudioFile(
      forWriting: dest,
      settings: format.settings,
      commonFormat: format.commonFormat,
      interleaved: format.isInterleaved
    )
    try file.write(from: buffer)

    // Bypass loudness normalize (silence would be rejected as silent audio).
    let validation = SvaAudioFileValidator.validate(url: dest)
    // Validator rejects near-silent peak — use a dedicated silence check.
    let attrs = try FileManager.default.attributesOfItem(atPath: dest.path)
    let size = (attrs[.size] as? NSNumber)?.intValue ?? 0
    let duration = try measureDuration(url: dest)
    guard size > 0, duration > seconds - 0.05, duration < seconds + 0.25 else {
      throw NSError(
        domain: "SvaSilenceAudio",
        code: 422,
        userInfo: [NSLocalizedDescriptionKey: "Silence CAF invalid duration/size"]
      )
    }
    // AVAudioPlayer should still open silence CAF.
    let playable = SvaAudioFileValidator.canPlayWithAVAudioPlayer(url: dest)
    NSLog(
      "[SVA-Audio] silence ready file=%@ size=%d durMs=%d playable=%d",
      fileName,
      size,
      Int((duration * 1000).rounded()),
      playable ? 1 : 0
    )
    return [
      "ok": true,
      "fileName": fileName,
      "path": dest.path,
      "durationMs": Int((duration * 1000).rounded()),
      "byteSize": size,
      "avPlayerPlayable": playable,
      "reused": false,
      "formatDescription": validation.formatDescription,
    ]
  }

  private static func measureDuration(url: URL) throws -> Double {
    let file = try AVAudioFile(forReading: url)
    let rate = file.processingFormat.sampleRate
    guard rate > 0 else { return 0 }
    return Double(file.length) / rate
  }
}

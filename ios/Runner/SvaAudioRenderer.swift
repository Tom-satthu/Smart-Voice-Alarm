import AVFoundation
import Foundation

/// Renders recordings / TTS / ringtone assets into Library/Sounds.
/// Notification custom sounds need Linear PCM / IMA4 / µLaw / aLaw in caf/wav/aiff.
enum SvaAudioRenderer {
  static var soundsDirectory: URL {
    let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    let sounds = library.appendingPathComponent("Sounds", isDirectory: true)
    try? FileManager.default.createDirectory(at: sounds, withIntermediateDirectories: true)
    return sounds
  }

  static func render(
    sourcePath: String?,
    assetKey: String?,
    ttsText: String?,
    ttsLocale: String?,
    fileName: String,
    maxSeconds: Double
  ) async throws -> [String: Any] {
    let dest = soundsDirectory.appendingPathComponent(fileName)
    let temp = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_render_\(UUID().uuidString).caf")

    if let text = ttsText, !text.isEmpty {
      try await renderTts(text: text, locale: ttsLocale, to: temp, maxSeconds: maxSeconds)
    } else if let path = sourcePath, !path.isEmpty {
      try convertAudio(from: URL(fileURLWithPath: path), to: temp, maxSeconds: maxSeconds)
    } else if let key = assetKey, !key.isEmpty {
      guard let bundled = resolveBundledSound(key: key) else {
        throw NSError(
          domain: "SvaAudioRenderer",
          code: 404,
          userInfo: [NSLocalizedDescriptionKey: "Bundled sound not found: \(key)"]
        )
      }
      try convertAudio(from: bundled, to: temp, maxSeconds: maxSeconds)
    } else {
      throw NSError(
        domain: "SvaAudioRenderer",
        code: 400,
        userInfo: [NSLocalizedDescriptionKey: "No audio source provided"]
      )
    }

    let duration = try measureDuration(url: temp)
    if duration <= 0.05 {
      try? FileManager.default.removeItem(at: temp)
      throw NSError(
        domain: "SvaAudioRenderer",
        code: 422,
        userInfo: [NSLocalizedDescriptionKey: "Rendered audio is empty or unreadable"]
      )
    }

    if FileManager.default.fileExists(atPath: dest.path) {
      try FileManager.default.removeItem(at: dest)
    }
    try FileManager.default.moveItem(at: temp, to: dest)

    return [
      "fileName": fileName,
      "path": dest.path,
      "durationMs": Int((duration * 1000).rounded()),
    ]
  }

  static func cleanupOrphans(activeFileNames: Set<String>) {
    let dir = soundsDirectory
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: dir,
      includingPropertiesForKeys: nil
    ) else { return }
    for file in files {
      let name = file.lastPathComponent
      guard name.hasPrefix("sva_") else { continue }
      if !activeFileNames.contains(name) {
        try? FileManager.default.removeItem(at: file)
      }
    }
  }

  private static func resolveBundledSound(key: String) -> URL? {
    let base = key.replacingOccurrences(of: ".wav", with: "")
      .replacingOccurrences(of: ".caf", with: "")
    if let url = Bundle.main.url(forResource: base, withExtension: "wav") { return url }
    if let url = Bundle.main.url(forResource: base, withExtension: "caf") { return url }
    let paths = [
      "flutter_assets/assets/ringtones/\(base).wav",
      "flutter_assets/assets/ringtones/\(base)",
    ]
    for path in paths {
      let full = Bundle.main.bundleURL.appendingPathComponent(path)
      if FileManager.default.fileExists(atPath: full.path) { return full }
    }
    return nil
  }

  /// Verifies a PCM buffer actually has audio bytes backing its frameLength.
  /// AVAudioFile.write(from:) hard-aborts the process (not a catchable Swift
  /// error) if handed a buffer that reports frames but has zero data bytes.
  private static func hasAudioBytes(_ buffer: AVAudioPCMBuffer) -> Bool {
    let bufferList = buffer.audioBufferList.pointee
    if bufferList.mNumberBuffers < 1 { return false }
    return bufferList.mBuffers.mDataByteSize > 0
  }

  /// Shrinking `AVAudioPCMBuffer.frameLength` in place on a buffer that just
  /// came out of an `AVAudioConverter` can leave its byte storage
  /// inconsistent (frameLength reports a smaller, non-zero count while the
  /// underlying `mDataByteSize` drops to 0) — writing that buffer trips a
  /// hard CoreAudio abort instead of a catchable Swift error. Build a fresh,
  /// correctly-sized buffer and copy the samples across instead of mutating
  /// `frameLength` on the original.
  private static func clamped(
    _ buffer: AVAudioPCMBuffer,
    toFrameLength frameLength: AVAudioFrameCount
  ) -> AVAudioPCMBuffer? {
    if frameLength >= buffer.frameLength { return buffer }
    guard frameLength > 0 else { return nil }
    guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: frameLength)
    else { return nil }
    copy.frameLength = frameLength
    let channels = Int(buffer.format.channelCount)
    if let src = buffer.floatChannelData, let dst = copy.floatChannelData {
      for c in 0..<channels {
        memcpy(dst[c], src[c], Int(frameLength) * MemoryLayout<Float>.size)
      }
    } else if let src = buffer.int16ChannelData, let dst = copy.int16ChannelData {
      for c in 0..<channels {
        memcpy(dst[c], src[c], Int(frameLength) * MemoryLayout<Int16>.size)
      }
    } else {
      return nil
    }
    return copy
  }

  /// Safe conversion via AVAudioFile + AVAudioConverter (no ExtAudioFile assert path).
  private static func convertAudio(from source: URL, to dest: URL, maxSeconds: Double) throws {
    if FileManager.default.fileExists(atPath: dest.path) {
      try FileManager.default.removeItem(at: dest)
    }

    let inputFile: AVAudioFile
    do {
      inputFile = try AVAudioFile(forReading: source)
    } catch {
      // Last resort: copy bytes if already a notification-friendly container.
      let ext = source.pathExtension.lowercased()
      if ["wav", "caf", "aiff", "aif"].contains(ext) {
        try FileManager.default.copyItem(at: source, to: dest)
        return
      }
      throw error
    }

    let outFormat = AVAudioFormat(
      commonFormat: .pcmFormatInt16,
      sampleRate: 44100,
      channels: 1,
      interleaved: true
    )!
    // AVAudioFile(forWriting:settings:) silently defaults its *processing*
    // format to Float32/non-interleaved no matter what `settings` says —
    // the on-disk format follows `settings`, but write(from:) requires the
    // buffer handed to it to match the processing format exactly. Since we
    // write Int16 interleaved mono buffers below, that mismatch is what was
    // tripping the "mDataByteSize (0) should be non-zero" CoreAudio abort.
    // Passing commonFormat/interleaved explicitly keeps them in sync.
    let outputFile = try AVAudioFile(
      forWriting: dest,
      settings: outFormat.settings,
      commonFormat: outFormat.commonFormat,
      interleaved: outFormat.isInterleaved
    )

    let maxFrames = AVAudioFramePosition(maxSeconds * outFormat.sampleRate)
    let inputFormat = inputFile.processingFormat
    let converter = AVAudioConverter(from: inputFormat, to: outFormat)

    let frameCapacity: AVAudioFrameCount = 4096
    guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: frameCapacity)
    else {
      throw NSError(
        domain: "SvaAudioRenderer",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Unable to allocate input buffer"]
      )
    }

    var written = AVAudioFramePosition(0)
    while inputFile.framePosition < inputFile.length, written < maxFrames {
      let remainingInput = AVAudioFrameCount(inputFile.length - inputFile.framePosition)
      let readCount = min(frameCapacity, remainingInput)
      inputBuffer.frameLength = readCount
      try inputFile.read(into: inputBuffer, frameCount: readCount)
      if inputBuffer.frameLength == 0 { break }

      if let converter {
        let ratio = outFormat.sampleRate / inputFormat.sampleRate
        let outCapacity = AVAudioFrameCount(Double(inputBuffer.frameLength) * ratio) + 32
        guard let outputBuffer = AVAudioPCMBuffer(
          pcmFormat: outFormat,
          frameCapacity: outCapacity
        ) else { break }

        var gotInput = false
        var convertError: NSError?
        let status = converter.convert(to: outputBuffer, error: &convertError) { _, outStatus in
          if gotInput {
            outStatus.pointee = .noDataNow
            return nil
          }
          gotInput = true
          outStatus.pointee = .haveData
          return inputBuffer
        }
        if let convertError { throw convertError }
        if status == .error { break }

        let remainingOut = AVAudioFrameCount(maxFrames - written)
        let toWrite = clamped(outputBuffer, toFrameLength: remainingOut)
        // `frameLength > 0` alone isn't a reliable guard here: AVAudioConverter
        // can hand back a buffer whose frameLength looks non-zero while its
        // underlying byte storage is still empty (e.g. while it's priming on
        // the first few packets). Writing that buffer trips a hard CoreAudio
        // abort ("mDataByteSize (0) should be non-zero") that crashes the
        // whole app instead of throwing a catchable error. Verify the raw
        // byte size too, and just skip that chunk instead of writing it.
        if let toWrite, toWrite.frameLength > 0, hasAudioBytes(toWrite) {
          try outputFile.write(from: toWrite)
          written += AVAudioFramePosition(toWrite.frameLength)
        }
      } else if inputFormat.commonFormat == .pcmFormatInt16,
                inputFormat.sampleRate == outFormat.sampleRate,
                inputFormat.channelCount == 1 {
        let remainingOut = AVAudioFrameCount(maxFrames - written)
        let toWrite = clamped(inputBuffer, toFrameLength: remainingOut)
        if let toWrite, toWrite.frameLength > 0, hasAudioBytes(toWrite) {
          try outputFile.write(from: toWrite)
          written += AVAudioFramePosition(toWrite.frameLength)
        }
      } else {
        throw NSError(
          domain: "SvaAudioRenderer",
          code: 501,
          userInfo: [NSLocalizedDescriptionKey: "Unable to create audio converter"]
        )
      }
    }

    if written == 0 {
      throw NSError(
        domain: "SvaAudioRenderer",
        code: 422,
        userInfo: [NSLocalizedDescriptionKey: "Converted audio is empty"]
      )
    }
  }

  // AVSpeechSynthesizer does not keep itself alive while synthesizing — if the
  // only strong reference is a local variable, ARC can deallocate it before
  // the write(_:bufferCallback:) completion fires, which leaves the awaiting
  // continuation (and the whole Save Alarm flow) hanging forever. Keep a
  // strong reference here for the duration of each render.
  private static var activeSynthesizers: [ObjectIdentifier: AVSpeechSynthesizer] = [:]

  private static func renderTts(
    text: String,
    locale: String?,
    to dest: URL,
    maxSeconds: Double
  ) async throws {
    let tempFloat = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_tts_\(UUID().uuidString).caf")

    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      let synthesizer = AVSpeechSynthesizer()
      let synthesizerKey = ObjectIdentifier(synthesizer)
      activeSynthesizers[synthesizerKey] = synthesizer
      let utterance = AVSpeechUtterance(string: text)
      if let locale, !locale.isEmpty {
        let normalized = locale.replacingOccurrences(of: "_", with: "-")
        utterance.voice = AVSpeechSynthesisVoice(language: normalized)
          ?? AVSpeechSynthesisVoice(language: String(normalized.prefix(2)))
      }
      utterance.rate = AVSpeechUtteranceDefaultSpeechRate

      var buffers: [AVAudioPCMBuffer] = []
      var finished = false

      synthesizer.write(utterance) { buffer in
        guard let pcm = buffer as? AVAudioPCMBuffer else { return }
        if pcm.frameLength == 0 {
          guard !finished else { return }
          finished = true
          defer { activeSynthesizers.removeValue(forKey: synthesizerKey) }
          do {
            guard let first = buffers.first else {
              throw NSError(
                domain: "SvaAudioRenderer",
                code: 423,
                userInfo: [NSLocalizedDescriptionKey: "TTS produced no audio"]
              )
            }
            if FileManager.default.fileExists(atPath: tempFloat.path) {
              try FileManager.default.removeItem(at: tempFloat)
            }
            // Match commonFormat/interleaved explicitly — see the note in
            // convertAudio() above about AVAudioFile's default processing
            // format silently mismatching the buffer we write.
            let file = try AVAudioFile(
              forWriting: tempFloat,
              settings: first.format.settings,
              commonFormat: first.format.commonFormat,
              interleaved: first.format.isInterleaved
            )
            let maxFrames = AVAudioFrameCount(maxSeconds * first.format.sampleRate)
            var total: AVAudioFrameCount = 0
            for buf in buffers {
              if total >= maxFrames { break }
              let remaining = maxFrames - total
              if buf.frameLength > remaining {
                guard let sliced = AVAudioPCMBuffer(
                  pcmFormat: buf.format,
                  frameCapacity: remaining
                ) else { continue }
                sliced.frameLength = remaining
                if let src = buf.floatChannelData, let dst = sliced.floatChannelData {
                  for c in 0..<Int(buf.format.channelCount) {
                    memcpy(dst[c], src[c], Int(remaining) * MemoryLayout<Float>.size)
                  }
                }
                try file.write(from: sliced)
                total += remaining
              } else {
                try file.write(from: buf)
                total += buf.frameLength
              }
            }
            continuation.resume()
          } catch {
            continuation.resume(throwing: error)
          }
          return
        }
        buffers.append(pcm)
      }
    }

    // Re-encode float TTS CAF → 16-bit mono PCM CAF for notifications.
    defer { try? FileManager.default.removeItem(at: tempFloat) }
    try convertAudio(from: tempFloat, to: dest, maxSeconds: maxSeconds)
  }

  private static func measureDuration(url: URL) throws -> Double {
    let file = try AVAudioFile(forReading: url)
    let rate = file.processingFormat.sampleRate
    if rate <= 0 { return 0 }
    return Double(file.length) / rate
  }
}

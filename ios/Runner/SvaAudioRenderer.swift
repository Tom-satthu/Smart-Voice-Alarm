import AVFoundation
import CryptoKit
import Foundation

/// Renders recordings / TTS / ringtone assets into Library/Sounds as Linear PCM CAF.
///
/// Hard rules:
/// - No force unwrap / fatalError / try! in production paths.
/// - Never write a PCM buffer whose AudioBufferList has mData == nil or mDataByteSize == 0.
/// - TTS synthesizer is owned by a retained serial operation until end/error/timeout.
enum SvaAudioRenderer {
  private static let queue = DispatchQueue(label: "com.smartvoicealarm.audio.render")

  /// Peak target ≈ -1 dBFS with a small headroom.
  private static let targetPeakLinear: Float = 0.8912509
  /// Speech RMS target ≈ -14 dBFS (perceived loudness, not just peak).
  private static let targetRmsLinear: Float = 0.20
  /// Cap make-up gain (~18 dB). Avoid 20× distortion on quiet speech.
  private static let maxNormalizeGain: Float = 8.0
  private static let compressorThreshold: Float = 0.35
  private static let compressorRatio: Float = 2.5
  private static let windowMs: Float = 50

  static var soundsDirectory: URL {
    let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
      ?? FileManager.default.temporaryDirectory
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
    maxSeconds: Double,
    targetDurationSeconds: Double? = nil,
    trailingSilenceSeconds: Double = 1.25,
    audioRole: String = "speech"
  ) async throws -> [String: Any] {
    let role = SvaAudioRenderRole.parse(audioRole)
    NSLog("[SVA-Audio] render begin file=%@ role=%@ tts=%d path=%d asset=%d trail=%.2f",
          fileName,
          role.rawValue,
          (ttsText?.isEmpty == false) ? 1 : 0,
          (sourcePath?.isEmpty == false) ? 1 : 0,
          (assetKey?.isEmpty == false) ? 1 : 0,
          trailingSilenceSeconds)

    let dest = soundsDirectory.appendingPathComponent(fileName)
    let temp = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_render_\(UUID().uuidString).caf")

    do {
      if let text = ttsText, !text.isEmpty {
        try await SvaTtsRenderService.shared.render(
          text: text,
          locale: ttsLocale,
          to: temp,
          maxSeconds: maxSeconds
        )
      } else if let path = sourcePath, !path.isEmpty {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
          queue.async {
            do {
              try convertAudio(from: URL(fileURLWithPath: path), to: temp, maxSeconds: maxSeconds)
              cont.resume()
            } catch {
              cont.resume(throwing: error)
            }
          }
        }
      } else if let key = assetKey, !key.isEmpty {
        guard let bundled = resolveBundledSound(key: key) else {
          throw svaError(404, "Bundled sound not found: \(key)")
        }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
          queue.async {
            do {
              try convertAudio(from: bundled, to: temp, maxSeconds: maxSeconds)
              cont.resume()
            } catch {
              cont.resume(throwing: error)
            }
          }
        }
      } else {
        throw svaError(400, "No audio source provided")
      }

      var ringtoneDiag: [String: Any] = [:]
      switch role {
      case .ringtone:
        // Ringtone: preserve gain — no speech RMS make-up / compressor.
        ringtoneDiag = try processRingtoneAudio(at: temp)
        let target = targetDurationSeconds ?? SvaRingtoneAudioConfig.contentSeconds
        let fitDiag = try fitRingtoneToExactDuration(
          at: temp,
          targetSeconds: min(target, maxSeconds)
        )
        for (k, v) in fitDiag { ringtoneDiag[k] = v }
      case .speech, .silence:
        try normalizeLoudness(at: temp)
        try validateRenderedFile(temp)
        if let target = targetDurationSeconds, target > 0 {
          // Legacy modulo fit — speech should not use this; kept for non-ringtone callers.
          try fitToExactDuration(at: temp, targetSeconds: min(target, maxSeconds))
        }
      }

      let contentValidation = SvaAudioFileValidator.validate(
        url: temp,
        maxDurationSeconds: maxSeconds + 0.25
      )
      guard contentValidation.ok else {
        throw svaError(
          422,
          contentValidation.errorMessage ?? "Rendered audio failed validation"
        )
      }
      let contentDurationMs = contentValidation.durationMs
      var trailingMs = 0
      if trailingSilenceSeconds > 0 {
        trailingMs = try appendTrailingSilence(
          at: temp,
          silenceSeconds: trailingSilenceSeconds
        )
      }
      let preValidation = SvaAudioFileValidator.validate(
        url: temp,
        maxDurationSeconds: maxSeconds + trailingSilenceSeconds + 0.5
      )
      guard preValidation.ok else {
        throw svaError(
          422,
          preValidation.errorMessage ?? "Rendered audio failed validation"
        )
      }
      if FileManager.default.fileExists(atPath: dest.path) {
        try FileManager.default.removeItem(at: dest)
      }
      try FileManager.default.moveItem(at: temp, to: dest)
      let validation = SvaAudioFileValidator.validate(
        url: dest,
        maxDurationSeconds: maxSeconds + trailingSilenceSeconds + 0.5
      )
      let size = validation.fileSize
      let hash = (try? debugFileHash(dest)) ?? "na"
      let loud = try measureFileLoudness(url: dest)
      NSLog(
        "[SVA-Audio] render ok file=%@ role=%@ path=%@ size=%d contentMs=%d trailMs=%d finalMs=%d hash=%@ peak=%.4f rms=%.4f nearClip=%d fmt=%@ playable=%d",
        fileName,
        role.rawValue,
        dest.path,
        size,
        contentDurationMs,
        trailingMs,
        validation.durationMs,
        hash,
        loud.peak,
        loud.rms,
        loud.nearClipCount,
        validation.formatDescription,
        validation.avPlayerPlayable ? 1 : 0
      )
      var out: [String: Any] = [
        "fileName": fileName,
        "path": dest.path,
        "durationMs": validation.durationMs,
        "contentDurationMs": contentDurationMs,
        "trailingSilenceMs": trailingMs,
        "finalizedFileDurationMs": validation.durationMs,
        "byteSize": size,
        "debugHash": hash,
        "sampleRate": validation.sampleRate,
        "channels": validation.channels,
        "formatDescription": validation.formatDescription,
        "avPlayerPlayable": validation.avPlayerPlayable,
        "renderedExists": validation.exists,
        "audioRole": role.rawValue,
        "peakLinear": loud.peak,
        "rmsLinear": loud.rms,
        "nearClipCount": loud.nearClipCount,
        "usedSpeechNormalize": role == .speech,
      ]
      for (k, v) in ringtoneDiag { out[k] = v }
      return out
    } catch {
      try? FileManager.default.removeItem(at: temp)
      NSLog("[SVA-Audio] render failed file=%@ err=%@", fileName, String(describing: error))
      throw error
    }
  }

  static func deleteSoundFile(_ fileName: String) {
    guard !fileName.isEmpty else { return }
    let url = soundsDirectory.appendingPathComponent(fileName)
    try? FileManager.default.removeItem(at: url)
  }

  static func cleanupOrphans(activeFileNames: Set<String>) {
    let pinned = SvaActiveSoundRegistry.pinnedFileNames()
    let keep = activeFileNames.union(pinned)
    guard !keep.isEmpty else {
      NSLog("[SVA-Audio] cleanupOrphans skipped — empty active+pinned set")
      return
    }
    let dir = soundsDirectory
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: dir,
      includingPropertiesForKeys: nil
    ) else { return }
    var removed = 0
    for file in files {
      let name = file.lastPathComponent
      guard name.hasPrefix("sva_") else { continue }
      if !keep.contains(name) {
        try? FileManager.default.removeItem(at: file)
        removed += 1
      }
    }
    NSLog(
      "[SVA-Audio] cleanupOrphans keep=%d pinned=%d removed=%d",
      keep.count,
      pinned.count,
      removed
    )
  }

  // MARK: - Helpers

  private static func svaError(_ code: Int, _ message: String) -> NSError {
    NSError(
      domain: "SvaAudioRenderer",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }

  private static func resolveBundledSound(key: String) -> URL? {
    // Accept basename ("soft_chime"), filename, or Flutter asset path.
    var base = key
      .replacingOccurrences(of: "assets/ringtones/", with: "")
      .replacingOccurrences(of: "flutter_assets/assets/ringtones/", with: "")
    if base.hasSuffix(".wav") || base.hasSuffix(".caf") {
      base = String(base.dropLast(4))
    }
    base = (base as NSString).lastPathComponent

    let candidates: [URL] = {
      var urls: [URL] = []
      if let u = Bundle.main.url(forResource: base, withExtension: "wav") {
        urls.append(u)
      }
      if let u = Bundle.main.url(forResource: base, withExtension: "caf") {
        urls.append(u)
      }
      let relativePaths = [
        "flutter_assets/assets/ringtones/\(base).wav",
        "flutter_assets/assets/ringtones/\(base)",
        "Frameworks/App.framework/flutter_assets/assets/ringtones/\(base).wav",
        "Frameworks/App.framework/flutter_assets/assets/ringtones/\(base)",
      ]
      for path in relativePaths {
        urls.append(Bundle.main.bundleURL.appendingPathComponent(path))
      }
      if let appFramework = Bundle.main.privateFrameworksURL?
        .appendingPathComponent("App.framework")
      {
        urls.append(
          appFramework
            .appendingPathComponent("flutter_assets/assets/ringtones/\(base).wav")
        )
        if let bundle = Bundle(url: appFramework),
           let u = bundle.url(
             forResource: base,
             withExtension: "wav",
             subdirectory: "flutter_assets/assets/ringtones"
           )
        {
          urls.append(u)
        }
      }
      return urls
    }()

    for url in candidates {
      if FileManager.default.fileExists(atPath: url.path) {
        NSLog("[SVA-Audio] ringtone resolved key=%@ path=%@", key, url.path)
        return url
      }
    }
    NSLog("[SVA-Audio] ringtone NOT found key=%@", key)
    return nil
  }

  static func outputFormat() -> AVAudioFormat? {
    AVAudioFormat(
      commonFormat: .pcmFormatInt16,
      sampleRate: 44100,
      channels: 1,
      interleaved: true
    )
  }

  private static func bufferHasValidAudioBytes(_ buffer: AVAudioPCMBuffer) -> Bool {
    guard buffer.frameLength > 0 else { return false }
    guard buffer.format.sampleRate > 0, buffer.format.channelCount > 0 else { return false }
    let abl = UnsafeMutableAudioBufferListPointer(buffer.mutableAudioBufferList)
    if abl.count < 1 { return false }
    for audioBuffer in abl {
      if audioBuffer.mData == nil { return false }
      if audioBuffer.mDataByteSize == 0 { return false }
    }
    return true
  }

  private static func copyBuffer(
    _ buffer: AVAudioPCMBuffer,
    frameLength: AVAudioFrameCount
  ) -> AVAudioPCMBuffer? {
    guard frameLength > 0 else { return nil }
    let frames = min(frameLength, buffer.frameLength)
    guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: frames)
    else { return nil }
    copy.frameLength = frames
    let channels = Int(buffer.format.channelCount)
    if buffer.format.commonFormat == .pcmFormatFloat32,
       let src = buffer.floatChannelData,
       let dst = copy.floatChannelData {
      for c in 0..<channels {
        memcpy(dst[c], src[c], Int(frames) * MemoryLayout<Float>.size)
      }
      return copy
    }
    if buffer.format.commonFormat == .pcmFormatInt16,
       let src = buffer.int16ChannelData,
       let dst = copy.int16ChannelData {
      let bytesPerFrame = buffer.format.isInterleaved
        ? MemoryLayout<Int16>.size * channels
        : MemoryLayout<Int16>.size
      if buffer.format.isInterleaved {
        memcpy(dst[0], src[0], Int(frames) * bytesPerFrame)
      } else {
        for c in 0..<channels {
          memcpy(dst[c], src[c], Int(frames) * MemoryLayout<Int16>.size)
        }
      }
      return copy
    }
    return nil
  }

  private static func convertAudio(from source: URL, to dest: URL, maxSeconds: Double) throws {
    if FileManager.default.fileExists(atPath: dest.path) {
      try FileManager.default.removeItem(at: dest)
    }

    let inputFile: AVAudioFile
    do {
      inputFile = try AVAudioFile(forReading: source)
    } catch {
      let ext = source.pathExtension.lowercased()
      if ["wav", "caf", "aiff", "aif"].contains(ext) {
        try FileManager.default.copyItem(at: source, to: dest)
        return
      }
      throw error
    }

    guard let outFormat = outputFormat() else {
      throw svaError(500, "Unable to create output format")
    }

    let outputFile = try AVAudioFile(
      forWriting: dest,
      settings: outFormat.settings,
      commonFormat: outFormat.commonFormat,
      interleaved: outFormat.isInterleaved
    )

    let maxFrames = AVAudioFramePosition(maxSeconds * outFormat.sampleRate)
    let inputFormat = inputFile.processingFormat
    guard let converter = AVAudioConverter(from: inputFormat, to: outFormat) else {
      throw svaError(501, "Unable to create audio converter")
    }

    NSLog(
      "[SVA-Audio] convert in=%@/%.0fHz/%dch → out=Int16/44100/1ch",
      String(describing: inputFormat.commonFormat.rawValue),
      inputFormat.sampleRate,
      inputFormat.channelCount
    )

    let frameCapacity: AVAudioFrameCount = 4096
    guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: frameCapacity)
    else { throw svaError(500, "Unable to allocate input buffer") }

    var written = AVAudioFramePosition(0)
    while inputFile.framePosition < inputFile.length, written < maxFrames {
      let remainingInput = AVAudioFrameCount(inputFile.length - inputFile.framePosition)
      let readCount = min(frameCapacity, remainingInput)
      do {
        try inputFile.read(into: inputBuffer, frameCount: readCount)
      } catch {
        break
      }
      if inputBuffer.frameLength == 0 { break }

      let ratio = outFormat.sampleRate / max(inputFormat.sampleRate, 1)
      let outCapacity = AVAudioFrameCount(Double(inputBuffer.frameLength) * ratio) + 32
      guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: outCapacity)
      else { break }

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
      switch status {
      case .haveData, .inputRanDry, .endOfStream:
        break
      case .error:
        break
      @unknown default:
        break
      }
      if status == .error { break }
      if outputBuffer.frameLength == 0 { continue }

      let remainingOut = AVAudioFrameCount(maxFrames - written)
      guard let toWrite = copyBuffer(outputBuffer, frameLength: remainingOut) else { continue }
      guard bufferHasValidAudioBytes(toWrite) else { continue }
      guard formatsCompatible(toWrite.format, outputFile.processingFormat) else { continue }
      try outputFile.write(from: toWrite)
      written += AVAudioFramePosition(toWrite.frameLength)
    }

    if written == 0 {
      throw svaError(422, "Converted audio is empty")
    }
  }

  /// Perceived-loudness pipeline: DC remove → RMS make-up → soft compress → limit.
  /// Never mutates system volume. Idempotent when already loud enough.
  static func normalizeLoudness(at url: URL) throws {
    guard let outFormat = outputFormat() else {
      throw svaError(500, "Unable to create output format")
    }
    let input = try AVAudioFile(forReading: url)
    let length = AVAudioFrameCount(input.length)
    guard length > 0 else { throw svaError(422, "Normalize source empty") }

    guard let readBuffer = AVAudioPCMBuffer(pcmFormat: input.processingFormat, frameCapacity: length)
    else { throw svaError(500, "Unable to allocate normalize read buffer") }
    try input.read(into: readBuffer)
    guard readBuffer.frameLength > 0 else { throw svaError(422, "Normalize read empty") }

    let pcm: AVAudioPCMBuffer
    if formatsCompatible(readBuffer.format, outFormat) {
      pcm = readBuffer
    } else {
      guard let converter = AVAudioConverter(from: readBuffer.format, to: outFormat) else {
        throw svaError(501, "Normalize converter unavailable")
      }
      let ratio = outFormat.sampleRate / max(readBuffer.format.sampleRate, 1)
      let capacity = AVAudioFrameCount(Double(readBuffer.frameLength) * ratio) + 32
      guard let converted = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: capacity)
      else { throw svaError(500, "Unable to allocate normalize convert buffer") }
      var gotInput = false
      var convertError: NSError?
      let status = converter.convert(to: converted, error: &convertError) { _, outStatus in
        if gotInput {
          outStatus.pointee = .noDataNow
          return nil
        }
        gotInput = true
        outStatus.pointee = .haveData
        return readBuffer
      }
      if let convertError { throw convertError }
      if status == .error || converted.frameLength == 0 {
        throw svaError(422, "Normalize convert produced no audio")
      }
      pcm = converted
    }

    guard let samples = pcm.int16ChannelData?[0] else {
      throw svaError(422, "Normalize missing Int16 channel data")
    }
    let frames = Int(pcm.frameLength)
    var floats = [Float](repeating: 0, count: frames)
    var mean: Float = 0
    for i in 0..<frames {
      let v = Float(samples[i]) / 32768.0
      floats[i] = v
      mean += v
    }
    mean /= Float(max(frames, 1))
    // Remove DC offset.
    for i in 0..<frames {
      floats[i] -= mean
    }

    let before = measureLoudness(floats)
    NSLog(
      "[SVA-Audio] loudness peakBefore=%.4f rmsBefore=%.4f windowRms=%.4f nearClip=%d frames=%d",
      before.peak,
      before.rms,
      before.windowRms,
      before.nearClipCount,
      frames
    )

    if before.peak <= 0.0001 && before.rms <= 0.0001 {
      throw svaError(422, "Audio is silent")
    }

    // Already loud enough — skip second pass (idempotent).
    if before.rms >= targetRmsLinear * 0.92 && before.peak >= targetPeakLinear * 0.85 {
      NSLog("[SVA-Audio] loudness skip (already processed) peak=%.4f rms=%.4f", before.peak, before.rms)
      return
    }

    // Make-up from RMS (speech body), not only absolute peak.
    let rmsRef = max(before.windowRms, before.rms)
    var gain: Float = 1.0
    if rmsRef > 0.0001 {
      gain = targetRmsLinear / rmsRef
    }
    // Also respect peak headroom so compressor/limiter are not overloaded.
    if before.peak > 0.0001 {
      let peakCap = (targetPeakLinear * 1.15) / before.peak
      if peakCap < gain { gain = peakCap }
    }
    if gain > maxNormalizeGain { gain = maxNormalizeGain }
    if gain < 1.0 { gain = 1.0 }

    var compressedSamples = 0
    var limitedSamples = 0
    for i in 0..<frames {
      var x = floats[i] * gain
      let ax = abs(x)
      if ax > compressorThreshold {
        let over = ax - compressorThreshold
        let compressed = compressorThreshold + over / compressorRatio
        x = (x >= 0 ? 1 : -1) * compressed
        compressedSamples += 1
      }
      // Soft final limiter toward -1 dBFS (no hard clip).
      let peakLimit = targetPeakLinear
      if abs(x) > peakLimit * 0.92 {
        let sign: Float = x >= 0 ? 1 : -1
        let t = abs(x)
        x = sign * (peakLimit * 0.92 + (peakLimit * 0.08) * tanhf((t - peakLimit * 0.92) * 10))
        limitedSamples += 1
      }
      x = max(-0.999, min(0.999, x))
      floats[i] = x
    }

    let after = measureLoudness(floats)
    NSLog(
      "[SVA-Audio] loudness peakAfter=%.4f rmsAfter=%.4f gain=%.2f compressedSamples=%d limitedSamples=%d",
      after.peak,
      after.rms,
      gain,
      compressedSamples,
      limitedSamples
    )

    guard let outBuffer = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: AVAudioFrameCount(frames))
    else { throw svaError(500, "Unable to allocate normalize output buffer") }
    outBuffer.frameLength = AVAudioFrameCount(frames)
    guard let dst = outBuffer.int16ChannelData?[0] else {
      throw svaError(500, "Normalize output channel missing")
    }
    for i in 0..<frames {
      dst[i] = Int16((floats[i] * 32767.0).rounded())
    }

    guard bufferHasValidAudioBytes(outBuffer) else {
      throw svaError(422, "Normalized buffer invalid")
    }

    let normalizedTemp = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_norm_\(UUID().uuidString).caf")
    let outputFile = try AVAudioFile(
      forWriting: normalizedTemp,
      settings: outFormat.settings,
      commonFormat: outFormat.commonFormat,
      interleaved: outFormat.isInterleaved
    )
    try outputFile.write(from: outBuffer)
    try validateRenderedFile(normalizedTemp)
    if FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(at: url)
    }
    try FileManager.default.moveItem(at: normalizedTemp, to: url)
  }

  private struct LoudnessStats {
    var peak: Float
    var rms: Float
    var windowRms: Float
    var nearClipCount: Int
  }

  private static func measureLoudness(_ samples: [Float]) -> LoudnessStats {
    let frames = samples.count
    guard frames > 0 else {
      return LoudnessStats(peak: 0, rms: 0, windowRms: 0, nearClipCount: 0)
    }
    var peak: Float = 0
    var sumSquares: Float = 0
    var nearClip = 0
    for v in samples {
      let a = abs(v)
      if a > peak { peak = a }
      sumSquares += a * a
      if a >= 0.98 { nearClip += 1 }
    }
    let rms = sqrtf(sumSquares / Float(frames))
    let window = max(1, Int(44100.0 * windowMs / 1000.0))
    var bestWindow: Float = 0
    var i = 0
    while i < frames {
      let end = min(frames, i + window)
      var wSum: Float = 0
      let count = end - i
      for j in i..<end {
        let a = abs(samples[j])
        wSum += a * a
      }
      let wRms = count > 0 ? sqrtf(wSum / Float(count)) : 0
      if wRms > bestWindow { bestWindow = wRms }
      i += window
    }
    return LoudnessStats(peak: peak, rms: rms, windowRms: bestWindow, nearClipCount: nearClip)
  }

  /// Transparent peak limiter for ringtone — never applies speech RMS make-up.
  static func processRingtoneAudio(at url: URL) throws -> [String: Any] {
    guard let outFormat = outputFormat() else {
      throw svaError(500, "Unable to create output format")
    }
    let pcm = try readAsInt16Mono(url: url, outFormat: outFormat)
    guard let samples = pcm.int16ChannelData?[0] else {
      throw svaError(422, "Ringtone missing Int16 channel")
    }
    let frames = Int(pcm.frameLength)
    var floats = [Float](repeating: 0, count: frames)
    for i in 0..<frames {
      floats[i] = Float(samples[i]) / 32768.0
    }
    let before = measureLoudness(floats)
    if before.peak <= 0.0001 && before.rms <= 0.0001 {
      throw svaError(422, "Ringtone audio is silent")
    }

    var gain: Float = 1.0
    var limited = 0
    if before.peak > SvaRingtoneAudioConfig.peakLimitLinear {
      gain = SvaRingtoneAudioConfig.peakLimitLinear / before.peak
      for i in 0..<frames {
        floats[i] *= gain
      }
      limited = frames
    }
    // Soft ceiling only — no make-up.
    for i in 0..<frames {
      var x = floats[i]
      if abs(x) > SvaRingtoneAudioConfig.peakLimitLinear {
        let sign: Float = x >= 0 ? 1 : -1
        x = sign * SvaRingtoneAudioConfig.peakLimitLinear
        limited += 1
      }
      floats[i] = max(-0.999, min(0.999, x))
    }
    let after = measureLoudness(floats)
    try writeInt16Mono(floats: floats, to: url, format: outFormat)
    NSLog(
      "[SVA-Audio] ringtonePeakOnly peakBefore=%.4f peakAfter=%.4f rmsBefore=%.4f rmsAfter=%.4f gain=%.3f limited=%d",
      before.peak,
      after.peak,
      before.rms,
      after.rms,
      gain,
      limited
    )
    return [
      "ringtonePeakBefore": before.peak,
      "ringtonePeakAfter": after.peak,
      "ringtoneRmsBefore": before.rms,
      "ringtoneRmsAfter": after.rms,
      "ringtoneGain": gain,
      "ringtoneSpeechNormalize": false,
    ]
  }

  /// Fit ringtone content to exact duration with seamless crossfade loops (not modulo).
  @discardableResult
  static func fitRingtoneToExactDuration(
    at url: URL,
    targetSeconds: Double
  ) throws -> [String: Any] {
    guard targetSeconds > 0 else { return [:] }
    guard let outFormat = outputFormat() else {
      throw svaError(500, "Unable to create output format")
    }
    let targetFrames = Int((targetSeconds * outFormat.sampleRate).rounded())
    guard targetFrames > 0 else { throw svaError(422, "Target duration invalid") }

    let pcm = try readAsInt16Mono(url: url, outFormat: outFormat)
    guard let srcPtr = pcm.int16ChannelData?[0] else {
      throw svaError(422, "Ringtone fit missing channel")
    }
    let srcFrames = Int(pcm.frameLength)
    guard srcFrames > 0 else { throw svaError(422, "Source empty for ringtone fit") }

    var src = [Int16](repeating: 0, count: srcFrames)
    for i in 0..<srcFrames { src[i] = srcPtr[i] }

    let crossfade = min(
      SvaRingtoneAudioConfig.crossfadeFrames,
      max(1, srcFrames / 4)
    )
    let fadeIn = min(SvaRingtoneAudioConfig.fadeInFrames, srcFrames / 8)
    let fadeOut = min(SvaRingtoneAudioConfig.fadeOutFrames, targetFrames / 8)

    let moduloDelta = Self.moduloLoopMaxBoundaryDelta(
      source: src,
      targetFrames: targetFrames
    )

    let built: [Int16]
    let loopCount: Int
    if srcFrames >= targetFrames {
      built = trimRingtoneNearZeroCrossing(source: src, targetFrames: targetFrames)
      loopCount = 1
    } else {
      built = loopRingtoneWithCrossfade(
        source: src,
        targetFrames: targetFrames,
        crossfadeFrames: crossfade
      )
      loopCount = max(1, Int(ceil(Double(targetFrames) / Double(max(srcFrames - crossfade, 1)))))
    }

    var out = built
    applyFadeInIfNeeded(&out, fadeFrames: fadeIn)
    applyFadeOut(&out, fadeFrames: fadeOut)

    let crossDelta = Self.crossfadeLoopMaxBoundaryDelta(
      output: out,
      sourceFrames: srcFrames,
      crossfadeFrames: crossfade
    )

    // Ensure no Int16 overflow / hard clip.
    var clipCount = 0
    var peak: Int = 0
    for i in 0..<out.count {
      let a = abs(Int(out[i]))
      if a > peak { peak = a }
      if a >= 32767 { clipCount += 1 }
    }

    try writeInt16Samples(out, to: url, format: outFormat)
    let duration = Double(out.count) / outFormat.sampleRate
    NSLog(
      "[SVA-Audio] fitRingtone target=%.2fs frames=%d src=%d loops≈%d xfade=%d moduloDelta=%d crossDelta=%d peak=%d clip=%d",
      targetSeconds,
      out.count,
      srcFrames,
      loopCount,
      crossfade,
      moduloDelta,
      crossDelta,
      peak,
      clipCount
    )
    guard abs(duration - targetSeconds) <= (2.0 / outFormat.sampleRate) + 0.001 else {
      throw svaError(422, "Ringtone fit duration mismatch")
    }
    return [
      "loopCount": loopCount,
      "crossfadeFrames": crossfade,
      "fadeInFrames": fadeIn,
      "fadeOutFrames": fadeOut,
      "moduloBoundaryDelta": moduloDelta,
      "maxBoundaryDiscontinuity": crossDelta,
      "ringtoneClipCount": clipCount,
      "ringtonePeakInt16": peak,
      "contentFrames": out.count,
    ]
  }

  /// Legacy modulo discontinuity metric (for regression tests).
  static func moduloLoopMaxBoundaryDelta(source: [Int16], targetFrames: Int) -> Int {
    let n = source.count
    guard n > 1, targetFrames > n else {
      return n > 0 ? abs(Int(source[n - 1]) - Int(source[0])) : 0
    }
    var maxDelta = 0
    var i = n
    while i < targetFrames {
      let delta = abs(Int(source[n - 1]) - Int(source[0]))
      if delta > maxDelta { maxDelta = delta }
      // Also compare adjacent modulo samples around the wrap.
      let prev = source[(i - 1) % n]
      let next = source[i % n]
      let jump = abs(Int(next) - Int(prev))
      if jump > maxDelta { maxDelta = jump }
      i += n
    }
    return maxDelta
  }

  /// Approx discontinuity at loop junctions after seamless build (samples near period edges).
  static func crossfadeLoopMaxBoundaryDelta(
    output: [Int16],
    sourceFrames: Int,
    crossfadeFrames: Int
  ) -> Int {
    let n = sourceFrames
    let x = max(1, crossfadeFrames)
    guard output.count > n, n > x * 2 else { return 0 }
    var maxDelta = 0
    var boundary = n
    // After first period, each net advance is (n - x).
    let strideLen = max(1, n - x)
    while boundary < output.count {
      let idx = boundary - 1
      if idx + 1 < output.count {
        let jump = abs(Int(output[idx + 1]) - Int(output[idx]))
        if jump > maxDelta { maxDelta = jump }
      }
      // Mid-crossfade region should be smooth — sample step at center of blend window.
      let mid = boundary - x / 2
      if mid > 0, mid + 1 < output.count {
        let jump = abs(Int(output[mid + 1]) - Int(output[mid]))
        if jump > maxDelta { maxDelta = jump }
      }
      boundary += strideLen
    }
    return maxDelta
  }

  static func loopRingtoneWithCrossfade(
    source: [Int16],
    targetFrames: Int,
    crossfadeFrames: Int
  ) -> [Int16] {
    let n = source.count
    guard n > 0, targetFrames > 0 else { return [] }
    var out = [Int16](repeating: 0, count: targetFrames)
    let x = min(crossfadeFrames, max(1, n / 4))

    let first = min(n, targetFrames)
    for i in 0..<first { out[i] = source[i] }
    var filled = first

    while filled < targetFrames {
      let remaining = targetFrames - filled
      let blend = min(x, filled, remaining, n)
      for i in 0..<blend {
        let t = Float(i + 1) / Float(blend + 1)
        // Equal-power crossfade.
        let gOut = cosf(t * Float.pi / 2)
        let gIn = sinf(t * Float.pi / 2)
        let a = Float(out[filled - blend + i]) / 32768.0
        let b = Float(source[i]) / 32768.0
        let mixed = a * gOut + b * gIn
        let clamped = max(-0.999, min(0.999, mixed))
        out[filled - blend + i] = Int16((clamped * 32767.0).rounded())
      }
      let copyStart = blend
      let copyLen = min(n - copyStart, remaining)
      guard copyLen > 0 else { break }
      for i in 0..<copyLen {
        out[filled + i] = source[copyStart + i]
      }
      filled += copyLen
    }
    return out
  }

  private static func trimRingtoneNearZeroCrossing(
    source: [Int16],
    targetFrames: Int
  ) -> [Int16] {
    let n = source.count
    guard targetFrames > 0 else { return [] }
    if n <= targetFrames {
      return Array(source.prefix(targetFrames))
    }
    // Search last ~5ms window before target for a near-zero sample.
    let window = min(220, targetFrames / 4, n)
    var cut = targetFrames
    var bestAbs = Int.max
    let startSearch = max(0, targetFrames - window)
    for i in startSearch..<targetFrames {
      let a = abs(Int(source[i]))
      if a < bestAbs {
        bestAbs = a
        cut = i + 1
      }
    }
    cut = min(max(cut, 1), targetFrames)
    var out = Array(source.prefix(cut))
    if out.count < targetFrames {
      out.append(contentsOf: repeatElement(Int16(0), count: targetFrames - out.count))
    } else if out.count > targetFrames {
      out = Array(out.prefix(targetFrames))
    }
    return out
  }

  private static func applyFadeInIfNeeded(_ samples: inout [Int16], fadeFrames: Int) {
    guard !samples.isEmpty, fadeFrames > 0 else { return }
    if abs(Int(samples[0])) < 200 { return }
    let n = min(fadeFrames, samples.count)
    for i in 0..<n {
      let g = Float(i) / Float(n)
      let v = Float(samples[i]) / 32768.0 * g
      samples[i] = Int16((max(-0.999, min(0.999, v)) * 32767.0).rounded())
    }
  }

  private static func applyFadeOut(_ samples: inout [Int16], fadeFrames: Int) {
    guard !samples.isEmpty, fadeFrames > 0 else { return }
    let n = min(fadeFrames, samples.count)
    let start = samples.count - n
    for i in 0..<n {
      let g = 1.0 - Float(i + 1) / Float(n)
      let v = Float(samples[start + i]) / 32768.0 * g
      samples[start + i] = Int16((max(-0.999, min(0.999, v)) * 32767.0).rounded())
    }
  }

  private static func readAsInt16Mono(
    url: URL,
    outFormat: AVAudioFormat
  ) throws -> AVAudioPCMBuffer {
    let input = try AVAudioFile(forReading: url)
    let srcFormat = input.processingFormat
    let srcLength = AVAudioFrameCount(input.length)
    guard srcLength > 0 else { throw svaError(422, "Source empty") }
    guard let srcBuffer = AVAudioPCMBuffer(pcmFormat: srcFormat, frameCapacity: srcLength)
    else { throw svaError(500, "read buffer alloc failed") }
    try input.read(into: srcBuffer)
    if formatsCompatible(srcBuffer.format, outFormat) {
      return srcBuffer
    }
    guard let converter = AVAudioConverter(from: srcBuffer.format, to: outFormat) else {
      throw svaError(501, "converter unavailable")
    }
    let ratio = outFormat.sampleRate / max(srcBuffer.format.sampleRate, 1)
    let capacity = AVAudioFrameCount(Double(srcBuffer.frameLength) * ratio) + 32
    guard let converted = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: capacity)
    else { throw svaError(500, "convert buffer failed") }
    var gotInput = false
    var convertError: NSError?
    let status = converter.convert(to: converted, error: &convertError) { _, outStatus in
      if gotInput {
        outStatus.pointee = .noDataNow
        return nil
      }
      gotInput = true
      outStatus.pointee = .haveData
      return srcBuffer
    }
    if let convertError { throw convertError }
    if status == .error || converted.frameLength == 0 {
      throw svaError(422, "convert produced no audio")
    }
    return converted
  }

  private static func writeInt16Mono(
    floats: [Float],
    to url: URL,
    format: AVAudioFormat
  ) throws {
    let frames = floats.count
    guard let outBuffer = AVAudioPCMBuffer(
      pcmFormat: format,
      frameCapacity: AVAudioFrameCount(frames)
    ),
      let dst = outBuffer.int16ChannelData?[0]
    else { throw svaError(500, "write buffer failed") }
    outBuffer.frameLength = AVAudioFrameCount(frames)
    for i in 0..<frames {
      dst[i] = Int16((floats[i] * 32767.0).rounded())
    }
    try writeBuffer(outBuffer, to: url, format: format)
  }

  private static func writeInt16Samples(
    _ samples: [Int16],
    to url: URL,
    format: AVAudioFormat
  ) throws {
    let frames = samples.count
    guard let outBuffer = AVAudioPCMBuffer(
      pcmFormat: format,
      frameCapacity: AVAudioFrameCount(frames)
    ),
      let dst = outBuffer.int16ChannelData?[0]
    else { throw svaError(500, "write samples failed") }
    outBuffer.frameLength = AVAudioFrameCount(frames)
    for i in 0..<frames { dst[i] = samples[i] }
    try writeBuffer(outBuffer, to: url, format: format)
  }

  private static func writeBuffer(
    _ buffer: AVAudioPCMBuffer,
    to url: URL,
    format: AVAudioFormat
  ) throws {
    let temp = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_write_\(UUID().uuidString).caf")
    let outputFile = try AVAudioFile(
      forWriting: temp,
      settings: format.settings,
      commonFormat: format.commonFormat,
      interleaved: format.isInterleaved
    )
    try outputFile.write(from: buffer)
    if FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(at: url)
    }
    try FileManager.default.moveItem(at: temp, to: url)
  }

  private static func measureFileLoudness(url: URL) throws -> LoudnessStats {
    guard let format = outputFormat() else {
      return LoudnessStats(peak: 0, rms: 0, windowRms: 0, nearClipCount: 0)
    }
    let pcm = try readAsInt16Mono(url: url, outFormat: format)
    guard let samples = pcm.int16ChannelData?[0] else {
      return LoudnessStats(peak: 0, rms: 0, windowRms: 0, nearClipCount: 0)
    }
    let frames = Int(pcm.frameLength)
    var floats = [Float](repeating: 0, count: frames)
    for i in 0..<frames {
      floats[i] = Float(samples[i]) / 32768.0
    }
    return measureLoudness(floats)
  }

  /// Trim or loop PCM CAF so duration equals [targetSeconds] (±1 frame).
  /// Legacy modulo loop — kept for speech callers / regression comparison only.
  static func fitToExactDuration(at url: URL, targetSeconds: Double) throws {
    guard targetSeconds > 0 else { return }
    guard let outFormat = outputFormat() else {
      throw svaError(500, "Unable to create output format")
    }
    let input = try AVAudioFile(forReading: url)
    let targetFrames = AVAudioFrameCount(targetSeconds * outFormat.sampleRate)
    guard targetFrames > 0 else { throw svaError(422, "Target duration invalid") }

    let srcFormat = input.processingFormat
    let srcLength = AVAudioFrameCount(input.length)
    guard srcLength > 0 else { throw svaError(422, "Source empty for fit") }

    guard let srcBuffer = AVAudioPCMBuffer(pcmFormat: srcFormat, frameCapacity: srcLength)
    else { throw svaError(500, "fit buffer alloc failed") }
    try input.read(into: srcBuffer)

    let pcm: AVAudioPCMBuffer
    if formatsCompatible(srcBuffer.format, outFormat) {
      pcm = srcBuffer
    } else {
      guard let converter = AVAudioConverter(from: srcBuffer.format, to: outFormat) else {
        throw svaError(501, "fit converter unavailable")
      }
      let ratio = outFormat.sampleRate / max(srcBuffer.format.sampleRate, 1)
      let capacity = AVAudioFrameCount(Double(srcBuffer.frameLength) * ratio) + 32
      guard let converted = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: capacity)
      else { throw svaError(500, "fit convert buffer failed") }
      var gotInput = false
      var convertError: NSError?
      let status = converter.convert(to: converted, error: &convertError) { _, outStatus in
        if gotInput {
          outStatus.pointee = .noDataNow
          return nil
        }
        gotInput = true
        outStatus.pointee = .haveData
        return srcBuffer
      }
      if let convertError { throw convertError }
      if status == .error || converted.frameLength == 0 {
        throw svaError(422, "fit convert produced no audio")
      }
      pcm = converted
    }

    guard let outBuffer = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: targetFrames),
          let src = pcm.int16ChannelData?[0],
          let dst = outBuffer.int16ChannelData?[0]
    else { throw svaError(500, "fit output channel missing") }
    outBuffer.frameLength = targetFrames
    let srcFrames = Int(pcm.frameLength)
    let dstFrames = Int(targetFrames)
    for i in 0..<dstFrames {
      dst[i] = src[i % srcFrames]
    }

    let temp = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_fit_\(UUID().uuidString).caf")
    let outputFile = try AVAudioFile(
      forWriting: temp,
      settings: outFormat.settings,
      commonFormat: outFormat.commonFormat,
      interleaved: outFormat.isInterleaved
    )
    try outputFile.write(from: outBuffer)
    if FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(at: url)
    }
    try FileManager.default.moveItem(at: temp, to: url)
    NSLog("[SVA-Audio] fitToExactDuration target=%.2fs frames=%d", targetSeconds, dstFrames)
  }

  /// Append linear PCM silence after existing content. Returns trailing silence ms.
  static func appendTrailingSilence(at url: URL, silenceSeconds: Double) throws -> Int {
    guard silenceSeconds > 0 else { return 0 }
    guard let outFormat = outputFormat() else {
      throw svaError(500, "Unable to create output format")
    }
    let input = try AVAudioFile(forReading: url)
    let srcFormat = input.processingFormat
    let srcLength = AVAudioFrameCount(input.length)
    guard srcLength > 0 else { throw svaError(422, "Source empty for trailing silence") }

    guard let srcBuffer = AVAudioPCMBuffer(pcmFormat: srcFormat, frameCapacity: srcLength)
    else { throw svaError(500, "trail buffer alloc failed") }
    try input.read(into: srcBuffer)

    let pcm: AVAudioPCMBuffer
    if formatsCompatible(srcBuffer.format, outFormat) {
      pcm = srcBuffer
    } else {
      guard let converter = AVAudioConverter(from: srcBuffer.format, to: outFormat) else {
        throw svaError(501, "trail converter unavailable")
      }
      let ratio = outFormat.sampleRate / max(srcBuffer.format.sampleRate, 1)
      let capacity = AVAudioFrameCount(Double(srcBuffer.frameLength) * ratio) + 32
      guard let converted = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: capacity)
      else { throw svaError(500, "trail convert buffer failed") }
      var gotInput = false
      var convertError: NSError?
      let status = converter.convert(to: converted, error: &convertError) { _, outStatus in
        if gotInput {
          outStatus.pointee = .noDataNow
          return nil
        }
        gotInput = true
        outStatus.pointee = .haveData
        return srcBuffer
      }
      if let convertError { throw convertError }
      if status == .error || converted.frameLength == 0 {
        throw svaError(422, "trail convert produced no audio")
      }
      pcm = converted
    }

    let silenceFrames = AVAudioFrameCount(silenceSeconds * outFormat.sampleRate)
    guard silenceFrames > 0 else { return 0 }
    let totalFrames = pcm.frameLength + silenceFrames
    guard let outBuffer = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: totalFrames),
          let src = pcm.int16ChannelData?[0],
          let dst = outBuffer.int16ChannelData?[0]
    else { throw svaError(500, "trail output channel missing") }
    outBuffer.frameLength = totalFrames
    let contentFrames = Int(pcm.frameLength)
    let total = Int(totalFrames)
    for i in 0..<contentFrames {
      dst[i] = src[i]
    }
    for i in contentFrames..<total {
      dst[i] = 0
    }

    let temp = FileManager.default.temporaryDirectory
      .appendingPathComponent("sva_trail_\(UUID().uuidString).caf")
    let outputFile = try AVAudioFile(
      forWriting: temp,
      settings: outFormat.settings,
      commonFormat: outFormat.commonFormat,
      interleaved: outFormat.isInterleaved
    )
    try outputFile.write(from: outBuffer)
    if FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(at: url)
    }
    try FileManager.default.moveItem(at: temp, to: url)
    let trailingMs = Int((Double(silenceFrames) / outFormat.sampleRate * 1000).rounded())
    NSLog(
      "[SVA-Audio] appendTrailingSilence silenceSec=%.3f trailMs=%d totalFrames=%d",
      silenceSeconds,
      trailingMs,
      total
    )
    return trailingMs
  }

  private static func formatsCompatible(_ a: AVAudioFormat, _ b: AVAudioFormat) -> Bool {
    a.commonFormat == b.commonFormat
      && abs(a.sampleRate - b.sampleRate) < 0.5
      && a.channelCount == b.channelCount
      && a.isInterleaved == b.isInterleaved
  }

  private static func validateRenderedFile(_ url: URL) throws {
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), !isDir.boolValue
    else { throw svaError(422, "Rendered file missing") }
    let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
    let size = (attrs[.size] as? NSNumber)?.intValue ?? 0
    guard size > 0 else { throw svaError(422, "Rendered file empty") }
    let file = try AVAudioFile(forReading: url)
    guard file.length > 0 else { throw svaError(422, "Rendered file length 0") }
    let duration = try measureDuration(url: url)
    guard duration.isFinite, duration > 0 else { throw svaError(422, "Rendered duration invalid") }
  }

  private static func measureDuration(url: URL) throws -> Double {
    let file = try AVAudioFile(forReading: url)
    let rate = file.processingFormat.sampleRate
    if rate <= 0 { return 0 }
    return Double(file.length) / rate
  }

  /// Debug-only fingerprint so preview vs schedule can prove same CAF bytes.
  private static func debugFileHash(_ url: URL) throws -> String {
    let data = try Data(contentsOf: url)
    let digest = SHA256.hash(data: data)
    return digest.prefix(8).map { String(format: "%02x", $0) }.joined()
  }
}

// MARK: - Serial TTS operation

/// Owns a single AVSpeechSynthesizer for the duration of one write session.
/// Continuations resume exactly once. Operations are serialized and strongly retained.
final class SvaTtsRenderService {
  static let shared = SvaTtsRenderService()

  private let queue = DispatchQueue(label: "com.smartvoicealarm.tts")
  /// Strong retention for the in-flight operation (must not be a local-only variable).
  private var currentOperation: SvaTtsOperation?
  private var waiters: [() -> Void] = []

  func render(
    text: String,
    locale: String?,
    to dest: URL,
    maxSeconds: Double
  ) async throws {
    try await withCheckedThrowingContinuation { (outer: CheckedContinuation<Void, Error>) in
      queue.async {
        let startNext: () -> Void = { [weak self] in
          guard let self else {
            outer.resume(throwing: NSError(
              domain: "SvaAudioRenderer",
              code: 500,
              userInfo: [NSLocalizedDescriptionKey: "TTS service deallocated"]
            ))
            return
          }
          let op = SvaTtsOperation(
            text: text,
            locale: locale,
            dest: dest,
            maxSeconds: maxSeconds
          )
          self.currentOperation = op
          op.run { [weak self] result in
            // Completion is never invoked while holding the operation lock.
            guard let self else {
              switch result {
              case .success:
                outer.resume()
              case .failure(let error):
                outer.resume(throwing: error)
              }
              return
            }
            self.queue.async {
              self.currentOperation = nil
              switch result {
              case .success:
                outer.resume()
              case .failure(let error):
                outer.resume(throwing: error)
              }
              if !self.waiters.isEmpty {
                let next = self.waiters.removeFirst()
                next()
              }
            }
          }
        }

        if self.currentOperation != nil {
          self.waiters.append(startNext)
        } else {
          startNext()
        }
      }
    }
  }
}

private final class SvaTtsOperation {
  private let text: String
  private let locale: String?
  private let dest: URL
  private let maxSeconds: Double
  private let synthesizer = AVSpeechSynthesizer()
  private let workQueue = DispatchQueue(label: "com.smartvoicealarm.tts.op")
  private var finished = false
  private var timeoutWork: DispatchWorkItem?
  private var outputFile: AVAudioFile?
  private var converter: AVAudioConverter?
  private var lastInputFormatDescription: String = ""
  private var outFormat: AVAudioFormat?
  private var writtenFrames: AVAudioFrameCount = 0
  private var completion: ((Result<Void, Error>) -> Void)?

  init(text: String, locale: String?, dest: URL, maxSeconds: Double) {
    self.text = text
    self.locale = locale
    self.dest = dest
    self.maxSeconds = maxSeconds
  }

  func run(completion: @escaping (Result<Void, Error>) -> Void) {
    self.completion = completion
    if FileManager.default.fileExists(atPath: dest.path) {
      try? FileManager.default.removeItem(at: dest)
    }

    guard let format = SvaAudioRenderer.outputFormat() else {
      finishOnce(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "TTS output format unavailable"]
      )))
      return
    }
    outFormat = format

    do {
      outputFile = try AVAudioFile(
        forWriting: dest,
        settings: format.settings,
        commonFormat: format.commonFormat,
        interleaved: format.isInterleaved
      )
    } catch {
      finishOnce(.failure(error))
      return
    }

    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = resolveVoice(locale: locale)
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    // Slightly higher volume in the utterance domain (0...1). Does not change system volume.
    utterance.volume = 1.0

    let timeout = DispatchWorkItem { [weak self] in
      self?.handleTimeout()
    }
    timeoutWork = timeout
    DispatchQueue.global().asyncAfter(deadline: .now() + 30, execute: timeout)

    // Strongly capture self so the operation (and synthesizer) survive until EOS/error/timeout.
    synthesizer.write(utterance) { [weak self] buffer in
      guard let self else { return }
      self.workQueue.async {
        self.handleBuffer(buffer)
      }
    }
  }

  private func resolveVoice(locale: String?) -> AVSpeechSynthesisVoice? {
    guard let locale, !locale.isEmpty else {
      let fallback = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        ?? AVSpeechSynthesisVoice.speechVoices().first
      NSLog("[SVA-Audio] TTS voice device default=%@", fallback?.language ?? "nil")
      return fallback
    }
    let normalized = locale.replacingOccurrences(of: "_", with: "-")
    if let exact = AVSpeechSynthesisVoice(language: normalized) {
      NSLog("[SVA-Audio] TTS voice exact locale=%@", normalized)
      return exact
    }
    let lang = String(normalized.prefix(2))
    if lang.count == 2, let byLang = AVSpeechSynthesisVoice(language: lang) {
      NSLog("[SVA-Audio] TTS voice language fallback %@ → %@", normalized, lang)
      return byLang
    }
    let device = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
      ?? AVSpeechSynthesisVoice.speechVoices().first
    NSLog(
      "[SVA-Audio] TTS voice locale missing %@ — using device default %@",
      normalized,
      device?.language ?? "nil"
    )
    return device
  }

  private func handleBuffer(_ buffer: AVAudioBuffer?) {
    guard !finished else { return }

    guard let pcm = buffer as? AVAudioPCMBuffer else { return }

    // End of stream.
    if pcm.frameLength == 0 {
      finalizeStream()
      return
    }

    guard let outFormat, let outputFile else { return }
    let maxFrames = AVAudioFrameCount(maxSeconds * outFormat.sampleRate)
    if writtenFrames >= maxFrames {
      finalizeStream()
      return
    }

    let formatKey =
      "\(pcm.format.commonFormat.rawValue)|\(pcm.format.sampleRate)|\(pcm.format.channelCount)|\(pcm.format.isInterleaved)"
    if converter == nil || formatKey != lastInputFormatDescription {
      converter = AVAudioConverter(from: pcm.format, to: outFormat)
      lastInputFormatDescription = formatKey
      NSLog(
        "[SVA-Audio] TTS buffer format=%@/%.0fHz/%dch interleaved=%d",
        String(describing: pcm.format.commonFormat.rawValue),
        pcm.format.sampleRate,
        pcm.format.channelCount,
        pcm.format.isInterleaved ? 1 : 0
      )
    }
    guard let converter else {
      finishOnce(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 501,
        userInfo: [NSLocalizedDescriptionKey: "TTS converter unavailable for buffer format"]
      )))
      return
    }

    let ratio = outFormat.sampleRate / max(pcm.format.sampleRate, 1)
    let outCapacity = AVAudioFrameCount(Double(pcm.frameLength) * ratio) + 32
    guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: outCapacity)
    else { return }

    var gotInput = false
    var convertError: NSError?
    let status = converter.convert(to: outputBuffer, error: &convertError) { _, outStatus in
      if gotInput {
        outStatus.pointee = .noDataNow
        return nil
      }
      gotInput = true
      outStatus.pointee = .haveData
      return pcm
    }
    if let convertError {
      finishOnce(.failure(convertError))
      return
    }
    if status == .error {
      finishOnce(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 502,
        userInfo: [NSLocalizedDescriptionKey: "TTS convert status error"]
      )))
      return
    }
    if outputBuffer.frameLength == 0 {
      // No data this callback — wait for more or EOS.
      return
    }

    let remaining = maxFrames - writtenFrames
    let frames = min(remaining, outputBuffer.frameLength)
    guard frames > 0 else { return }
    guard let sliced = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: frames)
    else { return }
    sliced.frameLength = frames
    guard let src = outputBuffer.int16ChannelData, let dst = sliced.int16ChannelData else {
      finishOnce(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 422,
        userInfo: [NSLocalizedDescriptionKey: "TTS Int16 channel data missing"]
      )))
      return
    }
    memcpy(dst[0], src[0], Int(frames) * MemoryLayout<Int16>.size)

    let abl = UnsafeMutableAudioBufferListPointer(sliced.mutableAudioBufferList)
    for audioBuffer in abl {
      if audioBuffer.mData == nil || audioBuffer.mDataByteSize == 0 {
        finishOnce(.failure(NSError(
          domain: "SvaAudioRenderer",
          code: 422,
          userInfo: [NSLocalizedDescriptionKey: "TTS buffer has empty AudioBuffer"]
        )))
        return
      }
    }

    do {
      try outputFile.write(from: sliced)
      writtenFrames += frames
      if writtenFrames >= maxFrames {
        synthesizer.stopSpeaking(at: .immediate)
        finalizeStream()
      }
    } catch {
      finishOnce(.failure(error))
    }
  }

  private func finalizeStream() {
    guard !finished else { return }
    // Release file handle before caller validates/normalizes.
    outputFile = nil
    converter = nil
    if writtenFrames == 0 {
      try? FileManager.default.removeItem(at: dest)
      finishOnce(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 423,
        userInfo: [NSLocalizedDescriptionKey: "TTS produced no audio"]
      )))
      return
    }
    finishOnce(.success(()))
  }

  private func handleTimeout() {
    workQueue.async { [weak self] in
      guard let self else { return }
      guard !self.finished else { return }
      self.synthesizer.stopSpeaking(at: .immediate)
      try? FileManager.default.removeItem(at: self.dest)
      self.finishOnce(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 408,
        userInfo: [NSLocalizedDescriptionKey: "TTS render timed out"]
      )))
    }
  }

  private func finishOnce(_ result: Result<Void, Error>) {
    // Serialize all terminal transitions on workQueue. Completion is never
    // invoked while holding an NSLock.
    workQueue.async { [weak self] in
      guard let self else { return }
      guard !self.finished else { return }
      self.finished = true
      self.timeoutWork?.cancel()
      self.timeoutWork = nil
      self.outputFile = nil
      self.converter = nil
      let cb = self.completion
      self.completion = nil
      cb?(result)
    }
  }

  deinit {
    timeoutWork?.cancel()
  }
}

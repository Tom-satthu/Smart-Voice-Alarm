import AVFoundation
import Foundation

/// Renders recordings / TTS / ringtone assets into Library/Sounds as Linear PCM CAF.
///
/// Hard rules:
/// - No force unwrap / fatalError / try! in production paths.
/// - Never write a PCM buffer whose AudioBufferList has mData == nil or mDataByteSize == 0.
/// - TTS synthesizer is owned by a serial operation until end/error/timeout.
enum SvaAudioRenderer {
  private static let queue = DispatchQueue(label: "com.smartvoicealarm.audio.render")

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
    maxSeconds: Double
  ) async throws -> [String: Any] {
    NSLog("[SVA-Audio] render begin file=%@ tts=%d path=%d asset=%d",
          fileName,
          (ttsText?.isEmpty == false) ? 1 : 0,
          (sourcePath?.isEmpty == false) ? 1 : 0,
          (assetKey?.isEmpty == false) ? 1 : 0)

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

      try validateRenderedFile(temp)
      if FileManager.default.fileExists(atPath: dest.path) {
        try FileManager.default.removeItem(at: dest)
      }
      try FileManager.default.moveItem(at: temp, to: dest)
      let duration = try measureDuration(url: dest)
      NSLog("[SVA-Audio] render ok file=%@ durationMs=%d", fileName, Int(duration * 1000))
      return [
        "fileName": fileName,
        "path": dest.path,
        "durationMs": Int((duration * 1000).rounded()),
      ]
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
    guard !activeFileNames.isEmpty else {
      NSLog("[SVA-Audio] cleanupOrphans skipped — empty active set")
      return
    }
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

  // MARK: - Helpers

  private static func svaError(_ code: Int, _ message: String) -> NSError {
    NSError(
      domain: "SvaAudioRenderer",
      code: code,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
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
    if let src = buffer.floatChannelData, let dst = copy.floatChannelData {
      for c in 0..<channels {
        memcpy(dst[c], src[c], Int(frames) * MemoryLayout<Float>.size)
      }
      return copy
    }
    if let src = buffer.int16ChannelData, let dst = copy.int16ChannelData {
      for c in 0..<channels {
        memcpy(dst[c], src[c], Int(frames) * MemoryLayout<Int16>.size)
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
}

// MARK: - Serial TTS operation

/// Owns a single AVSpeechSynthesizer for the duration of one write session.
/// Continuations resume exactly once. Operations are serialized.
final class SvaTtsRenderService {
  static let shared = SvaTtsRenderService()

  private let queue = DispatchQueue(label: "com.smartvoicealarm.tts")
  private var busy = false
  private var waiters: [() -> Void] = []

  func render(
    text: String,
    locale: String?,
    to dest: URL,
    maxSeconds: Double
  ) async throws {
    try await withCheckedThrowingContinuation { (outer: CheckedContinuation<Void, Error>) in
      queue.async {
        let run = { [weak self] in
          guard let self else {
            outer.resume(throwing: NSError(
              domain: "SvaAudioRenderer",
              code: 500,
              userInfo: [NSLocalizedDescriptionKey: "TTS service deallocated"]
            ))
            return
          }
          self.busy = true
          let op = SvaTtsOperation(
            text: text,
            locale: locale,
            dest: dest,
            maxSeconds: maxSeconds
          )
          op.run { result in
            self.queue.async {
              self.busy = false
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
        if self.busy {
          self.waiters.append(run)
        } else {
          run()
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
  private var finished = false
  private var timeoutWork: DispatchWorkItem?
  private let lock = NSLock()
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
      finish(.failure(NSError(
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
      finish(.failure(error))
      return
    }

    let utterance = AVSpeechUtterance(string: text)
    if let locale, !locale.isEmpty {
      let normalized = locale.replacingOccurrences(of: "_", with: "-")
      utterance.voice = AVSpeechSynthesisVoice(language: normalized)
        ?? AVSpeechSynthesisVoice(language: String(normalized.prefix(2)))
    }
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate

    let timeout = DispatchWorkItem { [weak self] in
      self?.handleTimeout()
    }
    timeoutWork = timeout
    DispatchQueue.global().asyncAfter(deadline: .now() + 30, execute: timeout)

    // Retain self via synthesizer callback chain until finish().
    synthesizer.write(utterance) { [weak self] buffer in
      self?.handleBuffer(buffer)
    }
  }

  private func handleBuffer(_ buffer: AVAudioBuffer?) {
    lock.lock()
    defer { lock.unlock() }
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

    // Ensure converter matches THIS buffer's format (do not assume first buffer).
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
    guard let converter else { return }

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
    if convertError != nil || status == .error { return }
    if outputBuffer.frameLength == 0 { return }

    let remaining = maxFrames - writtenFrames
    // Never mutate converter output frameLength in place — copy a sliced buffer.
    let channels = Int(outFormat.channelCount)
    let frames = min(remaining, outputBuffer.frameLength)
    guard frames > 0 else { return }
    guard let sliced = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: frames)
    else { return }
    sliced.frameLength = frames
    if let src = outputBuffer.int16ChannelData, let dst = sliced.int16ChannelData {
      for c in 0..<channels {
        memcpy(dst[c], src[c], Int(frames) * MemoryLayout<Int16>.size)
      }
    } else {
      return
    }

    let abl = UnsafeMutableAudioBufferListPointer(sliced.mutableAudioBufferList)
    for audioBuffer in abl {
      if audioBuffer.mData == nil || audioBuffer.mDataByteSize == 0 { return }
    }

    do {
      try outputFile.write(from: sliced)
      writtenFrames += frames
    } catch {
      finish(.failure(error))
    }
  }

  private func finalizeStream() {
    guard !finished else { return }
    if writtenFrames == 0 {
      finish(.failure(NSError(
        domain: "SvaAudioRenderer",
        code: 423,
        userInfo: [NSLocalizedDescriptionKey: "TTS produced no audio"]
      )))
      return
    }
    finish(.success(()))
  }

  private func handleTimeout() {
    lock.lock()
    defer { lock.unlock() }
    guard !finished else { return }
    synthesizer.stopSpeaking(at: .immediate)
    try? FileManager.default.removeItem(at: dest)
    finish(.failure(NSError(
      domain: "SvaAudioRenderer",
      code: 408,
      userInfo: [NSLocalizedDescriptionKey: "TTS render timed out"]
    )))
  }

  private func finish(_ result: Result<Void, Error>) {
    guard !finished else { return }
    finished = true
    timeoutWork?.cancel()
    timeoutWork = nil
    outputFile = nil
    converter = nil
    completion?(result)
    completion = nil
  }
}

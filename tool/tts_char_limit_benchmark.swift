#!/usr/bin/env swift
import AVFoundation
import Foundation

// Quick TTS length probe — logs lengths/durations only (never utterance text).

final class SpeakProbe: NSObject, AVSpeechSynthesizerDelegate {
  let sema = DispatchSemaphore(value: 0)
  var start = Date()
  var end = Date()
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    start = Date()
  }
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    end = Date()
    sema.signal()
  }
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    end = Date()
    sema.signal()
  }
}

func duration(chars: Int, locale: String, seed: String) -> Double {
  let text = String(repeating: seed, count: max(1, chars / max(seed.count, 1)))
  let clipped = String(text.prefix(chars))
  let u = AVSpeechUtterance(string: clipped)
  u.voice = AVSpeechSynthesisVoice(language: locale)
  u.volume = 0
  u.rate = AVSpeechUtteranceDefaultSpeechRate
  let synth = AVSpeechSynthesizer()
  let probe = SpeakProbe()
  synth.delegate = probe
  synth.speak(u)
  _ = probe.sema.wait(timeout: .now() + 45)
  return probe.end.timeIntervalSince(probe.start)
}

print("locale,chars,durationSec")
let probes: [(String, String, [Int])] = [
  ("vi-VN", "Xin chào buổi sáng. ", [100, 140, 160, 180]),
  ("en-US", "Good morning, wake up now. ", [200, 240, 280, 320]),
]
var viCap = 160
var enCap = 280
for (locale, seed, lengths) in probes {
  var safe = lengths.first ?? 100
  for len in lengths {
    let d = duration(chars: len, locale: locale, seed: seed)
    print("\(locale),\(len),\(String(format: "%.2f", d))")
    fflush(stdout)
    if d <= 18.0 { safe = len }
  }
  if locale.hasPrefix("vi") { viCap = safe }
  if locale.hasPrefix("en") { enCap = safe }
}
print("recommended_vi=\(viCap)")
print("recommended_en=\(enCap)")
print("fallback=220")

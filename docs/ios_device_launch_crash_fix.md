# iOS device launch crash fix

Branch: `fix/ios-device-launch-crash`  
Base for review: `review/ios-alarmkit-crash-state`  
Status: review only — do not merge

## 1. Root cause (startup)

`lib/main.dart` awaited `notifications.rescheduleAll(...)` before `runApp()`.

On iOS that path called `IosAlarmFanoutService.scheduleAlarm()`, which rendered TTS / recording / ringtone via native audio before Flutter UI started. Unsafe CoreAudio work could abort the process from the home-screen icon.

## 2. Older crash path

Native conversion could hit an unsafe `AVAudioFile.write` / format-mismatch path in CoreAudio (`SvaAudioRenderer` PCM/CAF conversion), aborting the process (not always a catchable Swift error).

## 3. Fix summary

- Call `runApp` before iOS alarm reconciliation.
- Startup reconciliation does **not** render TTS, recording, or ringtone audio.
- Reuse valid rendered files; mark missing/corrupt audio for repair instead of regenerating at launch.
- Fallback local notifications may use the system default sound only (no renderer).
- Serial TTS render operation retains a strong `AVSpeechSynthesizer` for the operation lifetime.
- TTS callbacks are serialized; single-resume completion; **30s** timeout.
- Output processing format: Linear PCM **Int16**, mono, **44100 Hz**, consistent interleaving.
- Validate rendered files before atomic move into `Library/Sounds`.
- Two-phase schedule: render + validate + schedule new children, then cancel old revision.
- Method channel results complete on the main thread; audio work off main.

## 4. Physical iPhone results (overlay install, data kept)

- Overlay install: passed
- App icon launch: **10/10** passed
- Force-close and relaunch: **5/5** passed
- 30-second post-launch observation: passed (no late crash)

## 5. Still pending (manual)

- Save short TTS and preview
- Save short recording and preview
- Create/fire a real single-voice alarm end-to-end

## 6. AlarmKit status

AlarmKit is **not** active yet:

- `usesAlarmKit = false`
- `supportsFullVoiceAlarm = false`
- Scheduling uses local-notification fan-out (`SvaNotificationFanout`)

## 7. Android

No Android behavior changes. `git diff -- android/` is empty for this fix.

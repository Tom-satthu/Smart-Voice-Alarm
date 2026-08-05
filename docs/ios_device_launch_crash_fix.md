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
- Serial TTS render operation retains a strong `AVSpeechSynthesizer` for the operation lifetime.
- TTS callbacks are serialized; single-resume completion; **30s** timeout.
- Output processing format: Linear PCM **Int16**, mono, **44100 Hz**, consistent interleaving.
- Validate rendered files before atomic move into `Library/Sounds`.
- Two-phase schedule: render + validate + schedule new children, then cancel old revision.
- Method channel results complete on the main thread; audio work off main.

## 4. TTS operation retention (follow-up)

- `SvaTtsRenderService` keeps the in-flight work in `currentOperation`.
- The operation is released only after success, error, or timeout.
- Timeout and buffer-path terminals go through `finishOnce` (completion runs once).
- Locale missing a specific voice falls back to language code, then device default.

## 5. Loudness normalization

- Peak target ≈ **-1 dBFS**
- Max gain **20×** for very quiet sources
- Soft limiter near full scale
- Does **not** change iOS system / ringtone volume
- Preview on iOS plays the same normalized rendered CAF when possible

## 6. Schedule / startup safety (follow-up)

- `cleanupOrphanSounds` was **removed** from `scheduleAlarm` (no cross-alarm file deletion).
- Failed renders delete only the new revision files and keep the old schedule.
- Required voice-segment render failures are hard failures (no silent partial success).
- `reconcileWithoutRender` is a **no-op** (no schedule / cancel / render on launch).

## 7. Add Voice: saved voice reuse

- Each saved voice row can show a **+** when an active sequence draft (`?id=`) is present.
- Tapping + appends that voice into the current sequence without a new saved-voice persistence row or file copy, then returns to the Voice Sequence screen.

## 8. Physical iPhone results (overlay install, data kept)

- Overlay install: passed
- App icon launch: **10/10** passed
- Force-close and relaunch: **5/5** passed
- 30-second post-launch observation: passed (no late crash)
- Automated tests: **90/90**

## 9. Still pending (manual on device)

- TTS-only alarm save / fire
- Recording + TTS combined alarm
- Notification loudness vs in-app preview
- Saved-voice **+** button end-to-end
- Confirm two alarms do not delete each other’s rendered files

## 10. AlarmKit status

AlarmKit is **not** active yet:

- `usesAlarmKit = false`
- `supportsFullVoiceAlarm = false`
- Scheduling uses local-notification fan-out (`SvaNotificationFanout`)

## 11. Android

No Android behavior changes. `git diff -- android/` is empty for this fix.

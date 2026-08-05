# iOS AlarmKit crash — current state (review capture)

## 1. Git HEAD before these changes

- Base commit: `dfa4e29` — Merge pull request #7 from Tom-deptrai/fix/alarm-stop-and-voice-ux
- Capture branch: `review/ios-alarmkit-crash-state` (from working tree on top of that HEAD)

## 2. Physical device

- iPhone on **iOS 26.5.2** (device name omitted; no full UDID in this doc)

## 3. Simulator

- App launches successfully (no crash observed in simulator)

## 4. Physical device — launch

- Tapping the app icon causes the app to exit immediately

## 5. Major changes in this capture

- AlarmKit path for iOS 26+ (currently stubbed / not the active schedule path in native code)
- Local notification fan-out for older iOS (and as the active schedule path)
- Native audio rendering into `Library/Sounds`
- TTS file generation for notification sounds
- Math Challenge routing from notification / pending challenge payloads
- App icon regeneration (opaque teal fill to avoid black borders)
- Add Voice refresh + saved-voices list UX
- New-alarm defaults (7 weekdays + Combined)
- Localization keys across ARB locales
- Developer attribution (platform-specific display name)

## 6. Claude Code analysis (suspected)

- `AVSpeechSynthesizer` may be released too early under ARC during write-to-file
- `AVAudioFile` / PCM buffer format mismatch (Float32 vs Int16)
- CoreAudio crash related to `mDataByteSize should be non-zero`

## 7. Claude Code / Cursor fixes already applied in this tree

- Native audio renderer rewritten toward safer `AVAudioFile` + `AVAudioConverter` paths
- Notification fan-out hardening (calendar triggers, auth before schedule, default-sound fallback)
- Capability / UX tweaks on create-alarm and add-voice screens
- Scene / AppDelegate adjustments for Flutter iOS lifecycle
- AlarmKit scheduling stubbed to avoid incomplete entitlement / intent launch crashes

## 8. Results after those fixes

- Simulator: launches
- Physical iPhone: launch crash / immediate exit when opening from icon still reported

## 9. Root cause status

- Final device-only launch root cause is **not fully confirmed** for the latest install cycle in this capture note; treat as review-in-progress, not closed.

## 10. Android

- `git diff -- android/` is empty
- Android behavior must remain unchanged

## Review intent

- This documentation and branch exist for technical review only.
- Do not merge to `main` from this capture without explicit follow-up.
- No App Store / Google Play / release actions from this PR.

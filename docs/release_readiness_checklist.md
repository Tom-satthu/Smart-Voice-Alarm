# Release readiness checklist

Branch: `fix/alarm-stop-and-voice-ux`  
PR: https://github.com/Tom-deptrai/Smart-Voice-Alarm/pull/7

Do **not** mark a row pass unless that check was actually run.

---

## Đã xác minh tự động

| Check | Status | Notes |
|-------|--------|-------|
| `flutter analyze` | Pass | No issues |
| `flutter test test/voice_catalog_test.dart` | Pass | Includes exact-locale snapshot, legacy ID, preferred retarget, corrupted event |
| `flutter build apk --debug` | Pass | Local debug APK |
| `flutter build appbundle --release` | Pass | Built with **debug signing fallback** (no `android/keystore.properties` in repo — not store-upload ready) |
| `flutter build web` | Pass | Compile OK; Wasm dry-run warnings from deps only; no deploy |

---

## Cần người dùng nghe / kiểm tra (chưa pass)

| Check | Status | Notes |
|-------|--------|-------|
| Preview đúng voice (On-device) | Not verified | Listen on device |
| Đổi Vietnamese Voice I–V | Not verified | |
| Concrete Google/Samsung voice | Not verified | |
| Alarm TTS phát đúng khi reo | Not verified | Must hear audio |
| Math dismiss → thoát app (không về Home toggle) | Not verified | After correct answer, app should leave UI |
| Notification Stop → mở challenge | Not verified | Must show math, not silent-stop |
| Stop trong app + math | Not verified | |
| App background / killed khi reo | Not verified | FGS handoff still drops notification after Flutter takes over — listen carefully |
| Reboot reschedule | Not verified | |
| iOS simulator/device | Not verified | No macOS in this audit environment |
| Web runtime (speechSynthesis delay / refresh) | Not verified | Compile only |

---

## Known residual risks (not marked release-blocking this pass)

1. After Flutter handoff, native FGS/notification/vibration/wake lock are stopped by design to avoid dual audio. Background OEM kill risk remains until a silent FGS holder is added.
2. Web may briefly expose an empty voice list until browser `speechSynthesis` voices load; reloadVoices on resume mitigates, but runtime not tested here.
3. Store upload still needs a real upload keystore (not in repo).

---

## Product decisions locked

- Keep current Voices screen / tab names.
- No Google-voices redesign, Cloud TTS, offline model, Firebase/R2, or large Voices refactor.
- Do not commit `docs/offline_voice_model_research_*.md` unless explicitly requested.

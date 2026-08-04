# Release readiness checklist

Branch: `fix/alarm-stop-and-voice-ux`  
PR: https://github.com/Tom-deptrai/Smart-Voice-Alarm/pull/7

Do **not** mark a row pass unless that check was actually run.

---

## Đã xác minh tự động

| Check | Status | Notes |
|-------|--------|-------|
| `flutter analyze` | Pending / see report | Re-run after Voices UX simplification |
| `flutter test test/voice_catalog_test.dart` | Pending / see report | |
| `flutter test test/voice_discovery_scan_test.dart` | Pending / see report | Scan generation / VoiceLoadContext |
| `flutter build apk --debug` | Pending / see report | |
| `flutter build web` | Pending / see report | Compile only; no deploy |
| `flutter build appbundle --release` | Prior pass | Debug signing fallback when keystore absent |

---

## Voices UX (manual — Samsung / người dùng)

| Check | Status | Notes |
|-------|--------|-------|
| Chỉ còn một màn (không TabBar) | Not verified | Current + Scan + Guide |
| Không còn tab “Giọng nói mới cài đặt” | Not verified | |
| Card “Giọng nói đang dùng” hiện đúng | Not verified | |
| Quét hiển thị giọng trên Samsung | Not verified | |
| Quét sau khi cài voice trong Settings cập nhật list | Not verified | |
| Quét không đổi giọng đang dùng (nếu vẫn còn) | Not verified | |
| Preview dùng đúng voice đã chọn | Not verified | Must listen |
| Alarm dùng cùng voice với preview | Not verified | Must listen |
| Voice giữ sau restart | Not verified | |
| Gỡ voice hệ thống không crash app | Not verified | |
| Hướng dẫn Android + nút mở settings | Not verified | |
| iOS / Web runtime guide | Not verified | Static only unless tested |

---

## Alarm / khác (manual)

| Check | Status | Notes |
|-------|--------|-------|
| Preview đúng voice | Not verified | Listen on device |
| Alarm TTS phát đúng khi reo | Not verified | Must hear audio |
| Math dismiss → thoát app | Not verified | |
| Notification Stop → challenge | Not verified | |
| App background / killed khi reo | Not verified | |
| Reboot reschedule | Not verified | |
| iOS simulator/device | Not verified | No macOS in this environment |
| Web runtime | Not verified | Compile only |

---

## Known residual risks

1. After Flutter handoff, native FGS/notification/vibration/wake lock are stopped to avoid dual audio.
2. Web may briefly expose an empty voice list until browser voices load.
3. Store upload needs a real upload keystore (not in repo).

---

## Product decisions locked

- Voices: single scroll screen (current / scan / setup guide). No newly-installed tab.
- No Google-voices redesign, Cloud TTS, offline model, Firebase/R2.
- Do not commit `docs/offline_voice_model_research_*.md` unless explicitly requested.

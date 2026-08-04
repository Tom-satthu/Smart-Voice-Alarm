# Google Play release checklist

Audit date: 2026-08-04
Application ID: `com.smartvoicealarm.app`
Version: `1.0.0` (`1`)

## Automated status

- [x] Source repository link removed from app UI, localization and web support.
- [x] Premium/IAP hidden and not initialized in paid-app release mode.
- [x] Runtime Google Fonts fetching eliminated; system fonts are used.
- [x] Microphone is requested only after an explanation in the recording flow.
- [x] Recording Cancel/background/dispose removes unsaved temporary audio.
- [x] Android recording directory excluded from cloud backup and device transfer.
- [x] `USE_EXACT_ALARM` retained for Android 13+; `SCHEDULE_EXACT_ALARM` is scoped to Android 12/12L (`maxSdkVersion=32`).
- [x] Internal alarm receiver is not exported; reboot/time-change receiver is separated.
- [x] FGS has media-playback type, monochrome notification icon and a 10-minute safety timeout.
- [x] Release Gradle configuration refuses debug-key fallback.
- [ ] Live Privacy Policy and Support URLs — `BLOCKED_BY_GITHUB_PERMISSION`.
- [ ] Upload keystore configuration — `RELEASE_SIGNING_BLOCKED` (owner must supply the existing key; never create/replace it here).
- [ ] Signed AAB and AAB-derived smoke test — blocked by signing.
- [ ] Human listening check for ringtone/TTS/recording.
- [ ] Play Console declarations, content rating, target audience, pricing and Data Safety entered by owner.

## Owner actions

1. Sign in to GitHub as `Tom-deptrai`, create public `smart-voice-alarm-legal`, copy only `legal_site_deployable/`, enable Pages from the default branch, and verify all URLs return HTTPS 200.
2. Put the resulting Privacy and Support URLs in `AppConstants`, rebuild and retest.
3. Restore the existing upload keystore and ignored `android/keystore.properties`; verify owner backup.
4. Build/sign AAB, validate/install an AAB-derived APK and perform device/human audio tests.
5. Complete every Play Console declaration using the files in this folder.

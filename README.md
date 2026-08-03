# Smart Voice Alarm

Commercial Flutter app for voice-based alarms. Wake up to your own recordings and text-to-speech sequences.

## Live demo (GitHub Pages)

**URL:** https://tom-satthu.github.io/Smart-Voice-Alarm/

Deployed via GitHub Actions (`.github/workflows/deploy-github-pages.yml`) on every push to `main`.

## Features

- Local persistence (Hive) for alarms, voice sequences, theme, language, reminder
- Voice sequences: recordings + offline system TTS
- Alarm engine: play sequence → repeat loops → continuous ringtone until Stop
- Alarm queue with **Stop** (current) and **Stop All**
- Android: AlarmManager + BroadcastReceiver + foreground service (audio starts without tapping a notification); reschedule after reboot
- iOS: full voice playback while the app is active; local notification with system sound when the app is killed
- Settings → Voice & Speech for system voice packs

## Platform limits

### Android

- Exact alarms require the system exact-alarm permission on newer OS versions.
- Some OEMs aggressively kill background work; AlarmClock + foreground service is used for reliability.
- Voice packs are installed through the system TTS installer (`INSTALL_TTS_DATA`). This app does not ship or host Google voice packages.

### iOS

- While the app is in the foreground / background (still running), Voice Sequence + TTS playback uses the in-app Alarm Engine.
- **When iOS has fully killed the app**, TTS and custom recordings cannot continue to run. The system shows a local notification with an appropriate alert sound instead.
- Additional voices must be downloaded by the user in **Settings → Accessibility → Spoken Content → Voices**. The app cannot install voice packs itself.

### Web

- Demo UI and browser TTS voices work where supported.
- Microphone recording and system voice-pack install are unavailable in the browser.

## Run

```bash
flutter pub get
flutter run
```

## Analyze & builds

```bash
flutter analyze
flutter build web --release --base-href "/Smart-Voice-Alarm/"
flutter build apk --debug
```

## Structure

```
lib/
  app/
  core/
  shared/
  features/
    splash/
    home/
    alarm/
    voice_sequence/
    settings/
    premium/
  theme/
  router/
  localization/
```

# Smart Voice Alarm

Commercial Flutter app for voice-based alarms. Wake up to your own recordings and text-to-speech sequences.

## Phase 1 — Architecture & UI Prototype

This repository currently ships:

- Clean Architecture with Feature-First organization
- Material Design 3, Light & Dark mode
- Riverpod state management
- Go Router navigation
- Localization (English default, extensible)
- Responsive layouts for phone, tablet, and web
- Full UI screens: Splash, Home, Create Alarm, Voice Sequence, Add Voice, TTS, Record, Settings, Premium

Business logic, database, notifications, and TTS engine are intentionally deferred to later phases.

## Live demo

GitHub Pages: https://tom-satthu.github.io/Smart-Voice-Alarm/

## Run

```bash
flutter pub get
flutter run
```

## Analyze & Web Build

```bash
flutter analyze
flutter build web
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

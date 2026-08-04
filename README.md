# Smart Voice Alarm

Local-first Flutter app that wakes you with your own recordings and system text-to-speech sequences.

## Live website

- App demo: https://tom-satthu.github.io/Smart-Voice-Alarm/
- Privacy: https://tom-satthu.github.io/Smart-Voice-Alarm/privacy/
- Terms: https://tom-satthu.github.io/Smart-Voice-Alarm/terms/
- Support: https://tom-satthu.github.io/Smart-Voice-Alarm/support/

## Product model

| Plan | What you get |
|------|--------------|
| **Free** | Full features (TTS, recording, voice sequences, themes, reminder). Limit: **3 alarms**. |
| **Premium Lifetime** | Unlimited alarms. One-time non-consumable purchase. No subscription. |

Primary CTA: **Unlock Unlimited Alarms**  
Product ID: `smart_voice_alarm_unlimited`  
Target price: **USD 1.99** (UI shows the localized store price when available)

## Main features

- Local Hive persistence for alarms, sequences, settings, and Premium entitlement
- Voice sequences: recordings + offline system TTS
- Alarm engine with Stop / Stop All and queueing
- Android AlarmManager + foreground service for reliable wake-ups
- iOS local notification fallback when the process is killed
- Voices browser grouped by language / locale with search
- 13 UI languages
- Real In-App Purchase via `in_app_purchase` (disabled safely on web)

## Architecture

```
lib/
  app/                 MaterialApp + locale/theme wiring
  core/                constants, services (IAP, entitlement, TTS, alarms)
  features/            splash, home, alarm, voice_sequence, settings, premium
  shared/              Hive stores, models, providers, widgets
  localization/        ARB + generated AppLocalizations
  theme/               colors, typography, Material 3 themes
  router/              go_router routes
```

Application / bundle ID: `com.smartvoicealarm.app`  
Version: `1.0.0` · Build: `1`

## Run

```bash
flutter pub get
flutter run                 # device / emulator
flutter run -d chrome       # web demo
```

## Analyze, test, builds

```bash
flutter analyze
flutter test
flutter build web --release --base-href "/Smart-Voice-Alarm/"
flutter build apk --debug
flutter build appbundle --release   # requires release signing (see below)
```

## In-App Purchase setup

1. Create a **non-consumable** product with ID `smart_voice_alarm_unlimited` in:
   - App Store Connect → Features → In-App Purchases
   - Google Play Console → Monetize → Products → In-app products
2. Set price near **USD 1.99** (stores localize automatically).
3. Activate / publish the product for the app package `com.smartvoicealarm.app`.
4. Use a sandbox / license tester account to verify purchase and restore.
5. The app loads the store price at runtime and never unlocks Premium from a fake button press.

On **web**, purchase buttons stay disabled and show a safe demo message.

### Manual store checklist

See [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md).

## Android exact alarms

- Manifest already requests `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`.
- On Android 12+, users may need to allow **Alarms & reminders** for the app.
- After reboot, `AlarmReceiver` reschedules persisted alarms.

## iOS limits when the app is killed

While the app process is alive, the Alarm Engine can play voice sequences and TTS.  
If iOS has **fully terminated** the process, custom audio cannot continue. The scheduled local notification uses a system sound instead.

## Download more system voices

- **Android:** Settings → Voices → Download More Voices (opens system TTS installer), then Refresh Voices.
- **iOS:** Settings → Accessibility → Spoken Content → Voices, download packs, return to the app, Refresh Voices.

## Release signing (manual — owner only)

Do **not** commit keystores, passwords, or certificates.

### Android

1. Generate a keystore locally (example):

```bash
keytool -genkey -v -keystore ~/smart-voice-alarm-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Copy `android/keystore.properties.example` to `android/keystore.properties` and fill paths/passwords.
3. Wire `signingConfigs` in `android/app/build.gradle.kts` to that file (keep the file gitignored).
4. Build: `flutter build appbundle --release`

### iOS

Requires a **macOS machine with Xcode**.

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set Team / signing for bundle ID `com.smartvoicealarm.app`.
3. Archive and upload to App Store Connect.

## Support email

Configured in `lib/core/constants/app_constants.dart` as `supportEmail`:  
`timeforwork789@gmail.com`

Google Play public developer name: **Nguyên Đức**

## License

See repository license / open-source licenses screen inside the app.

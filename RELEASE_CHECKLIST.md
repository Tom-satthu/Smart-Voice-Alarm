# Release checklist — Smart Voice Alarm

Use this before submitting Android / iOS builds.

## App identity

- [ ] Android `applicationId` = `com.smartvoicealarm.app`
- [ ] iOS bundle ID = `com.smartvoicealarm.app`
- [ ] Display name = Smart Voice Alarm
- [ ] Version `1.0.0` / build `1` (bump as needed)
- [ ] App icons + splash verified on light and dark launch

## App Store Connect (deferred until Mac available)

- [ ] Create app record with bundle ID `com.smartvoicealarm.app`
- [ ] Fill metadata, subtitle, keywords, categories
- [ ] Upload screenshots for required device sizes
- [ ] Privacy Policy URL: PENDING (host via proposed `smart-voice-alarm-legal` GitHub Pages)
- [ ] Support URL: PENDING
- [ ] Terms / EULA: optional for current local + lifetime IAP model — do not use placeholder URLs
- [ ] Age rating questionnaire completed
- [ ] Export compliance / encryption answers completed
- [ ] Create sandbox Apple ID for purchase testing
- [ ] Verify iOS seller name against Apple account (`IOS_SELLER_NAME_NEEDS_VERIFICATION_AGAINST_APPLE_ACCOUNT`)

## Google Play Console (priority)

- [ ] Create app with package `com.smartvoicealarm.app`
- [ ] Complete store listing + graphics
- [ ] Privacy Policy URL set (PENDING until legal Pages published)
- [ ] Support email: timeforwork789@gmail.com
- [ ] Public developer name: Nguyên Đức
- [ ] Data safety form: see `docs/privacy_data_audit.md` (do not claim “no data collection” without reviewing fonts/billing)
- [ ] Content rating questionnaire
- [ ] Create license testers for IAP
- [ ] Upload AAB to internal testing first

## In-app product

- [ ] Product ID: `smart_voice_alarm_unlimited`
- [ ] Type: **Non-consumable** (Apple) / **Managed product / non-consumable equivalent** (Play)
- [ ] Price ≈ USD 1.99
- [ ] Localized title/description mention **Premium Lifetime** and **unlimited alarms**
- [ ] Product active / approved
- [ ] Verify app shows **store-returned localized price**
- [ ] Verify purchase unlocks >3 alarms
- [ ] Verify Restore Purchase on fresh install
- [ ] Confirm Free users can still use TTS, recording, themes, reminder

## Privacy & legal

- [ ] Privacy / Terms / Support pages live on GitHub Pages
- [ ] About + Settings open the real URLs
- [ ] Support email in `AppConstants.supportEmail` is monitored
- [ ] No placeholder legal domains remain

## Signing

- [ ] Android upload keystore created **outside** git
- [ ] `android/keystore.properties` present locally and gitignored
- [ ] iOS distribution certificate + provisioning profile on Mac
- [ ] No secrets committed

## Build

- [ ] `flutter analyze` clean
- [ ] `flutter test` passing
- [ ] `flutter build appbundle --release`
- [ ] iOS Archive from Xcode on macOS
- [ ] Web demo rebuilt for Pages if legal pages changed

## Device testing

- [ ] Create 3 free alarms works
- [ ] Creating / duplicating a 4th opens Premium with **Unlock Unlimited Alarms**
- [ ] Purchase / restore on Android test track
- [ ] Purchase / restore on iOS sandbox
- [ ] Exact alarm permission on Android 12+
- [ ] Boot reschedule on Android
- [ ] iOS killed-app notification path understood
- [ ] Voices language grouping + search
- [ ] Dark mode / light mode smoke test
- [ ] Locale switch persists

## Store metadata copy notes

- Emphasize local-first, your own voice, lifetime unlock
- Do not claim cloud sync, accounts, or subscriptions
- Be explicit about iOS killed-state limitation for custom voice playback

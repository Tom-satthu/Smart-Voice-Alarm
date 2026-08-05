# Privacy / data handling audit for Smart Voice Alarm
# Generated from code inspection. Not a legal privacy policy.

**Status:** Public Privacy Policy, Support and Subscription Terms URLs are live and configured in app constants.

Configured support email: `timeforwork789@gmail.com`  
Android public developer name: **Nguyên Đức**  
Play Console: owner confirmed account purchased and verified.

**Privacy Policy URL:** `https://tom-deptrai.github.io/smart-voice-alarm-legal/privacy-policy/` — verified HTTPS 200.

iOS seller name planned later: Trần Thị Cẩm Mỹ — `IOS_SELLER_NAME_NEEDS_VERIFICATION_AGAINST_APPLE_ACCOUNT` (do not put on Android legal pages).


## 1. Data the app processes

| Data | Purpose | Where created |
|------|---------|---------------|
| Alarm schedules (time, repeat, label, type) | Core alarm function | User input |
| Voice sequence text / TTS voice selection | Spoken alarm content | User input / device TTS |
| Local audio recordings | Custom voice segments | Microphone (`record`) |
| Theme mode, locale, reminder settings | Preferences | User settings |
| Premium purchase entitlement | Unlock alarm limit | Store billing (`in_app_purchase`) |
| Notification / exact-alarm permission state | Reliability | OS APIs |

No account system, login, or cloud profile was found in app code.

## 2. Data stored on-device only

- Hive / local storage for alarms and related models
- SharedPreferences for theme, locale, reminder, and similar prefs
- Local filesystem paths for recorded audio (via `path_provider`)
- Package metadata (version/build) read at runtime

These remain on the device unless the user exports/shares them themselves (no in-app cloud sync found).

## 3. Data sent over the network

| Path | Observed? | Notes |
|------|-----------|-------|
| App backend / custom API | No | No Firebase / HTTP client app service found |
| Analytics / crash reporting | No | Not in `pubspec.yaml` |
| Ads / advertising ID | No | Not present |
| Cloud TTS | No | Uses on-device `flutter_tts` |
| Store billing | Yes (platform) | `in_app_purchase` talks to Play Billing / StoreKit when user buys or restores |
| URL opens (support mailto, GitHub, future privacy URL) | User-initiated | `url_launcher` |
| Google Play Billing | Yes (platform) | Product metadata and purchase state/token for annual entitlement; no card data in app |

**Do not claim “no data collection” in store forms without confirming Google Fonts runtime behavior and store billing disclosures.**

## 4. Third-party SDKs / packages (relevant)

| Package | Purpose | Likely data / privacy note |
|---------|---------|----------------------------|
| `flutter_local_notifications` | Alarm/reminder notifications | Local scheduling; OS notification APIs |
| `permission_handler` | Permission status / settings | Local |
| `record` | Microphone recording | Local audio files |
| `just_audio` / `audio_session` | Playback | Local |
| `flutter_tts` | Device TTS | May use vendor TTS engines on device |
| `in_app_purchase` | Annual Premium subscription | Purchase tokens handled by stores and never logged by app code |
| `url_launcher` | mailto / https | User-initiated |
| `package_info_plus` | Version/build in UI & support mail | Local metadata |
| `hive` / `shared_preferences` | Local persistence | Local |
| No Firebase / Sentry / Ads / social SDK | — | Not declared in dependencies |

iOS privacy manifests: verify per-plugin manifests at archive time on macOS (not verified in this Windows audit).

## 5. Permissions

### Android (`AndroidManifest.xml`)

| Permission | Why | Required for core alarm? |
|------------|-----|---------------------------|
| `RECORD_AUDIO` | Record voice segments | Optional feature |
| `POST_NOTIFICATIONS` | Show alarm/reminder notifications | Yes (Android 13+) |
| `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` | Fire alarms on time | Yes for reliable alarms |
| `WAKE_LOCK` | Keep device awake while ringing | Yes for ringing reliability |
| `VIBRATE` | Alarm feedback | Optional UX |
| `RECEIVE_BOOT_COMPLETED` | Reschedule after reboot | Yes |
| `USE_FULL_SCREEN_INTENT` | Full-screen alarm UI | Strongly useful for alarms |
| `FOREGROUND_SERVICE` + `MEDIA_PLAYBACK` | Keep alarm audio running | Yes for continuous playback |

### iOS (`Info.plist`)

| Key | Why |
|-----|-----|
| `NSMicrophoneUsageDescription` | Voice recording |
| `UIBackgroundModes` → `audio` | Continue alarm audio |

No location, contacts, photo library, tracking, or ATT usage descriptions found.

## 6. Google Play Data Safety — draft hints

Owner must answer in Play Console; these are **code-based suggestions only**:

- **Collected?** Prefer “data collected” only where store billing / fonts / OS telemetry apply; most alarm content stays on device.
- **Shared?** No third-party analytics/ads sharing found.
- **Encrypted in transit?** N/A for local-only features; store purchases use platform channels.
- **Data deletion:** No account → typically “users can delete by clearing app data / uninstall”. Confirm Play form wording.
- **Sensitive permissions:** declare exact alarms / notifications / microphone as applicable.
- **Ads:** declare **No** (code has none).
- Exact alarm / FGS declarations: follow current Play Console questionnaires for alarm apps.

## 7. Apple App Privacy — draft hints

- Likely **no tracking**.
- Data linked to user: typically none if no account.
- Purchase history may be handled by Apple; answer per App Store Connect guidance.
- Microphone: used for optional recordings stored on device.
- Confirm after macOS archive / privacy report.

## 8. Owner confirmation required

- Final Privacy Policy text and **public HTTPS URL**
- Whether Google Fonts network fetches are acceptable / should be vendored offline
- Legal/copyright owner name for store listing
- Whether any future analytics/crash tools will be added (currently none)
- Premium product IDs live status in both stores
- Confirmation that web `/privacy` and `/terms` pages are authoritative or temporary drafts only

## 9. Privacy Policy URL status

| Item | Status |
|------|--------|
| `AppConstants.privacyPolicyUrl` | Live GitHub Pages HTTPS URL |
| In-app Privacy row | Visible and opens the public policy |
| Broken GitHub Pages URLs previously | Removed from app constants |
| Email used as privacy URL | **Must not** |

Store submit is blocked until a real public Privacy Policy URL is provided and wired into `AppConstants.privacyPolicyUrl`.

# Privacy Policy draft (English) — Smart Voice Alarm

**Status:** DRAFT — not published. Owner must approve content and effective date before hosting.

**Effective date:** `[OWNER TO CONFIRM]`

**App:** Smart Voice Alarm  
**Android public developer name:** Nguyên Đức  
**Contact:** timeforwork789@gmail.com  

This draft is based on `docs/privacy_data_audit.md` and current app code. It is not legal advice.

---

## 1. Who we are

Smart Voice Alarm is a mobile application that helps you schedule alarms and play voice sequences on your device.

On Google Play, the public developer name is **Nguyên Đức**.

For privacy questions, contact: **timeforwork789@gmail.com**.

## 2. Scope

This policy describes how Smart Voice Alarm handles information when you use the Android app (and related builds of the same product). Platform store services (Google Play) have their own privacy practices.

## 3. Information the app accesses or processes

Depending on how you use the app, Smart Voice Alarm may process:

- Alarm schedules you create (time, repeat rules, labels, alarm type)
- Voice sequence text and the system TTS voice you select
- Audio you record for custom voice segments (microphone)
- App preferences (theme, language, reminder settings)
- Permission states needed for notifications and exact alarms
- Purchase entitlement for Premium Lifetime (processed through Google Play Billing)

The app does **not** provide an in-app account, login, or cloud profile.

## 4. Information stored on your device

The following is stored locally on your device (for example via on-device databases, preferences, and local files):

- Alarms and related settings
- Voice sequences and recordings you create
- Theme, language, and reminder preferences
- Local Premium entitlement state as managed with the store APIs

Clearing app data or uninstalling the app removes this local data, subject to how your device and Google Play handle app storage and purchases.

## 5. Information that may leave your device

Based on current code review:

- The app does **not** include Firebase, analytics SDKs, crash-reporting SDKs, advertising SDKs, or a custom app backend for uploading alarm content.
- If you purchase or restore Premium, Google Play Billing handles the transaction. Purchase-related data is processed under Google’s policies.
- If you open Support, the device email app may send a message you compose to timeforwork789@gmail.com. Diagnostic fields that may be pre-filled (version, platform) do not include alarm contents or personal identifiers beyond what you choose to write.
- If you open links (for example GitHub or a hosted privacy/support page), your browser or system handler loads those pages.
- The app uses `google_fonts`. Font files may be fetched over the network when not already available on the device. Owner should confirm whether fonts will be vendored offline before finalizing store “data collection” answers.

This policy does **not** claim that the app never sends any data off-device. Platform services and optional network font loading may involve network activity.

## 6. Android permissions and why they are used

| Permission / capability | Purpose |
|-------------------------|---------|
| Notifications | Show alarm and reminder notifications |
| Exact alarms | Fire alarms at the scheduled time |
| Foreground service (media playback) | Keep alarm audio playing reliably |
| Boot completed | Reschedule alarms after device restart |
| Wake lock / vibrate / full-screen intent | Improve alarm reliability and attention |
| Microphone | Optional recording of custom voice segments |

You can deny optional permissions; core alarm reliability may be reduced if notification or exact-alarm permissions are denied.

## 7. Third-party services

The app may interact with:

- **Google Play / Play Billing** — distribution and in-app purchases
- **Device TTS engines** — speak alarm text using voices installed on the device
- **Operating system notification and alarm APIs**
- **GitHub** (if you open the public repository link)
- **google_fonts** packaging (possible font download)

These services are governed by their own terms and privacy policies.

## 8. Retention and deletion

- Local app data remains on your device until you delete it (clear storage / uninstall) or edit/remove items in the app.
- Emails you send to support are retained as needed to respond to your request.
- Purchase records are retained by Google according to Google Play policies.

There is no in-app cloud account to delete. Account deletion requests for a non-existent app account are not applicable.

## 9. Children

Smart Voice Alarm is a general-audience utility. It is not directed at children under 13. Do not use the app to submit personal information of children. Final target-audience and Play content-rating answers remain owner-confirmed.

## 10. Security

We use reasonable on-device storage provided by the operating system and standard platform APIs. No method of electronic storage or transmission is completely secure.

## 11. Changes to this policy

We may update this Privacy Policy. When a public URL is published, the effective date will be updated. Continued use after changes means you should review the latest version on the hosted page.

## 12. Contact

Email: **timeforwork789@gmail.com**  
Android public developer name: **Nguyên Đức**

## 13. Hosting note (not part of published policy body)

Intended hosting plan: separate public GitHub Pages repo (proposed name `smart-voice-alarm-legal`) with:

- `/index.html`
- `/privacy-policy/index.html`
- `/support/index.html`

**Public Privacy Policy URL:** `PENDING` (not created; do not invent a live URL)

Owner approval required before creating the legal repo, enabling Pages, or wiring the URL into the app.

# Google Play release checklist

Audit date: 2026-08-05

Application ID: `com.smartvoicealarm.app`

Version: `1.0.0` (`1`)

## Automated status

- [x] Source repository link removed from app UI/localization/web support.
- [x] Free download, seven-day app-managed trial and annual subscription entitlement implemented.
- [x] Billing uses exact `premium_annual` / `annual-auto`, localized Play price and purchased/restored-only access.
- [x] Trial UTC persistence, rollback resistance, permanent expiry and three-day verified-subscriber offline grace tested.
- [x] No free alarm-count limit, monthly plan, lifetime product, ads or hidden production unlock.
- [x] Recording, exact-alarm, full-screen intent, FGS cleanup and release signing guard preserved.
- [x] Public HTTPS legal site live; Home, Privacy, Support and Subscription Terms return HTTP 200.
- [x] Upload keystore created outside the repository; ignored local properties configured with no debug-signing fallback.
- [x] Signed AAB created and verified with `jarsigner`; official bundletool 1.18.3 validation passed.
- [x] AAB-derived release APK verified with v2/v3 signing and installed on Samsung SM-G975F.
- [x] Release smoke: launch, non-debuggable package, seven-day trial, compact paywall, Settings Premium, Voice Sequence countdown, create/edit alarm and test-alarm cleanup.
- [ ] Real Billing test from Play internal track — product/configuration required.
- [ ] Human listening check for ringtone/TTS/recording.
- [ ] Play declarations, listing assets and owner confirmation.

See `subscription_setup.md`, `upload_key_backup_instructions.md`, `internal_testing_checklist.md` and `final_owner_actions.md`.

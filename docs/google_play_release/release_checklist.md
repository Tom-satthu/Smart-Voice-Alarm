# Google Play release checklist

Audit date: 2026-08-04

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
- [ ] Upload keystore configuration — `RELEASE_SIGNING_BLOCKED` until interactive owner setup.
- [ ] Signed AAB, bundle validation and AAB-derived Samsung smoke test — blocked by signing.
- [ ] Real Billing test from Play internal track — product/configuration required.
- [ ] Human listening check for ringtone/TTS/recording.
- [ ] Play declarations, listing assets and owner confirmation.

See `subscription_setup.md`, `upload_key_backup_guide.md` and `final_owner_actions.md`.

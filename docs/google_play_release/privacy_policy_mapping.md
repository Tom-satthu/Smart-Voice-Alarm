# Privacy policy mapping

| Code behavior | Policy section | Evidence |
|---|---|---|
| Alarm/settings/recordings local | Local data and recording | `lib/shared/data/local_store.dart`, recording storage |
| Seven-day local trial | Trial data | `TrialEntitlementService`, UTC keys in `SettingsRepository` |
| Clock rollback does not extend trial | Trial data | latest-trusted-time and permanent-expiry logic |
| Annual Play subscription | Purchases | `PremiumPurchaseService`, `premium_annual` / `annual-auto` |
| Short verified-subscriber offline cache | Purchases | documented three-day grace in `ReleaseConfig` |
| No analytics/ads/Firebase/backend | Third parties | dependency and source audit |
| User-initiated support email | Contact | `SupportContact.mailtoUri()` |
| Network-capable system voices | Third parties | TTS engine metadata/platform APIs |

Verification is client-side only. Purchase tokens must never be logged or included in support data.

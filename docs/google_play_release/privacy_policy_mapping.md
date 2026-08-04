# Privacy policy mapping

| Code behavior | Policy section | Evidence |
|---|---|---|
| Alarm/settings persisted locally | Local data | Hive repositories in `lib/shared/data/local_store.dart` |
| Recording user-triggered | Microphone and recordings | `RecordScreen` rationale + `RecordingService` |
| Recording app-specific | Storage/retention | `StoragePaths.recordingsDirPath()` |
| No recording backup/transfer | Storage/retention | Android backup XML excludes `app_flutter/recordings/` |
| Notifications/exact alarm/FSI/FGS | Android permissions | Main manifest + native alarm service |
| No analytics/ads/Firebase | Network/third parties | Dependency and source audit |
| Paid-app release, IAP disabled | Purchases | `ReleaseConfig.monetizationMode == paidApp` |
| User-initiated support email | Contact | `SupportContact.mailtoUri()` |
| Network-capable system voices | Third parties | TTS engine metadata and platform APIs |

Re-run this mapping after any dependency or permission change.

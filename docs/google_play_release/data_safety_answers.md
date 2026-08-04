# Data Safety draft

This is a Console-entry draft, not a submitted declaration. Reconfirm against the final signed AAB and Play SDK Index before submission.

## Collection and sharing

- **Audio files:** accessed on-device only when the user records. Stored in app-specific storage; not sent off-device by app code; therefore not declared as collected by the developer. Excluded from Android cloud backup/device transfer.
- **Alarm labels, schedules, voice choice and settings:** stored locally in Hive/preferences; not sent to developer servers.
- **Support email:** user-initiated external email. The generated draft contains support subject, app version/build and platform; it does not attach recordings, alarm labels or device identifiers. Information the user manually adds to email is collected for support and is not shared for advertising.
- **Payments:** current mode is a paid Play listing; no in-app billing is initialized. Google Play processes purchase/account/payment data outside app code.
- **Third-party SDKs:** no Firebase, analytics, crash reporting or ads SDK found. System TTS engines can access network for voices marked network-required under their own provider policies.

## Security and deletion

- No app-operated server transport exists, so transport encryption is not applicable to local data. HTTPS is used for legal/support links.
- Users delete recordings by deleting the segment/alarm where unreferenced, or by uninstalling/clearing app data.
- Support emails can be deleted on request by contacting `timeforwork789@gmail.com` with enough information to identify the message; never request a recording or password.

## Console answers requiring owner confirmation

- Data collection: likely **No** for automatic app collection; support email is user-initiated and must be assessed against current Google definitions at submission time.
- Data sharing: **No** by app code.
- Ads: **No**.
- Account creation: **No**.
- Independent security review: **No**, unless later completed.

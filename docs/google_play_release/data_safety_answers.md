# Data Safety draft

This is a Console-entry draft, not a submitted declaration. Reconfirm it against the final signed AAB and the Play SDK Index before submission.

## Collection and sharing

- Alarm schedules, labels, settings, trial timestamps, entitlement cache, voice choices and recordings are stored in app-private local storage. App code does not send them to a developer server.
- Recording is user-initiated, stored locally, excluded from Android backup/device transfer, and never uploaded by app code.
- Google Play Billing processes the annual subscription. The app receives purchase state, an opaque purchase token and product metadata needed for client-side entitlement. It does not receive or store card numbers and does not log or share purchase tokens.
- Support email is user-initiated. The prepared message contains app/build/platform diagnostics, not alarm labels, recordings or device identifiers.
- No Firebase, analytics, crash-reporting or advertising SDK is present. There is no account system or developer backend.
- A device TTS engine can use its own network service for voices it marks network-required, under that provider's policy.

## Trial and deletion

The free download includes a seven-day app-managed trial. Trial start, latest trusted UTC time and expiry are stored locally without IMEI, Advertising ID, fingerprinting or another device identifier. Clearing app data or uninstalling deletes these trial records and other local app data. Google Play retains purchase records under Google's policies, so Restore can recover an active subscription.

## Console answers requiring owner confirmation

- Data collection: assess Google Play Billing's current SDK disclosure in the Play SDK Index; app-owned alarm/recording data is not transmitted off device.
- Data sharing by app code: **No**.
- Ads: **No**.
- Account creation: **No**.
- Financial information: the app does not collect card/payment credentials; Google Play processes payment.
- Independent security review: **No**, unless one is later completed.

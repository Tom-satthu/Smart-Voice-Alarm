# Google Play internal testing checklist

Do not mark an item complete until it has been verified through an app installed from the Google Play Internal testing opt-in link. A sideloaded build cannot prove Play Billing behavior.

## Artifact and Console

- [ ] Signed release AAB uploaded.
- [ ] No Play Console warnings block the internal release.
- [ ] Play App Signing enabled and app-signing SHA-256 recorded privately.
- [ ] Subscription `premium_annual` exists and is active.
- [ ] Auto-renewing base plan `annual-auto` is active with a one-year billing period.
- [ ] USD 2.99 base price, regional prices, and taxes reviewed.
- [ ] No monthly plan and no Play-managed free-trial offer exist.
- [ ] Tester Google account added as a license tester and to the Internal testing track.
- [ ] Tester accepted the opt-in invitation.
- [ ] App installed from Google Play, not sideloaded.

## Billing and entitlement

- [ ] Localized annual price is visible and matches the Play purchase sheet.
- [ ] Purchase sheet opens for the exact annual product/base plan.
- [ ] Canceling the purchase sheet does not unlock Premium.
- [ ] A pending purchase does not unlock Premium.
- [ ] A completed purchase unlocks Premium.
- [ ] Initial purchase is acknowledged.
- [ ] Restore transactions restores an active entitlement.
- [ ] Reinstall with the same Google account restores the entitlement.
- [ ] Manage subscription link opens the correct Play subscription.
- [ ] Cancellation, expiration, grace/account-hold behavior is tested where Play test timing permits.
- [ ] Entitlement refresh after app resume is verified.
- [ ] The app-managed seven-day trial expiry path is exercised with a controlled test clock or documented QA setup; no Play-managed trial is configured.

## Alarm safety and release UX

- [ ] Existing alarms can still ring, be stopped, disabled, and deleted after entitlement expiry.
- [ ] Creating, editing, and duplicating alarms is blocked after entitlement expiry.
- [ ] System-sound alarm fired and was heard by a human.
- [ ] TTS alarm fired and was heard by a human.
- [ ] Recording alarm fired and was heard by a human.
- [ ] Ringing route, notification, foreground service, and Stop/Dismiss cleanup were verified.
- [ ] No test alarm remains enabled.
- [ ] Privacy, Subscription Terms, Support, and open-source licenses open correctly.
- [ ] No source-repository link appears in the release UI.

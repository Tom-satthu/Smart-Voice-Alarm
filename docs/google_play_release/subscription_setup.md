# Google Play annual subscription setup

The app must be **Free** in Play Console. Do not configure a paid download, monthly plan, lifetime product or Play-managed free-trial offer.

## Product configuration

- Subscription ID: `premium_annual`
- Base plan ID: `annual-auto`
- Type: auto-renewing subscription
- Billing period: 1 year
- Base price: USD 2.99 per year
- App UI price source: localized `ProductDetails` returned by Google Play; never hard-code USD 2.99 in production UI

Suggested product name: **Smart Voice Alarm Premium – Annual**

Suggested description: **Full access to Smart Voice Alarm for one year. Automatically renews annually unless canceled.**

Vietnamese name: **Smart Voice Alarm Premium – 1 năm**

Vietnamese description: **Sử dụng đầy đủ Smart Voice Alarm trong một năm. Tự động gia hạn hằng năm cho đến khi hủy.**

## Console procedure

1. Set App pricing to Free.
2. Create subscription `premium_annual`, then base plan `annual-auto` with a one-year auto-renewing period.
3. Set the USD 2.99 base price; review taxes, regional conversion and every generated country price.
4. Do not add an offer or free trial. Activate both subscription and base plan.
5. Add license testers and publish a signed AAB to an internal testing track.
6. Install only from the Play testing link and verify purchase, pending payment, cancellation, restore, same-account reinstall, manage/cancel, account hold/grace behavior exposed by Play, and test renewal/expiry timing.
7. Confirm the localized annual price shown in app exactly matches Play.

Until the product and base plan are active, status is `PLAY_CONSOLE_SUBSCRIPTION_CONFIGURATION_REQUIRED`. A sideload test is not proof that production Billing works.

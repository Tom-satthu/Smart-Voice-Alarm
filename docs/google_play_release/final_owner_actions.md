# Final Google Play owner actions

These are owner-operated Play Console steps. They are intentionally unchecked until the app owner completes and verifies them.

## A. Create the app record

1. Create the app as **Smart Voice Alarm** and choose the intended default listing language.
2. Select **App**, not Game.
3. Select **Free**. Do not create it as a paid-download app.
4. Declare that the app contains an in-app purchase/subscription.
5. Confirm package name `com.smartvoicealarm.app` before the first upload.

## B. Enable Play App Signing

1. Accept Play App Signing during the first release setup.
2. For a new app, prefer allowing Google to generate and protect the app-signing key.
3. Use the local upload key only to sign AAB files uploaded to Play Console.
4. Do not upload the private keystore except through a specific Play workflow that explicitly requires it.
5. After setup, record the Play app-signing SHA-256 certificate and upload-certificate SHA-256 in the owner's encrypted release records.
6. Follow `upload_key_backup_instructions.md` and verify the backups before relying on the key.

## C. Configure the annual subscription

1. Create subscription ID `premium_annual`.
2. Create base plan ID `annual-auto`.
3. Select auto-renewing with a billing period of one year.
4. Set the base price to USD 2.99 and review regional pricing and taxes.
5. Do not create a monthly plan.
6. Do not create a Play-managed free-trial offer; the seven-day trial is managed locally by the app without a payment method.
7. Activate both the subscription and base plan.

## D. Test through Google Play

1. Add the tester Google accounts as license testers.
2. Create an Internal testing release and upload the signed AAB.
3. Publish the internal release, open the tester opt-in link, and install from Google Play rather than sideloading.
4. Work through every item in `internal_testing_checklist.md`, including localized price, purchase, cancel, pending, restore, reinstall, manage/cancel, and entitlement refresh after resume.
5. Do not treat a sideloaded APK or bundletool APK as proof that real Play Billing works.

## E. Complete Store and policy sections

1. Enter the public Privacy Policy URL and verify Support and Subscription Terms links.
2. Complete Data Safety against the final AAB and current Play SDK Index.
3. Declare **Ads: No**.
4. Complete App access and reviewer instructions.
5. Complete content rating and target audience.
6. Complete exact-alarm, full-screen-intent, and foreground-service declarations.
7. Complete the localized store listing, screenshots, feature graphic, release notes, and contact details.
8. Select intended countries/regions and review pricing/tax availability.
9. Have the owner listen to system-sound, TTS, and recording alarms and confirm Stop/Dismiss behavior.
10. Resolve every blocking Console warning before production review.

Do not submit for production review until Billing has passed using an Internal-testing Play install, human audio verification is complete, and all declarations and assets have been owner-approved.

# Upload key backup instructions

Use this checklist immediately after creating or restoring the Smart Voice Alarm upload key. The upload key signs AAB files sent to Google Play; it is not the Play App Signing key that Google protects for the installed application.

## Record privately

Store the following together in an encrypted password manager or encrypted vault:

- application: Smart Voice Alarm;
- Android package: `com.smartvoicealarm.app`;
- keystore filename and storage location;
- key alias;
- store password;
- key password;
- creation date and certificate expiration date;
- public upload certificate and its SHA-256 fingerprint;
- responsible owner and recovery notes.

Never put passwords, the private keystore, private-key data, or machine-specific absolute paths in Git, documentation, screenshots, chat, tickets, or shell history.

## Backup standard

1. Keep the working keystore outside the repository.
2. Keep at least two encrypted backup copies in two separately controlled locations.
3. Test that each backup can be opened and contains the expected alias without exposing passwords in logs.
4. Keep the exported public certificate with the private recovery record. The public certificate is safe to inspect, but do not commit it unless the owner explicitly chooses to publish it.
5. Record which Play Console app uses the key and whether Play App Signing has accepted it as the upload certificate.

Do not upload the keystore to GitHub, a public Google Drive link, unencrypted email, or an unencrypted removable drive. If a registered upload key is lost or exposed, use Google Play's upload-key reset process; do not replace it silently or reuse another application's key.

## Before every release commit

Run these checks without printing `android/keystore.properties`:

```text
git check-ignore android/keystore.properties
git ls-files android/keystore.properties
git status --short
```

The properties file must be ignored and absent from tracked files. AAB, APK, `.jks`, `.keystore`, and private signing material must also remain untracked.

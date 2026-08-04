# Upload artifact information

Build timestamp: 2026-08-05 01:23:07 ICT

Source commit used for the build: `de63b3d26d552952bef351d24221389991850c81` plus the reviewed, uncommitted Premium-layout and release-documentation changes later committed on PR #7.

| Field | Verified value |
|---|---|
| Application ID | `com.smartvoicealarm.app` |
| Version name/code | `1.0.0` / `1` |
| Signed AAB path | `build/app/outputs/bundle/release/app-release.aab` |
| AAB size | 61,877,998 bytes |
| AAB SHA-256 | `EC5B81E72173FFF1044CB1D62ADE2C73B16C1ADDD7D7843B00ADA8BD8CA5E375` |
| Upload certificate SHA-256 | `0537B2EF433F8B015AC93633CB59F95478A6C5ED86835700B7E362CE5894ADE5` |
| Certificate | RSA 3072-bit, `SHA256withRSA`, valid through 2056-07-28 |
| AAB signature | `jarsigner` verified; self-signed upload certificate is expected before Play App Signing |
| Bundletool | Official `google/bundletool` 1.18.3 validation passed |
| APK set | `build/app/outputs/bundle/release/app-release.apks`, 63,197,209 bytes |
| AAB-derived APK | `universal.apk`, 63,196,901 bytes, SHA-256 `0F254E426CF4F1DAD46E684800F1051FFD9BCB9746B4C2F21D8800350CFA2062` |
| APK signature | APK Signature Scheme v2/v3 verified; same upload-certificate fingerprint as AAB |
| Release build | Not debuggable; installed successfully on Samsung SM-G975F / Android 12 |

`RELEASE_SIGNING_READY`: **YES**.

Do not commit `.jks`, `.keystore`, `android/keystore.properties`, APK, APKS, AAB, bundletool output, password files, or private signing material. The local AAB is ready for an Internal testing upload, but real Billing must be tested from a Google Play installation before production submission.

# Upload artifact information

| Field | Current value |
|---|---|
| Application ID | `com.smartvoicealarm.app` |
| Version name/code | `1.0.0` / `1` |
| Expected artifact | `build/app/outputs/bundle/release/app-release.aab` |
| Signing | `RELEASE_SIGNING_BLOCKED` — no local ignored keystore configuration found |
| Debug fallback | Disabled; release Gradle build fails instead |
| AAB path/size/certificate | Pending valid upload key |
| Bundletool validation | Pending AAB |
| AAB-derived smoke test | Pending AAB |

Never commit `.jks`, `.keystore` or `android/keystore.properties`. After the owner restores the existing upload key, run `flutter build appbundle --release`, validate with bundletool, inspect the artifact certificate without printing secrets, and record SHA-256 of the AAB here.

# Upload artifact information

| Field | Current value |
|---|---|
| Application ID | `com.smartvoicealarm.app` |
| Version name/code | `1.0.0` / `1` |
| Expected AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Signing | `RELEASE_SIGNING_BLOCKED` — upload keystore/properties absent; debug fallback correctly refused |
| AAB path/size/certificate | Not available because release build stopped at signing guard |
| Bundletool validation | Blocked until signed AAB exists |
| AAB-derived Samsung smoke test | Blocked until signed AAB exists |
| Debug APK smoke artifact | Built and installed, but is not a Play upload artifact |

Never commit `.jks`, `.keystore`, `android/keystore.properties`, APK or AAB files. Create/restore the upload key interactively, then follow `upload_key_backup_guide.md`, build the release AAB, validate it with bundletool, inspect its signing certificate and record its SHA-256 here.

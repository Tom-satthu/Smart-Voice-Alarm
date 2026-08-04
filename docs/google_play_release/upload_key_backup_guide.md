# Upload key backup guide

- Generate the upload key with `keytool` interactively; type passwords only into the local terminal.
- Store the keystore outside the repository (or only at an ignored path) and keep `android/keystore.properties` ignored.
- Maintain at least two encrypted backups in separately controlled locations.
- Record alias, certificate SHA-256, creation/expiry dates and responsible owner in a private password manager; never place passwords in Git, screenshots, chat or issue trackers.
- Verify with `git check-ignore`, `git status` and `git ls-files` before every commit.
- Do not overwrite a key already registered with Play App Signing. Follow Google Play's upload-key reset process if the registered upload key is lost.

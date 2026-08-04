# Store release information checklist

**Priority platform:** Google Play (Android) first. iOS deferred until a Mac is available.

**Confirmed owner facts**

| Item | Value |
|------|-------|
| Support email | timeforwork789@gmail.com |
| Google Play public developer name | Nguyên Đức |
| Play Console account | Purchased and verification completed |
| iOS display name (planned, unverified) | Trần Thị Cẩm Mỹ — `IOS_SELLER_NAME_NEEDS_VERIFICATION_AGAINST_APPLE_ACCOUNT` |

Statuses: `READY` | `MISSING` | `NEEDS OWNER INPUT` | `NOT APPLICABLE` | `NEEDS VERIFICATION` | `PENDING`

---

## Privacy / Support hosting plan (GitHub Pages)

Owner has **no custom domain**. Recommended approach: a **separate public legal docs repo** (proposed name `smart-voice-alarm-legal`), then enable GitHub Pages.

**Do not create the repo or enable Pages until the owner explicitly allows it.**

Proposed structure:

```text
/
  index.html
  privacy-policy/index.html
  support/index.html
```

| URL | Status |
|-----|--------|
| Legal site base URL | PENDING |
| Privacy Policy URL | PENDING (`PRIVACY_POLICY_URL_REQUIRED`) |
| Support page URL | PENDING |

Local drafts ready for owner review:

- `docs/privacy_policy_draft_en.md`
- `docs/privacy_policy_draft_vi.md`
- `docs/support_page_draft.md`
- `docs/privacy_data_audit.md`

After Pages is live and approved, set `AppConstants.privacyPolicyUrl` (and optionally website/support URL) to the real HTTPS URLs only.

---

## Android release priority buckets

### A. Before uploading an AAB

| Item | Status | Notes |
|------|--------|-------|
| Package name `com.smartvoicealarm.app` | READY | Do not change |
| versionName / versionCode | READY | `pubspec.yaml` `1.0.0+1` |
| Release signing / upload keystore | NEEDS OWNER INPUT | Do not commit secrets; `keystore.properties` pattern exists |
| Play App Signing enrollment | NEEDS OWNER INPUT | |
| AAB build succeeds with release key | NEEDS VERIFICATION | |
| App icon (adaptive) | NEEDS VERIFICATION | Present in Android res |
| No debug-only support URLs in release UI | READY | Broken URLs removed; privacy hidden until set |

### B. Before sending for review

| Item | Status | Notes |
|------|--------|-------|
| Privacy Policy public HTTPS URL | MISSING / PENDING | Host via legal Pages plan |
| Support email on listing | READY | timeforwork789@gmail.com |
| Support website / page | PENDING | `/support/` on legal site |
| Data Safety form | NEEDS OWNER INPUT | Use `privacy_data_audit.md` |
| Ads declaration | READY (code: no ads) | Still answer in Console |
| App access (no login) | READY / NOT APPLICABLE | No restricted features behind login |
| Exact alarm declaration | NEEDS VERIFICATION | Manifest has exact alarm permissions |
| Foreground service declaration | NEEDS VERIFICATION | `mediaPlayback` FGS |
| Content rating questionnaire | NEEDS OWNER INPUT | |
| Target audience | NEEDS OWNER INPUT | |
| Short + full description | NEEDS OWNER INPUT | |
| Feature graphic 1024×500 | MISSING | |
| Phone screenshots | MISSING | |
| Category / tags / countries / pricing | NEEDS OWNER INPUT | Free + Premium lifetime |
| Premium product configured in Play Console | NEEDS VERIFICATION | `smart_voice_alarm_unlimited` |
| Testing track requirements | NEEDS OWNER INPUT | Follow current personal/org account rules |
| Release notes | NEEDS OWNER INPUT | |

### C. After first release (can wait)

| Item | Status |
|------|--------|
| Play Store public listing URL in app (Rate/Share) | PENDING until published |
| Custom domain for legal pages | NOT APPLICABLE unless owner buys one later |
| Marketing site | NOT APPLICABLE currently |
| Tablet screenshots | NEEDS OWNER INPUT only if listing tablets |
| Terms of Use page | NOT required for current local + lifetime IAP model; optional |

### D. iOS only — defer

| Item | Status |
|------|--------|
| Mac + Xcode archive | MISSING (deferred) |
| Apple Developer team / signing | NEEDS OWNER INPUT |
| Seller name verification | `IOS_SELLER_NAME_NEEDS_VERIFICATION_AGAINST_APPLE_ACCOUNT` (planned: Trần Thị Cẩm Mỹ) |
| App Store numeric ID | `APP_STORE_ID_REQUIRED` |
| App Privacy questionnaire | Deferred |
| iOS screenshots / review notes | Deferred |
| Hard-code iOS seller into Android legal pages | **Must not** |

iOS work must not block Android submission.

---

## Google Play field checklist

| Field | Status | Notes |
|-------|--------|-------|
| App name | READY | Smart Voice Alarm |
| Short description | NEEDS OWNER INPUT | |
| Full description | NEEDS OWNER INPUT | |
| App icon | NEEDS VERIFICATION | |
| Feature graphic | MISSING | |
| Phone screenshots | MISSING | |
| Tablet screenshots | NEEDS OWNER INPUT | |
| App category | NEEDS OWNER INPUT | |
| Tags | NEEDS OWNER INPUT | |
| Support email | READY | timeforwork789@gmail.com |
| Support website | PENDING | GitHub Pages plan |
| Privacy Policy URL | PENDING | |
| Data Safety | NEEDS OWNER INPUT | |
| Content rating | NEEDS OWNER INPUT | |
| Target audience | NEEDS OWNER INPUT | |
| Ads declaration | READY (code) | Declare No ads |
| App access | NOT APPLICABLE | No login |
| Exact alarm declaration | NEEDS VERIFICATION | |
| FGS declarations | NEEDS VERIFICATION | |
| Countries/regions | NEEDS OWNER INPUT | |
| Pricing | NEEDS OWNER INPUT | |
| Release notes | NEEDS OWNER INPUT | |
| AAB | NEEDS VERIFICATION | Needs release keystore |
| Play App Signing | NEEDS OWNER INPUT | |
| Developer account verification | READY | Owner confirmed complete |
| Testing requirements | NEEDS OWNER INPUT | |
| Package name | READY | `com.smartvoicealarm.app` |
| Version code/name | READY | `1.0.0+1` |
| Public developer name | READY | Nguyên Đức |

## Apple App Store (deferred)

Tracked for later only — see bucket D. Do not treat as Android blockers.

---

## App identity (code)

| Item | Value / status |
|------|----------------|
| Flutter package | `smart_voice_alarm` |
| Version | `1.0.0+1` |
| Android applicationId | `com.smartvoicealarm.app` |
| Android namespace | `com.smartvoicealarm.app` |
| Android label | Smart Voice Alarm |
| iOS display name (static) | Smart Voice Alarm |
| In-app developer string | Nguyên Đức |
| Support email constant | timeforwork789@gmail.com |
| Privacy URL constant | empty until PENDING URL is live |
| GitHub (app source) | https://github.com/Tom-deptrai/Smart-Voice-Alarm |
| Legal Pages repo | Not created — proposed `smart-voice-alarm-legal` |

## Owner actions still needed (Android path)

1. Approve privacy/support drafts  
2. Allow creation of `smart-voice-alarm-legal` + GitHub Pages  
3. Confirm effective date on privacy policy  
4. Wire real Privacy URL into app after publish  
5. Prepare feature graphic + screenshots  
6. Complete Play Console questionnaires (Data Safety, content rating, audience, exact alarm, FGS)  
7. Configure Premium product + testing track  
8. Provide/use release upload keystore (never commit secrets)  
9. Confirm whether to vendor Google Fonts offline for stricter “local-only” messaging  

## Intentionally omitted from release Settings UI

- Rate app / Share app until store URLs exist  
- Privacy / Terms rows until real HTTPS URLs exist  
- iOS seller name on Android About / legal pages  
- Placeholder domains (`example.com`, dead GitHub Pages URLs)

# Smart Voice Alarm

Repo: `Tom-deptrai/Smart-Voice-Alarm`. Working branch: `feature/ios-alarmkit` (tracks PR #10).

## Git rules

- Do not merge PR #10 unless the user explicitly asks.
- No rebase, no amend, no force-push, no `git reset --hard` — ever, unless explicitly requested.
- After a coding task is complete and verified safe (analyze/tests/build pass), commit and push to `origin feature/ios-alarmkit`.
- Never push to any other branch without explicit instruction.

## Product constants — do not change without explicit instruction

- Package: `com.smartvoicealarm.app`
- Version: `1.0.0+1`
- Billing: product `premium_annual`, base plan `annual-auto`

## Protected behavior

These are stable, user-verified on real devices. Never regress them silently:

- iOS AlarmKit scheduling and lifecycle
- Math Challenge (enable/disable, solving ends the occurrence)
- Voice/TTS/recording playback, ringtone rendering, the 5-second gap, stop recovery
- One-shot alarms auto-turn OFF after completion; OFF stays OFF; deleted alarms never reappear
- Android alarm behavior — must stay exactly as-is; iOS-only changes must not touch Android code paths

If a task seems to require touching any of the above, stop and confirm with the user first — don't guess.

## Working process

- Audit the current source before any non-trivial change — read the actual code path involved, don't assume from memory or past sessions.
- Prefer release builds (`flutter build ios --release --no-codesign`, or a signed release install) when the user wants to try the app from the home screen icon on a real iPhone — debug builds behave differently for background/lock-screen notification delivery.
- After every task, report: files changed, tests run and result, commit SHA (if committed), push status, and the exact revert command.

## Do not include in this file

No secrets, tokens, credentials, or device identifiers (UDIDs, provisioning profile IDs, etc.).

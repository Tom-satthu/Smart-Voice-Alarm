# App access / reviewer notes

No account, login, invitation code or credentials are required. A first successful foreground launch starts a full-feature seven-day app-managed trial without asking for a payment method.

Reviewer path:

1. Launch the app; the trial starts only after the foreground UI initializes.
2. Create/edit alarms and add ringtone, device TTS or a local recording. Microphone permission is requested only after Record is pressed.
3. Open Voice Sequence to see the genuine remaining-trial countdown and optional Premium entry point.
4. Open Settings > Premium to inspect the annual subscription, Restore and Google Play management actions.

The production app contains no hidden entitlement bypass. An expired state is covered by automated fake-clock tests; real purchase/expiry must be checked from an internal Play testing track with a license tester after `premium_annual` / `annual-auto` is active. Sideloaded builds may correctly show Product unavailable.

Public legal pages are live at `https://tom-deptrai.github.io/smart-voice-alarm-legal/`.

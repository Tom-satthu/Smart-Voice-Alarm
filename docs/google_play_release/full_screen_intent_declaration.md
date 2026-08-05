# Full-screen intent declaration

`USE_FULL_SCREEN_INTENT` is used only when a user-created alarm is actively firing. The native foreground service posts a high-importance `CATEGORY_ALARM` notification with a full-screen `PendingIntent`. Normal reminders do not use this native full-screen path.

If full-screen access is unavailable, Android retains the high-priority alarm notification and content intent; the user can tap it to reach the ringing screen. No marketing or ordinary notification opens full screen.

Demo video script: show an enabled alarm, lock the device, wait for it to fire, show the ringing UI/notification, demonstrate Stop challenge and cleanup, then show a daily reminder does not open full screen. Do not edit or simulate the firing event in the video.

Android 14 permission-state behavior still requires final physical-device verification.

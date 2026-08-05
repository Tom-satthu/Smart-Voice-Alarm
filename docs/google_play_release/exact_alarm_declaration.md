# Exact alarm declaration

Smart Voice Alarm's core purpose is to wake the user at a time they explicitly schedule. The app declares `USE_EXACT_ALARM` for Android 13+ and scopes `SCHEDULE_EXACT_ALARM` to Android 12/12L (`maxSdkVersion=32`). It uses `AlarmManager.setAlarmClock`, with one stable `PendingIntent` request code derived from the persisted alarm ID.

Without exact delivery, the app's primary alarm function can be delayed by Doze or idle restrictions and fail its user expectation. The permission is not used for analytics, sync, advertising or background refresh.

Demo steps: create an enabled alarm 2–3 minutes ahead, background/lock the device, wait for the alarm, show the alarm-category notification/full-screen surface, then stop it. Repeat after reboot and after changing time zone. Show edit, disable and delete cancel/reschedule behavior.

Owner must submit the exact-alarm declaration in Play Console and verify current policy eligibility before publishing.

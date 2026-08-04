# Foreground service declaration

Type: `mediaPlayback`
Permission: `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`

The service starts from the exact alarm broadcast so audible alarm media can begin immediately while Flutter initializes. It calls `startForeground` before audio/vibration, owns a partial wake lock capped at 10 minutes, and stops foreground/audio/vibration/wake lock on Stop, dismiss, snooze, engine handoff, destruction or the 10-minute timeout.

Delay/interruption can make a scheduled wake-up silent or late. The service is not used to record audio and `FOREGROUND_SERVICE_MICROPHONE` is not declared.

Demo video script: schedule alarm, lock device, show foreground alarm notification and audible-state indicators, stop it, then show notification/service are removed. Human audio confirmation must accompany the technical demo.

package com.smartvoicealarm.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Plays alarm audio immediately (no notification tap required) and keeps a
 * full-screen-capable ongoing notification while Flutter boots and takes over.
 */
class AlarmForegroundService : Service() {
    private var player: MediaPlayer? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelfSafe()
                return START_NOT_STICKY
            }
            else -> {
                val alarmId = intent?.getStringExtra(AlarmScheduler.EXTRA_ALARM_ID) ?: "alarm"
                val label = intent?.getStringExtra(AlarmScheduler.EXTRA_LABEL) ?: "Alarm"
                ensureChannel()
                val notification = buildNotification(alarmId, label)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
                    )
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }
                startRingtone()
            }
        }
        return START_STICKY
    }

    private fun startRingtone() {
        if (player != null) return
        try {
            player = MediaPlayer.create(this, R.raw.soft_chime)?.apply {
                isLooping = true
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build(),
                )
                start()
            }
        } catch (_: Exception) {
            // Flutter engine will take over playback when ready.
        }
    }

    private fun buildNotification(alarmId: String, label: String): Notification {
        val fullScreen = PendingIntent.getActivity(
            this,
            alarmId.hashCode(),
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
                putExtra("from_native_alarm", true)
            },
            pendingFlags(),
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(label)
            .setContentText("Smart Voice Alarm")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setFullScreenIntent(fullScreen, true)
            .setContentIntent(fullScreen)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Alarms",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Voice alarm alerts"
            setSound(null, null)
            enableVibration(true)
        }
        mgr.createNotificationChannel(channel)
    }

    private fun pendingFlags(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    private fun stopSelfSafe() {
        try {
            player?.stop()
        } catch (_: Exception) {
        }
        player?.release()
        player = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        try {
            player?.stop()
        } catch (_: Exception) {
        }
        player?.release()
        player = null
        super.onDestroy()
    }

    companion object {
        const val ACTION_START = "com.smartvoicealarm.app.ACTION_START_ALARM"
        const val ACTION_STOP = "com.smartvoicealarm.app.ACTION_STOP_ALARM"
        const val CHANNEL_ID = "smart_voice_alarm_native"
        const val NOTIFICATION_ID = 42001

        fun stop(context: Context) {
            val intent = Intent(context, AlarmForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }
}

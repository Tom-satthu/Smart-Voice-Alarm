package com.smartvoicealarm.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray

/**
 * Fires when AlarmManager triggers. Starts the foreground ringing service and
 * brings the full-screen alarm UI to the front without requiring a tap.
 * Also handles the notification Stop action.
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val app = context.applicationContext
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED ||
            intent?.action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            intent?.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent?.action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            AlarmScheduler.rescheduleAll(app)
            return
        }

        if (intent?.action == ACTION_STOP) {
            AlarmForegroundService.stop(app)
            MainActivity.notifyNativeAlarmStopped()
            return
        }

        if (intent?.action != ACTION_FIRE) return

        val alarmId = intent.getStringExtra(AlarmScheduler.EXTRA_ALARM_ID) ?: return
        val label = intent.getStringExtra(AlarmScheduler.EXTRA_LABEL) ?: "Alarm"
        val ringtone = intent.getStringExtra(AlarmScheduler.EXTRA_RINGTONE)

        val serviceIntent = Intent(app, AlarmForegroundService::class.java).apply {
            action = AlarmForegroundService.ACTION_START
            putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmScheduler.EXTRA_LABEL, label)
            putExtra(AlarmScheduler.EXTRA_RINGTONE, ringtone)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            app.startForegroundService(serviceIntent)
        } else {
            app.startService(serviceIntent)
        }

        val activity = Intent(app, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
            putExtra("from_native_alarm", true)
        }
        app.startActivity(activity)

        rescheduleOrDisable(app, alarmId)
    }

    private fun rescheduleOrDisable(context: Context, alarmId: String) {
        val prefs = context.getSharedPreferences("sva_native_alarms", Context.MODE_PRIVATE)
        val raw = prefs.getString("alarms", "[]") ?: "[]"
        val arr = JSONArray(raw)
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            if (obj.getString("id") != alarmId) continue
            val mask = obj.optInt("repeatDaysMask", 0)
            val hour = obj.optInt("hour", 7)
            val minute = obj.optInt("minute", 0)
            val label = obj.optString("label", "Alarm")
            val ringtone = obj.optString("ringtone", null)
            if (mask == 0) {
                AlarmScheduler.markDisabled(context, alarmId)
            } else {
                val next = AlarmScheduler.nextTriggerMillis(
                    System.currentTimeMillis() + 1_000,
                    hour,
                    minute,
                    mask,
                )
                AlarmScheduler.schedule(
                    context,
                    alarmId,
                    next,
                    label,
                    ringtone,
                    mask,
                    hour,
                    minute,
                )
            }
            return
        }
    }

    companion object {
        const val ACTION_FIRE = "com.smartvoicealarm.app.ACTION_FIRE_ALARM"
        const val ACTION_STOP = "com.smartvoicealarm.app.ACTION_STOP_ALARM_UI"
    }
}

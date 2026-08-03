package com.smartvoicealarm.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

/**
 * Schedules exact alarms via AlarmManager and persists payloads for reboot.
 */
object AlarmScheduler {
    private const val PREFS = "sva_native_alarms"
    private const val KEY_ALARMS = "alarms"

    const val EXTRA_ALARM_ID = "alarm_id"
    const val EXTRA_LABEL = "alarm_label"
    const val EXTRA_RINGTONE = "alarm_ringtone"

    fun schedule(
        context: Context,
        alarmId: String,
        triggerAtMillis: Long,
        label: String,
        ringtoneName: String?,
        repeatDaysMask: Int,
        hour: Int,
        minute: Int,
    ) {
        cancel(context, alarmId)
        persist(
            context,
            alarmId,
            triggerAtMillis,
            label,
            ringtoneName,
            repeatDaysMask,
            hour,
            minute,
            enabled = true,
        )

        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = pendingIntent(context, alarmId, label, ringtoneName)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val show = PendingIntent.getActivity(
                context,
                alarmId.hashCode() xor 0x55,
                Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra(EXTRA_ALARM_ID, alarmId)
                },
                pendingFlags(),
            )
            am.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAtMillis, show), pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pi)
        }
    }

    fun cancel(context: Context, alarmId: String) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(pendingIntent(context, alarmId, "", null))
        removePersisted(context, alarmId)
    }

    fun cancelAll(context: Context) {
        val prefs = prefs(context)
        val raw = prefs.getString(KEY_ALARMS, "[]") ?: "[]"
        val arr = JSONArray(raw)
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            val id = obj.getString("id")
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.cancel(
                pendingIntent(
                    context,
                    id,
                    obj.optString("label"),
                    obj.optString("ringtone", null),
                ),
            )
        }
        prefs.edit().putString(KEY_ALARMS, "[]").apply()
    }

    fun rescheduleAll(context: Context) {
        val prefs = prefs(context)
        val raw = prefs.getString(KEY_ALARMS, "[]") ?: "[]"
        val arr = JSONArray(raw)
        val now = System.currentTimeMillis()
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            if (!obj.optBoolean("enabled", true)) continue
            val id = obj.getString("id")
            val label = obj.optString("label", "Alarm")
            val ringtone = obj.optString("ringtone", null)
            val mask = obj.optInt("repeatDaysMask", 0)
            val hour = obj.optInt("hour", 7)
            val minute = obj.optInt("minute", 0)
            val next = nextTriggerMillis(now, hour, minute, mask)
            schedule(context, id, next, label, ringtone, mask, hour, minute)
        }
    }

    fun nextTriggerMillis(now: Long, hour: Int, minute: Int, repeatDaysMask: Int): Long {
        val cal = java.util.Calendar.getInstance().apply {
            timeInMillis = now
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
            set(java.util.Calendar.HOUR_OF_DAY, hour)
            set(java.util.Calendar.MINUTE, minute)
        }
        for (offset in 0..8) {
            val candidate = java.util.Calendar.getInstance().apply {
                timeInMillis = cal.timeInMillis
                add(java.util.Calendar.DAY_OF_YEAR, offset)
            }
            if (candidate.timeInMillis <= now) continue
            if (repeatDaysMask == 0) return candidate.timeInMillis
            val dayBit = calendarDayBit(candidate.get(java.util.Calendar.DAY_OF_WEEK))
            if ((repeatDaysMask and dayBit) != 0) return candidate.timeInMillis
        }
        return now + 60_000
    }

    /** Monday=1 … Sunday=64 */
    fun calendarDayBit(calendarDayOfWeek: Int): Int {
        return when (calendarDayOfWeek) {
            java.util.Calendar.MONDAY -> 1
            java.util.Calendar.TUESDAY -> 2
            java.util.Calendar.WEDNESDAY -> 4
            java.util.Calendar.THURSDAY -> 8
            java.util.Calendar.FRIDAY -> 16
            java.util.Calendar.SATURDAY -> 32
            else -> 64
        }
    }

    private fun pendingIntent(
        context: Context,
        alarmId: String,
        label: String,
        ringtoneName: String?,
    ): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = AlarmReceiver.ACTION_FIRE
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_LABEL, label)
            putExtra(EXTRA_RINGTONE, ringtoneName)
        }
        return PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            pendingFlags(),
        )
    }

    private fun pendingFlags(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun persist(
        context: Context,
        alarmId: String,
        triggerAtMillis: Long,
        label: String,
        ringtoneName: String?,
        repeatDaysMask: Int,
        hour: Int,
        minute: Int,
        enabled: Boolean,
    ) {
        val prefs = prefs(context)
        val arr = JSONArray(prefs.getString(KEY_ALARMS, "[]") ?: "[]")
        val next = JSONArray()
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            if (obj.getString("id") != alarmId) next.put(obj)
        }
        next.put(
            JSONObject()
                .put("id", alarmId)
                .put("triggerAt", triggerAtMillis)
                .put("label", label)
                .put("ringtone", ringtoneName)
                .put("repeatDaysMask", repeatDaysMask)
                .put("hour", hour)
                .put("minute", minute)
                .put("enabled", enabled),
        )
        prefs.edit().putString(KEY_ALARMS, next.toString()).apply()
    }

    private fun removePersisted(context: Context, alarmId: String) {
        val prefs = prefs(context)
        val arr = JSONArray(prefs.getString(KEY_ALARMS, "[]") ?: "[]")
        val next = JSONArray()
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            if (obj.getString("id") != alarmId) next.put(obj)
        }
        prefs.edit().putString(KEY_ALARMS, next.toString()).apply()
    }

    fun markDisabled(context: Context, alarmId: String) {
        val prefs = prefs(context)
        val arr = JSONArray(prefs.getString(KEY_ALARMS, "[]") ?: "[]")
        val next = JSONArray()
        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            if (obj.getString("id") == alarmId) {
                obj.put("enabled", false)
            }
            next.put(obj)
        }
        prefs.edit().putString(KEY_ALARMS, next.toString()).apply()
        cancel(context, alarmId)
    }
}

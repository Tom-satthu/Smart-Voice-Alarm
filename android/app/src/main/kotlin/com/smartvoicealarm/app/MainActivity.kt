package com.smartvoicealarm.app

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val alarmsChannel = "com.smartvoicealarm.app/alarms"
    private val ttsChannel = "com.smartvoicealarm.app/tts"
    private var launchAlarmId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureAlarmExtra(intent, notifyFlutter = false)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureAlarmExtra(intent, notifyFlutter = true)
    }

    private fun captureAlarmExtra(intent: Intent?, notifyFlutter: Boolean) {
        val id = intent?.getStringExtra(AlarmScheduler.EXTRA_ALARM_ID)
        if (!id.isNullOrBlank()) {
            launchAlarmId = id
            if (notifyFlutter) {
                notifyAlarmTriggered(id)
            }
        }
        if (intent?.getBooleanExtra(EXTRA_STOP_ALARM, false) == true) {
            AlarmForegroundService.stop(applicationContext)
            notifyNativeAlarmStopped()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            alarmsChannel,
        )
        alarmsMethodChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val id = call.argument<String>("id")
                        ?: return@setMethodCallHandler result.error("bad_args", "id", null)
                    val triggerAt = call.argument<Number>("triggerAtMillis")?.toLong()
                        ?: return@setMethodCallHandler result.error("bad_args", "triggerAtMillis", null)
                    val label = call.argument<String>("label") ?: "Alarm"
                    val ringtone = call.argument<String>("ringtoneName")
                    val mask = call.argument<Number>("repeatDaysMask")?.toInt() ?: 0
                    val hour = call.argument<Number>("hour")?.toInt() ?: 7
                    val minute = call.argument<Number>("minute")?.toInt() ?: 0
                    AlarmScheduler.schedule(
                        applicationContext,
                        id,
                        triggerAt,
                        label,
                        ringtone,
                        mask,
                        hour,
                        minute,
                    )
                    result.success(null)
                }
                "cancelAlarm" -> {
                    val id = call.argument<String>("id")
                        ?: return@setMethodCallHandler result.error("bad_args", "id", null)
                    AlarmScheduler.cancel(applicationContext, id)
                    result.success(null)
                }
                "cancelAll" -> {
                    AlarmScheduler.cancelAll(applicationContext)
                    result.success(null)
                }
                "rescheduleAll" -> {
                    AlarmScheduler.rescheduleAll(applicationContext)
                    result.success(null)
                }
                "stopForegroundAlarm" -> {
                    AlarmForegroundService.stop(applicationContext)
                    result.success(null)
                }
                "markDisabled" -> {
                    val id = call.argument<String>("id")
                        ?: return@setMethodCallHandler result.error("bad_args", "id", null)
                    AlarmScheduler.markDisabled(applicationContext, id)
                    result.success(null)
                }
                "consumeLaunchAlarmId" -> {
                    val id = launchAlarmId
                    launchAlarmId = null
                    result.success(id)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ttsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openInstallTtsData" -> {
                        try {
                            startActivity(
                                Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA).addFlags(
                                    Intent.FLAG_ACTIVITY_NEW_TASK,
                                ),
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("tts_install", e.message, null)
                        }
                    }
                    "checkTtsData" -> {
                        try {
                            @Suppress("DEPRECATION")
                            startActivityForResult(
                                Intent(TextToSpeech.Engine.ACTION_CHECK_TTS_DATA),
                                REQ_CHECK_TTS,
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("tts_check", e.message, null)
                        }
                    }
                    "openSystemTtsSettings" -> {
                        try {
                            startActivity(
                                Intent("com.android.settings.TTS_SETTINGS").addFlags(
                                    Intent.FLAG_ACTIVITY_NEW_TASK,
                                ),
                            )
                            result.success(true)
                        } catch (_: Exception) {
                            try {
                                startActivity(
                                    Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
                                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                                )
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("tts_settings", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        if (alarmsMethodChannel != null) {
            alarmsMethodChannel = null
        }
        super.onDestroy()
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQ_CHECK_TTS) {
            // Result is informational; Flutter refreshes voices on resume.
        }
    }

    companion object {
        private const val REQ_CHECK_TTS = 9911
        const val EXTRA_STOP_ALARM = "stop_alarm"

        @Volatile
        private var alarmsMethodChannel: MethodChannel? = null

        private val mainHandler = Handler(Looper.getMainLooper())

        fun notifyAlarmTriggered(alarmId: String) {
            mainHandler.post {
                alarmsMethodChannel?.invokeMethod("onAlarmTriggered", alarmId)
            }
        }

        fun notifyNativeAlarmStopped() {
            mainHandler.post {
                alarmsMethodChannel?.invokeMethod("onNativeAlarmStopped", null)
            }
        }
    }
}

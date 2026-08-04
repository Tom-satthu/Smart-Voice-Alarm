package com.smartvoicealarm.app

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.Voice
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val alarmsChannel = "com.smartvoicealarm.app/alarms"
    private val ttsChannel = "com.smartvoicealarm.app/tts"
    private var launchAlarmId: String? = null
    private var probeTts: TextToSpeech? = null

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
                    "getEngineVoiceState" -> getEngineVoiceState(result)
                    "resolveSystemDefaultsForLocales" -> {
                        val locales = call.argument<List<String>>("locales")
                            ?: emptyList()
                        withFreshTts(result) { tts ->
                            locales.map { tag ->
                                resolveDefaultForLocale(tts, tag)
                            }
                        }
                    }
                    "getTtsVoices" -> withFreshTts(result) { tts ->
                        tts.voices?.mapNotNull { requested ->
                            tts.language = requested.locale
                            val setResult = tts.setVoice(requested)
                            val current = tts.voice
                            val selectable = setResult == TextToSpeech.SUCCESS && current != null &&
                                current.name == requested.name &&
                                current.locale.toLanguageTag().equals(requested.locale.toLanguageTag(), ignoreCase = true)
                            voiceToMap(requested)?.plus(
                                mapOf(
                                    "engine" to tts.defaultEngine,
                                    "selectable" to selectable,
                                    "resolvedName" to current?.name,
                                    "resolvedLocale" to current?.locale?.toLanguageTag(),
                                ),
                            )
                        } ?: emptyList<Map<String, Any?>>()
                    }
                    "probeTtsVoice" -> {
                        val name = call.argument<String>("name")
                            ?: return@setMethodCallHandler result.error("bad_args", "name", null)
                        val localeTag = call.argument<String>("locale")
                            ?: return@setMethodCallHandler result.error("bad_args", "locale", null)
                        withFreshTts(result) { tts ->
                            val requested = tts.voices?.firstOrNull {
                                it.name == name && it.locale.toLanguageTag().equals(localeTag, ignoreCase = true)
                            } ?: return@withFreshTts null
                            tts.language = requested.locale
                            val setResult = tts.setVoice(requested)
                            val current = tts.voice
                            if (setResult == TextToSpeech.SUCCESS && current?.name == requested.name &&
                                current.locale.toLanguageTag().equals(requested.locale.toLanguageTag(), ignoreCase = true)
                            ) voiceToMap(current) else null
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun resolveDefaultForLocale(
        tts: TextToSpeech,
        requestedTag: String,
    ): Map<String, Any?> {
        val locale = Locale.forLanguageTag(requestedTag.replace('_', '-'))
        // setLanguage only — do not call setVoice. This mirrors what the
        // system applies as the managed default for that language/locale.
        @Suppress("DEPRECATION")
        val availability = tts.setLanguage(locale)
        val current = tts.voice
        return hashMapOf(
            "requestedLocale" to requestedTag,
            "resolvedVoiceName" to current?.name,
            "resolvedLocale" to current?.locale?.toLanguageTag(),
            "enginePackage" to tts.defaultEngine,
            "languageAvailability" to availability,
            "name" to current?.name,
            "identifier" to current?.name,
            "locale" to (current?.locale?.toLanguageTag() ?: requestedTag),
            "engine" to tts.defaultEngine,
        )
    }

    private fun withFreshTts(result: MethodChannel.Result, block: (TextToSpeech) -> Any?) {
        val replied = AtomicBoolean(false)
        var instance: TextToSpeech? = null
        try {
            instance = TextToSpeech(applicationContext) { status ->
                val tts = instance
                if (!replied.compareAndSet(false, true)) return@TextToSpeech
                if (status != TextToSpeech.SUCCESS || tts == null) {
                    result.success(null)
                } else {
                    try { result.success(block(tts)) }
                    catch (e: Exception) { result.error("tts_probe", e.message, null) }
                    finally { tts.shutdown() }
                }
            }
        } catch (e: Exception) {
            if (replied.compareAndSet(false, true)) result.error("tts_probe", e.message, null)
        }
    }

    private fun getEngineVoiceState(result: MethodChannel.Result) {
        val replied = AtomicBoolean(false)
        fun reply(value: Any?) {
            if (replied.compareAndSet(false, true)) {
                result.success(value)
            }
        }

        try {
            probeTts?.shutdown()
            probeTts = TextToSpeech(applicationContext) { status ->
                val tts = probeTts
                if (status != TextToSpeech.SUCCESS || tts == null) {
                    reply(null)
                    tts?.shutdown()
                    probeTts = null
                    return@TextToSpeech
                }
                try {
                    val payload = hashMapOf<String, Any?>(
                        "current" to voiceToMap(tts.voice)?.plus(mapOf("engine" to tts.defaultEngine)),
                        "default" to voiceToMap(tts.defaultVoice)?.plus(mapOf("engine" to tts.defaultEngine)),
                        "engine" to tts.defaultEngine,
                        "voices" to (tts.voices?.map { voiceToMap(it) } ?: emptyList<Map<String, Any?>>()),
                    )
                    reply(payload)
                } catch (e: Exception) {
                    if (replied.compareAndSet(false, true)) {
                        result.error("tts_probe", e.message, null)
                    }
                } finally {
                    tts.shutdown()
                    if (probeTts === tts) {
                        probeTts = null
                    }
                }
            }
        } catch (e: Exception) {
            reply(null)
        }
    }

    private fun voiceToMap(voice: Voice?): Map<String, Any?>? {
        if (voice == null) return null
        val locale: Locale = voice.locale
        return hashMapOf(
            "name" to voice.name,
            "identifier" to voice.name,
            "locale" to locale.toLanguageTag(),
            "networkRequired" to voice.isNetworkConnectionRequired,
            "network_required" to if (voice.isNetworkConnectionRequired) "1" else "0",
        )
    }

    override fun onDestroy() {
        probeTts?.shutdown()
        probeTts = null
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

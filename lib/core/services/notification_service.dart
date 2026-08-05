import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/models/ui_models.dart';
import 'ios_alarm_fanout_service.dart';
import 'ios_alarm_scheduler.dart';
import 'native_alarm_scheduler.dart';

typedef AlarmNotificationCallback = void Function(String alarmId);
typedef IosChallengeCallback = void Function(IosPendingChallenge challenge);

class NotificationService {
  NotificationService({
    NativeAlarmScheduler? nativeScheduler,
    IosAlarmFanoutService? iosFanout,
  }) : _native = nativeScheduler ?? NativeAlarmScheduler(),
       _iosFanout = iosFanout ?? IosAlarmFanoutService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final NativeAlarmScheduler _native;
  final IosAlarmFanoutService _iosFanout;

  static const _alarmChannelId = 'smart_voice_alarm_alarms';
  static const _reminderChannelId = 'smart_voice_alarm_reminders';
  static const reminderNotificationId = 91001;

  AlarmNotificationCallback? onAlarmTriggered;
  IosChallengeCallback? onIosChallenge;
  bool _initialized = false;
  String _appName = 'Smart Voice Alarm';
  String _alarmChannelName = 'Alarms';
  String _alarmChannelDesc = 'Voice alarm alerts';
  String _reminderChannelName = 'Reminders';
  String _reminderChannelDesc = 'Daily reminder to set tomorrow’s alarm';

  NativeAlarmScheduler get native => _native;
  IosAlarmFanoutService get iosFanout => _iosFanout;

  Future<void> applyLocalizedCopy({
    required String appName,
    required String alarmChannelName,
    required String alarmChannelDescription,
    required String reminderChannelName,
    required String reminderChannelDescription,
  }) async {
    _appName = appName;
    _alarmChannelName = alarmChannelName;
    _alarmChannelDesc = alarmChannelDescription;
    _reminderChannelName = reminderChannelName;
    _reminderChannelDesc = reminderChannelDescription;
    if (!_initialized || kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _alarmChannelId,
          _alarmChannelName,
          description: _alarmChannelDesc,
          importance: Importance.max,
          playSound: false,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _reminderChannelId,
          _reminderChannelName,
          description: _reminderChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
    } catch (error) {
      debugPrint('applyLocalizedCopy failed: $error');
    }
  }

  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    try {
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          if (payload.startsWith('alarm:')) {
            onAlarmTriggered?.call(payload.substring(6));
          }
        },
      );

      if (_iosFanout.isSupported) {
        _iosFanout.scheduler.attachHandlers();
        _iosFanout.scheduler.onOpenChallenge = (challenge) {
          onIosChallenge?.call(challenge);
        };
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidPlugin?.createNotificationChannel(
          AndroidNotificationChannel(
            _alarmChannelId,
            _alarmChannelName,
            description: _alarmChannelDesc,
            importance: Importance.max,
            playSound: false,
          ),
        );
        await androidPlugin?.createNotificationChannel(
          AndroidNotificationChannel(
            _reminderChannelId,
            _reminderChannelName,
            description: _reminderChannelDesc,
            importance: Importance.defaultImportance,
          ),
        );
      }

      _initialized = true;
    } catch (error, stack) {
      debugPrint('NotificationService.init failed: $error\n$stack');
    }
  }

  /// Requests notification access only from a user-initiated alarm/reminder
  /// flow. Initialization intentionally never presents a permission dialog.
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await plugin?.requestNotificationsPermission() ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await plugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  Future<bool> get notificationPermissionGranted async {
    if (kIsWeb) return false;
    return Permission.notification.isGranted;
  }

  Future<void> cancelAlarm(String alarmId) async {
    if (kIsWeb) return;
    try {
      if (_native.isSupported) {
        await _native.cancelAlarm(alarmId);
      }
      if (_iosFanout.isSupported) {
        await _iosFanout.cancelAlarm(alarmId);
      }
      if (_initialized) {
        await _plugin.cancel(alarmId.hashCode);
      }
    } catch (error) {
      debugPrint('cancelAlarm failed: $error');
    }
  }

  Future<bool> scheduleAlarm(AlarmUiModel alarm) async {
    if (kIsWeb) return true;
    try {
      if (!alarm.isEnabled) {
        await cancelAlarm(alarm.id);
        return true;
      }

      final next = _nextOccurrence(alarm);
      if (next == null) {
        await cancelAlarm(alarm.id);
        return true;
      }

      // Android: AlarmManager + FGS so audio starts without a notification tap.
      if (_native.isSupported) {
        await _native.scheduleAlarm(alarm, next);
        if (_initialized) {
          await _plugin.cancel(alarm.id.hashCode);
        }
        return true;
      }

      // iOS: notification fan-out with pre-rendered Library/Sounds clips.
      if (_iosFanout.isSupported) {
        if (_initialized) {
          await _plugin.cancel(alarm.id.hashCode);
        }
        try {
          await _iosFanout.scheduler.requestAuthorization();
        } catch (e) {
          debugPrint('[SVA-Schedule] iOS auth before schedule: $e');
        }
        final result = await _iosFanout.scheduleAlarm(alarm, next);
        if (!result.ok) {
          debugPrint(
            '[SVA-Schedule] scheduleAlarm soft-fail code=${result.errorCode} '
            'msg=${result.errorMessage}',
          );
          return false;
        }
        return true;
      }

      if (!_initialized) return false;
      await _plugin.cancel(alarm.id.hashCode);

      final details = NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        android: AndroidNotificationDetails(
          _alarmChannelId,
          _alarmChannelName,
          channelDescription: _alarmChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          playSound: true,
        ),
      );

      await _plugin.zonedSchedule(
        alarm.id.hashCode,
        alarm.label,
        _appName,
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'alarm:${alarm.id}',
        matchDateTimeComponents: alarm.repeatDays.isEmpty
            ? null
            : DateTimeComponents.dayOfWeekAndTime,
      );
      return true;
    } catch (error) {
      debugPrint('scheduleAlarm failed: $error');
      return false;
    }
  }

  Future<void> rescheduleAll(List<AlarmUiModel> alarms) async {
    if (kIsWeb) return;
    for (final alarm in alarms) {
      await scheduleAlarm(alarm);
    }
  }

  /// iOS launch-safe reconcile: no native audio render, no orphan wipe.
  Future<void> reconcileIosAlarmsWithoutRender(
    List<AlarmUiModel> alarms,
  ) async {
    if (kIsWeb || !_iosFanout.isSupported) return;
    debugPrint('[SVA-Startup] reconcileIosAlarmsWithoutRender');
    try {
      await _iosFanout.reconcileWithoutRender(alarms);
    } catch (error, stack) {
      debugPrint('[SVA-Startup] light reconcile error: $error\n$stack');
    }
  }

  Future<void> scheduleDailyReminder({
    required bool enabled,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;
    try {
      await _plugin.cancel(reminderNotificationId);
      if (!enabled) return;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        reminderNotificationId,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannelId,
            _reminderChannelName,
            channelDescription: _reminderChannelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'reminder',
      );
    } catch (error) {
      debugPrint('scheduleDailyReminder failed: $error');
    }
  }

  Future<String?> consumeLaunchAlarmId() async {
    if (kIsWeb) return null;
    final nativeId = await _native.consumeLaunchAlarmId();
    if (nativeId != null && nativeId.isNotEmpty) return nativeId;

    final iosPending = await _iosFanout.scheduler.peekPendingChallenge();
    if (iosPending != null && iosPending.parentAlarmId.isNotEmpty) {
      return iosPending.parentAlarmId;
    }

    if (!_initialized) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return null;
      final payload = details!.notificationResponse?.payload;
      if (payload == null || !payload.startsWith('alarm:')) return null;
      return payload.substring(6);
    } catch (_) {
      return null;
    }
  }

  Future<bool> consumeLaunchDismissChallenge() async {
    if (kIsWeb) return false;
    if (await _native.consumeLaunchDismissChallenge()) return true;
    final pending = await _iosFanout.scheduler.peekPendingChallenge();
    return pending?.openChallenge == true;
  }

  Future<IosPendingChallenge?> consumeIosPendingChallenge() {
    return _iosFanout.scheduler.consumePendingChallenge();
  }

  tz.TZDateTime? nextOccurrence(AlarmUiModel alarm) => _nextOccurrence(alarm);

  void _ensureTimeZone() {
    try {
      // Touch local to detect uninitialized timezone database.
      tz.TZDateTime.now(tz.local);
    } catch (_) {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime? _nextOccurrence(AlarmUiModel alarm) {
    _ensureTimeZone();
    final now = tz.TZDateTime.now(tz.local);
    for (var offset = 0; offset < 8; offset++) {
      final candidateDay = now.add(Duration(days: offset));
      final candidate = tz.TZDateTime(
        tz.local,
        candidateDay.year,
        candidateDay.month,
        candidateDay.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      if (!candidate.isAfter(now)) continue;

      if (alarm.repeatDays.isEmpty) {
        return candidate;
      }

      final weekday = _weekdayFromDate(candidate);
      if (alarm.repeatDays.contains(weekday)) {
        return candidate;
      }
    }
    return null;
  }

  Weekday _weekdayFromDate(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday => Weekday.monday,
      DateTime.tuesday => Weekday.tuesday,
      DateTime.wednesday => Weekday.wednesday,
      DateTime.thursday => Weekday.thursday,
      DateTime.friday => Weekday.friday,
      DateTime.saturday => Weekday.saturday,
      _ => Weekday.sunday,
    };
  }
}

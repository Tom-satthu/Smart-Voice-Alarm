import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../shared/models/ui_models.dart';

/// Android AlarmManager bridge. No-op on iOS/web/tests.
class NativeAlarmScheduler {
  NativeAlarmScheduler();

  static const _channel =
      MethodChannel('com.smartvoicealarm.app/alarms');

  void Function(String alarmId)? onAlarmTriggered;
  VoidCallback? onNativeAlarmStopped;
  bool _handlerAttached = false;

  /// Disabled under widget tests and non-Android hosts.
  bool get isSupported {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    if (const bool.fromEnvironment('FLUTTER_TEST')) return false;
    // Avoid MethodChannel hangs under flutter_test without importing flutter_test.
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (bindingName.contains('TestWidgetsFlutterBinding')) return false;
    return true;
  }

  /// Listens for native → Flutter events (alarm open / notification Stop).
  void attachPlatformHandlers() {
    if (!isSupported || _handlerAttached) return;
    _handlerAttached = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAlarmTriggered':
          final id = call.arguments?.toString();
          if (id != null && id.isNotEmpty) {
            onAlarmTriggered?.call(id);
          }
        case 'onNativeAlarmStopped':
          onNativeAlarmStopped?.call();
        default:
          break;
      }
    });
  }

  Future<void> scheduleAlarm(AlarmUiModel alarm, DateTime triggerAt) async {
    if (!isSupported) return;
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm.id);
      return;
    }
    try {
      await _channel
          .invokeMethod<void>('scheduleAlarm', {
            'id': alarm.id,
            'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
            'label': alarm.label,
            'ringtoneName': alarm.ringtoneName,
            'repeatDaysMask': _repeatMask(alarm.repeatDays),
            'hour': alarm.time.hour,
            'minute': alarm.time.minute,
          })
          .timeout(const Duration(milliseconds: 800));
    } catch (error, stack) {
      debugPrint('NativeAlarmScheduler.scheduleAlarm failed: $error\n$stack');
    }
  }

  Future<void> cancelAlarm(String alarmId) async {
    if (!isSupported) return;
    try {
      await _channel
          .invokeMethod<void>('cancelAlarm', {'id': alarmId})
          .timeout(const Duration(milliseconds: 800));
    } catch (error) {
      debugPrint('NativeAlarmScheduler.cancelAlarm failed: $error');
    }
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    try {
      await _channel
          .invokeMethod<void>('cancelAll')
          .timeout(const Duration(milliseconds: 800));
    } catch (error) {
      debugPrint('NativeAlarmScheduler.cancelAll failed: $error');
    }
  }

  Future<void> rescheduleAll() async {
    if (!isSupported) return;
    try {
      await _channel
          .invokeMethod<void>('rescheduleAll')
          .timeout(const Duration(milliseconds: 800));
    } catch (error) {
      debugPrint('NativeAlarmScheduler.rescheduleAll failed: $error');
    }
  }

  Future<void> stopForegroundAlarm() async {
    if (!isSupported) return;
    try {
      await _channel
          .invokeMethod<void>('stopForegroundAlarm')
          .timeout(const Duration(milliseconds: 800));
    } catch (error) {
      debugPrint('NativeAlarmScheduler.stopForegroundAlarm failed: $error');
    }
  }

  Future<void> markDisabled(String alarmId) async {
    if (!isSupported) return;
    try {
      await _channel
          .invokeMethod<void>('markDisabled', {'id': alarmId})
          .timeout(const Duration(milliseconds: 800));
    } catch (error) {
      debugPrint('NativeAlarmScheduler.markDisabled failed: $error');
    }
  }

  Future<String?> consumeLaunchAlarmId() async {
    if (!isSupported) return null;
    try {
      return await _channel
          .invokeMethod<String>('consumeLaunchAlarmId')
          .timeout(const Duration(milliseconds: 800));
    } catch (_) {
      return null;
    }
  }

  int _repeatMask(Set<Weekday> days) {
    var mask = 0;
    for (final day in days) {
      mask |= switch (day) {
        Weekday.monday => 1,
        Weekday.tuesday => 2,
        Weekday.wednesday => 4,
        Weekday.thursday => 8,
        Weekday.friday => 16,
        Weekday.saturday => 32,
        Weekday.sunday => 64,
      };
    }
    return mask;
  }
}

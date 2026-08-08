import '../../shared/providers/prototype_providers.dart';
import 'alarm_schedule_result.dart';
import 'notification_service.dart';

/// Shared terminal completion for a fired alarm occurrence.
///
/// One-shot (`repeatDays` empty): persist parent OFF, never schedule next.
/// Legacy repeating: keep parent ON and schedule the next matching day.
class AlarmLifecycleService {
  AlarmLifecycleService({
    required AlarmListController alarms,
    required NotificationService notifications,
  }) : _alarms = alarms,
       _notifications = notifications;

  final AlarmListController _alarms;
  final NotificationService _notifications;

  /// Marks the current occurrence terminal and applies one-shot / repeat policy.
  Future<AlarmScheduleResult> completeAlarmOccurrence({
    required String alarmId,
    String? occurrenceId,
    bool clearPendingChallenge = true,
  }) async {
    final isIos = _notifications.iosFanout.isSupported;
    if (isIos) {
      // Barrier first so late recovery cannot win the race.
      await _notifications.iosFanout.scheduler.activateParentCancellation(
        parentAlarmId: alarmId,
        reason: 'occurrence_complete',
      );
      if (occurrenceId != null && occurrenceId.isNotEmpty) {
        await _notifications.iosFanout.scheduler.markOccurrenceSolved(
          parentAlarmId: alarmId,
          occurrenceId: occurrenceId,
        );
        await _notifications.iosFanout.cancelOccurrence(
          parentAlarmId: alarmId,
          occurrenceId: occurrenceId,
        );
      } else {
        await _notifications.iosFanout.cancelAlarm(alarmId);
      }
      if (clearPendingChallenge) {
        await _notifications.iosFanout.scheduler.clearPendingChallenge(
          parentAlarmId: alarmId,
          occurrenceId: occurrenceId ?? '',
        );
      }
    } else {
      await _notifications.cancelAlarm(alarmId);
    }

    final alarm = _alarms.findById(alarmId);
    if (alarm == null) {
      return AlarmScheduleResult.ok(stage: 'occurrence_complete_missing');
    }

    if (alarm.repeatDays.isEmpty) {
      // One-shot: disable parent permanently until user toggles ON.
      final disabled = alarm.copyWith(isEnabled: false);
      await _alarms.persistEnabledState(
        disabled,
        activateNativeBarrier: true,
        scheduleAfter: false,
      );
      return AlarmScheduleResult.ok(stage: 'occurrence_complete_oneshot_off');
    }

    // Legacy repeating: keep enabled and schedule next occurrence.
    if (alarm.isEnabled) {
      return _notifications.scheduleAlarm(alarm);
    }
    await _notifications.cancelAlarm(alarmId);
    return AlarmScheduleResult.ok(stage: 'occurrence_complete_disabled');
  }
}

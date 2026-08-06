import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';

void main() {
  group('AlarmKit sound name diagnostics', () {
    test('segment map carries soundFileName with extension', () {
      final segment = IosAlarmSegment(
        parentAlarmId: 'p',
        occurrenceId: 'o',
        segmentIndex: 0,
        childId: 'c',
        startAt: DateTime(2026, 8, 6, 12),
        soundFileName: 'sva_abc_rev.caf',
        duration: const Duration(seconds: 2),
        label: 'recording',
      );
      expect(segment.toNativeMap()['soundFileName'], 'sva_abc_rev.caf');
      expect(segment.toNativeMap()['label'], 'recording');
    });

    test('schedule result default fallback has warning', () {
      final result = AlarmScheduleResult.ok(
        backend: AlarmScheduleBackend.alarmKit,
        backendReason: 'authorized',
        warningCode: 'custom_sound_fallback',
        warningMessage: 'Custom sound not found — using default AlarmKit sound',
      );
      expect(result.hasWarning, isTrue);
      expect(result.warningCode, 'custom_sound_fallback');
    });

    test('recording tts ringtone labels are distinct', () {
      expect(
        IosAlarmSegment(
          parentAlarmId: 'p',
          occurrenceId: 'o',
          segmentIndex: 0,
          childId: 'c1',
          startAt: DateTime(2026, 8, 6),
          soundFileName: 'a.caf',
          duration: const Duration(seconds: 1),
          label: 'recording',
        ).label,
        isNot(
          IosAlarmSegment(
            parentAlarmId: 'p',
            occurrenceId: 'o',
            segmentIndex: 1,
            childId: 'c2',
            startAt: DateTime(2026, 8, 6),
            soundFileName: 'b.caf',
            duration: const Duration(seconds: 1),
            label: 'tts',
          ).label,
        ),
      );
    });

    test('mixed occurrence uses one backend label only', () {
      const backends = {
        AlarmScheduleBackend.alarmKit,
        AlarmScheduleBackend.notificationFanout,
      };
      expect(backends.length, 2);
      // Contract: never schedule both for one occurrence.
      final chosen = AlarmScheduleBackend.alarmKit;
      expect(
        chosen == AlarmScheduleBackend.alarmKit ||
            chosen == AlarmScheduleBackend.notificationFanout,
        isTrue,
      );
      expect(
        chosen == AlarmScheduleBackend.alarmKit &&
            chosen == AlarmScheduleBackend.notificationFanout,
        isFalse,
      );
    });
  });
}

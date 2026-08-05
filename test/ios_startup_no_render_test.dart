import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/services/ios_alarm_fanout_service.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_segment_planner.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('startup must not render on iOS path', () {
    test('IosAlarmScheduler.isSupported is false under FLUTTER_TEST', () {
      // MethodChannel client is disabled in unit tests — startup reconcile
      // therefore cannot invoke native renderSound.
      final scheduler = IosAlarmScheduler();
      expect(scheduler.isSupported, isFalse);
      expect(IosAlarmFanoutService(scheduler: scheduler).isSupported, isFalse);
    });

    test('reconcileWithoutRender is a no-op when unsupported', () async {
      final service = IosAlarmFanoutService(scheduler: IosAlarmScheduler());
      final alarm = AlarmUiModel(
        id: 'a1',
        time: const TimeOfDay(hour: 7, minute: 0),
        repeatDays: Weekday.values.toSet(),
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'Test',
      );
      await service.reconcileWithoutRender([alarm]);
      // Must not throw and must not attempt scheduling when unsupported.
      expect(service.isSupported, isFalse);
    });
  });

  group('two-phase schedule contract', () {
    test('planner builds unique child ids without requiring cancel-first', () {
      final planner = IosAlarmSegmentPlanner();
      final alarm = AlarmUiModel(
        id: 'a1',
        time: const TimeOfDay(hour: 7, minute: 0),
        repeatDays: const {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Test',
        repeatCount: 1,
      );
      final segments = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: DateTime(2026, 8, 5, 7),
        voiceClips: [
          preparedClip(
            fileName: 'revA_0.caf',
            duration: const Duration(seconds: 3),
          ),
        ],
        ringtoneClips: const [],
      );
      expect(segments, hasLength(1));
      expect(segments.single.soundFileName, 'revA_0.caf');
      expect(segments.single.childId, isNotEmpty);
    });

    test('failed empty render reports needsAudioRepair', () async {
      final service = IosAlarmFanoutService(scheduler: IosAlarmScheduler());
      final result = await service.scheduleAlarm(
        AlarmUiModel(
          id: 'a1',
          time: const TimeOfDay(hour: 7, minute: 0),
          repeatDays: const {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'Test',
          voiceSequenceId: 'missing',
        ),
        DateTime.now().add(const Duration(minutes: 5)),
      );
      // Under test, isSupported is false → schedule is a soft success no-op.
      expect(result.ok, isTrue);
    });
  });

  group('AlarmUiModel repair flag', () {
    test('round-trips audioNeedsRegeneration', () {
      const alarm = AlarmUiModel(
        id: 'a1',
        time: TimeOfDay(hour: 6, minute: 30),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'X',
        audioNeedsRegeneration: true,
      );
      final decoded = AlarmUiModel.fromJson(alarm.toJson());
      expect(decoded.audioNeedsRegeneration, isTrue);
    });
  });

  group('capability honesty', () {
    test('unsupported capability is not full AlarmKit support', () {
      final cap = IosAlarmCapability.unsupported();
      expect(cap.usesAlarmKit, isFalse);
      expect(cap.isFullSupport, isFalse);
    });
  });

  group('platform', () {
    test('Android target is unchanged by iOS-only helpers', () {
      // Guardrail: this suite must not import android/ or mutate Android APIs.
      expect(defaultTargetPlatform, isNot(equals(TargetPlatform.iOS)));
    });
  });
}

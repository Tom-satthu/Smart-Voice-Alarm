import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_segment_planner.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  group('IosAlarmSegmentPlanner repeatCount + mixed', () {
    const gap = Duration(seconds: 5);
    final planner = IosAlarmSegmentPlanner(gap: gap, maxNotifications: 64);
    final start = DateTime(2026, 8, 6, 7, 0);

    test('1 voice × repeat 1', () {
      const alarm = AlarmUiModel(
        id: 'a1',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'One',
        repeatCount: 1,
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(seconds: 2),
          ),
        ],
        ringtoneClips: const [],
      );
      expect(plan, hasLength(1));
      expect(plan.single.startAt, start);
      expect(plan.single.soundFileName, 'v0.caf');
    });

    test('2 voices × repeat 3 exact timestamps', () {
      const alarm = AlarmUiModel(
        id: 'a2',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Two',
        repeatCount: 3,
      );
      final voices = [
        preparedClip(fileName: 'v0.caf', duration: const Duration(seconds: 2)),
        preparedClip(fileName: 'v1.caf', duration: const Duration(seconds: 3)),
      ];
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: voices,
        ringtoneClips: const [],
      );
      expect(plan, hasLength(6));
      var cursor = start;
      var i = 0;
      for (var r = 0; r < 3; r++) {
        for (final clip in voices) {
          expect(plan[i].startAt, cursor);
          expect(plan[i].soundFileName, clip.fileName);
          expect(plan[i].occurrenceId, 'occ');
          expect(plan[i].segmentIndex, i);
          cursor = cursor.add(clip.duration).add(gap);
          i += 1;
        }
      }
      expect(plan.map((s) => s.childId).toSet(), hasLength(6));
    });

    test('mixed 2 voices × repeat 3 + ringtone after last voice', () {
      const alarm = AlarmUiModel(
        id: 'a3',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'Mixed',
        repeatCount: 3,
        ringtoneName: 'Soft Chime',
      );
      final voices = [
        preparedClip(fileName: 'v0.caf', duration: const Duration(seconds: 2)),
        preparedClip(fileName: 'v1.caf', duration: const Duration(seconds: 3)),
      ];
      final tones = [
        preparedClip(
          fileName: 'tone.caf',
          duration: const Duration(seconds: 8),
        ),
      ];
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: voices,
        ringtoneClips: tones,
      );
      expect(plan, hasLength(7));
      expect(plan.last.soundFileName, 'tone.caf');
      // 3 repeats × (2+5 + 3+5) = 3 × 15 = 45s after start
      expect(plan.last.startAt, start.add(const Duration(seconds: 45)));
    });

    test('mixed without ringtone throws', () {
      const alarm = AlarmUiModel(
        id: 'a4',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'Broken',
        repeatCount: 1,
      );
      expect(
        () => planner.plan(
          alarm: alarm,
          occurrenceId: 'occ',
          occurrenceStart: start,
          voiceClips: [
            preparedClip(
              fileName: 'v0.caf',
              duration: const Duration(seconds: 2),
            ),
          ],
          ringtoneClips: const [],
        ),
        throwsA(isA<IosPlanValidationException>()),
      );
    });

    test('ringtone-only ignores voice repeatCount multiplication', () {
      const alarm = AlarmUiModel(
        id: 'a5',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.ringtone,
        label: 'Tone',
        repeatCount: 5,
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(seconds: 2),
          ),
        ],
        ringtoneClips: [
          preparedClip(
            fileName: 'tone.caf',
            duration: const Duration(seconds: 8),
          ),
        ],
      );
      expect(plan, hasLength(1));
      expect(plan.single.soundFileName, 'tone.caf');
    });

    test('overflow does not truncate — throws', () {
      final tiny = IosAlarmSegmentPlanner(maxNotifications: 4);
      const alarm = AlarmUiModel(
        id: 'a6',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Overflow',
        repeatCount: 3,
      );
      expect(
        () => tiny.plan(
          alarm: alarm,
          occurrenceId: 'occ',
          occurrenceStart: start,
          voiceClips: [
            preparedClip(
              fileName: 'v0.caf',
              duration: const Duration(seconds: 1),
            ),
            preparedClip(
              fileName: 'v1.caf',
              duration: const Duration(seconds: 1),
            ),
          ],
          ringtoneClips: const [],
        ),
        throwsA(
          isA<IosPlanValidationException>().having(
            (e) => e.code,
            'code',
            'notification_limit',
          ),
        ),
      );
    });
  });
}

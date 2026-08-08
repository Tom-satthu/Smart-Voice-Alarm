import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/alarm_kit_timeline_config.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_segment_planner.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  group('IosAlarmSegmentPlanner silence timeline', () {
    const gap = Duration(seconds: 5);
    final planner = IosAlarmSegmentPlanner(
      gap: gap,
      maxChildren: 64,
      targetHorizon: const Duration(minutes: 30),
    );
    final start = DateTime(2026, 8, 6, 7, 0);

    test('1. repeatCount > 1 does not multiply voices on iOS', () {
      const alarm = AlarmUiModel(
        id: 'a1',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'One',
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
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      // One cycle: voice + silence (repeatCount ignored).
      expect(plan.segments, hasLength(2));
      expect(plan.segments.first.role, IosSegmentRole.voice);
      expect(plan.segments.last.role, IosSegmentRole.silence);
    });

    test('2. voice finalized duration → silence 5s (no planner padding)', () {
      const alarm = AlarmUiModel(
        id: 'a2',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'V7',
        repeatCount: 3,
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(milliseconds: 8250),
            contentDuration: const Duration(seconds: 7),
            trailingSilence: AlarmKitTimelineConfig.trailingSilence,
          ),
        ],
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      expect(plan.segments[0].duration, const Duration(milliseconds: 8250));
      expect(plan.segments[1].duration, gap);
      expect(plan.segments[1].soundFileName, kSvaSilenceFileName);
      expect(
        plan.segments[1].startAt,
        start.add(const Duration(milliseconds: 8250)),
      );
    });

    test('3-4. two voices with silence gaps, no voice overlap', () {
      const alarm = AlarmUiModel(
        id: 'a3',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Two',
        repeatCount: 9,
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(seconds: 4),
          ),
          preparedClip(
            fileName: 'v1.caf',
            duration: const Duration(seconds: 6),
          ),
        ],
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      expect(plan.segments.map((s) => s.role).toList(), [
        IosSegmentRole.voice,
        IosSegmentRole.silence,
        IosSegmentRole.voice,
        IosSegmentRole.silence,
      ]);
      expect(
        plan.segments[2].startAt,
        start.add(const Duration(seconds: 4)).add(gap),
      );
      // No overlapping windows.
      for (var i = 0; i < plan.segments.length - 1; i++) {
        final end = plan.segments[i].startAt.add(plan.segments[i].duration);
        expect(
          !plan.segments[i + 1].startAt.isBefore(end),
          isTrue,
          reason: 'segment ${i + 1} must not start before $i ends',
        );
      }
    });

    test('5-7. mixed: ringtone 10s content + trailing, next cycle voice1', () {
      const alarm = AlarmUiModel(
        id: 'a4',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'Mixed',
        repeatCount: 3,
        ringtoneName: 'Soft Chime',
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(seconds: 3),
          ),
        ],
        ringtoneClips: [
          preparedClip(
            fileName: 'tone.caf',
            duration: const Duration(seconds: 30),
          ),
        ],
        maxCyclesOverride: 2,
      );
      // cycle: voice, silence, ringtone, silence
      expect(plan.childrenPerCycle, 4);
      expect(plan.cyclesScheduled, 2);
      final ringtone = plan.segments.where(
        (s) => s.role == IosSegmentRole.ringtone,
      );
      final expectedRingtone =
          AlarmKitTimelineConfig.ringtoneDuration +
          AlarmKitTimelineConfig.trailingSilence;
      expect(ringtone.every((s) => s.duration == expectedRingtone), isTrue);
      final firstCycleEnd = plan.segments[3].startAt.add(
        plan.segments[3].duration,
      );
      expect(plan.segments[4].role, IosSegmentRole.voice);
      expect(plan.segments[4].soundFileName, 'v0.caf');
      expect(plan.segments[4].startAt, firstCycleEnd);
      expect(plan.segments[3].role, IosSegmentRole.silence);
      expect(plan.segments[3].soundFileName, kSvaSilenceFileName);
    });

    test('8. segments do not overlap', () {
      const alarm = AlarmUiModel(
        id: 'a5',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'NoOverlap',
        repeatCount: 2,
        ringtoneName: 'Soft Chime',
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(seconds: 5),
          ),
          preparedClip(
            fileName: 'v1.caf',
            duration: const Duration(seconds: 5),
          ),
        ],
        ringtoneClips: [
          preparedClip(
            fileName: 'tone.caf',
            duration: const Duration(seconds: 10),
          ),
        ],
        maxCyclesOverride: 1,
      );
      for (var i = 0; i < plan.segments.length - 1; i++) {
        final end = plan.segments[i].startAt.add(plan.segments[i].duration);
        expect(!plan.segments[i + 1].startAt.isBefore(end), isTrue);
      }
    });

    test(
      'trailing silence is inside finalized duration; product gap is 5s',
      () {
        const alarm = AlarmUiModel(
          id: 'pad',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'Pad',
          repeatCount: 1,
        );
        final plan = planner.plan(
          alarm: alarm,
          occurrenceId: 'occ',
          occurrenceStart: start,
          voiceClips: [
            preparedClip(
              fileName: 'v0.caf',
              duration: const Duration(milliseconds: 8250),
              contentDuration: const Duration(seconds: 7),
              trailingSilence: AlarmKitTimelineConfig.trailingSilence,
            ),
          ],
          ringtoneClips: const [],
          maxCyclesOverride: 1,
        );
        final voiceEnd = start.add(const Duration(milliseconds: 8250));
        final silenceStart = plan.segments[1].startAt;
        expect(silenceStart, voiceEnd);
        expect(plan.segments[1].duration, gap);
      },
    );

    test('short TTS timeline has no audible overlap / no double padding', () {
      const alarm = AlarmUiModel(
        id: 'tts-short',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Short',
        repeatCount: 1,
      );
      final content = const Duration(milliseconds: 1800);
      final finalized = content + AlarmKitTimelineConfig.trailingSilence;
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'tts.caf',
            duration: finalized,
            contentDuration: content,
            trailingSilence: AlarmKitTimelineConfig.trailingSilence,
          ),
        ],
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      expect(plan.segments[0].duration, finalized);
      expect(plan.segments[1].startAt, start.add(finalized));
      expect(plan.segments[1].duration, gap);
    });

    test('9. silent child uses silence CAF name', () {
      const alarm = AlarmUiModel(
        id: 'a6',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Sil',
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
        maxCyclesOverride: 1,
      );
      final silences = plan.segments.where(
        (s) => s.role == IosSegmentRole.silence,
      );
      expect(silences, isNotEmpty);
      expect(
        silences.every((s) => s.soundFileName == kSvaSilenceFileName),
        isTrue,
      );
      expect(silences.every((s) => s.soundFileName != '.default'), isTrue);
    });

    test('10. rolling cycles dedupe child ids', () {
      const alarm = AlarmUiModel(
        id: 'a7',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Dedup',
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
        maxCyclesOverride: 3,
      );
      final ids = plan.segments.map((s) => s.childId).toSet();
      expect(ids.length, plan.segments.length);

      final again = planner.plan(
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
        maxCyclesOverride: 3,
      );
      expect(
        again.segments.map((s) => s.childId).toList(),
        plan.segments.map((s) => s.childId).toList(),
      );
    });

    test('11. rolling horizon respects maxChildren', () {
      final tiny = IosAlarmSegmentPlanner(maxChildren: 4, gap: gap);
      const alarm = AlarmUiModel(
        id: 'a8',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Horizon',
        repeatCount: 99,
      );
      final plan = tiny.plan(
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
      // childrenPerCycle=2 → max 2 cycles
      expect(plan.childCount, lessThanOrEqualTo(4));
      expect(plan.cyclesScheduled, 2);
    });

    test('16. old repeatCount migration ignored', () {
      const alarm = AlarmUiModel(
        id: 'a9',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'Legacy',
        repeatCount: 7,
        ringtoneName: 'Soft Chime',
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
          preparedClip(
            fileName: 'v1.caf',
            duration: const Duration(seconds: 2),
          ),
        ],
        ringtoneClips: [
          preparedClip(
            fileName: 'tone.caf',
            duration: const Duration(seconds: 8),
          ),
        ],
        maxCyclesOverride: 1,
      );
      // 2 voices + 2 silences + ringtone + silence = 6, not 7*voices
      expect(plan.segments.length, 6);
      expect(plan.audibleChildCount, 3);
      expect(plan.silentChildCount, 3);
    });

    test('voice clamp content max + trailing silence', () {
      const alarm = AlarmUiModel(
        id: 'a10',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Clamp',
        repeatCount: 1,
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'long.caf',
            duration: const Duration(seconds: 45),
          ),
        ],
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      expect(
        plan.segments.first.duration,
        AlarmKitTimelineConfig.maxVoiceContentDuration +
            AlarmKitTimelineConfig.trailingSilence +
            const Duration(seconds: 1),
      );

      final withMeta = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ2',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'ok.caf',
            duration: const Duration(milliseconds: 21250),
            contentDuration: const Duration(seconds: 20),
            trailingSilence: AlarmKitTimelineConfig.trailingSilence,
          ),
        ],
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      expect(
        withMeta.segments.first.duration,
        const Duration(milliseconds: 21250),
      );
    });

    test('mixed without ringtone throws', () {
      const alarm = AlarmUiModel(
        id: 'a11',
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
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';

import 'memory_store.dart';

class _ScriptedNotifications extends NotificationService {
  _ScriptedNotifications(this._results);

  final List<AlarmScheduleResult> _results;
  VoiceSequenceUiModel? lastOverride;
  int calls = 0;

  @override
  Future<AlarmScheduleResult> scheduleAlarm(
    AlarmUiModel alarm, {
    VoiceSequenceUiModel? sequenceOverride,
  }) async {
    lastOverride = sequenceOverride;
    calls += 1;
    if (_results.isEmpty) {
      return AlarmScheduleResult.success;
    }
    return _results.removeAt(0);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Save alarm transaction', () {
    test('schedule success commits both alarm and sequence', () async {
      final alarms = MemoryAlarmRepository();
      final sequences = MemoryVoiceSequenceRepository();
      final notifications = _ScriptedNotifications([
        AlarmScheduleResult.ok(stage: 'notification_schedule'),
      ]);
      final controller = AlarmListController(alarms, notifications, sequences);

      final seq = const VoiceSequenceUiModel(
        id: 'seq-new',
        name: 'Draft',
        segments: [
          VoiceSegmentUiModel(
            id: 's1',
            name: 'Hi',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'Hi',
          ),
        ],
      );
      final result = await controller.add(
        const AlarmUiModel(
          id: 'a-new',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'New',
          voiceSequenceId: 'seq-new',
        ),
        sequenceOverride: seq,
      );

      expect(result.ok, isTrue);
      expect(alarms.findById('a-new'), isNotNull);
      expect(alarms.findById('a-new')!.audioNeedsRegeneration, isFalse);
      expect(sequences.findById('seq-new')?.segments, hasLength(1));
      expect(notifications.lastOverride?.id, 'seq-new');
    });

    test('schedule fail commits neither and no regeneration row', () async {
      final alarms = MemoryAlarmRepository();
      final sequences = MemoryVoiceSequenceRepository();
      final notifications = _ScriptedNotifications([
        AlarmScheduleResult.fail(
          errorCode: 'recording_file_missing',
          errorMessage: 'missing',
          stage: 'recording_source_validation',
        ),
      ]);
      final controller = AlarmListController(alarms, notifications, sequences);

      final seq = const VoiceSequenceUiModel(
        id: 'seq-fail',
        name: 'Draft',
        segments: [
          VoiceSegmentUiModel(
            id: 's1',
            name: 'Rec',
            type: VoiceSegmentType.recording,
            duration: Duration(seconds: 1),
            filePath: '/tmp/missing.m4a',
          ),
        ],
      );
      final result = await controller.add(
        const AlarmUiModel(
          id: 'a-fail',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.mixed,
          label: 'Fail',
          voiceSequenceId: 'seq-fail',
          ringtoneName: 'Soft Chime',
        ),
        sequenceOverride: seq,
      );

      expect(result.ok, isFalse);
      expect(result.errorCode, 'recording_file_missing');
      expect(result.stage, 'recording_source_validation');
      expect(alarms.loadAll(), isEmpty);
      expect(sequences.findById('seq-fail'), isNull);
      expect(controller.state, isEmpty);
    });

    test('edit fail keeps original alarm and sequence', () async {
      final originalSeq = const VoiceSequenceUiModel(
        id: 'seq-edit',
        name: 'Original',
        segments: [
          VoiceSegmentUiModel(
            id: 'keep',
            name: 'Keep',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'Keep',
          ),
        ],
      );
      final originalAlarm = const AlarmUiModel(
        id: 'a-edit',
        time: TimeOfDay(hour: 6, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Original',
        voiceSequenceId: 'seq-edit',
      );
      final alarms = MemoryAlarmRepository([originalAlarm]);
      final sequences = MemoryVoiceSequenceRepository([originalSeq]);
      final notifications = _ScriptedNotifications([
        AlarmScheduleResult.fail(
          errorCode: 'tts_render_failed',
          errorMessage: 'boom',
          stage: 'tts_render',
        ),
      ]);
      final controller = AlarmListController(alarms, notifications, sequences);

      final editedSeq = originalSeq.copyWith(
        segments: [
          ...originalSeq.segments,
          const VoiceSegmentUiModel(
            id: 'new',
            name: 'New',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'New',
          ),
        ],
      );
      final result = await controller.update(
        originalAlarm.copyWith(label: 'Changed'),
        sequenceOverride: editedSeq,
      );

      expect(result.ok, isFalse);
      expect(alarms.findById('a-edit')!.label, 'Original');
      expect(sequences.findById('seq-edit')!.segments, hasLength(1));
      expect(controller.state.single.label, 'Original');
    });

    test('mixed ringtone fallback warning is structured success', () async {
      final notifications = _ScriptedNotifications([
        AlarmScheduleResult.ok(
          stage: 'notification_schedule',
          warningCode: 'ringtone_fallback_system',
          warningMessage: 'Custom ringtone could not be prepared.',
        ),
      ]);
      final alarms = MemoryAlarmRepository();
      final sequences = MemoryVoiceSequenceRepository();
      final controller = AlarmListController(alarms, notifications, sequences);
      final result = await controller.add(
        const AlarmUiModel(
          id: 'a-warn',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.mixed,
          label: 'Warn',
          voiceSequenceId: 'seq-w',
          ringtoneName: 'Soft Chime',
        ),
        sequenceOverride: const VoiceSequenceUiModel(
          id: 'seq-w',
          name: 'S',
          segments: [
            VoiceSegmentUiModel(
              id: 'v',
              name: 'V',
              type: VoiceSegmentType.tts,
              duration: Duration(seconds: 1),
              text: 'V',
            ),
          ],
        ),
      );
      expect(result.ok, isTrue);
      expect(result.hasWarning, isTrue);
      expect(result.warningCode, 'ringtone_fallback_system');
      expect(alarms.findById('a-warn'), isNotNull);
    });

    test('schedule receives draft sequence override before persist', () async {
      final notifications = _ScriptedNotifications([
        AlarmScheduleResult.ok(stage: 'notification_schedule'),
      ]);
      final sequences = MemoryVoiceSequenceRepository();
      final controller = AlarmListController(
        MemoryAlarmRepository(),
        notifications,
        sequences,
      );
      final draft = const VoiceSequenceUiModel(
        id: 'draft-only',
        name: 'Draft',
        segments: [
          VoiceSegmentUiModel(
            id: 's',
            name: 'S',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'S',
          ),
        ],
      );
      expect(sequences.findById('draft-only'), isNull);
      await controller.add(
        const AlarmUiModel(
          id: 'a1',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'A',
          voiceSequenceId: 'draft-only',
        ),
        sequenceOverride: draft,
      );
      expect(notifications.lastOverride?.segments, hasLength(1));
      expect(sequences.findById('draft-only'), isNotNull);
    });
  });
}

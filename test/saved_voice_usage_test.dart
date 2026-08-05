import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/saved_voice_usage_service.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';

import 'memory_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sourceSavedVoiceId', () {
    test(
      'addExistingSavedVoice links library id without new saved row',
      () async {
        final saved = VoiceSegmentUiModel(
          id: 'lib-1',
          name: 'Hello',
          type: VoiceSegmentType.tts,
          duration: const Duration(seconds: 3),
          text: 'Hello',
          localeId: 'en-US',
        );
        final seqRepo = MemoryVoiceSequenceRepository([
          const VoiceSequenceUiModel(
            id: 'seq-1',
            name: 'Draft',
            segments: [
              VoiceSegmentUiModel(
                id: 'keep',
                name: 'Keep',
                type: VoiceSegmentType.tts,
                duration: Duration(seconds: 1),
                text: 'Keep',
                sourceSavedVoiceId: 'other',
              ),
            ],
          ),
        ]);
        final savedRepo = MemorySavedVoiceRepository([saved]);
        final controller = VoiceSequenceController(
          seqRepo,
          seqRepo.findById('seq-1'),
          savedRepo,
        );

        await controller.addExistingSavedVoice(saved);

        expect(controller.state.segments, hasLength(2));
        expect(controller.state.segments.first.id, 'keep');
        expect(controller.state.segments.last.sourceSavedVoiceId, 'lib-1');
        expect(controller.state.segments.last.id, isNot('lib-1'));
        expect(savedRepo.loadAll(), hasLength(1));
      },
    );

    test('add creates library row and sequence link', () async {
      final seqRepo = MemoryVoiceSequenceRepository([
        const VoiceSequenceUiModel(id: 'seq-1', name: 'Draft', segments: []),
      ]);
      final savedRepo = MemorySavedVoiceRepository();
      final controller = VoiceSequenceController(
        seqRepo,
        seqRepo.findById('seq-1'),
        savedRepo,
      );

      await controller.add(
        const VoiceSegmentUiModel(
          id: 'new-lib',
          name: 'TTS',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 2),
          text: 'Hi',
          localeId: 'en-US',
        ),
      );

      expect(savedRepo.loadAll().single.id, 'new-lib');
      expect(controller.state.segments.single.sourceSavedVoiceId, 'new-lib');
      expect(controller.state.segments.single.id, isNot('new-lib'));
    });
  });

  group('SavedVoiceUsageService', () {
    test('blocks delete when two alarms share a saved voice', () {
      final savedRepo = MemorySavedVoiceRepository([
        const VoiceSegmentUiModel(
          id: 'lib-a',
          name: 'A',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 2),
          text: 'A',
        ),
      ]);
      final seqRepo = MemoryVoiceSequenceRepository([
        const VoiceSequenceUiModel(
          id: 'seq-shared',
          name: 'Shared',
          segments: [
            VoiceSegmentUiModel(
              id: 'seg-1',
              name: 'A',
              type: VoiceSegmentType.tts,
              duration: Duration(seconds: 2),
              text: 'A',
              sourceSavedVoiceId: 'lib-a',
            ),
          ],
        ),
      ]);
      final alarmRepo = MemoryAlarmRepository([
        const AlarmUiModel(
          id: 'alarm-1',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'One',
          voiceSequenceId: 'seq-shared',
        ),
        const AlarmUiModel(
          id: 'alarm-2',
          time: TimeOfDay(hour: 8, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'Two',
          voiceSequenceId: 'seq-shared',
        ),
      ]);

      final usage = SavedVoiceUsageService(
        alarms: alarmRepo,
        sequences: seqRepo,
        savedVoices: savedRepo,
      ).usageFor('lib-a');

      expect(usage.canDeleteSafely, isFalse);
      expect(usage.usageCount, 2);
      expect(usage.alarmIds, containsAll(['alarm-1', 'alarm-2']));
    });

    test('unused voices list excludes only active-alarm usage', () {
      final savedRepo = MemorySavedVoiceRepository([
        const VoiceSegmentUiModel(
          id: 'used',
          name: 'Used',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 1),
          text: 'U',
        ),
        const VoiceSegmentUiModel(
          id: 'orphan-only',
          name: 'Orphan',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 1),
          text: 'O',
        ),
        const VoiceSegmentUiModel(
          id: 'free',
          name: 'Free',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 1),
          text: 'F',
        ),
      ]);
      final seqRepo = MemoryVoiceSequenceRepository([
        const VoiceSequenceUiModel(
          id: 'seq-active',
          name: 'Active',
          segments: [
            VoiceSegmentUiModel(
              id: 's1',
              name: 'Used',
              type: VoiceSegmentType.tts,
              duration: Duration(seconds: 1),
              text: 'U',
              sourceSavedVoiceId: 'used',
            ),
          ],
        ),
        const VoiceSequenceUiModel(
          id: 'seq-orphan',
          name: 'Orphan',
          segments: [
            VoiceSegmentUiModel(
              id: 's2',
              name: 'Orphan',
              type: VoiceSegmentType.tts,
              duration: Duration(seconds: 1),
              text: 'O',
              sourceSavedVoiceId: 'orphan-only',
            ),
          ],
        ),
      ]);
      final alarmRepo = MemoryAlarmRepository([
        const AlarmUiModel(
          id: 'alarm-1',
          time: TimeOfDay(hour: 7, minute: 0),
          repeatDays: {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'One',
          voiceSequenceId: 'seq-active',
        ),
      ]);
      final unused = SavedVoiceUsageService(
        alarms: alarmRepo,
        sequences: seqRepo,
        savedVoices: savedRepo,
      ).unusedVoices();
      expect(unused.map((v) => v.id).toSet(), {'orphan-only', 'free'});
    });

    test('usage 0 with orphan allows delete', () {
      final usage = SavedVoiceUsageService(
        alarms: MemoryAlarmRepository(),
        sequences: MemoryVoiceSequenceRepository([
          const VoiceSequenceUiModel(
            id: 'orphan',
            name: 'Orphan',
            segments: [
              VoiceSegmentUiModel(
                id: 's',
                name: 'V',
                type: VoiceSegmentType.tts,
                duration: Duration(seconds: 1),
                text: 'V',
                sourceSavedVoiceId: 'lib-o',
              ),
            ],
          ),
        ]),
        savedVoices: MemorySavedVoiceRepository([
          const VoiceSegmentUiModel(
            id: 'lib-o',
            name: 'V',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'V',
          ),
        ]),
      ).usageFor('lib-o');

      expect(usage.usageCount, 0);
      expect(usage.orphanSequenceIds, contains('orphan'));
      expect(usage.canDelete, isTrue);
      expect(usage.activeAlarmIds, isEmpty);
    });

    test('active 1 alarm blocks delete and lists alarm id', () {
      final usage = SavedVoiceUsageService(
        alarms: MemoryAlarmRepository([
          const AlarmUiModel(
            id: 'alarm-1',
            time: TimeOfDay(hour: 7, minute: 0),
            repeatDays: {},
            isEnabled: true,
            type: AlarmType.voice,
            label: 'One',
            voiceSequenceId: 'seq',
          ),
        ]),
        sequences: MemoryVoiceSequenceRepository([
          const VoiceSequenceUiModel(
            id: 'seq',
            name: 'S',
            segments: [
              VoiceSegmentUiModel(
                id: 's',
                name: 'V',
                type: VoiceSegmentType.tts,
                duration: Duration(seconds: 1),
                text: 'V',
                sourceSavedVoiceId: 'lib',
              ),
            ],
          ),
        ]),
        savedVoices: MemorySavedVoiceRepository([
          const VoiceSegmentUiModel(
            id: 'lib',
            name: 'V',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'V',
          ),
        ]),
      ).usageFor('lib');

      expect(usage.usageCount, 1);
      expect(usage.canDelete, isFalse);
      expect(usage.activeAlarmIds, {'alarm-1'});
    });
  });
}

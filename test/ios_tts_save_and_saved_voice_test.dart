import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/services/ios_alarm_fanout_service.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';

import 'memory_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reconcileWithoutRender', () {
    test('is a documented no-op on unsupported scheduler', () async {
      final service = IosAlarmFanoutService(scheduler: IosAlarmScheduler());
      await service.reconcileWithoutRender([
        AlarmUiModel(
          id: 'a1',
          time: const TimeOfDay(hour: 7, minute: 0),
          repeatDays: const {},
          isEnabled: true,
          type: AlarmType.voice,
          label: 'T',
        ),
      ]);
      expect(service.isSupported, isFalse);
    });
  });

  group('addExistingSavedVoice', () {
    test('appends to sequence without changing saved voice list', () async {
      final seqRepo = MemoryVoiceSequenceRepository([
        const VoiceSequenceUiModel(
          id: 'seq-test',
          name: 'Draft',
          segments: [
            VoiceSegmentUiModel(
              id: 'existing',
              name: 'Keep me',
              type: VoiceSegmentType.tts,
              duration: Duration(seconds: 2),
              text: 'Keep',
            ),
          ],
        ),
      ]);
      final saved = VoiceSegmentUiModel(
        id: 'saved-1',
        name: 'Hello',
        type: VoiceSegmentType.tts,
        duration: const Duration(seconds: 4),
        text: 'Hello world',
        localeId: 'en-US',
      );
      final savedRepo = MemorySavedVoiceRepository([saved]);
      final savedBefore = savedRepo.loadAll();

      final controller = VoiceSequenceController(
        seqRepo,
        seqRepo.findById('seq-test'),
        savedRepo,
        true, // persisted edit path
      );

      await controller.addExistingSavedVoice(saved);

      expect(controller.state.segments, hasLength(2));
      expect(controller.state.segments.first.id, 'existing');
      expect(controller.state.segments.first.name, 'Keep me');
      expect(controller.state.segments.last.text, 'Hello world');
      expect(controller.state.segments.last.id, isNot('saved-1'));
      expect(controller.state.segments.last.sourceSavedVoiceId, 'saved-1');
      expect(savedRepo.loadAll(), hasLength(savedBefore.length));
      expect(savedRepo.loadAll().single.id, 'saved-1');
      expect(seqRepo.findById('seq-test')!.segments, hasLength(2));
    });
  });

  group('schedule contract', () {
    test('unsupported platform soft-succeeds without rendering', () async {
      final result = await IosAlarmFanoutService(scheduler: IosAlarmScheduler())
          .scheduleAlarm(
            AlarmUiModel(
              id: 'a1',
              time: const TimeOfDay(hour: 7, minute: 0),
              repeatDays: const {},
              isEnabled: true,
              type: AlarmType.voice,
              label: 'T',
              voiceSequenceId: 'missing',
            ),
            DateTime.now().add(const Duration(minutes: 3)),
          );
      expect(result.ok, isTrue);
    });
  });

  group('platform guard', () {
    test('Android path unchanged by suite', () {
      expect(defaultTargetPlatform, isNot(equals(TargetPlatform.iOS)));
    });
  });
}

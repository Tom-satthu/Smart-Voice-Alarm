import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';

import 'memory_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceSequence draft lifecycle', () {
    test('mutations do not persist until commit', () async {
      final seqRepo = MemoryVoiceSequenceRepository();
      final savedRepo = MemorySavedVoiceRepository();
      final controller = VoiceSequenceController(
        seqRepo,
        const VoiceSequenceUiModel(id: 'draft-1', name: 'Draft', segments: []),
        savedRepo,
        false,
      );

      await controller.add(
        const VoiceSegmentUiModel(
          id: 'lib-1',
          name: 'Hello',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 2),
          text: 'Hello',
        ),
      );

      expect(controller.state.segments, hasLength(1));
      expect(seqRepo.findById('draft-1'), isNull);

      await controller.commit();
      expect(seqRepo.findById('draft-1')?.segments, hasLength(1));
    });

    test('discard new draft clears memory without orphan persist', () async {
      final seqRepo = MemoryVoiceSequenceRepository();
      final savedRepo = MemorySavedVoiceRepository();
      final controller = VoiceSequenceController(
        seqRepo,
        const VoiceSequenceUiModel(id: 'draft-2', name: 'Draft', segments: []),
        savedRepo,
        false,
      );

      await controller.addExistingSavedVoice(
        const VoiceSegmentUiModel(
          id: 'lib-x',
          name: 'X',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 1),
          text: 'X',
        ),
      );
      expect(controller.state.segments, hasLength(1));

      await controller.discard(hadPersistedOriginal: false);
      expect(controller.state.segments, isEmpty);
      expect(seqRepo.findById('draft-2'), isNull);
    });

    test('discard edit reloads persisted original', () async {
      final original = const VoiceSequenceUiModel(
        id: 'seq-edit',
        name: 'Original',
        segments: [
          VoiceSegmentUiModel(
            id: 'keep',
            name: 'Keep',
            type: VoiceSegmentType.tts,
            duration: Duration(seconds: 1),
            text: 'Keep',
            sourceSavedVoiceId: 'lib-k',
          ),
        ],
      );
      final seqRepo = MemoryVoiceSequenceRepository([original]);
      final controller = VoiceSequenceController(
        seqRepo,
        original,
        MemorySavedVoiceRepository(),
        false,
      );

      await controller.addExistingSavedVoice(
        const VoiceSegmentUiModel(
          id: 'lib-new',
          name: 'New',
          type: VoiceSegmentType.tts,
          duration: Duration(seconds: 1),
          text: 'New',
        ),
      );
      expect(controller.state.segments, hasLength(2));
      expect(seqRepo.findById('seq-edit')?.segments, hasLength(1));

      await controller.discard(hadPersistedOriginal: true);
      expect(controller.state.segments, hasLength(1));
      expect(controller.state.segments.single.id, 'keep');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/recording_file_store.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  const sharedPath = '/app/recordings/shared.m4a';
  const recording = VoiceSegmentUiModel(
    id: 'recording-1',
    name: 'Recording',
    type: VoiceSegmentType.recording,
    duration: Duration(seconds: 2),
    filePath: sharedPath,
  );
  const tts = VoiceSegmentUiModel(
    id: 'tts-1',
    name: 'TTS',
    type: VoiceSegmentType.tts,
    duration: Duration(seconds: 2),
    text: 'Wake up',
  );

  test('shared recording is retained while any sequence references it', () {
    const sequences = [
      VoiceSequenceUiModel(id: 'a', name: 'A', segments: [recording]),
      VoiceSequenceUiModel(id: 'b', name: 'B', segments: [recording]),
    ];

    expect(RecordingFileStore.isReferenced(sharedPath, sequences), isTrue);
  });

  test('TTS segments never count as recording file references', () {
    const sequences = [
      VoiceSequenceUiModel(id: 'a', name: 'A', segments: [tts]),
    ];

    expect(RecordingFileStore.isReferenced(sharedPath, sequences), isFalse);
  });
}

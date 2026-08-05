import 'package:path/path.dart' as p;

import '../../shared/models/ui_models.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;
import 'storage_paths.dart';

abstract final class RecordingFileStore {
  static bool isReferenced(
    String path, {
    Iterable<VoiceSequenceUiModel> sequences = const [],
    Iterable<VoiceSegmentUiModel> savedVoices = const [],
  }) {
    final normalized = p.normalize(path);
    final inSequences = sequences.any(
      (sequence) => sequence.segments.any(
        (segment) =>
            segment.type == VoiceSegmentType.recording &&
            segment.filePath != null &&
            p.normalize(segment.filePath!) == normalized,
      ),
    );
    if (inSequences) return true;
    final inSaved = savedVoices.any(
      (voice) =>
          voice.type == VoiceSegmentType.recording &&
          voice.filePath != null &&
          p.normalize(voice.filePath!) == normalized,
    );
    return inSaved;
  }

  static Future<bool> deleteIfUnreferenced(
    String? path, {
    Iterable<VoiceSequenceUiModel> sequences = const [],
    Iterable<VoiceSegmentUiModel> savedVoices = const [],
  }) async {
    if (path == null || path.isEmpty) return false;
    if (isReferenced(path, sequences: sequences, savedVoices: savedVoices)) {
      return false;
    }
    final root = p.normalize(await StoragePaths.recordingsDirPath());
    final candidate = p.normalize(path);
    if (!p.isWithin(root, candidate)) return false;
    // Never delete Library/Sounds rendered CAF from this helper.
    if (candidate.contains(
          '${p.separator}Library${p.separator}Sounds${p.separator}',
        ) ||
        candidate.contains('/Library/Sounds/')) {
      return false;
    }
    await io_file.deleteFileIfExists(candidate);
    return true;
  }
}

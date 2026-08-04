import 'package:path/path.dart' as p;

import '../../shared/models/ui_models.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;
import 'storage_paths.dart';

abstract final class RecordingFileStore {
  static bool isReferenced(
    String path,
    Iterable<VoiceSequenceUiModel> sequences,
  ) {
    return sequences.any(
      (sequence) => sequence.segments.any(
        (segment) =>
            segment.type == VoiceSegmentType.recording &&
            segment.filePath == path,
      ),
    );
  }

  static Future<bool> deleteIfUnreferenced(
    String? path,
    Iterable<VoiceSequenceUiModel> sequences,
  ) async {
    if (path == null || path.isEmpty || isReferenced(path, sequences)) {
      return false;
    }
    final root = p.normalize(await StoragePaths.recordingsDirPath());
    final candidate = p.normalize(path);
    if (!p.isWithin(root, candidate)) return false;
    await io_file.deleteFileIfExists(candidate);
    return true;
  }
}

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_dir;

class StoragePaths {
  StoragePaths._();

  static Future<String> recordingsDirPath() async {
    if (kIsWeb) {
      throw UnsupportedError('Recording storage is unavailable on web.');
    }
    final root = await getApplicationDocumentsDirectory();
    final dirPath = p.join(root.path, 'recordings');
    await io_dir.ensureDirectoryExists(dirPath);
    return dirPath;
  }

  static Future<String> newRecordingPath() async {
    final dir = await recordingsDirPath();
    final name = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return p.join(dir, name);
  }
}

abstract final class RingtoneAssets {
  static const softChime = 'assets/ringtones/soft_chime.wav';
  static const oceanBreeze = 'assets/ringtones/ocean_breeze.wav';
  static const nightPulse = 'assets/ringtones/night_pulse.wav';
  static const forestDawn = 'assets/ringtones/forest_dawn.wav';
  static const crystalBell = 'assets/ringtones/crystal_bell.wav';

  static String pathForName(String? name) {
    return switch (name) {
      'Ocean Breeze' => oceanBreeze,
      'Night Pulse' => nightPulse,
      'Forest Dawn' => forestDawn,
      'Crystal Bell' => crystalBell,
      _ => softChime,
    };
  }
}

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

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

/// Bundled ringtone catalog. [name] is the persisted alarm field value.
class RingtoneAsset {
  const RingtoneAsset({
    required this.name,
    required this.assetPath,
  });

  final String name;
  final String assetPath;
}

abstract final class RingtoneAssets {
  static const softChime = 'assets/ringtones/soft_chime.wav';
  static const oceanBreeze = 'assets/ringtones/ocean_breeze.wav';
  static const nightPulse = 'assets/ringtones/night_pulse.wav';
  static const forestDawn = 'assets/ringtones/forest_dawn.wav';
  static const crystalBell = 'assets/ringtones/crystal_bell.wav';
  static const morningGlow = 'assets/ringtones/morning_glow.wav';
  static const gentleRain = 'assets/ringtones/gentle_rain.wav';
  static const silverHarp = 'assets/ringtones/silver_harp.wav';
  static const amberTone = 'assets/ringtones/amber_tone.wav';
  static const lotusBell = 'assets/ringtones/lotus_bell.wav';
  static const windChimes = 'assets/ringtones/wind_chimes.wav';
  static const calmStream = 'assets/ringtones/calm_stream.wav';
  static const sunriseFanfare = 'assets/ringtones/sunrise_fanfare.wav';
  static const deepPulse = 'assets/ringtones/deep_pulse.wav';
  static const glassSpark = 'assets/ringtones/glass_spark.wav';
  static const meadowSong = 'assets/ringtones/meadow_song.wav';
  static const auroraChime = 'assets/ringtones/aurora_chime.wav';
  static const velvetKnock = 'assets/ringtones/velvet_knock.wav';
  static const pearlDrop = 'assets/ringtones/pearl_drop.wav';
  static const skylineRise = 'assets/ringtones/skyline_rise.wav';
  static const emberGlow = 'assets/ringtones/ember_glow.wav';
  static const harborBell = 'assets/ringtones/harbor_bell.wav';

  static const all = <RingtoneAsset>[
    RingtoneAsset(name: 'Soft Chime', assetPath: softChime),
    RingtoneAsset(name: 'Ocean Breeze', assetPath: oceanBreeze),
    RingtoneAsset(name: 'Night Pulse', assetPath: nightPulse),
    RingtoneAsset(name: 'Forest Dawn', assetPath: forestDawn),
    RingtoneAsset(name: 'Crystal Bell', assetPath: crystalBell),
    RingtoneAsset(name: 'Morning Glow', assetPath: morningGlow),
    RingtoneAsset(name: 'Gentle Rain', assetPath: gentleRain),
    RingtoneAsset(name: 'Silver Harp', assetPath: silverHarp),
    RingtoneAsset(name: 'Amber Tone', assetPath: amberTone),
    RingtoneAsset(name: 'Lotus Bell', assetPath: lotusBell),
    RingtoneAsset(name: 'Wind Chimes', assetPath: windChimes),
    RingtoneAsset(name: 'Calm Stream', assetPath: calmStream),
    RingtoneAsset(name: 'Sunrise Fanfare', assetPath: sunriseFanfare),
    RingtoneAsset(name: 'Deep Pulse', assetPath: deepPulse),
    RingtoneAsset(name: 'Glass Spark', assetPath: glassSpark),
    RingtoneAsset(name: 'Meadow Song', assetPath: meadowSong),
    RingtoneAsset(name: 'Aurora Chime', assetPath: auroraChime),
    RingtoneAsset(name: 'Velvet Knock', assetPath: velvetKnock),
    RingtoneAsset(name: 'Pearl Drop', assetPath: pearlDrop),
    RingtoneAsset(name: 'Skyline Rise', assetPath: skylineRise),
    RingtoneAsset(name: 'Ember Glow', assetPath: emberGlow),
    RingtoneAsset(name: 'Harbor Bell', assetPath: harborBell),
  ];

  static String pathForName(String? name) {
    for (final tone in all) {
      if (tone.name == name) return tone.assetPath;
    }
    return softChime;
  }
}

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// Plays local files and bundled assets. Safe no-op on web when unsupported.
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;
  bool _alarmAttributesApplied = false;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  bool get playing => _player.playing;

  Future<void> _ensureAlarmAttributes() async {
    if (kIsWeb || _alarmAttributesApplied) return;
    try {
      await _player.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm,
        ),
      );
      _alarmAttributesApplied = true;
    } catch (error) {
      debugPrint('AudioPlayerService alarm attributes failed: $error');
    }
  }

  Future<void> playAsset(String assetPath) async {
    await _player.stop();
    await _ensureAlarmAttributes();
    await _player.setLoopMode(LoopMode.off);
    await _player.setAsset(assetPath);
    await _player.play();
    await _player.processingStateStream.firstWhere(
      (state) =>
          state == ProcessingState.completed ||
          state == ProcessingState.idle,
    );
  }

  /// Loops an asset until [stop] is called.
  Future<void> loopAsset(String assetPath) async {
    await _player.stop();
    await _ensureAlarmAttributes();
    await _player.setLoopMode(LoopMode.one);
    await _player.setAsset(assetPath);
    await _player.play();
  }

  Future<void> playFile(String filePath) async {
    if (kIsWeb) return;
    await _player.stop();
    await _ensureAlarmAttributes();
    await _player.setLoopMode(LoopMode.off);
    await _player.setFilePath(filePath);
    await _player.play();
    await _player.processingStateStream.firstWhere(
      (state) =>
          state == ProcessingState.completed ||
          state == ProcessingState.idle,
    );
  }

  Future<void> playFilePreview(String filePath) async {
    if (kIsWeb) return;
    await _player.stop();
    await _player.setLoopMode(LoopMode.off);
    await _player.setFilePath(filePath);
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.setLoopMode(LoopMode.off);
  }

  Future<void> pause() => _player.pause();

  Future<void> dispose() => _player.dispose();
}

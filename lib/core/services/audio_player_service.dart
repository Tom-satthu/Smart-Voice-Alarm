import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Plays local files and bundled assets. Safe no-op on web when unsupported.
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  bool get playing => _player.playing;

  Future<void> playAsset(String assetPath) async {
    await _player.stop();
    await _player.setAsset(assetPath);
    await _player.play();
    await _player.processingStateStream.firstWhere(
      (state) =>
          state == ProcessingState.completed ||
          state == ProcessingState.idle,
    );
  }

  Future<void> playFile(String filePath) async {
    if (kIsWeb) return;
    await _player.stop();
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
    await _player.setFilePath(filePath);
    await _player.play();
  }

  Future<void> stop() => _player.stop();
  Future<void> pause() => _player.pause();

  Future<void> dispose() => _player.dispose();
}

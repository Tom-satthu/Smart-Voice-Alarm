import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'storage_paths.dart';

enum RecordingStatus { idle, recording, stopped }

class RecordingService {
  RecordingService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;
  DateTime? _startedAt;
  RecordingStatus status = RecordingStatus.idle;

  String? get currentPath => _currentPath;
  Duration get elapsed {
    if (_startedAt == null) return Duration.zero;
    return DateTime.now().difference(_startedAt!);
  }

  Future<bool> ensurePermission() async {
    if (kIsWeb) return false;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> get hasPermission async {
    if (kIsWeb) return false;
    return Permission.microphone.isGranted;
  }

  Future<void> start() async {
    if (kIsWeb) {
      throw UnsupportedError('Recording is not supported on web.');
    }
    final granted = await ensurePermission();
    if (!granted) {
      throw StateError('Microphone permission denied.');
    }
    _currentPath = await StoragePaths.newRecordingPath();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentPath!,
    );
    _startedAt = DateTime.now();
    status = RecordingStatus.recording;
  }

  Future<String?> stop() async {
    if (status != RecordingStatus.recording) return _currentPath;
    final path = await _recorder.stop();
    status = RecordingStatus.stopped;
    _currentPath = path ?? _currentPath;
    return _currentPath;
  }

  Future<void> cancel() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    status = RecordingStatus.idle;
    _currentPath = null;
    _startedAt = null;
  }

  Future<void> dispose() => _recorder.dispose();
}

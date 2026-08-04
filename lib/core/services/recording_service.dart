import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'storage_paths.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;

enum RecordingStatus { idle, recording, stopped }

enum MicrophoneAccess { granted, denied, permanentlyDenied, restricted }

class RecordingService {
  RecordingService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;
  DateTime? _startedAt;
  RecordingStatus status = RecordingStatus.idle;
  bool _starting = false;
  bool _retained = false;

  String? get currentPath => _currentPath;
  Duration get elapsed {
    if (_startedAt == null) return Duration.zero;
    return DateTime.now().difference(_startedAt!);
  }

  Future<MicrophoneAccess> microphoneAccess({bool request = false}) async {
    if (kIsWeb) return MicrophoneAccess.restricted;
    final permission = request
        ? await Permission.microphone.request()
        : await Permission.microphone.status;
    if (permission.isGranted) return MicrophoneAccess.granted;
    if (permission.isPermanentlyDenied) {
      return MicrophoneAccess.permanentlyDenied;
    }
    if (permission.isRestricted) return MicrophoneAccess.restricted;
    return MicrophoneAccess.denied;
  }

  Future<bool> get hasPermission async {
    if (kIsWeb) return false;
    return Permission.microphone.isGranted;
  }

  Future<void> start() async {
    if (kIsWeb) {
      throw UnsupportedError('Recording is not supported on web.');
    }
    if (_starting || status == RecordingStatus.recording) {
      throw StateError('A recording is already in progress.');
    }
    if (!await hasPermission) {
      throw StateError('Microphone permission denied.');
    }
    _starting = true;
    try {
      await cancel();
      _currentPath = await StoragePaths.newRecordingPath();
      _retained = false;
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
    } finally {
      _starting = false;
    }
  }

  Future<String?> stop() async {
    if (status != RecordingStatus.recording) return _currentPath;
    final path = await _recorder.stop();
    status = RecordingStatus.stopped;
    _currentPath = path ?? _currentPath;
    final finalized = _currentPath;
    if (finalized == null || await io_file.fileLength(finalized) == 0) {
      if (finalized != null) await io_file.deleteFileIfExists(finalized);
      _currentPath = null;
      status = RecordingStatus.idle;
      throw StateError('Recording could not be finalized.');
    }
    return _currentPath;
  }

  void retainCurrentFile() {
    if (_currentPath != null && status == RecordingStatus.stopped) {
      _retained = true;
    }
  }

  Future<void> cancel() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    final abandoned = _currentPath;
    if (abandoned != null && !_retained) {
      await io_file.deleteFileIfExists(abandoned);
    }
    status = RecordingStatus.idle;
    _currentPath = null;
    _startedAt = null;
    _retained = false;
  }

  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}

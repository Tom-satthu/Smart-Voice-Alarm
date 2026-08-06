import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'recording_limits.dart';
import 'storage_paths.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;

enum RecordingStatus { idle, recording, stopped }

enum MicrophoneAccess { granted, denied, permanentlyDenied, restricted }

class RecordingService {
  RecordingService({
    this.maxDuration = kMaxRecordingDuration,
    AudioRecorder? recorder,
  }) : _recorder = recorder ?? AudioRecorder();

  final Duration maxDuration;
  final AudioRecorder _recorder;
  String? _currentPath;
  DateTime? _startedAt;
  RecordingStatus status = RecordingStatus.idle;
  bool _starting = false;
  bool _retained = false;
  bool _stopping = false;
  Timer? _autoStopTimer;
  Completer<String?>? _stopCompleter;

  String? get currentPath => _currentPath;
  Duration get elapsed {
    if (_startedAt == null) return Duration.zero;
    final raw = DateTime.now().difference(_startedAt!);
    if (raw > maxDuration) return maxDuration;
    return raw;
  }

  bool get isStopping => _stopping;

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
      _armAutoStop();
    } finally {
      _starting = false;
    }
  }

  void _armAutoStop() {
    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(maxDuration, () {
      unawaited(stop());
    });
  }

  /// Stops the recorder. Safe to call concurrently (auto-stop + manual).
  /// Second callers await the same in-flight stop.
  Future<String?> stop() async {
    if (_stopCompleter != null) {
      return _stopCompleter!.future;
    }
    if (status != RecordingStatus.recording) return _currentPath;

    _stopping = true;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    final completer = Completer<String?>();
    _stopCompleter = completer;
    try {
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
      completer.complete(_currentPath);
      return _currentPath;
    } catch (e, st) {
      if (!completer.isCompleted) completer.completeError(e, st);
      rethrow;
    } finally {
      _stopping = false;
      _stopCompleter = null;
    }
  }

  void retainCurrentFile() {
    if (_currentPath != null && status == RecordingStatus.stopped) {
      _retained = true;
    }
  }

  Future<void> cancel() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    if (_stopCompleter != null) {
      try {
        await _stopCompleter!.future;
      } catch (_) {}
    }
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
    _stopping = false;
  }

  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}

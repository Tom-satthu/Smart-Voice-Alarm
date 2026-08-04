import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import 'audio_player_service.dart';
import 'storage_paths.dart';
import 'tts_service.dart';

enum AlarmEnginePhase { idle, playingVoice, playingRingtone, completed }

typedef AlarmFiredCallback = FutureOr<void> Function(AlarmUiModel alarm);
typedef AlarmStopNativeCallback = FutureOr<void> Function();

/// Plays voice sequences then loops ringtone until the user stops.
///
/// Queue rules:
/// - Later alarms wait until the active alarm ends.
/// - [stopCurrent] ends only the active alarm and continues the queue.
/// - [stopAll] clears the queue and stops everything.
class AlarmEngine {
  AlarmEngine({
    AudioPlayerService? audioPlayer,
    TtsService? tts,
    AlarmRepository? alarmRepository,
    VoiceSequenceRepository? sequenceRepository,
    this.onAlarmStarted,
    this.onStopNative,
  }) : _audio = audioPlayer ?? AudioPlayerService(),
       _tts = tts ?? TtsService(),
       _alarms = alarmRepository ?? AlarmRepository(),
       _sequences = sequenceRepository ?? VoiceSequenceRepository();

  final AudioPlayerService _audio;
  final TtsService _tts;
  final AlarmRepository _alarms;
  final VoiceSequenceRepository _sequences;

  /// Called when an alarm begins playback (for one-shot disable / reschedule).
  final AlarmFiredCallback? onAlarmStarted;

  /// Stops native foreground service / notification / vibration / wake lock.
  final AlarmStopNativeCallback? onStopNative;

  final Queue<String> _queue = Queue<String>();
  bool _running = false;
  bool _stopCurrentRequested = false;
  bool _stopAllRequested = false;
  Completer<void>? _ringtoneHold;

  AlarmEnginePhase phase = AlarmEnginePhase.idle;
  String? activeAlarmId;
  String? statusText;
  int queuedCount = 0;

  final _phaseController = StreamController<AlarmEnginePhase>.broadcast();
  Stream<AlarmEnginePhase> get phaseStream => _phaseController.stream;

  final _activeController = StreamController<String?>.broadcast();
  Stream<String?> get activeAlarmStream => _activeController.stream;

  bool get isRunning => _running;
  bool get hasQueued => _queue.isNotEmpty;

  Future<void> enqueue(String alarmId) async {
    if (_queue.contains(alarmId) || activeAlarmId == alarmId) return;
    // Prevent native FGS dual-play when a second alarm fires while Flutter
    // already owns the ringing session.
    if (_running) {
      await _stopNativeOnly();
    }
    _queue.addLast(alarmId);
    queuedCount = _queue.length;
    if (!_running) {
      await _processQueue();
    } else {
      queuedCount = _queue.length;
    }
  }

  /// Stops the active alarm only; continues with the next queued alarm.
  Future<void> stopCurrent() async {
    _stopCurrentRequested = true;
    await _interruptPlayback(stopNative: true);
    _ringtoneHold?.complete();
    _ringtoneHold = null;
  }

  /// Stops everything and clears the queue.
  Future<void> stopAll() async {
    _stopAllRequested = true;
    _stopCurrentRequested = true;
    _queue.clear();
    queuedCount = 0;
    await _interruptPlayback(stopNative: true);
    _ringtoneHold?.complete();
    _ringtoneHold = null;
    _running = false;
    activeAlarmId = null;
    _activeController.add(null);
    phase = AlarmEnginePhase.idle;
    _phaseController.add(phase);
  }

  /// Removes [alarmId] from the queue, or stops it if currently ringing.
  Future<void> dismissAlarm(String alarmId) async {
    final removed = _queue.remove(alarmId);
    if (removed) {
      queuedCount = _queue.length;
    }
    if (activeAlarmId == alarmId) {
      await stopCurrent();
    } else if (removed) {
      await _stopNativeOnly();
    }
  }

  /// Backwards-compatible alias for [stopAll].
  Future<void> stop() => stopAll();

  Future<void> _interruptPlayback({required bool stopNative}) async {
    await _audio.stop();
    await _tts.stop();
    if (stopNative) {
      await _stopNativeOnly();
    }
  }

  Future<void> _stopNativeOnly() async {
    final stop = onStopNative;
    if (stop != null) {
      await stop();
    }
  }

  Future<void> _processQueue() async {
    if (_running) return;
    _running = true;
    _stopAllRequested = false;

    while (_queue.isNotEmpty && !_stopAllRequested) {
      _stopCurrentRequested = false;
      final alarmId = _queue.removeFirst();
      queuedCount = _queue.length;
      activeAlarmId = alarmId;
      _activeController.add(alarmId);
      await _playAlarm(alarmId);
      if (_stopAllRequested) break;
    }

    _running = false;
    activeAlarmId = null;
    _activeController.add(null);
    queuedCount = 0;
    phase = AlarmEnginePhase.completed;
    _phaseController.add(phase);
    phase = AlarmEnginePhase.idle;
    _phaseController.add(phase);
  }

  Future<void> _playAlarm(String alarmId) async {
    final alarm = _alarms.findById(alarmId);
    if (alarm == null) return;

    // Hand off from native FGS before Flutter starts audio to avoid dual play.
    await _stopNativeOnly();

    final started = onAlarmStarted;
    if (started != null) {
      await started(alarm);
    }

    // Re-read after callback (one-shot may have flipped isEnabled).
    final fresh = _alarms.findById(alarmId) ?? alarm;

    final sequence = fresh.voiceSequenceId == null
        ? null
        : _sequences.findById(fresh.voiceSequenceId!);

    final hasVoice = sequence != null && sequence.segments.isNotEmpty;
    final playVoice = hasVoice && fresh.type != AlarmType.ringtone;

    if (playVoice) {
      phase = AlarmEnginePhase.playingVoice;
      _phaseController.add(phase);
      final loops = fresh.repeatCount.clamp(1, 20);
      for (var loop = 0; loop < loops && !_shouldStopAlarm; loop++) {
        for (final segment in sequence.segments) {
          if (_shouldStopAlarm) break;
          statusText = segment.name;
          await _playSegment(segment);
        }
      }
    }

    // Always ring until the user stops (Prompt 2).
    if (!_shouldStopAlarm) {
      phase = AlarmEnginePhase.playingRingtone;
      _phaseController.add(phase);
      statusText = fresh.ringtoneName ?? 'Ringtone';
      await _loopRingtone(RingtoneAssets.pathForName(fresh.ringtoneName));
    }
  }

  bool get _shouldStopAlarm => _stopCurrentRequested || _stopAllRequested;

  Future<void> _loopRingtone(String assetPath) async {
    _ringtoneHold = Completer<void>();
    try {
      await _audio.loopAsset(assetPath);
      await _ringtoneHold!.future;
    } finally {
      _ringtoneHold = null;
      await _audio.stop();
    }
  }

  Future<void> _playSegment(VoiceSegmentUiModel segment) async {
    if (segment.type == VoiceSegmentType.recording) {
      final path = segment.filePath;
      if (path == null || path.isEmpty || kIsWeb) return;
      await _audio.playFile(path);
      return;
    }

    final text = segment.text?.trim() ?? '';
    if (text.isEmpty) return;
    await _tts.speakSegment(
      text: text,
      voiceId: segment.voiceId,
      locale: segment.localeId,
    );
  }

  Future<void> dispose() async {
    await stopAll();
    await _phaseController.close();
    await _activeController.close();
  }
}

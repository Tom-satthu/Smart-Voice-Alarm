import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import 'audio_player_service.dart';
import 'storage_paths.dart';
import 'tts_service.dart';

enum AlarmEnginePhase {
  idle,
  playingVoice,
  playingRingtone,
  completed,
}

class AlarmEngine {
  AlarmEngine({
    AudioPlayerService? audioPlayer,
    TtsService? tts,
    AlarmRepository? alarmRepository,
    VoiceSequenceRepository? sequenceRepository,
  })  : _audio = audioPlayer ?? AudioPlayerService(),
        _tts = tts ?? TtsService(),
        _alarms = alarmRepository ?? AlarmRepository(),
        _sequences = sequenceRepository ?? VoiceSequenceRepository();

  final AudioPlayerService _audio;
  final TtsService _tts;
  final AlarmRepository _alarms;
  final VoiceSequenceRepository _sequences;

  final Queue<String> _queue = Queue<String>();
  bool _running = false;
  bool _stopRequested = false;

  AlarmEnginePhase phase = AlarmEnginePhase.idle;
  String? activeAlarmId;
  String? statusText;

  final _phaseController = StreamController<AlarmEnginePhase>.broadcast();
  Stream<AlarmEnginePhase> get phaseStream => _phaseController.stream;

  bool get isRunning => _running;

  Future<void> enqueue(String alarmId) async {
    if (_queue.contains(alarmId) || activeAlarmId == alarmId) return;
    _queue.addLast(alarmId);
    if (!_running) {
      await _processQueue();
    }
  }

  Future<void> stop() async {
    _stopRequested = true;
    await _audio.stop();
    await _tts.stop();
    _queue.clear();
    _running = false;
    activeAlarmId = null;
    phase = AlarmEnginePhase.idle;
    _phaseController.add(phase);
  }

  Future<void> _processQueue() async {
    if (_running) return;
    _running = true;
    _stopRequested = false;

    while (_queue.isNotEmpty && !_stopRequested) {
      final alarmId = _queue.removeFirst();
      activeAlarmId = alarmId;
      await _playAlarm(alarmId);
    }

    _running = false;
    activeAlarmId = null;
    phase = AlarmEnginePhase.completed;
    _phaseController.add(phase);
    phase = AlarmEnginePhase.idle;
    _phaseController.add(phase);
  }

  Future<void> _playAlarm(String alarmId) async {
    final alarm = _alarms.findById(alarmId);
    if (alarm == null || !alarm.isEnabled) return;

    final sequence = alarm.voiceSequenceId == null
        ? null
        : _sequences.findById(alarm.voiceSequenceId!);

    final hasVoice = sequence != null && sequence.segments.isNotEmpty;
    final playVoice =
        hasVoice && alarm.type != AlarmType.ringtone;
    final playRingtone = alarm.type != AlarmType.voice;

    if (playVoice) {
      phase = AlarmEnginePhase.playingVoice;
      _phaseController.add(phase);
      final loops = alarm.repeatCount.clamp(1, 20);
      for (var loop = 0; loop < loops && !_stopRequested; loop++) {
        for (final segment in sequence.segments) {
          if (_stopRequested) return;
          statusText = segment.name;
          await _playSegment(segment);
        }
      }
    }

    if (playRingtone && !_stopRequested) {
      phase = AlarmEnginePhase.playingRingtone;
      _phaseController.add(phase);
      statusText = alarm.ringtoneName ?? 'Ringtone';
      // Play ringtone a few cycles so it is noticeable.
      for (var i = 0; i < 4 && !_stopRequested; i++) {
        await _audio.playAsset(
          RingtoneAssets.pathForName(alarm.ringtoneName),
        );
      }
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
    await stop();
    await _phaseController.close();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import 'alarm_kit_timeline_config.dart';
import 'alarm_schedule_result.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;
import 'ios_alarm_scheduler.dart';
import 'ios_alarm_segment_planner.dart';
import 'storage_paths.dart';

/// Renders voice/ringtone clips and schedules iOS fan-out segments.
///
/// Uses a two-phase transaction: never cancel the previous schedule until the
/// new revision has been fully rendered, validated, and scheduled.
class IosAlarmFanoutService {
  IosAlarmFanoutService({
    IosAlarmScheduler? scheduler,
    VoiceSequenceRepository? sequences,
    IosAlarmSegmentPlanner? planner,
  }) : _scheduler = scheduler ?? IosAlarmScheduler(),
       _sequences = sequences ?? VoiceSequenceRepository(),
       _planner = planner ?? IosAlarmSegmentPlanner();

  final IosAlarmScheduler _scheduler;
  final VoiceSequenceRepository _sequences;
  final IosAlarmSegmentPlanner _planner;
  final _uuid = const Uuid();

  IosAlarmScheduler get scheduler => _scheduler;

  bool get isSupported => _scheduler.isSupported;

  Future<IosAlarmCapability> capability() => _scheduler.getCapability();

  Future<void> cancelAlarm(String alarmId) => _scheduler.cancelParent(alarmId);

  Future<void> cancelOccurrence({
    required String parentAlarmId,
    required String occurrenceId,
  }) {
    return _scheduler.cancelOccurrence(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
    );
  }

  /// Launch-safe path: never renders audio, never schedules, never cancels.
  Future<void> reconcileWithoutRender(List<AlarmUiModel> alarms) async {
    if (!isSupported) return;
    debugPrint(
      '[SVA-Startup] reconcileWithoutRender no-op '
      '(alarms=${alarms.length}; no schedule/cancel/render)',
    );
  }

  Future<AlarmScheduleResult> scheduleAlarm(
    AlarmUiModel alarm,
    DateTime occurrence, {
    VoiceSequenceUiModel? sequenceOverride,
  }) async {
    final tx = _uuid.v4().substring(0, 8);
    void log(String stage, String detail) {
      debugPrint('[SVA-Save] transaction=$tx stage=$stage $detail');
    }

    if (!_scheduler.isSupported) {
      return AlarmScheduleResult.ok(
        stage: 'notification_schedule',
        transactionId: tx,
      );
    }
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm.id);
      return AlarmScheduleResult.ok(
        stage: 'notification_schedule',
        transactionId: tx,
      );
    }

    log('validation', 'alarmType=${alarm.type.name}');
    final occurrenceId = IosAlarmSegmentPlanner.occurrenceIdFor(
      alarm,
      occurrence,
    );
    final revision = _uuid.v4().substring(0, 8);
    debugPrint(
      '[SVA-Schedule] begin parent=${alarm.id} occurrence=$occurrenceId '
      'rev=$revision tx=$tx',
    );

    final voiceClips = <PreparedAlarmClip>[];
    final ringtoneClips = <PreparedAlarmClip>[];
    final renderedNames = <String>[];
    String? warningCode;
    String? warningMessage;

    Future<AlarmScheduleResult> fail({
      required String code,
      required String message,
      required String stage,
      String? sourceType,
      String? sourceId,
      String? filePath,
    }) async {
      log(stage, 'FAIL code=$code');
      for (final name in renderedNames) {
        try {
          await _scheduler.deleteSoundFile(name);
        } catch (_) {}
      }
      return AlarmScheduleResult.fail(
        errorCode: code,
        errorMessage: message,
        stage: stage,
        sourceType: sourceType,
        sourceId: sourceId,
        filePath: filePath,
        needsAudioRepair: true,
        transactionId: tx,
      );
    }

    // Resolve sequence: prefer in-memory draft snapshot.
    VoiceSequenceUiModel? sequence;
    if (alarm.type != AlarmType.ringtone) {
      log('voice_sequence_lookup', 'override=${sequenceOverride != null}');
      sequence =
          sequenceOverride ??
          (alarm.voiceSequenceId == null
              ? null
              : _sequences.findById(alarm.voiceSequenceId!));
      final segments = sequence?.segments ?? const <VoiceSegmentUiModel>[];
      log('voice_sequence_lookup', 'sequenceSegments=${segments.length}');

      if (segments.isEmpty && alarm.type == AlarmType.voice) {
        return fail(
          code: 'voice_empty',
          message: 'Voice alarm has no segments to render',
          stage: 'validation',
        );
      }
      if (alarm.type == AlarmType.mixed && segments.isEmpty) {
        return fail(
          code: 'mixed_missing_voice',
          message: 'Mixed alarm requires at least one voice segment',
          stage: 'validation',
        );
      }

      var voiceIndex = 0;
      for (final segment in segments) {
        if (voiceIndex >= 5) break;

        if (segment.type == VoiceSegmentType.recording) {
          final pre = await _preflightRecording(segment);
          if (pre != null) {
            return fail(
              code: pre.errorCode!,
              message: pre.errorMessage!,
              stage: pre.stage!,
              sourceType: 'recording',
              sourceId: segment.id,
              filePath: segment.filePath,
            );
          }
        } else if (segment.type == VoiceSegmentType.tts) {
          final text = segment.text?.trim() ?? '';
          if (text.isEmpty) {
            return fail(
              code: 'tts_empty',
              message: 'TTS segment has empty text',
              stage: 'validation',
              sourceType: 'tts',
              sourceId: segment.id,
            );
          }
        }

        try {
          final fileName = IosAlarmSegmentPlanner.soundFileName(
            parentId: alarm.id,
            occurrenceId: occurrenceId,
            segmentIndex: voiceIndex,
            revision: revision,
          );
          final stage = segment.type == VoiceSegmentType.tts
              ? 'tts_render'
              : 'recording_render';
          log(stage, 'segmentIndex=$voiceIndex');
          final rendered = await _renderVoiceSegment(segment, fileName);
          if (rendered.durationMs <= 0 || rendered.path.isEmpty) {
            return fail(
              code: 'render_invalid',
              message: 'Rendered voice segment invalid',
              stage: stage,
              sourceType: segment.type.name,
              sourceId: segment.id,
            );
          }
          renderedNames.add(rendered.fileName);
          voiceClips.add(
            preparedClip(
              fileName: rendered.fileName,
              duration: Duration(milliseconds: rendered.effectiveFinalizedMs),
              label: segment.type == VoiceSegmentType.tts ? 'tts' : 'recording',
              contentDuration: Duration(
                milliseconds: rendered.effectiveContentDurationMs,
              ),
              trailingSilence: Duration(
                milliseconds: rendered.trailingSilenceMs > 0
                    ? rendered.trailingSilenceMs
                    : AlarmKitTimelineConfig.trailingSilence.inMilliseconds,
              ),
            ),
          );
          debugPrint(
            '[SVA-Audio] scheduleSound type=${segment.type.name} '
            'path=${rendered.path} file=${rendered.fileName} '
            'size=${rendered.byteSize} contentMs=${rendered.effectiveContentDurationMs} '
            'trailMs=${rendered.trailingSilenceMs} '
            'finalMs=${rendered.effectiveFinalizedMs} '
            'hash=${rendered.debugHash}',
          );
          voiceIndex += 1;
        } catch (e) {
          final stage = segment.type == VoiceSegmentType.tts
              ? 'tts_render'
              : 'recording_render';
          debugPrint('[SVA-Audio] voice render failed ${segment.id}: $e');
          return fail(
            code: segment.type == VoiceSegmentType.tts
                ? 'tts_render_failed'
                : 'recording_render_failed',
            message: '$e',
            stage: stage,
            sourceType: segment.type.name,
            sourceId: segment.id,
            filePath: segment.filePath,
          );
        }
      }

      if (segments.isNotEmpty && voiceClips.isEmpty) {
        return fail(
          code: 'voice_render_empty',
          message: 'No voice clips rendered',
          stage: 'recording_render',
        );
      }
    }

    if (alarm.type != AlarmType.voice) {
      final assetPath = RingtoneAssets.pathForName(alarm.ringtoneName);
      final key = _ringtoneAssetKey(alarm.ringtoneName);
      log(
        'ringtone_asset_lookup',
        'name=${alarm.ringtoneName} asset=$assetPath key=$key',
      );

      final assetOk = await _flutterAssetExists(assetPath);
      log(
        'ringtone_asset_lookup',
        'flutterBundleExists=$assetOk nativeKey=$key',
      );

      try {
        final fileName = IosAlarmSegmentPlanner.soundFileName(
          parentId: alarm.id,
          occurrenceId: occurrenceId,
          segmentIndex: 100,
          revision: revision,
        );
        log('ringtone_render', 'begin file=$fileName');

        // Prefer materializing via Flutter AssetBundle so iOS App.framework
        // layout cannot break native Bundle.main lookups.
        IosRenderedSound rendered;
        final materialized = await _materializeFlutterAsset(assetPath);
        if (materialized != null) {
          log('ringtone_render', 'materialized path exists — using sourcePath');
          rendered = await _scheduler.renderSound(
            fileName: fileName,
            sourcePath: materialized,
            maxSeconds: 10,
            targetDurationSeconds: 10,
            trailingSilenceSeconds:
                AlarmKitTimelineConfig.trailingSilence.inMilliseconds / 1000.0,
            audioRole: 'ringtone',
          );
        } else {
          rendered = await _scheduler.renderSound(
            fileName: fileName,
            assetKey: key,
            maxSeconds: 10,
            targetDurationSeconds: 10,
            trailingSilenceSeconds:
                AlarmKitTimelineConfig.trailingSilence.inMilliseconds / 1000.0,
            audioRole: 'ringtone',
          );
        }
        renderedNames.add(rendered.fileName);
        ringtoneClips.add(
          preparedClip(
            fileName: rendered.fileName,
            duration: Duration(milliseconds: rendered.effectiveFinalizedMs),
            label: 'ringtone',
            contentDuration: Duration(
              milliseconds: rendered.effectiveContentDurationMs > 0
                  ? rendered.effectiveContentDurationMs
                  : AlarmKitTimelineConfig.ringtoneDuration.inMilliseconds,
            ),
            trailingSilence: Duration(
              milliseconds: rendered.trailingSilenceMs > 0
                  ? rendered.trailingSilenceMs
                  : AlarmKitTimelineConfig.trailingSilence.inMilliseconds,
            ),
          ),
        );
      } catch (e) {
        debugPrint('[SVA-Audio] ringtone render failed: $e');
        // Mixed/ringtone: fall back to system default sound child — never
        // silently drop the ringtone slot or blame the voice recording.
        ringtoneClips.add(
          preparedClip(
            fileName: '',
            duration: const Duration(seconds: 8),
            label: 'system_default',
          ),
        );
        warningCode = 'ringtone_fallback_system';
        warningMessage =
            'Custom ringtone could not be prepared. The system alarm sound will be used.';
        log('ringtone_render', 'fallback system default after error');
      }
    }

    if (alarm.type == AlarmType.mixed &&
        voiceClips.isNotEmpty &&
        ringtoneClips.isEmpty) {
      return fail(
        code: 'mixed_missing_ringtone',
        message: 'Mixed alarm requires a ringtone clip',
        stage: 'plan',
      );
    }

    if (voiceClips.isEmpty && ringtoneClips.isEmpty) {
      return fail(
        code: 'render_empty',
        message: 'Unable to render alarm audio',
        stage: 'plan',
      );
    }

    List<IosAlarmSegment> planned;
    IosAlarmPlan? planMeta;
    try {
      log(
        'plan',
        'voice=${voiceClips.length} ringtone=${ringtoneClips.length}',
      );
      // Ensure shared silence CAF exists before planning/scheduling.
      try {
        await _scheduler.ensureSilenceSound(seconds: 5);
      } catch (e) {
        debugPrint('[SVA-Audio] ensureSilence failed: $e');
        return fail(
          code: 'silence_render_failed',
          message: 'Could not prepare silence gap sound',
          stage: 'plan',
        );
      }
      planMeta = _planner.plan(
        alarm: alarm,
        occurrenceId: occurrenceId,
        occurrenceStart: occurrence,
        voiceClips: voiceClips,
        ringtoneClips: ringtoneClips,
      );
      planned = planMeta.segments;
    } on IosPlanValidationException catch (e) {
      for (final name in renderedNames) {
        try {
          await _scheduler.deleteSoundFile(name);
        } catch (_) {}
      }
      return fail(code: e.code, message: e.message, stage: 'plan');
    }

    debugPrint(
      '[SVA-Plan] type=${alarm.type.name} voiceCount=${voiceClips.length} '
      'ringtoneCount=${ringtoneClips.length} iosRepeatIgnored=1 '
      'cycles=${planMeta.cyclesScheduled} horizonMs=${planMeta.rollingHorizon.inMilliseconds} '
      'planned=${planned.length} audible=${planMeta.audibleChildCount} '
      'silent=${planMeta.silentChildCount}',
    );
    for (final segment in planned) {
      debugPrint(
        '[SVA-Plan] child index=${segment.segmentIndex} '
        'cycle=${segment.cycleIndex} role=${segment.role.name} '
        'start=${segment.startAt.toIso8601String()} '
        'durMs=${segment.duration.inMilliseconds} '
        'file=${segment.soundFileName}',
      );
    }

    try {
      final resolved = await _resolveBackendOnSave();
      final backend = resolved.backend;
      final backendReason = resolved.backendReason;
      var resolvedWarningCode = resolved.warningCode ?? warningCode;
      var resolvedWarningMessage = resolved.warningMessage ?? warningMessage;
      debugPrint(
        '[SVA-AlarmKit] backend=$backend reason=$backendReason '
        'authorization=${resolved.capability.alarmKitAuthorization}',
      );
      log(
        'schedule_backend',
        'backend=$backend reason=$backendReason segments=${planned.length}',
      );

      final native = await _scheduler.scheduleSegments(
        segments: planned,
        title: alarm.label.isEmpty ? 'Smart Voice Alarm' : alarm.label,
        body: 'Solve to stop',
        backend: backend,
        occurrenceMeta: {
          'revision': revision,
          'cyclesScheduled': planMeta.cyclesScheduled,
          'cycleDurationMs': planMeta.cycleDuration.inMilliseconds,
          'childCount': planMeta.childCount,
          'audibleChildCount': planMeta.audibleChildCount,
          'silentChildCount': planMeta.silentChildCount,
          'rollingHorizonEnd':
              planMeta.lastScheduledEnd?.millisecondsSinceEpoch.toDouble() ?? 0,
          'trailingSilenceMs':
              AlarmKitTimelineConfig.trailingSilence.inMilliseconds,
          'gapMs': _planner.gap.inMilliseconds,
          'alarmTitle': alarm.label.isEmpty ? 'Smart Voice Alarm' : alarm.label,
          'cycleTemplate': _planner.cycleTemplateMaps(
            type: alarm.type,
            voiceClips: voiceClips,
            ringtoneClips: ringtoneClips,
          ),
          'mathChallengeEnabled': alarm.mathChallengeEnabled,
          'isOneShot': alarm.repeatDays.isEmpty,
        },
      );
      final ok = native['ok'] != false;
      if (!ok) {
        for (final name in renderedNames) {
          try {
            await _scheduler.deleteSoundFile(name);
          } catch (_) {}
        }
        return AlarmScheduleResult.fail(
          errorCode: native['errorCode']?.toString() ?? 'schedule_failed',
          errorMessage: native['errorMessage']?.toString() ?? 'Schedule failed',
          stage: native['stage']?.toString() ?? 'notification_schedule',
          transactionId: tx,
          backend: native['backend']?.toString() ?? backend,
          backendReason: backendReason,
        );
      }

      final useAlarmKit = backend == AlarmScheduleBackend.alarmKit;
      final scheduledIds =
          (native['scheduledIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          planned.map((s) => s.childId).toList();
      final keepIds = useAlarmKit
          ? scheduledIds.toSet()
          : planned.map((s) => s.childId).toSet();

      try {
        log('selective_cancel', 'keep=${keepIds.length}');
        await _scheduler.cancelParentExcept(
          parentAlarmId: alarm.id,
          keepChildIds: keepIds,
        );
      } catch (e) {
        debugPrint('[SVA-Schedule] selective cancel failed: $e');
      }

      final mergedWarning =
          native['warningCode']?.toString() ?? resolvedWarningCode;
      final mergedWarningMsg =
          native['warningMessage']?.toString() ?? resolvedWarningMessage;

      log(
        'result',
        'code=${mergedWarning ?? 'ok'} stage=${native['stage']} '
            'backend=$backend reason=$backendReason ok=true',
      );
      return AlarmScheduleResult.ok(
        stage:
            native['stage']?.toString() ??
            (useAlarmKit ? 'alarmkit_schedule' : 'notification_schedule'),
        warningCode: mergedWarning,
        warningMessage: mergedWarningMsg,
        transactionId: tx,
        backend: backend,
        backendReason: backendReason,
        scheduledIds: scheduledIds,
      );
    } catch (e) {
      for (final name in renderedNames) {
        try {
          await _scheduler.deleteSoundFile(name);
        } catch (_) {}
      }
      return fail(
        code: 'schedule_failed',
        message: '$e',
        stage: 'notification_schedule',
      );
    }
  }

  Future<_BackendResolution> _resolveBackendOnSave() async {
    var cap = await _scheduler.getCapability();
    if (cap.shouldUseAlarmKitBackend) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.alarmKit,
        backendReason: cap.backendSelectionReason.isNotEmpty
            ? cap.backendSelectionReason
            : 'authorized',
        capability: cap,
      );
    }
    if (!cap.runtimeVersionEligible) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.notificationFanout,
        backendReason: 'version_ineligible',
        capability: cap,
      );
    }
    if (cap.diagnosticForceOff) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.notificationFanout,
        backendReason: 'diagnostic_force_off',
        capability: cap,
        warningCode: 'alarmkit_diagnostic_off',
        warningMessage: 'AlarmKit disabled in this review build.',
      );
    }
    if (cap.userDisabled) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.notificationFanout,
        backendReason: 'user_disabled',
        capability: cap,
        warningCode: 'alarmkit_user_disabled',
        warningMessage: 'AlarmKit turned off — using notification fallback.',
      );
    }
    if (cap.isAlarmKitDenied) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.notificationFanout,
        backendReason: 'denied',
        capability: cap,
        warningCode: 'alarmkit_denied_fallback',
        warningMessage:
            'Alarm permission denied — notifications will ring instead.',
      );
    }

    final probe = await _scheduler.probeAlarmKitPassive();
    cap = await _scheduler.getCapability();
    final probeAuth =
        probe['alarmKitAuthorization']?.toString() ?? cap.alarmKitAuthorization;

    if (probe['ok'] != true) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.notificationFanout,
        backendReason: 'session_probe_failed',
        capability: cap,
        warningCode: 'alarmkit_probe_failed',
        warningMessage: 'AlarmKit unavailable this time — using notifications.',
      );
    }

    if (probeAuth == 'notDetermined' || probeAuth == 'unknown') {
      final auth = await _scheduler.requestAlarmKitAuthorization();
      cap = await _scheduler.getCapability();
      final authState =
          auth['alarmKitAuthorization']?.toString() ??
          cap.alarmKitAuthorization;
      if (authState == 'authorized' &&
          (auth['ok'] == true || cap.shouldUseAlarmKitBackend)) {
        return _BackendResolution(
          backend: AlarmScheduleBackend.alarmKit,
          backendReason: 'authorized',
          capability: cap,
        );
      }
      if (authState == 'denied') {
        return _BackendResolution(
          backend: AlarmScheduleBackend.notificationFanout,
          backendReason: 'denied',
          capability: cap,
          warningCode: 'alarmkit_denied_fallback',
          warningMessage:
              'Alarm permission denied — notifications will ring instead.',
        );
      }
      if (auth['ok'] != true) {
        return _BackendResolution(
          backend: AlarmScheduleBackend.notificationFanout,
          backendReason: 'session_request_failed',
          capability: cap,
          warningCode: 'alarmkit_request_failed',
          warningMessage: 'Could not enable AlarmKit — using notifications.',
        );
      }
    }

    if (probeAuth == 'authorized' && cap.shouldUseAlarmKitBackend) {
      return _BackendResolution(
        backend: AlarmScheduleBackend.alarmKit,
        backendReason: 'authorized',
        capability: cap,
      );
    }

    return _BackendResolution(
      backend: AlarmScheduleBackend.notificationFanout,
      backendReason: cap.backendSelectionReason.isNotEmpty
          ? cap.backendSelectionReason
          : 'needs_user_probe_or_authorization',
      capability: cap,
      warningCode: 'alarmkit_fallback',
      warningMessage: 'Using notification fallback for this alarm.',
    );
  }

  Future<AlarmScheduleResult?> _preflightRecording(
    VoiceSegmentUiModel segment,
  ) async {
    final path = segment.filePath;
    if (path == null || path.isEmpty) {
      return AlarmScheduleResult.fail(
        errorCode: 'recording_path_missing',
        errorMessage: 'Recording segment missing file path',
        stage: 'recording_source_validation',
        sourceType: 'recording',
        sourceId: segment.id,
      );
    }
    final exists = await io_file.fileExists(path);
    debugPrint('[SVA-Save] recording pathExists=$exists size check next');
    if (!exists) {
      return AlarmScheduleResult.fail(
        errorCode: 'recording_file_missing',
        errorMessage: 'Recording file does not exist',
        stage: 'recording_source_validation',
        sourceType: 'recording',
        sourceId: segment.id,
        filePath: path,
      );
    }
    final size = await io_file.fileLength(path);
    debugPrint('[SVA-Save] recording pathExists=true size=$size');
    if (size <= 0) {
      return AlarmScheduleResult.fail(
        errorCode: 'recording_file_empty',
        errorMessage: 'Recording file is empty',
        stage: 'recording_source_validation',
        sourceType: 'recording',
        sourceId: segment.id,
        filePath: path,
      );
    }
    final ext = p.extension(path).toLowerCase();
    const allowed = {'.m4a', '.wav', '.caf', '.mp3', '.aac', '.mp4'};
    if (ext.isNotEmpty && !allowed.contains(ext)) {
      return AlarmScheduleResult.fail(
        errorCode: 'recording_unsupported_format',
        errorMessage: 'Recording container not supported: $ext',
        stage: 'recording_source_validation',
        sourceType: 'recording',
        sourceId: segment.id,
        filePath: path,
      );
    }
    return null;
  }

  Future<bool> _flutterAssetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _materializeFlutterAsset(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final dir = await getTemporaryDirectory();
      final name = p.basename(assetPath);
      final out = p.join(dir.path, 'sva_asset_$name');
      await io_file.ensureDirectoryExists(dir.path);
      // Write via dart:io through conditional import helpers is awkward for
      // bytes — use MethodChannel-free path via path_provider + write.
      // ignore: avoid_slow_async_io
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      // Use scheduler-free file write via dynamic File when IO available.
      return await _writeBytes(out, bytes);
    } catch (e) {
      debugPrint('[SVA-Save] materialize asset failed: $e');
      return null;
    }
  }

  Future<String?> _writeBytes(String path, List<int> bytes) async {
    try {
      // Delegated through a tiny helper that uses dart:io when available.
      await _ByteWriter.write(path, bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<IosRenderedSound> _renderVoiceSegment(
    VoiceSegmentUiModel segment,
    String fileName,
  ) {
    if (segment.type == VoiceSegmentType.tts) {
      return _scheduler.renderSound(
        fileName: fileName,
        ttsText: segment.text ?? segment.name,
        ttsLocale: segment.localeId,
        maxSeconds: 20,
        trailingSilenceSeconds:
            AlarmKitTimelineConfig.trailingSilence.inMilliseconds / 1000.0,
      );
    }
    final path = segment.filePath;
    if (path == null || path.isEmpty) {
      throw StateError('Recording segment missing file path');
    }
    if (segment.duration > const Duration(seconds: 20)) {
      debugPrint(
        '[SVA-Audio] recording source longer than 20s; alarm uses first 20s only',
      );
    }
    return _scheduler.renderSound(
      fileName: fileName,
      sourcePath: path,
      maxSeconds: 20,
      trailingSilenceSeconds:
          AlarmKitTimelineConfig.trailingSilence.inMilliseconds / 1000.0,
    );
  }

  String _ringtoneAssetKey(String? name) {
    final path = RingtoneAssets.pathForName(name);
    final file = path.split('/').last;
    final base = file.replaceAll(RegExp(r'\.(wav|caf|mp3)$'), '');
    if (base.isNotEmpty) return base;
    if (name == null || name.isEmpty) return 'soft_chime';
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (slug.isEmpty) return 'soft_chime';
    return slug;
  }

  DateTime? nextAfter(AlarmUiModel alarm, DateTime from) {
    for (var offset = 1; offset < 8; offset++) {
      final day = from.add(Duration(days: offset));
      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      if (alarm.repeatDays.isEmpty) return candidate;
      final weekday = switch (candidate.weekday) {
        DateTime.monday => Weekday.monday,
        DateTime.tuesday => Weekday.tuesday,
        DateTime.wednesday => Weekday.wednesday,
        DateTime.thursday => Weekday.thursday,
        DateTime.friday => Weekday.friday,
        DateTime.saturday => Weekday.saturday,
        _ => Weekday.sunday,
      };
      if (alarm.repeatDays.contains(weekday)) return candidate;
    }
    return null;
  }
}

class _BackendResolution {
  const _BackendResolution({
    required this.backend,
    required this.backendReason,
    required this.capability,
    this.warningCode,
    this.warningMessage,
  });

  final String backend;
  final String backendReason;
  final IosAlarmCapability capability;
  final String? warningCode;
  final String? warningMessage;
}

/// Tiny IO helper so fanout can write materialized assets without importing
/// dart:io at the library top level on web.
class _ByteWriter {
  static Future<void> write(String path, List<int> bytes) async {
    await io_file.writeBytes(path, bytes);
  }
}

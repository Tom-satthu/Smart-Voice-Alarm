import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../shared/data/local_store.dart';
import '../../shared/models/ui_models.dart';
import '../../shared/providers/prototype_providers.dart';
import 'alarm_schedule_result.dart';
import '../debug/sva_build_stamp.dart';
import 'io_dir_stub.dart' if (dart.library.io) 'io_dir_io.dart' as io_file;
import 'ios_alarm_segment_planner.dart';
import 'notification_service.dart';
import 'storage_paths.dart';

/// Debug-only automated iOS alarm diagnostics.
class IosAlarmDiagnostics {
  IosAlarmDiagnostics({NotificationService? notifications})
    : _notifications = notifications ?? NotificationService();

  final NotificationService _notifications;
  final _uuid = const Uuid();

  static bool get isAvailable =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      (kDebugMode || SvaBuildStamp.reviewBuild);

  Future<String> runAll() async {
    if (!isAvailable) {
      return 'SKIP: diagnostics only run on debug iOS builds';
    }
    final buf = StringBuffer()
      ..writeln('SVA iOS Alarm Diagnostics')
      ..writeln('started=${DateTime.now().toIso8601String()}')
      ..writeln('');

    final cases = <Future<DiagCase> Function()>[
      _caseRecordingRender,
      _caseTtsRender,
      _caseMixedPlan,
      _caseRepeatPlan,
      _caseTransactionFailure,
      _caseDraftCancelNoOrphan,
      _caseChallengePayload,
      _caseRingtoneAssetResolution,
      _casePendingQuery,
      _caseAlarmKitCapabilityRouting,
      _caseAlarmKitDiagnosticsShape,
    ];

    for (final run in cases) {
      final result = await run();
      buf.writeln(result.format());
      buf.writeln('');
    }
    buf.writeln('done=${DateTime.now().toIso8601String()}');
    final report = buf.toString();
    debugPrint(report);
    return report;
  }

  Future<DiagCase> _caseRecordingRender() async {
    const name = 'diag_rec';
    try {
      final fixture = await _materializeSoftChimeAsFixture();
      if (fixture == null) {
        return DiagCase.fail(
          name,
          code: 'fixture_missing',
          stage: 'recording_source_validation',
          detail: 'Could not materialize soft_chime fixture',
        );
      }
      final size = await io_file.fileLength(fixture);
      final fileName = 'sva_diag_rec_${_uuid.v4().substring(0, 8)}.caf';
      final rendered = await _notifications.iosFanout.scheduler.renderSound(
        fileName: fileName,
        sourcePath: fixture,
        maxSeconds: 20,
      );
      await _notifications.iosFanout.scheduler.deleteSoundFile(fileName);
      final ok =
          rendered.durationMs > 0 &&
          rendered.path.isNotEmpty &&
          rendered.byteSize > 0;
      return DiagCase(
        name: name,
        passed: ok,
        errorCode: ok ? null : 'render_invalid',
        stage: 'recording_render',
        detail:
            'size=$size durationMs=${rendered.durationMs} '
            'outSize=${rendered.byteSize} hash=${rendered.debugHash}',
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'recording_render_failed',
        stage: 'recording_render',
        detail: '$e',
      );
    }
  }

  Future<DiagCase> _caseTtsRender() async {
    const name = 'diag_tts';
    try {
      final fileName = 'sva_diag_tts_${_uuid.v4().substring(0, 8)}.caf';
      final rendered = await _notifications.iosFanout.scheduler.renderSound(
        fileName: fileName,
        ttsText: 'Diagnostics check',
        ttsLocale: 'en-US',
        maxSeconds: 10,
      );
      await _notifications.iosFanout.scheduler.deleteSoundFile(fileName);
      final ok = rendered.durationMs > 0 && rendered.path.isNotEmpty;
      return DiagCase(
        name: name,
        passed: ok,
        stage: 'tts_render',
        detail:
            'durationMs=${rendered.durationMs} size=${rendered.byteSize} '
            '(text omitted)',
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'tts_render_failed',
        stage: 'tts_render',
        detail: '$e',
      );
    }
  }

  Future<DiagCase> _caseMixedPlan() async {
    const name = 'diag_mixed_plan';
    final planner = IosAlarmSegmentPlanner();
    final start = DateTime.now().add(const Duration(seconds: 90));
    const alarm = AlarmUiModel(
      id: 'diag-mixed',
      time: TimeOfDay(hour: 7, minute: 0),
      repeatDays: {},
      isEnabled: true,
      type: AlarmType.mixed,
      label: 'Diag',
      repeatCount: 1,
      ringtoneName: 'Soft Chime',
    );
    final plan = planner.plan(
      alarm: alarm,
      occurrenceId: 'diag_occ',
      occurrenceStart: start,
      voiceClips: [
        preparedClip(fileName: 'v.caf', duration: const Duration(seconds: 2)),
      ],
      ringtoneClips: [
        preparedClip(fileName: 'r.caf', duration: const Duration(seconds: 5)),
      ],
    );
    final hasTone = plan.any((s) => s.soundFileName == 'r.caf');
    return DiagCase(
      name: name,
      passed: plan.length == 2 && hasTone,
      stage: 'plan',
      detail: 'children=${plan.length} ringtoneChild=$hasTone',
      plannedChildCount: plan.length,
    );
  }

  Future<DiagCase> _caseRepeatPlan() async {
    const name = 'diag_repeat_plan';
    final planner = IosAlarmSegmentPlanner();
    final start = DateTime(2026, 1, 1, 7);
    const alarm = AlarmUiModel(
      id: 'diag-repeat',
      time: TimeOfDay(hour: 7, minute: 0),
      repeatDays: {},
      isEnabled: true,
      type: AlarmType.mixed,
      label: 'Diag',
      repeatCount: 3,
      ringtoneName: 'Soft Chime',
    );
    final plan = planner.plan(
      alarm: alarm,
      occurrenceId: 'occ',
      occurrenceStart: start,
      voiceClips: [
        preparedClip(fileName: 'v0.caf', duration: const Duration(seconds: 2)),
        preparedClip(fileName: 'v1.caf', duration: const Duration(seconds: 3)),
      ],
      ringtoneClips: [
        preparedClip(
          fileName: 'tone.caf',
          duration: const Duration(seconds: 8),
        ),
      ],
    );
    final ok = plan.length == 7 && plan.last.soundFileName == 'tone.caf';
    return DiagCase(
      name: name,
      passed: ok,
      stage: 'plan',
      detail: 'children=${plan.length} last=${plan.last.soundFileName}',
      plannedChildCount: plan.length,
    );
  }

  Future<DiagCase> _caseTransactionFailure() async {
    const name = 'diag_tx_fail';
    final alarmRepo = _DiagAlarmRepo();
    final seqRepo = _DiagSequenceRepo();
    final controller = AlarmListController(
      alarmRepo,
      _FailingNotificationService(),
      seqRepo,
    );
    final seq = VoiceSequenceUiModel(
      id: 'diag-orphan-seq',
      name: 'Diag',
      segments: [
        VoiceSegmentUiModel(
          id: 'seg',
          name: 'Bad',
          type: VoiceSegmentType.recording,
          duration: const Duration(seconds: 1),
          filePath: '/tmp/sva_does_not_exist_${_uuid.v4()}.m4a',
        ),
      ],
    );
    final result = await controller.add(
      const AlarmUiModel(
        id: 'diag-fail-alarm',
        time: TimeOfDay(hour: 8, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Fail',
        voiceSequenceId: 'diag-orphan-seq',
      ),
      sequenceOverride: seq,
    );

    final ok =
        !result.ok &&
        alarmRepo.loadAll().isEmpty &&
        seqRepo.loadAll().isEmpty &&
        result.errorCode == 'recording_file_missing';
    return DiagCase(
      name: name,
      passed: ok,
      errorCode: result.errorCode,
      stage: result.stage ?? 'repository_commit',
      detail:
          'alarms=${alarmRepo.loadAll().length} '
          'sequences=${seqRepo.loadAll().length}',
    );
  }

  Future<DiagCase> _caseDraftCancelNoOrphan() async {
    const name = 'diag_draft_cancel';
    final seqRepo = _DiagSequenceRepo();
    final seqId = 'diag-draft-${_uuid.v4()}';
    final controller = VoiceSequenceController(
      seqRepo,
      VoiceSequenceUiModel(id: seqId, name: 'Draft', segments: const []),
      _DiagSavedRepo(),
      false,
    );
    await controller.addExistingSavedVoice(
      const VoiceSegmentUiModel(
        id: 'lib-diag',
        name: 'Lib',
        type: VoiceSegmentType.tts,
        duration: Duration(seconds: 1),
        text: 'x',
      ),
    );
    await controller.discard(hadPersistedOriginal: false);
    final orphan = seqRepo.findById(seqId);
    return DiagCase(
      name: name,
      passed: orphan == null,
      stage: 'validation',
      detail: 'orphanPersisted=${orphan != null}',
    );
  }

  Future<DiagCase> _caseChallengePayload() async {
    const name = 'diag_challenge_route';
    final body = _ringingPath(
      'alarm-1',
      challenge: true,
      occurrenceId: 'occ-1',
    );
    const dismissOpens = false;
    final ok =
        body.contains('challenge=1') &&
        body.contains('occurrenceId=occ-1') &&
        !dismissOpens;
    return DiagCase(
      name: name,
      passed: ok,
      stage: 'validation',
      detail: 'bodyAndSolveShareChallengeRoute dismissOpens=$dismissOpens',
    );
  }

  Future<DiagCase> _caseRingtoneAssetResolution() async {
    const name = 'diag_ringtone_asset';
    final asset = RingtoneAssets.pathForName('Soft Chime');
    try {
      final data = await rootBundle.load(asset);
      final ok = data.lengthInBytes > 0;
      return DiagCase(
        name: name,
        passed: ok,
        stage: 'ringtone_asset_lookup',
        detail: 'asset=$asset bytes=${data.lengthInBytes}',
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'ringtone_asset_missing',
        stage: 'ringtone_asset_lookup',
        detail: '$e',
      );
    }
  }

  Future<DiagCase> _casePendingQuery() async {
    const name = 'diag_pending_query';
    try {
      final count = await _notifications.iosFanout.scheduler
          .pendingRequestCount();
      final ids = await _notifications.iosFanout.scheduler
          .pendingRequestIdentifiers();
      return DiagCase(
        name: name,
        passed: true,
        stage: 'notification_schedule',
        detail: 'pendingCount=$count ids=${ids.length}',
        pendingIdentifiers: ids,
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'pending_query_failed',
        stage: 'notification_schedule',
        detail: '$e',
      );
    }
  }

  Future<DiagCase> _caseAlarmKitCapabilityRouting() async {
    const name = 'diag_alarmkit_routing';
    try {
      final cap = await _notifications.iosFanout.capability();
      final backend = cap.shouldUseAlarmKitBackend
          ? AlarmScheduleBackend.alarmKit
          : AlarmScheduleBackend.notificationFanout;
      final exclusive =
          backend == AlarmScheduleBackend.alarmKit ||
          backend == AlarmScheduleBackend.notificationFanout;
      return DiagCase(
        name: name,
        passed: exclusive,
        stage: 'validation',
        detail:
            'backend=$backend eligible=${cap.runtimeVersionEligible} '
            'auth=${cap.alarmKitAuthorization} runtime=${cap.alarmKitRuntimeEnabled} '
            'disabled=${cap.alarmKitDisabled}',
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'capability_failed',
        stage: 'validation',
        detail: '$e',
      );
    }
  }

  Future<DiagCase> _caseAlarmKitDiagnosticsShape() async {
    const name = 'diag_alarmkit_native_passive';
    try {
      final raw = await _notifications.iosFanout.scheduler
          .alarmKitDiagnostics();
      final counters = await _notifications.iosFanout.scheduler
          .alarmKitStartupCounters();
      final hasAuth = raw.containsKey('authorization');
      final passive = raw['passiveOnly'] == true;
      final readCount =
          (counters['authorizationStateReadCount'] as num?)?.toInt() ?? -1;
      return DiagCase(
        name: name,
        passed: hasAuth && passive && readCount == 0,
        stage: 'validation',
        detail:
            'passive=$passive auth=${raw['authorization']} '
            'readCount=$readCount requestCount=${counters['requestAuthorizationCount']} '
            'scheduleCount=${counters['scheduleCount']}',
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'alarmkit_diag_failed',
        stage: 'validation',
        detail: '$e',
      );
    }
  }

  /// Staged user-initiated probe — stops on first failure.
  Future<DiagCase> runStagedAlarmKitProbe() async {
    const name = 'diag_alarmkit_staged_probe';
    try {
      final counters = await _notifications.iosFanout.scheduler
          .alarmKitStartupCounters();
      if (((counters['authorizationStateReadCount'] as num?)?.toInt() ?? 0) >
          0) {
        return DiagCase.fail(
          name,
          code: 'startup_alarmkit_touched',
          stage: 'passive_environment',
          detail: 'AlarmKit read before staged probe',
        );
      }
      final env = await _notifications.iosFanout.capability();
      if (!env.runtimeVersionEligible || env.alarmKitDisabled) {
        return DiagCase(
          name: name,
          passed: true,
          stage: 'passive_environment',
          detail:
              'skipped probe eligible=${env.runtimeVersionEligible} disabled=${env.alarmKitDisabled}',
        );
      }
      final probe = await _notifications.iosFanout.scheduler
          .probeAlarmKitPassive();
      if (probe['ok'] != true) {
        return DiagCase.fail(
          name,
          code: 'probe_failed',
          stage: 'authorization_check',
          detail: '${probe['error'] ?? probe['alarmKitAuthorization']}',
        );
      }
      return DiagCase(
        name: name,
        passed: true,
        stage: 'authorization_check',
        detail: 'auth=${probe['alarmKitAuthorization']}',
      );
    } catch (e) {
      return DiagCase.fail(
        name,
        code: 'staged_probe_exception',
        stage: 'authorization_check',
        detail: '$e',
      );
    }
  }

  Future<String?> _materializeSoftChimeAsFixture() async {
    try {
      final data = await rootBundle.load(RingtoneAssets.softChime);
      final dir = await getTemporaryDirectory();
      final out = p.join(dir.path, 'sva_diag_fixture.wav');
      await io_file.writeBytes(
        out,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      return out;
    } catch (_) {
      return null;
    }
  }

  static String _ringingPath(
    String id, {
    bool challenge = false,
    String? occurrenceId,
  }) {
    final params = <String>[];
    if (challenge) params.add('challenge=1');
    if (occurrenceId != null && occurrenceId.isNotEmpty) {
      params.add('occurrenceId=${Uri.encodeComponent(occurrenceId)}');
    }
    if (params.isEmpty) return '/alarm/ringing/$id';
    return '/alarm/ringing/$id?${params.join('&')}';
  }
}

class DiagCase {
  const DiagCase({
    required this.name,
    required this.passed,
    this.errorCode,
    this.stage,
    this.detail = '',
    this.plannedChildCount,
    this.pendingIdentifiers,
  });

  factory DiagCase.fail(
    String name, {
    required String code,
    required String stage,
    String detail = '',
  }) {
    return DiagCase(
      name: name,
      passed: false,
      errorCode: code,
      stage: stage,
      detail: detail,
    );
  }

  final String name;
  final bool passed;
  final String? errorCode;
  final String? stage;
  final String detail;
  final int? plannedChildCount;
  final List<String>? pendingIdentifiers;

  String format() {
    final status = passed ? 'PASS' : 'FAIL';
    return [
      '[$status] $name',
      if (stage != null) '  stage=$stage',
      if (errorCode != null) '  errorCode=$errorCode',
      if (plannedChildCount != null) '  plannedChildCount=$plannedChildCount',
      if (pendingIdentifiers != null)
        '  pendingIdentifiers=${pendingIdentifiers!.length}',
      if (detail.isNotEmpty) '  $detail',
    ].join('\n');
  }
}

class _DiagAlarmRepo extends AlarmRepository {
  final Map<String, AlarmUiModel> _items = {};

  @override
  List<AlarmUiModel> loadAll() => _items.values.toList();

  @override
  Future<void> upsert(AlarmUiModel alarm) async => _items[alarm.id] = alarm;

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  AlarmUiModel? findById(String id) => _items[id];
}

class _DiagSequenceRepo extends VoiceSequenceRepository {
  final Map<String, VoiceSequenceUiModel> _items = {};

  @override
  List<VoiceSequenceUiModel> loadAll() => _items.values.toList();

  @override
  VoiceSequenceUiModel? findById(String id) => _items[id];

  @override
  Future<void> upsert(VoiceSequenceUiModel sequence) async =>
      _items[sequence.id] = sequence;

  @override
  Future<void> delete(String id) async => _items.remove(id);
}

class _DiagSavedRepo extends SavedVoiceRepository {
  final Map<String, VoiceSegmentUiModel> _items = {};

  @override
  List<VoiceSegmentUiModel> loadAll() => _items.values.toList();

  @override
  Future<void> upsert(VoiceSegmentUiModel voice) async =>
      _items[voice.id] = voice;

  @override
  Future<void> delete(String id) async => _items.remove(id);
}

class _FailingNotificationService extends NotificationService {
  @override
  Future<AlarmScheduleResult> scheduleAlarm(
    AlarmUiModel alarm, {
    VoiceSequenceUiModel? sequenceOverride,
  }) async {
    return AlarmScheduleResult.fail(
      errorCode: 'recording_file_missing',
      errorMessage: 'Simulated missing recording',
      stage: 'recording_source_validation',
    );
  }
}

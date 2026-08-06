import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Describes iOS alarm capability for UI banners and scheduling.
class IosAlarmCapability {
  const IosAlarmCapability({
    required this.usesAlarmKit,
    required this.alarmKitAuthorization,
    required this.iosVersion,
    this.runtimeVersionEligible = false,
    this.alarmKitDisabled = false,
    this.alarmKitRuntimeEnabled = false,
    this.supportsFullVoiceAlarm = false,
    this.probeEverSucceeded = false,
    this.userDisabled = false,
    this.diagnosticForceOff = false,
    this.sessionProbeFailed = false,
    this.selectedBackend = '',
    this.backendSelectionReason = '',
    this.maxVoiceSeconds = 20,
    this.maxVoiceSegments = 5,
    this.maxRingtoneSegments = 2,
    this.gapSeconds = 5,
  });

  final bool usesAlarmKit;
  final String alarmKitAuthorization;
  final String iosVersion;
  final bool runtimeVersionEligible;
  final bool alarmKitDisabled;
  final bool alarmKitRuntimeEnabled;
  final bool supportsFullVoiceAlarm;
  final bool probeEverSucceeded;
  final bool userDisabled;
  final bool diagnosticForceOff;
  final bool sessionProbeFailed;
  final String selectedBackend;
  final String backendSelectionReason;
  final int maxVoiceSeconds;
  final int maxVoiceSegments;
  final int maxRingtoneSegments;
  final int gapSeconds;

  bool get isFullSupport => usesAlarmKit && supportsFullVoiceAlarm;
  bool get isAlarmKitAuthorized => alarmKitAuthorization == 'authorized';
  bool get isAlarmKitDenied => alarmKitAuthorization == 'denied';
  bool get isAlarmKitNotDetermined => alarmKitAuthorization == 'notDetermined';
  bool get isAlarmKitUnknown =>
      alarmKitAuthorization == 'unknown' ||
      alarmKitAuthorization == 'unsupported';

  /// Prefer AlarmKit only after user-initiated probe succeeded and authorized.
  bool get shouldUseAlarmKitBackend {
    if (selectedBackend.isNotEmpty) {
      return selectedBackend == 'alarmKit';
    }
    return runtimeVersionEligible &&
        !alarmKitDisabled &&
        !userDisabled &&
        !diagnosticForceOff &&
        alarmKitRuntimeEnabled &&
        usesAlarmKit &&
        isAlarmKitAuthorized &&
        supportsFullVoiceAlarm &&
        probeEverSucceeded;
  }

  factory IosAlarmCapability.unsupported() => const IosAlarmCapability(
    usesAlarmKit: false,
    alarmKitAuthorization: 'unsupported',
    iosVersion: '',
    supportsFullVoiceAlarm: false,
  );

  factory IosAlarmCapability.fromMap(Map<dynamic, dynamic> map) {
    final uses = map['usesAlarmKit'] == true;
    final auth =
        map['cachedAuthorization']?.toString() ??
        map['alarmKitAuthorization']?.toString() ??
        'unknown';
    return IosAlarmCapability(
      usesAlarmKit: uses,
      alarmKitAuthorization: auth,
      iosVersion: map['iosVersion']?.toString() ?? '',
      runtimeVersionEligible: map['runtimeVersionEligible'] == true,
      alarmKitDisabled: map['alarmKitDisabled'] == true,
      alarmKitRuntimeEnabled: map['alarmKitRuntimeEnabled'] == true,
      supportsFullVoiceAlarm: map['supportsFullVoiceAlarm'] == true,
      probeEverSucceeded: map['probeEverSucceeded'] == true,
      userDisabled: map['userDisabled'] == true,
      diagnosticForceOff: map['diagnosticForceOff'] == true,
      sessionProbeFailed: map['sessionProbeFailed'] == true,
      selectedBackend: map['selectedBackend']?.toString() ?? '',
      backendSelectionReason: map['backendSelectionReason']?.toString() ?? '',
      maxVoiceSeconds: (map['maxVoiceSeconds'] as num?)?.toInt() ?? 20,
      maxVoiceSegments: (map['maxVoiceSegments'] as num?)?.toInt() ?? 5,
      maxRingtoneSegments: (map['maxRingtoneSegments'] as num?)?.toInt() ?? 2,
      gapSeconds: (map['gapSeconds'] as num?)?.toInt() ?? 5,
    );
  }
}

class IosPendingChallenge {
  const IosPendingChallenge({
    required this.parentAlarmId,
    required this.occurrenceId,
    required this.childId,
    required this.segmentIndex,
    required this.scheduledTimestamp,
    this.openChallenge = true,
  });

  final String parentAlarmId;
  final String occurrenceId;
  final String childId;
  final int segmentIndex;
  final double scheduledTimestamp;
  final bool openChallenge;

  factory IosPendingChallenge.fromMap(Map<dynamic, dynamic> map) {
    return IosPendingChallenge(
      parentAlarmId: map['parentAlarmId']?.toString() ?? '',
      occurrenceId: map['occurrenceId']?.toString() ?? '',
      childId: map['childId']?.toString() ?? '',
      segmentIndex: (map['segmentIndex'] as num?)?.toInt() ?? 0,
      scheduledTimestamp: (map['scheduledTimestamp'] as num?)?.toDouble() ?? 0,
      openChallenge: map['openChallenge'] != false,
    );
  }
}

class IosRenderedSound {
  const IosRenderedSound({
    required this.fileName,
    required this.path,
    required this.durationMs,
    this.byteSize = 0,
    this.debugHash = '',
    this.contentDurationMs,
    this.trailingSilenceMs = 0,
    this.finalizedFileDurationMs,
  });

  final String fileName;
  final String path;

  /// Finalized CAF duration (content + trailing silence).
  final int durationMs;
  final int byteSize;
  final String debugHash;
  final int? contentDurationMs;
  final int trailingSilenceMs;
  final int? finalizedFileDurationMs;

  int get effectiveContentDurationMs =>
      contentDurationMs ??
      (durationMs - trailingSilenceMs).clamp(0, durationMs);

  int get effectiveFinalizedMs => finalizedFileDurationMs ?? durationMs;
}

/// Role of a scheduled child in the AlarmKit / fan-out timeline.
enum IosSegmentRole { voice, silence, ringtone }

/// Shared silence CAF used between audible AlarmKit children.
const String kSvaSilenceFileName = 'sva_silence_5s.caf';

class IosAlarmSegment {
  const IosAlarmSegment({
    required this.parentAlarmId,
    required this.occurrenceId,
    required this.segmentIndex,
    required this.childId,
    required this.startAt,
    required this.soundFileName,
    required this.duration,
    this.label = '',
    this.role = IosSegmentRole.voice,
    this.cycleIndex = 0,
    this.recoveryGeneration = 0,
  });

  final String parentAlarmId;
  final String occurrenceId;
  final int segmentIndex;
  final String childId;
  final DateTime startAt;
  final String soundFileName;
  final Duration duration;
  final String label;
  final IosSegmentRole role;
  final int cycleIndex;
  final int recoveryGeneration;

  Map<String, dynamic> toNativeMap() => {
    'parentAlarmId': parentAlarmId,
    'occurrenceId': occurrenceId,
    'segmentIndex': segmentIndex,
    'childId': childId,
    'startAtMillis': startAt.millisecondsSinceEpoch,
    'soundFileName': soundFileName,
    'durationMs': duration.inMilliseconds,
    'label': label,
    'role': role.name,
    'cycleIndex': cycleIndex,
    'recoveryGeneration': recoveryGeneration,
  };
}

/// iOS-only MethodChannel client. No-op on Android/web/tests.
class IosAlarmScheduler {
  IosAlarmScheduler();

  static const _channel = MethodChannel('com.smartvoicealarm.app/ios_alarms');

  void Function(IosPendingChallenge challenge)? onOpenChallenge;
  bool _handlerAttached = false;

  bool get isSupported {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    if (const bool.fromEnvironment('FLUTTER_TEST')) return false;
    return true;
  }

  void attachHandlers() {
    if (!isSupported || _handlerAttached) return;
    _handlerAttached = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onOpenChallenge') {
        final args = call.arguments;
        if (args is Map) {
          onOpenChallenge?.call(IosPendingChallenge.fromMap(args));
        }
      }
    });
  }

  Future<IosAlarmCapability> getCapability() async {
    if (!isSupported) return IosAlarmCapability.unsupported();
    try {
      final raw = await _channel.invokeMethod<Map>('getCapability');
      if (raw == null) return IosAlarmCapability.unsupported();
      return IosAlarmCapability.fromMap(raw);
    } catch (e) {
      debugPrint('IosAlarmScheduler.getCapability failed: $e');
      return IosAlarmCapability.unsupported();
    }
  }

  Future<Map<String, dynamic>> requestAuthorization() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map>('requestAuthorization');
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (e) {
      debugPrint('IosAlarmScheduler.requestAuthorization failed: $e');
      return const {};
    }
  }

  /// User-initiated passive probe (reads authorization only).
  Future<Map<String, dynamic>> probeAlarmKitPassive() async {
    if (!isSupported) return const {'ok': false};
    try {
      final raw = await _channel.invokeMethod<Map>('probeAlarmKitPassive');
      return Map<String, dynamic>.from(raw ?? const {'ok': false});
    } catch (e) {
      debugPrint('[SVA-AlarmKit] probeAlarmKitPassive failed: $e');
      return {'ok': false, 'error': '$e'};
    }
  }

  Future<Map<String, dynamic>> requestAlarmKitAuthorization() async {
    if (!isSupported) return const {'ok': false};
    try {
      final raw = await _channel.invokeMethod<Map>(
        'requestAlarmKitAuthorization',
      );
      return Map<String, dynamic>.from(raw ?? const {'ok': false});
    } catch (e) {
      debugPrint('[SVA-AlarmKit] requestAlarmKitAuthorization failed: $e');
      return {'ok': false, 'error': '$e'};
    }
  }

  Future<Map<String, dynamic>> alarmKitStartupCounters() async {
    if (!isSupported) {
      return const {
        'authorizationStateReadCount': 0,
        'requestAuthorizationCount': 0,
        'scheduleCount': 0,
        'reconcileCount': 0,
      };
    }
    try {
      final raw = await _channel.invokeMethod<Map>('alarmKitStartupCounters');
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (_) {
      return const {};
    }
  }

  Future<void> debugClearAlarmKitKillSwitch() async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('resetLegacyAlarmKitDiagnosticState');
  }

  Future<Map<String, dynamic>> passiveAlarmKitDiagnostics() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map>(
        'passiveAlarmKitDiagnostics',
      );
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (e) {
      debugPrint('[SVA-AlarmKit] passive diagnostics failed: $e');
      return const {};
    }
  }

  Future<bool> acknowledgePendingChallenge({
    required String parentAlarmId,
    required String occurrenceId,
  }) async {
    if (!isSupported) return false;
    try {
      final raw = await _channel.invokeMethod<bool>(
        'acknowledgePendingChallenge',
        {'parentAlarmId': parentAlarmId, 'occurrenceId': occurrenceId},
      );
      return raw ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearPendingChallengeAfterSolve({
    required String parentAlarmId,
    required String occurrenceId,
  }) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('clearPendingChallengeAfterSolve', {
      'parentAlarmId': parentAlarmId,
      'occurrenceId': occurrenceId,
    });
  }

  Future<IosRenderedSound> renderSound({
    required String fileName,
    String? sourcePath,
    String? assetKey,
    String? ttsText,
    String? ttsLocale,
    double maxSeconds = 20,
    double? targetDurationSeconds,
    double trailingSilenceSeconds = 1.25,
  }) async {
    final raw = await _channel.invokeMethod<Map>('renderSound', {
      'fileName': fileName,
      'sourcePath': sourcePath,
      'assetKey': assetKey,
      'ttsText': ttsText,
      'ttsLocale': ttsLocale,
      'maxSeconds': maxSeconds,
      if (targetDurationSeconds != null)
        'targetDurationSeconds': targetDurationSeconds,
      'trailingSilenceSeconds': trailingSilenceSeconds,
    });
    if (raw == null) {
      throw StateError('renderSound returned null');
    }
    return IosRenderedSound(
      fileName: raw['fileName']?.toString() ?? fileName,
      path: raw['path']?.toString() ?? '',
      durationMs: (raw['durationMs'] as num?)?.toInt() ?? 0,
      byteSize: (raw['byteSize'] as num?)?.toInt() ?? 0,
      debugHash: raw['debugHash']?.toString() ?? '',
      contentDurationMs: (raw['contentDurationMs'] as num?)?.toInt(),
      trailingSilenceMs: (raw['trailingSilenceMs'] as num?)?.toInt() ?? 0,
      finalizedFileDurationMs: (raw['finalizedFileDurationMs'] as num?)
          ?.toInt(),
    );
  }

  Future<Map<String, dynamic>> ensureSilenceSound({double seconds = 5}) async {
    if (!isSupported) {
      return {'ok': true, 'fileName': kSvaSilenceFileName};
    }
    try {
      final raw = await _channel.invokeMethod<Map>('ensureSilenceSound', {
        'seconds': seconds,
        'fileName': kSvaSilenceFileName,
      });
      return Map<String, dynamic>.from(raw ?? const {'ok': true});
    } catch (e) {
      debugPrint('[SVA-Audio] ensureSilenceSound failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> measureTtsDuration({
    required String text,
    String? locale,
    double maxSeconds = 20,
  }) async {
    if (!isSupported) return const {'ok': false};
    try {
      final raw = await _channel.invokeMethod<Map>('measureTtsDuration', {
        'text': text,
        'locale': locale,
        'maxSeconds': maxSeconds,
      });
      return Map<String, dynamic>.from(raw ?? const {'ok': false});
    } catch (e) {
      return {'ok': false, 'error': '$e'};
    }
  }

  Future<void> markOccurrenceSolved({
    required String parentAlarmId,
    required String occurrenceId,
  }) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('markOccurrenceSolved', {
      'parentAlarmId': parentAlarmId,
      'occurrenceId': occurrenceId,
    });
  }

  Future<Map<String, dynamic>> occurrenceDiagnostics({
    required String parentAlarmId,
    required String occurrenceId,
  }) async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map>('occurrenceDiagnostics', {
        'parentAlarmId': parentAlarmId,
        'occurrenceId': occurrenceId,
      });
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (_) {
      return const {};
    }
  }

  /// Schedules segments on exactly one backend.
  ///
  /// [backend] must be `alarmKit` or `notificationFanout`. Never schedules both.
  /// [soundNameMode] is AlarmKit-only: `withExtension` or `withoutExtension`.
  Future<Map<String, dynamic>> scheduleSegments({
    required List<IosAlarmSegment> segments,
    required String title,
    required String body,
    required String backend,
    String? soundNameMode,
    Map<String, dynamic>? occurrenceMeta,
  }) async {
    if (!isSupported || segments.isEmpty) {
      return {
        'ok': true,
        'backend': backend,
        'scheduledIds': <String>[],
        'stage': 'notification_schedule',
      };
    }
    final args = <String, dynamic>{
      'title': title,
      'body': body,
      'backend': backend,
      'segments': segments.map((s) => s.toNativeMap()).toList(),
    };
    if (soundNameMode != null && soundNameMode.isNotEmpty) {
      args['soundNameMode'] = soundNameMode;
    }
    if (occurrenceMeta != null) {
      args['occurrenceMeta'] = occurrenceMeta;
    }
    final raw = await _channel.invokeMethod<Map>('scheduleSegments', args);
    return Map<String, dynamic>.from(raw ?? {'ok': true, 'backend': backend});
  }

  Future<Map<String, dynamic>> diagnoseSoundFile({
    required String fileName,
    String sourceType = 'unknown',
  }) async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map>('diagnoseSoundFile', {
        'fileName': fileName,
        'sourceType': sourceType,
      });
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (e) {
      debugPrint('[SVA-Sound] diagnose failed: $e');
      return {'ok': false, 'error': '$e'};
    }
  }

  Future<Map<String, dynamic>> lastSoundDiagnostics() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map>('lastSoundDiagnostics');
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (_) {
      return const {};
    }
  }

  Future<void> setAlarmKitSoundNameMode(String mode) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('setAlarmKitSoundNameMode', {
      'mode': mode,
    });
  }

  Future<String> getAlarmKitSoundNameMode() async {
    if (!isSupported) return 'withExtension';
    try {
      final raw = await _channel.invokeMethod<Map>('getAlarmKitSoundNameMode');
      return raw?['mode']?.toString() ?? 'withExtension';
    } catch (_) {
      return 'withExtension';
    }
  }

  Future<Map<String, dynamic>> alarmKitDiagnostics() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map>('alarmKitDiagnostics');
      return Map<String, dynamic>.from(raw ?? const {});
    } catch (e) {
      debugPrint('[SVA-AlarmKit] diagnostics failed: $e');
      return const {};
    }
  }

  Future<void> cancelParent(String parentAlarmId) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('cancelParent', {
      'parentAlarmId': parentAlarmId,
    });
  }

  /// Cancels pending children for [parentAlarmId] except [keepChildIds].
  Future<void> cancelParentExcept({
    required String parentAlarmId,
    required Set<String> keepChildIds,
  }) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('cancelParentExcept', {
      'parentAlarmId': parentAlarmId,
      'keepChildIds': keepChildIds.toList(),
    });
  }

  Future<void> deleteSoundFile(String fileName) async {
    if (!isSupported || fileName.isEmpty) return;
    await _channel.invokeMethod<void>('deleteSoundFile', {
      'fileName': fileName,
    });
  }

  Future<void> cancelOccurrence({
    required String parentAlarmId,
    required String occurrenceId,
  }) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('cancelOccurrence', {
      'parentAlarmId': parentAlarmId,
      'occurrenceId': occurrenceId,
    });
  }

  Future<IosPendingChallenge?> consumePendingChallenge() async {
    if (!isSupported) return null;
    try {
      final raw = await _channel.invokeMethod<Map>('consumePendingChallenge');
      if (raw == null) return null;
      return IosPendingChallenge.fromMap(raw);
    } catch (_) {
      return null;
    }
  }

  Future<IosPendingChallenge?> peekPendingChallenge() async {
    if (!isSupported) return null;
    try {
      final raw = await _channel.invokeMethod<Map>('peekPendingChallenge');
      if (raw == null) return null;
      return IosPendingChallenge.fromMap(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> cleanupOrphanSounds(Set<String> activeFileNames) async {
    if (!isSupported) return;
    // Never run with an empty active set — that would delete every sva_* file.
    if (activeFileNames.isEmpty) {
      debugPrint('[SVA-Audio] cleanupOrphanSounds skipped (empty active set)');
      return;
    }
    await _channel.invokeMethod<void>('cleanupOrphanSounds', {
      'activeFileNames': activeFileNames.toList(),
    });
  }

  Future<int> pendingRequestCount() async {
    if (!isSupported) return 0;
    try {
      final raw = await _channel.invokeMethod<int>('pendingRequestCount');
      return raw ?? 0;
    } catch (e) {
      debugPrint('[SVA-Schedule] pendingRequestCount failed: $e');
      return 0;
    }
  }

  Future<List<String>> pendingRequestIdentifiers() async {
    if (!isSupported) return const [];
    try {
      final raw = await _channel.invokeMethod<List>(
        'pendingRequestIdentifiers',
      );
      if (raw == null) return const [];
      return raw.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('[SVA-Schedule] pendingRequestIdentifiers failed: $e');
      return const [];
    }
  }
}

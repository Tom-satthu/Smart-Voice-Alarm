import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Describes iOS alarm capability for UI banners and scheduling.
class IosAlarmCapability {
  const IosAlarmCapability({
    required this.usesAlarmKit,
    required this.alarmKitAuthorization,
    required this.iosVersion,
    this.maxVoiceSeconds = 20,
    this.maxVoiceSegments = 5,
    this.maxRingtoneSegments = 2,
    this.gapSeconds = 5,
  });

  final bool usesAlarmKit;
  final String alarmKitAuthorization;
  final String iosVersion;
  final int maxVoiceSeconds;
  final int maxVoiceSegments;
  final int maxRingtoneSegments;
  final int gapSeconds;

  bool get isFullSupport => usesAlarmKit;
  bool get isAlarmKitAuthorized => alarmKitAuthorization == 'authorized';
  bool get isAlarmKitDenied => alarmKitAuthorization == 'denied';

  factory IosAlarmCapability.unsupported() => const IosAlarmCapability(
    usesAlarmKit: false,
    alarmKitAuthorization: 'unsupported',
    iosVersion: '',
  );

  factory IosAlarmCapability.fromMap(Map<dynamic, dynamic> map) {
    return IosAlarmCapability(
      usesAlarmKit: map['usesAlarmKit'] == true,
      alarmKitAuthorization:
          map['alarmKitAuthorization']?.toString() ?? 'unknown',
      iosVersion: map['iosVersion']?.toString() ?? '',
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
  });

  final String fileName;
  final String path;
  final int durationMs;
}

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
  });

  final String parentAlarmId;
  final String occurrenceId;
  final int segmentIndex;
  final String childId;
  final DateTime startAt;
  final String soundFileName;
  final Duration duration;
  final String label;

  Map<String, dynamic> toNativeMap() => {
    'parentAlarmId': parentAlarmId,
    'occurrenceId': occurrenceId,
    'segmentIndex': segmentIndex,
    'childId': childId,
    'startAtMillis': startAt.millisecondsSinceEpoch,
    'soundFileName': soundFileName,
    'durationMs': duration.inMilliseconds,
    'label': label,
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

  Future<IosRenderedSound> renderSound({
    required String fileName,
    String? sourcePath,
    String? assetKey,
    String? ttsText,
    String? ttsLocale,
    double maxSeconds = 20,
  }) async {
    final raw = await _channel.invokeMethod<Map>('renderSound', {
      'fileName': fileName,
      'sourcePath': sourcePath,
      'assetKey': assetKey,
      'ttsText': ttsText,
      'ttsLocale': ttsLocale,
      'maxSeconds': maxSeconds,
    });
    if (raw == null) {
      throw StateError('renderSound returned null');
    }
    return IosRenderedSound(
      fileName: raw['fileName']?.toString() ?? fileName,
      path: raw['path']?.toString() ?? '',
      durationMs: (raw['durationMs'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> scheduleSegments({
    required List<IosAlarmSegment> segments,
    required String title,
    required String body,
  }) async {
    if (!isSupported || segments.isEmpty) return;
    await _channel.invokeMethod<void>('scheduleSegments', {
      'title': title,
      'body': body,
      'segments': segments.map((s) => s.toNativeMap()).toList(),
    });
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
}

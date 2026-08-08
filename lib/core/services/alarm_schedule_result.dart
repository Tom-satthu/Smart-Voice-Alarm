/// Structured outcome for alarm scheduling (iOS fan-out / AlarmKit and shared Save UI).
class AlarmScheduleResult {
  const AlarmScheduleResult({
    required this.ok,
    this.errorCode,
    this.errorMessage,
    this.stage,
    this.sourceType,
    this.sourceId,
    this.filePath,
    this.warningCode,
    this.warningMessage,
    this.needsAudioRepair = false,
    this.transactionId,
    this.backend,
    this.backendReason,
    this.scheduledIds = const [],
  });

  final bool ok;
  final String? errorCode;
  final String? errorMessage;
  final String? stage;
  final String? sourceType;
  final String? sourceId;
  final String? filePath;
  final String? warningCode;
  final String? warningMessage;
  final bool needsAudioRepair;
  final String? transactionId;

  /// `alarmKit` or `notificationFanout` when known.
  final String? backend;
  final String? backendReason;
  final List<String> scheduledIds;

  bool get hasWarning => warningCode != null && warningCode!.trim().isNotEmpty;

  static const AlarmScheduleResult success = AlarmScheduleResult(ok: true);

  factory AlarmScheduleResult.ok({
    String? warningCode,
    String? warningMessage,
    String? stage,
    String? transactionId,
    String? backend,
    String? backendReason,
    List<String> scheduledIds = const [],
  }) {
    return AlarmScheduleResult(
      ok: true,
      stage: stage ?? 'repository_commit',
      warningCode: warningCode,
      warningMessage: warningMessage,
      transactionId: transactionId,
      backend: backend,
      backendReason: backendReason,
      scheduledIds: scheduledIds,
    );
  }

  factory AlarmScheduleResult.fail({
    required String errorCode,
    required String errorMessage,
    required String stage,
    String? sourceType,
    String? sourceId,
    String? filePath,
    bool needsAudioRepair = false,
    String? transactionId,
    String? backend,
    String? backendReason,
  }) {
    return AlarmScheduleResult(
      ok: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
      stage: stage,
      sourceType: sourceType,
      sourceId: sourceId,
      filePath: filePath,
      needsAudioRepair: needsAudioRepair,
      transactionId: transactionId,
      backend: backend,
      backendReason: backendReason,
    );
  }

  AlarmScheduleResult copyWith({
    bool? ok,
    String? errorCode,
    String? errorMessage,
    String? stage,
    String? sourceType,
    String? sourceId,
    String? filePath,
    String? warningCode,
    String? warningMessage,
    bool? needsAudioRepair,
    String? transactionId,
    String? backend,
    String? backendReason,
    List<String>? scheduledIds,
  }) {
    return AlarmScheduleResult(
      ok: ok ?? this.ok,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      stage: stage ?? this.stage,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      filePath: filePath ?? this.filePath,
      warningCode: warningCode ?? this.warningCode,
      warningMessage: warningMessage ?? this.warningMessage,
      needsAudioRepair: needsAudioRepair ?? this.needsAudioRepair,
      transactionId: transactionId ?? this.transactionId,
      backend: backend ?? this.backend,
      backendReason: backendReason ?? this.backendReason,
      scheduledIds: scheduledIds ?? this.scheduledIds,
    );
  }

  @override
  String toString() =>
      'AlarmScheduleResult(ok=$ok backend=$backend reason=$backendReason '
      'code=$errorCode stage=$stage warn=$warningCode msg=$errorMessage)';
}

/// @nodoc Kept for call sites that still reference the iOS-specific name.
typedef IosScheduleResult = AlarmScheduleResult;

/// Backend identifiers written into [AlarmScheduleResult.backend].
abstract final class AlarmScheduleBackend {
  static const alarmKit = 'alarmKit';
  static const notificationFanout = 'notificationFanout';
}

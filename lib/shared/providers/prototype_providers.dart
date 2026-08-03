import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/localization/app_locale_support.dart';
import '../../core/services/alarm_engine.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/premium_entitlement_service.dart';
import '../../core/services/premium_purchase_service.dart';
import '../../core/services/recording_service.dart';
import '../../core/services/storage_paths.dart';
import '../../core/services/tts_platform_bridge.dart';
import '../../core/services/tts_service.dart';
import '../data/local_store.dart';
import '../models/ui_models.dart';

const _uuid = Uuid();

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});

final sequenceRepositoryProvider = Provider<VoiceSequenceRepository>((ref) {
  return VoiceSequenceRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final premiumEntitlementProvider = Provider<PremiumEntitlementService>((ref) {
  return PremiumEntitlementService(ref.watch(settingsRepositoryProvider));
});

final premiumPurchaseServiceProvider = Provider<PremiumPurchaseService>((ref) {
  final service = PremiumPurchaseService(
    entitlement: ref.watch(premiumEntitlementProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final premiumPurchaseProvider =
    StateNotifierProvider<PremiumPurchaseController, PremiumPurchaseState>((
  ref,
) {
  return PremiumPurchaseController(ref.watch(premiumPurchaseServiceProvider));
});

class PremiumPurchaseController extends StateNotifier<PremiumPurchaseState> {
  PremiumPurchaseController(this._service)
      : super(_service.state) {
    _sub = _service.stream.listen((next) {
      if (mounted) state = next;
    });
    state = _service.state;
  }

  final PremiumPurchaseService _service;
  StreamSubscription<PremiumPurchaseState>? _sub;

  Future<void> init() => _service.init();
  Future<void> buy() => _service.buy();
  Future<void> restore() => _service.restore();
  Future<void> refreshProducts() => _service.refreshProducts();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final isPremiumProvider = Provider<bool>((ref) {
  final purchase = ref.watch(premiumPurchaseProvider);
  final local = ref.watch(premiumEntitlementProvider).isPremium;
  return purchase.isPremium || local;
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

final recordingServiceProvider = Provider<RecordingService>((ref) {
  final service = RecordingService();
  ref.onDispose(service.dispose);
  return service;
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

final ttsPlatformBridgeProvider = Provider<TtsPlatformBridge>((ref) {
  return TtsPlatformBridge();
});

final alarmEngineProvider = Provider<AlarmEngine>((ref) {
  final notifications = ref.watch(notificationServiceProvider);
  final alarmRepo = ref.watch(alarmRepositoryProvider);
  final engine = AlarmEngine(
    audioPlayer: ref.watch(audioPlayerServiceProvider),
    tts: ref.watch(ttsServiceProvider),
    alarmRepository: alarmRepo,
    sequenceRepository: ref.watch(sequenceRepositoryProvider),
    onStopNative: () => notifications.native.stopForegroundAlarm(),
    onAlarmStarted: (alarm) async {
      // Native audio already stopped in AlarmEngine._playAlarm before this.
      if (alarm.repeatDays.isEmpty) {
        final disabled = alarm.copyWith(isEnabled: false);
        await alarmRepo.upsert(disabled);
        await notifications.scheduleAlarm(disabled);
        await ref.read(alarmListProvider.notifier).reload();
      } else {
        // Keep repeating alarms scheduled for the next matching day.
        await notifications.scheduleAlarm(alarm);
      }
    },
  );
  ref.onDispose(engine.dispose);
  return engine;
});

class AlarmListController extends StateNotifier<List<AlarmUiModel>> {
  AlarmListController([
    AlarmRepository? repo,
    NotificationService? notifications,
    VoiceSequenceRepository? sequences,
  ])  : _repo = repo ?? AlarmRepository(),
        _notifications = notifications ?? NotificationService(),
        _sequences = sequences ?? VoiceSequenceRepository(),
        super(const []) {
    state = _repo.loadAll();
  }

  final AlarmRepository _repo;
  final NotificationService _notifications;
  final VoiceSequenceRepository _sequences;

  Future<void> reload() async {
    state = _repo.loadAll();
  }

  Future<void> toggle(String id) async {
    state = [
      for (final alarm in state)
        if (alarm.id == id)
          alarm.copyWith(isEnabled: !alarm.isEnabled)
        else
          alarm,
    ];
    final updated = state.firstWhere((a) => a.id == id);
    await _repo.upsert(updated);
    await _notifications.scheduleAlarm(updated);
  }

  Future<void> remove(String id) async {
    state = state.where((alarm) => alarm.id != id).toList();
    await _repo.delete(id);
    await _notifications.cancelAlarm(id);
  }

  Future<void> add(AlarmUiModel alarm) async {
    state = [...state, alarm]..sort(_byTime);
    await _repo.upsert(alarm);
    await _notifications.scheduleAlarm(alarm);
  }

  Future<void> update(AlarmUiModel alarm) async {
    state = [
      for (final item in state)
        if (item.id == alarm.id) alarm else item,
    ]..sort(_byTime);
    await _repo.upsert(alarm);
    await _notifications.scheduleAlarm(alarm);
  }

  /// Returns the duplicated alarm id for navigation into edit.
  Future<String> duplicate(String id) async {
    final source = state.firstWhere((alarm) => alarm.id == id);
    final copy = source.copyWith(
      id: _uuid.v4(),
      label: '${source.label} copy',
      isEnabled: false,
      voiceSequenceId: source.voiceSequenceId == null
          ? null
          : await _duplicateSequence(source.voiceSequenceId!),
    );
    await add(copy);
    return copy.id;
  }

  Future<String?> _duplicateSequence(String sequenceId) async {
    final source = _sequences.findById(sequenceId);
    if (source == null) return null;
    final copy = source.copyWith(
      id: _uuid.v4(),
      name: '${source.name} copy',
      segments: [
        for (final segment in source.segments)
          segment.copyWith(id: _uuid.v4()),
      ],
    );
    await _sequences.upsert(copy);
    return copy.id;
  }

  Future<void> clearAll() async {
    state = [];
    await _repo.saveAll(const []);
  }

  AlarmUiModel? findById(String id) {
    for (final alarm in state) {
      if (alarm.id == id) return alarm;
    }
    return _repo.findById(id);
  }

  static int _byTime(AlarmUiModel a, AlarmUiModel b) {
    return (a.time.hour * 60 + a.time.minute)
        .compareTo(b.time.hour * 60 + b.time.minute);
  }
}

final alarmListProvider =
    StateNotifierProvider<AlarmListController, List<AlarmUiModel>>((ref) {
  return AlarmListController(
    ref.watch(alarmRepositoryProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(sequenceRepositoryProvider),
  );
});

class VoiceSequenceController extends StateNotifier<VoiceSequenceUiModel> {
  VoiceSequenceController([
    VoiceSequenceRepository? repo,
    VoiceSequenceUiModel? initial,
  ])  : _repo = repo ?? VoiceSequenceRepository(),
        super(
          initial ??
              const VoiceSequenceUiModel(
                id: 'seq-1',
                name: 'Morning motivation',
                segments: [],
              ),
        );

  final VoiceSequenceRepository _repo;

  Future<void> persist() => _repo.upsert(state);

  Future<void> reorder(int oldIndex, int newIndex) async {
    final segments = List<VoiceSegmentUiModel>.from(state.segments);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = segments.removeAt(oldIndex);
    segments.insert(newIndex, item);
    state = state.copyWith(segments: segments);
    await persist();
  }

  Future<void> removeAt(int index) async {
    final segments = List<VoiceSegmentUiModel>.from(state.segments)
      ..removeAt(index);
    state = state.copyWith(segments: segments);
    await persist();
  }

  Future<void> add(VoiceSegmentUiModel segment) async {
    state = state.copyWith(segments: [...state.segments, segment]);
    await persist();
  }

  Future<void> updateAt(int index, VoiceSegmentUiModel segment) async {
    final segments = List<VoiceSegmentUiModel>.from(state.segments);
    segments[index] = segment;
    state = state.copyWith(segments: segments);
    await persist();
  }

  Future<void> rename(String name) async {
    state = state.copyWith(name: name);
    await persist();
  }
}

final voiceSequenceProvider = StateNotifierProvider.family<
    VoiceSequenceController, VoiceSequenceUiModel, String>((ref, sequenceId) {
  final repo = ref.watch(sequenceRepositoryProvider);
  final existing = repo.findById(sequenceId);
  final initial = existing ??
      VoiceSequenceUiModel(
        id: sequenceId,
        name: 'Voice Sequence',
        segments: const [],
      );
  final controller = VoiceSequenceController(repo, initial);
  if (existing == null) {
    // Fire-and-forget create so nested screens can write segments.
    controller.persist();
  }
  return controller;
});

/// Fallback sequence id used when a route omits `?id=`.
const defaultSequenceId = 'seq-1';

final ttsVoicesProvider =
    FutureProvider.autoDispose<List<TtsVoiceUiModel>>((ref) async {
  return ref.watch(ttsServiceProvider).loadVoices();
});

final usableTtsVoicesProvider =
    FutureProvider.autoDispose<List<TtsVoiceUiModel>>((ref) async {
  return ref.watch(ttsServiceProvider).loadUsableVoices();
});

class PreferredVoiceController extends StateNotifier<
    ({String? id, String? locale, String? language})> {
  PreferredVoiceController([SettingsRepository? repo])
      : _repo = repo ?? SettingsRepository(),
        super((
          id: (repo ?? SettingsRepository()).loadPreferredVoiceId(),
          locale: (repo ?? SettingsRepository()).loadPreferredVoiceLocale(),
          language: (repo ?? SettingsRepository()).loadPreferredVoiceLanguage(),
        )) {
    state = (
      id: _repo.loadPreferredVoiceId(),
      locale: _repo.loadPreferredVoiceLocale(),
      language: _repo.loadPreferredVoiceLanguage(),
    );
  }

  final SettingsRepository _repo;

  Future<void> setVoice({
    required String id,
    required String locale,
    String? language,
  }) async {
    final lang = language ?? locale.split(RegExp('[-_]')).first.toLowerCase();
    state = (id: id, locale: locale, language: lang);
    await _repo.savePreferredVoice(voiceId: id, localeId: locale);
    await _repo.savePreferredVoiceLanguage(lang);
  }

  Future<void> setLanguage(String language) async {
    state = (id: state.id, locale: state.locale, language: language);
    await _repo.savePreferredVoiceLanguage(language);
  }
}

final preferredVoiceProvider = StateNotifierProvider<
    PreferredVoiceController, ({String? id, String? locale, String? language})>((
  ref,
) {
  return PreferredVoiceController(ref.watch(settingsRepositoryProvider));
});

final ringtonesProvider = Provider<List<RingtoneUiModel>>((ref) {
  return const [
    RingtoneUiModel(
      id: 'ring-1',
      name: 'Soft Chime',
      assetPath: RingtoneAssets.softChime,
    ),
    RingtoneUiModel(
      id: 'ring-2',
      name: 'Ocean Breeze',
      assetPath: RingtoneAssets.oceanBreeze,
    ),
    RingtoneUiModel(
      id: 'ring-3',
      name: 'Night Pulse',
      assetPath: RingtoneAssets.nightPulse,
    ),
    RingtoneUiModel(
      id: 'ring-4',
      name: 'Forest Dawn',
      assetPath: RingtoneAssets.forestDawn,
    ),
    RingtoneUiModel(
      id: 'ring-5',
      name: 'Crystal Bell',
      assetPath: RingtoneAssets.crystalBell,
    ),
  ];
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController([SettingsRepository? repo])
      : _repo = repo ?? SettingsRepository(),
        super(const Locale('en')) {
    state = _resolveInitial(_repo);
  }

  final SettingsRepository _repo;

  static Locale _resolveInitial(SettingsRepository repo) {
    if (repo.hasSavedLocale) {
      return AppLocaleSupport.resolve(null, repo.loadLocale());
    }
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    return AppLocaleSupport.resolve(device);
  }

  Future<void> setLocale(Locale locale) async {
    final resolved = AppLocaleSupport.resolve(null, locale);
    state = resolved;
    await _repo.saveLocale(resolved);
  }
}

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(settingsRepositoryProvider));
});

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.time,
  });

  final bool enabled;
  final TimeOfDay time;

  ReminderSettings copyWith({
    bool? enabled,
    TimeOfDay? time,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      time: time ?? this.time,
    );
  }
}

class ReminderSettingsController extends StateNotifier<ReminderSettings> {
  ReminderSettingsController([
    SettingsRepository? repo,
    NotificationService? notifications,
  ])  : _repo = repo ?? SettingsRepository(),
        _notifications = notifications ?? NotificationService(),
        super(
          const ReminderSettings(
            enabled: true,
            time: TimeOfDay(hour: 23, minute: 0),
          ),
        ) {
    state = ReminderSettings(
      enabled: _repo.loadReminderEnabled(),
      time: _repo.loadReminderTime(),
    );
  }

  final SettingsRepository _repo;
  final NotificationService _notifications;

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await _repo.saveReminderEnabled(value);
    await ensureScheduled();
  }

  Future<void> setTime(TimeOfDay time) async {
    state = state.copyWith(time: time);
    await _repo.saveReminderTime(time);
    await ensureScheduled();
  }

  Future<void> ensureScheduled() async {
    // Title/body are resolved by callers with l10n when possible; keep English
    // fallback only for cold start before UI exists.
    await _notifications.scheduleDailyReminder(
      enabled: state.enabled,
      time: state.time,
      title: _reminderTitle ?? 'Set tomorrow’s alarm',
      body: _reminderBody ??
          'Take a moment to schedule your Smart Voice Alarm for tomorrow.',
    );
  }

  String? _reminderTitle;
  String? _reminderBody;

  Future<void> ensureScheduledLocalized({
    required String title,
    required String body,
  }) async {
    _reminderTitle = title;
    _reminderBody = body;
    await ensureScheduled();
  }
}

final reminderSettingsProvider =
    StateNotifierProvider<ReminderSettingsController, ReminderSettings>((ref) {
  return ReminderSettingsController(
    ref.watch(settingsRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

/// Seeds sample data once for first launch so the UI is not empty.
Future<void> seedPrototypeDataIfNeeded({bool force = false}) async {
  final settings = SettingsRepository();
  if (!force && settings.didSeed) return;

  final alarms = AlarmRepository();
  final sequences = VoiceSequenceRepository();

  if (!force && alarms.loadAll().isNotEmpty) {
    await settings.markSeeded();
    return;
  }

  const sequence = VoiceSequenceUiModel(
    id: 'seq-1',
    name: 'Morning motivation',
    segments: [
      VoiceSegmentUiModel(
        id: 'seg-1',
        name: 'Wake gently',
        type: VoiceSegmentType.recording,
        duration: Duration(seconds: 8),
      ),
      VoiceSegmentUiModel(
        id: 'seg-2',
        name: 'Today matters',
        type: VoiceSegmentType.tts,
        duration: Duration(seconds: 12),
        text: 'Today is a great day. Stand up and breathe.',
        localeId: 'en-US',
      ),
      VoiceSegmentUiModel(
        id: 'seg-3',
        name: 'Hydrate reminder',
        type: VoiceSegmentType.recording,
        duration: Duration(seconds: 5),
      ),
    ],
  );
  await sequences.upsert(sequence);

  await alarms.saveAll(const [
    AlarmUiModel(
      id: 'alarm-1',
      time: TimeOfDay(hour: 6, minute: 30),
      repeatDays: {
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      },
      isEnabled: false,
      type: AlarmType.voice,
      label: 'Morning focus',
      voiceSequenceId: 'seq-1',
      ringtoneName: 'Soft Chime',
      repeatCount: 3,
    ),
    AlarmUiModel(
      id: 'alarm-2',
      time: TimeOfDay(hour: 7, minute: 15),
      repeatDays: {Weekday.saturday, Weekday.sunday},
      isEnabled: false,
      type: AlarmType.mixed,
      label: 'Weekend rise',
      voiceSequenceId: 'seq-1',
      ringtoneName: 'Ocean Breeze',
      repeatCount: 2,
    ),
  ]);
  await settings.markSeeded();
}

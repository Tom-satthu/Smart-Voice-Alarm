import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/localization/app_locale_support.dart';
import '../../core/localization/voice_catalog.dart';
import '../../core/services/alarm_engine.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/premium_purchase_service.dart';
import '../../core/services/recording_file_store.dart';
import '../../core/services/recording_service.dart';
import '../../core/services/storage_paths.dart';
import '../../core/services/tts_platform_bridge.dart';
import '../../core/services/tts_service.dart';
import '../../core/services/trial_entitlement_service.dart';
import '../data/local_store.dart';
import '../models/ui_models.dart';

const _uuid = Uuid();

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository();
});

final sequenceRepositoryProvider = Provider<VoiceSequenceRepository>((ref) {
  return VoiceSequenceRepository();
});

final savedVoiceRepositoryProvider = Provider<SavedVoiceRepository>((ref) {
  return SavedVoiceRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final premiumPurchaseServiceProvider = Provider<PremiumPurchaseService>((ref) {
  final service = PremiumPurchaseService();
  ref.onDispose(service.dispose);
  return service;
});

final premiumPurchaseProvider =
    StateNotifierProvider<PremiumPurchaseController, PremiumPurchaseState>((
      ref,
    ) {
      return PremiumPurchaseController(
        ref.watch(premiumPurchaseServiceProvider),
      );
    });

class PremiumPurchaseController extends StateNotifier<PremiumPurchaseState> {
  PremiumPurchaseController(this._service) : super(_service.state) {
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
  Future<void> syncEntitlementsFromStore() =>
      _service.syncEntitlementsFromStore();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final trialEntitlementServiceProvider = Provider<TrialEntitlementService>((
  ref,
) {
  return TrialEntitlementService(
    store: SettingsTrialEntitlementStore(ref.watch(settingsRepositoryProvider)),
  );
});

final trialEntitlementProvider =
    StateNotifierProvider<TrialEntitlementController, TrialEntitlementState>((
      ref,
    ) {
      final controller = TrialEntitlementController(
        trial: ref.watch(trialEntitlementServiceProvider),
        initializeBilling: () async {
          await ref.read(premiumPurchaseProvider.notifier).init();
          return ref.read(premiumPurchaseProvider);
        },
        refreshBilling: () async {
          await ref
              .read(premiumPurchaseProvider.notifier)
              .syncEntitlementsFromStore();
          return ref.read(premiumPurchaseProvider);
        },
      );
      ref.listen<PremiumPurchaseState>(premiumPurchaseProvider, (_, next) {
        controller.applyPurchaseState(next);
      });
      return controller;
    });

class TrialEntitlementController extends StateNotifier<TrialEntitlementState> {
  TrialEntitlementController({
    required TrialEntitlementService trial,
    required Future<PremiumPurchaseState> Function() initializeBilling,
    required Future<PremiumPurchaseState> Function() refreshBilling,
  }) : _trial = trial,
       _initializeBilling = initializeBilling,
       _refreshBilling = refreshBilling,
       super(const TrialEntitlementState.initializing());

  final TrialEntitlementService _trial;
  final Future<PremiumPurchaseState> Function() _initializeBilling;
  final Future<PremiumPurchaseState> Function() _refreshBilling;
  bool _initialized = false;

  Future<void> initializeSuccessfulLaunch() async {
    if (_initialized) return;
    _initialized = true;
    state = const TrialEntitlementState.initializing();
    await _trial.initializeSuccessfulLaunch();
    final purchase = await _initializeBilling();
    state = await _trial.applySubscriptionVerification(purchase.verification);
  }

  Future<void> refreshOnResume() async {
    if (!_initialized) return;
    state = await _trial.refreshLocalTime();
    final purchase = await _refreshBilling();
    state = await _trial.applySubscriptionVerification(purchase.verification);
  }

  Future<void> applyPurchaseState(PremiumPurchaseState purchase) async {
    if (!_initialized || !mounted) return;
    state = await _trial.applySubscriptionVerification(purchase.verification);
  }
}

final canUseMainFeaturesProvider = Provider<bool>((ref) {
  return ref.watch(trialEntitlementProvider).hasFullAccess;
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
  return TtsService(bridge: ref.watch(ttsPlatformBridgeProvider));
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
    SavedVoiceRepository? savedVoices,
  ]) : _repo = repo ?? AlarmRepository(),
       _notifications = notifications ?? NotificationService(),
       _sequences = sequences ?? VoiceSequenceRepository(),
       _savedVoices = savedVoices ?? SavedVoiceRepository(),
       super(const []) {
    state = _repo.loadAll();
  }

  final AlarmRepository _repo;
  final NotificationService _notifications;
  final VoiceSequenceRepository _sequences;
  final SavedVoiceRepository _savedVoices;

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
    final removed = state.where((alarm) => alarm.id == id).firstOrNull;
    state = state.where((alarm) => alarm.id != id).toList();
    await _repo.delete(id);
    await _notifications.cancelAlarm(id);
    final sequenceId = removed?.voiceSequenceId;
    if (sequenceId != null &&
        !state.any((alarm) => alarm.voiceSequenceId == sequenceId)) {
      final orphan = _sequences.findById(sequenceId);
      if (orphan != null) {
        await _sequences.delete(sequenceId);
        final remaining = _sequences.loadAll();
        // Saved voices are a reusable library — never auto-delete them here.
        final saved = _savedVoices.loadAll();
        for (final segment in orphan.segments) {
          if (segment.type == VoiceSegmentType.recording) {
            await RecordingFileStore.deleteIfUnreferenced(
              segment.filePath,
              sequences: remaining,
              savedVoices: saved,
            );
          }
        }
      }
    }
  }

  /// Returns whether native/iOS scheduling succeeded.
  Future<bool> add(AlarmUiModel alarm) async {
    final scheduled = await _notifications.scheduleAlarm(alarm);
    final saved = alarm.copyWith(
      audioNeedsRegeneration: !scheduled && alarm.type != AlarmType.ringtone,
    );
    state = [...state, saved]..sort(_byTime);
    await _repo.upsert(saved);
    return scheduled;
  }

  /// Returns whether native/iOS scheduling succeeded.
  Future<bool> update(AlarmUiModel alarm) async {
    final scheduled = await _notifications.scheduleAlarm(alarm);
    final saved = alarm.copyWith(
      audioNeedsRegeneration: !scheduled && alarm.type != AlarmType.ringtone,
    );
    state = [
      for (final item in state)
        if (item.id == saved.id) saved else item,
    ]..sort(_byTime);
    await _repo.upsert(saved);
    return scheduled;
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
        for (final segment in source.segments) segment.copyWith(id: _uuid.v4()),
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
    return (a.time.hour * 60 + a.time.minute).compareTo(
      b.time.hour * 60 + b.time.minute,
    );
  }
}

final alarmListProvider =
    StateNotifierProvider<AlarmListController, List<AlarmUiModel>>((ref) {
      return AlarmListController(
        ref.watch(alarmRepositoryProvider),
        ref.watch(notificationServiceProvider),
        ref.watch(sequenceRepositoryProvider),
        ref.watch(savedVoiceRepositoryProvider),
      );
    });

class VoiceSequenceController extends StateNotifier<VoiceSequenceUiModel> {
  VoiceSequenceController([
    VoiceSequenceRepository? repo,
    VoiceSequenceUiModel? initial,
    SavedVoiceRepository? savedVoices,
    bool persistMutations = false,
  ]) : _repo = repo ?? VoiceSequenceRepository(),
       _savedVoices = savedVoices ?? SavedVoiceRepository(),
       _persistMutations = persistMutations,
       super(
         initial ??
             const VoiceSequenceUiModel(
               id: 'seq-1',
               name: 'Morning motivation',
               segments: [],
             ),
       );

  final VoiceSequenceRepository _repo;
  final SavedVoiceRepository _savedVoices;
  bool _persistMutations;

  /// When false, mutations stay in memory until [commit].
  bool get isDraftMode => !_persistMutations;

  Future<void> persist() => _repo.upsert(state);

  /// Writes the current in-memory sequence to the repository.
  Future<void> commit() async {
    await persist();
    _persistMutations = true;
  }

  /// Reloads from disk (edit cancel) or clears to empty shell (new draft).
  Future<void> discard({required bool hadPersistedOriginal}) async {
    if (hadPersistedOriginal) {
      final existing = _repo.findById(state.id);
      if (existing != null) {
        state = existing;
        _persistMutations = true;
        return;
      }
    }
    state = VoiceSequenceUiModel(
      id: state.id,
      name: state.name,
      segments: const [],
    );
    _persistMutations = false;
  }

  Future<void> _afterMutate() async {
    if (_persistMutations) {
      await persist();
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final segments = List<VoiceSegmentUiModel>.from(state.segments);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = segments.removeAt(oldIndex);
    segments.insert(newIndex, item);
    state = state.copyWith(segments: segments);
    await _afterMutate();
  }

  Future<void> removeAt(int index) async {
    final segments = List<VoiceSegmentUiModel>.from(state.segments);
    final removed = segments.removeAt(index);
    state = state.copyWith(segments: segments);
    await _afterMutate();
    if (_persistMutations && removed.type == VoiceSegmentType.recording) {
      await RecordingFileStore.deleteIfUnreferenced(
        removed.filePath,
        sequences: _repo.loadAll(),
        savedVoices: _savedVoices.loadAll(),
      );
    }
  }

  Future<void> add(VoiceSegmentUiModel segment) async {
    final libraryId = segment.sourceSavedVoiceId ?? segment.id;
    final libraryVoice = VoiceSegmentUiModel(
      id: libraryId,
      name: segment.name,
      type: segment.type,
      duration: segment.duration,
      text: segment.text,
      filePath: segment.filePath,
      voiceId: segment.voiceId,
      localeId: segment.localeId,
      createdAt: segment.createdAt ?? DateTime.now(),
    );
    await _savedVoices.upsert(libraryVoice);

    final sequenceEntry = VoiceSegmentUiModel(
      id: _uuid.v4(),
      name: segment.name,
      type: segment.type,
      duration: segment.duration,
      text: segment.text,
      filePath: segment.filePath,
      voiceId: segment.voiceId,
      localeId: segment.localeId,
      createdAt: segment.createdAt ?? libraryVoice.createdAt,
      sourceSavedVoiceId: libraryId,
    );
    state = state.copyWith(segments: [...state.segments, sequenceEntry]);
    await _afterMutate();
  }

  /// Adds a saved voice into the current sequence draft without creating a new
  /// saved-voice persistence row or copying recording files.
  Future<void> addExistingSavedVoice(VoiceSegmentUiModel saved) async {
    final libraryId = saved.sourceSavedVoiceId ?? saved.id;
    final entry = VoiceSegmentUiModel(
      id: _uuid.v4(),
      name: saved.name,
      type: saved.type,
      duration: saved.duration,
      text: saved.text,
      filePath: saved.filePath,
      voiceId: saved.voiceId,
      localeId: saved.localeId,
      createdAt: saved.createdAt,
      sourceSavedVoiceId: libraryId,
    );
    state = state.copyWith(segments: [...state.segments, entry]);
    await _afterMutate();
  }

  Future<void> updateAt(int index, VoiceSegmentUiModel segment) async {
    final segments = List<VoiceSegmentUiModel>.from(state.segments);
    segments[index] = segment;
    state = state.copyWith(segments: segments);
    await _afterMutate();
  }

  Future<void> rename(String name) async {
    state = state.copyWith(name: name);
    await _afterMutate();
  }
}

final savedVoicesProvider =
    StateNotifierProvider<SavedVoicesController, List<VoiceSegmentUiModel>>((
      ref,
    ) {
      return SavedVoicesController(ref.watch(savedVoiceRepositoryProvider));
    });

class SavedVoicesController extends StateNotifier<List<VoiceSegmentUiModel>> {
  SavedVoicesController(this._repo) : super(_repo.loadAll());

  final SavedVoiceRepository _repo;

  Future<void> refresh() async {
    state = _repo.loadAll();
  }

  Future<void> upsert(VoiceSegmentUiModel voice) async {
    await _repo.upsert(voice);
    state = _repo.loadAll();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.loadAll();
  }
}

/// Sequence ids currently open as unsaved create/edit drafts.
final openDraftSequenceIdsProvider = StateProvider<Set<String>>((ref) => {});

final voiceSequenceProvider =
    StateNotifierProvider.family<
      VoiceSequenceController,
      VoiceSequenceUiModel,
      String
    >((ref, sequenceId) {
      final repo = ref.watch(sequenceRepositoryProvider);
      final saved = ref.watch(savedVoiceRepositoryProvider);
      final existing = repo.findById(sequenceId);
      final initial =
          existing ??
          VoiceSequenceUiModel(
            id: sequenceId,
            name: 'Voice Sequence',
            segments: const [],
          );
      // Always memory-first. Create/Edit Alarm calls commit() on Save.
      return VoiceSequenceController(repo, initial, saved, false);
    });

/// Fallback sequence id used when a route omits `?id=`.
const defaultSequenceId = 'seq-1';

final ttsVoicesProvider = FutureProvider.autoDispose<List<TtsVoiceUiModel>>((
  ref,
) async {
  final preferred = ref.watch(preferredVoiceProvider);
  final app = ref.watch(localeProvider);
  final system = WidgetsBinding.instance.platformDispatcher.locale;
  return ref
      .watch(ttsServiceProvider)
      .loadVoices(
        preferredLocale: preferred.locale,
        appLocale: app.toLanguageTag(),
        systemLocale: system.toLanguageTag(),
      );
});

final usableTtsVoicesProvider =
    FutureProvider.autoDispose<List<TtsVoiceUiModel>>((ref) async {
      final preferred = ref.watch(preferredVoiceProvider);
      final app = ref.watch(localeProvider);
      final system = WidgetsBinding.instance.platformDispatcher.locale;
      return ref
          .watch(ttsServiceProvider)
          .loadUsableVoices(
            preferredLocale: preferred.locale,
            appLocale: app.toLanguageTag(),
            systemLocale: system.toLanguageTag(),
          );
    });

class PreferredVoiceController
    extends StateNotifier<({String? id, String? locale, String? language})> {
  PreferredVoiceController([SettingsRepository? repo])
    : _repo = repo ?? SettingsRepository(),
      super(_loadAndMigrate(repo ?? SettingsRepository()));

  final SettingsRepository _repo;

  static ({String? id, String? locale, String? language}) _loadAndMigrate(
    SettingsRepository repo,
  ) {
    final rawId = repo.loadPreferredVoiceId();
    final normalizedId = VoiceCatalog.normalizeSystemDefaultVoiceId(rawId);
    final locale = repo.loadPreferredVoiceLocale();
    var language = repo.loadPreferredVoiceLanguage();
    if (normalizedId != null &&
        normalizedId.startsWith('system-default|') &&
        (language == null || language.isEmpty)) {
      language = VoiceCatalog.languageCodeOf(
        normalizedId.substring('system-default|'.length),
      );
    }
    if (normalizedId != null &&
        normalizedId != rawId &&
        normalizedId.startsWith('system-default|')) {
      // Persist legacy → language-scoped system-default id (idempotent).
      unawaited(
        repo.savePreferredVoice(voiceId: normalizedId, localeId: locale),
      );
      if (language != null) {
        unawaited(repo.savePreferredVoiceLanguage(language));
      }
    }
    return (id: normalizedId, locale: locale, language: language);
  }

  Future<void> setVoice({
    required String id,
    required String locale,
    String? language,
  }) async {
    final normalizedId = VoiceCatalog.normalizeSystemDefaultVoiceId(id) ?? id;
    final normalizedLocale = VoiceCatalog.normalizeLocaleTag(locale);
    final lang = VoiceCatalog.normalizeLanguageCode(
      language ?? VoiceCatalog.languageCodeOf(normalizedLocale),
    );
    state = (id: normalizedId, locale: normalizedLocale, language: lang);
    await _repo.savePreferredVoice(
      voiceId: normalizedId,
      localeId: normalizedLocale,
    );
    await _repo.savePreferredVoiceLanguage(lang);
  }

  Future<void> setLanguage(String language) async {
    state = (id: state.id, locale: state.locale, language: language);
    await _repo.savePreferredVoiceLanguage(language);
  }
}

final preferredVoiceProvider =
    StateNotifierProvider<
      PreferredVoiceController,
      ({String? id, String? locale, String? language})
    >((ref) {
      return PreferredVoiceController(ref.watch(settingsRepositoryProvider));
    });

final ringtonesProvider = Provider<List<RingtoneUiModel>>((ref) {
  return [
    for (final tone in RingtoneAssets.all)
      RingtoneUiModel(
        id: tone.name,
        name: tone.name,
        assetPath: tone.assetPath,
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

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(settingsRepositoryProvider));
});

class ReminderSettings {
  const ReminderSettings({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;

  ReminderSettings copyWith({bool? enabled, TimeOfDay? time}) {
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
  ]) : _repo = repo ?? SettingsRepository(),
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
      body:
          _reminderBody ??
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

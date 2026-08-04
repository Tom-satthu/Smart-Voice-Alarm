import 'package:flutter/material.dart';
import 'package:smart_voice_alarm/shared/data/local_store.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

/// In-memory stand-ins for widget tests (Hive futures hang under fake async).
class MemoryAlarmRepository extends AlarmRepository {
  MemoryAlarmRepository([List<AlarmUiModel> seed = const []]) {
    for (final alarm in seed) {
      _items[alarm.id] = alarm;
    }
  }

  final Map<String, AlarmUiModel> _items = {};

  @override
  List<AlarmUiModel> loadAll() {
    final items = _items.values.toList()
      ..sort((a, b) {
        final am = a.time.hour * 60 + a.time.minute;
        final bm = b.time.hour * 60 + b.time.minute;
        return am.compareTo(bm);
      });
    return items;
  }

  @override
  Future<void> saveAll(List<AlarmUiModel> alarms) async {
    _items
      ..clear()
      ..addEntries(alarms.map((a) => MapEntry(a.id, a)));
  }

  @override
  Future<void> upsert(AlarmUiModel alarm) async {
    _items[alarm.id] = alarm;
  }

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }

  @override
  AlarmUiModel? findById(String id) => _items[id];
}

class MemoryVoiceSequenceRepository extends VoiceSequenceRepository {
  MemoryVoiceSequenceRepository([List<VoiceSequenceUiModel> seed = const []]) {
    for (final sequence in seed) {
      _items[sequence.id] = sequence;
    }
  }

  final Map<String, VoiceSequenceUiModel> _items = {};

  @override
  List<VoiceSequenceUiModel> loadAll() => _items.values.toList();

  @override
  VoiceSequenceUiModel? findById(String id) => _items[id];

  @override
  Future<void> upsert(VoiceSequenceUiModel sequence) async {
    _items[sequence.id] = sequence;
  }

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }
}

class MemorySettingsRepository extends SettingsRepository {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _hasSavedLocale = false;
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 23, minute: 0);
  bool _didSeed = false;

  @override
  ThemeMode loadThemeMode() => _themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async => _themeMode = mode;

  @override
  Locale loadLocale() => _locale;

  @override
  bool get hasSavedLocale => _hasSavedLocale;

  @override
  Future<void> saveLocale(Locale locale) async {
    _locale = locale;
    _hasSavedLocale = true;
  }

  @override
  bool loadReminderEnabled() => _reminderEnabled;

  @override
  Future<void> saveReminderEnabled(bool enabled) async =>
      _reminderEnabled = enabled;

  @override
  TimeOfDay loadReminderTime() => _reminderTime;

  @override
  Future<void> saveReminderTime(TimeOfDay time) async => _reminderTime = time;

  @override
  bool get didSeed => _didSeed;

  @override
  Future<void> markSeeded() async => _didSeed = true;

  @override
  Future<void> clearSeedFlag() async => _didSeed = false;

  @override
  String? loadPreferredVoiceId() => _preferredVoiceId;

  @override
  String? loadPreferredVoiceLocale() => _preferredVoiceLocale;

  @override
  Future<void> savePreferredVoice({
    required String? voiceId,
    required String? localeId,
  }) async {
    _preferredVoiceId = voiceId;
    _preferredVoiceLocale = localeId;
  }

  String? _preferredVoiceId;
  String? _preferredVoiceLocale;
  String? _preferredVoiceLanguage;
  Set<String> _newVoiceIds = {};
  bool _premiumUnlocked = false;

  @override
  String? loadPreferredVoiceLanguage() => _preferredVoiceLanguage;

  @override
  Future<void> savePreferredVoiceLanguage(String? languageCode) async {
    _preferredVoiceLanguage = languageCode;
  }

  @override
  Set<String> loadNewVoiceIds() => Set<String>.from(_newVoiceIds);

  @override
  Future<void> saveNewVoiceIds(Set<String> voiceIds) async {
    _newVoiceIds = Set<String>.from(voiceIds);
  }

  @override
  bool loadPremiumUnlocked() => _premiumUnlocked;

  @override
  Future<void> savePremiumUnlocked(bool unlocked) async {
    _premiumUnlocked = unlocked;
  }
}

/// Sample data matching the product seed, for tests.
abstract final class TestSeedData {
  static const sequence = VoiceSequenceUiModel(
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

  static const alarms = <AlarmUiModel>[
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
  ];
}

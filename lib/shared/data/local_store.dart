import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/ui_models.dart';

abstract final class AppBoxes {
  static const alarms = 'alarms';
  static const sequences = 'sequences';
  static const settings = 'settings';
}

class LocalDatabase {
  LocalDatabase._();

  static bool _ready = false;

  static bool get isReady => _ready;

  /// Opens Hive boxes. Call [Hive.init] or [Hive.initFlutter] first when needed.
  static Future<void> openBoxes() async {
    if (_ready) return;
    await Future.wait([
      _openStringBox(AppBoxes.alarms),
      _openStringBox(AppBoxes.sequences),
      _openSettingsBox(),
    ]);
    _ready = true;
  }

  static Future<void> initFlutter() async {
    await Hive.initFlutter();
    await openBoxes();
  }

  static Future<void> _openStringBox(String name) async {
    if (Hive.isBoxOpen(name)) return;
    await Hive.openBox<String>(name);
  }

  static Future<void> _openSettingsBox() async {
    if (Hive.isBoxOpen(AppBoxes.settings)) return;
    await Hive.openBox(AppBoxes.settings);
  }

  static Box<String> get alarmsBox => Hive.box<String>(AppBoxes.alarms);
  static Box<String> get sequencesBox => Hive.box<String>(AppBoxes.sequences);
  static Box get settingsBox => Hive.box(AppBoxes.settings);

  static Future<void> clearAllForTests() async {
    if (!_ready) return;
    // Prefer deleteAll over clear() — clear() can hang in widget tests.
    await alarmsBox.deleteAll(alarmsBox.keys.toList());
    await sequencesBox.deleteAll(sequencesBox.keys.toList());
    await settingsBox.deleteAll(settingsBox.keys.toList());
  }
}

class AlarmRepository {
  List<AlarmUiModel> loadAll() {
    final box = LocalDatabase.alarmsBox;
    final items = box.values
        .map((raw) => AlarmUiModel.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            ))
        .toList()
      ..sort((a, b) {
        final am = a.time.hour * 60 + a.time.minute;
        final bm = b.time.hour * 60 + b.time.minute;
        return am.compareTo(bm);
      });
    return items;
  }

  Future<void> saveAll(List<AlarmUiModel> alarms) async {
    final box = LocalDatabase.alarmsBox;
    await box.clear();
    for (final alarm in alarms) {
      await box.put(alarm.id, jsonEncode(alarm.toJson()));
    }
  }

  Future<void> upsert(AlarmUiModel alarm) async {
    await LocalDatabase.alarmsBox.put(alarm.id, jsonEncode(alarm.toJson()));
  }

  Future<void> delete(String id) async {
    await LocalDatabase.alarmsBox.delete(id);
  }

  AlarmUiModel? findById(String id) {
    final raw = LocalDatabase.alarmsBox.get(id);
    if (raw == null) return null;
    return AlarmUiModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class VoiceSequenceRepository {
  List<VoiceSequenceUiModel> loadAll() {
    return LocalDatabase.sequencesBox.values
        .map(
          (raw) => VoiceSequenceUiModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  VoiceSequenceUiModel? findById(String id) {
    final raw = LocalDatabase.sequencesBox.get(id);
    if (raw == null) return null;
    return VoiceSequenceUiModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> upsert(VoiceSequenceUiModel sequence) async {
    await LocalDatabase.sequencesBox
        .put(sequence.id, jsonEncode(sequence.toJson()));
  }

  Future<void> delete(String id) async {
    await LocalDatabase.sequencesBox.delete(id);
  }
}

class SettingsRepository {
  static const _themeKey = 'themeMode';
  static const _localeKey = 'locale';
  static const _reminderEnabledKey = 'reminderEnabled';
  static const _reminderHourKey = 'reminderHour';
  static const _reminderMinuteKey = 'reminderMinute';
  static const _seededKey = 'didSeed';
  static const _preferredVoiceIdKey = 'preferredVoiceId';
  static const _preferredVoiceLocaleKey = 'preferredVoiceLocale';
  static const _preferredVoiceLanguageKey = 'preferredVoiceLanguage';
  static const _premiumUnlockedKey = 'premiumLifetimeUnlocked';

  ThemeMode loadThemeMode() {
    final raw = LocalDatabase.settingsBox.get(_themeKey) as String?;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await LocalDatabase.settingsBox.put(_themeKey, value);
  }

  Locale loadLocale() {
    final code = LocalDatabase.settingsBox.get(_localeKey) as String?;
    if (code == null || code.isEmpty) {
      return const Locale('en');
    }
    final parts = code.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }

  bool get hasSavedLocale =>
      LocalDatabase.settingsBox.get(_localeKey) != null;

  Future<void> saveLocale(Locale locale) async {
    final value = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    await LocalDatabase.settingsBox.put(_localeKey, value);
  }

  bool loadReminderEnabled() =>
      LocalDatabase.settingsBox.get(_reminderEnabledKey) as bool? ?? true;

  Future<void> saveReminderEnabled(bool enabled) async {
    await LocalDatabase.settingsBox.put(_reminderEnabledKey, enabled);
  }

  TimeOfDay loadReminderTime() {
    final hour = LocalDatabase.settingsBox.get(_reminderHourKey) as int? ?? 23;
    final minute =
        LocalDatabase.settingsBox.get(_reminderMinuteKey) as int? ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveReminderTime(TimeOfDay time) async {
    await LocalDatabase.settingsBox.put(_reminderHourKey, time.hour);
    await LocalDatabase.settingsBox.put(_reminderMinuteKey, time.minute);
  }

  bool get didSeed =>
      LocalDatabase.settingsBox.get(_seededKey) as bool? ?? false;

  Future<void> markSeeded() async {
    await LocalDatabase.settingsBox.put(_seededKey, true);
  }

  Future<void> clearSeedFlag() async {
    await LocalDatabase.settingsBox.delete(_seededKey);
  }

  String? loadPreferredVoiceId() =>
      LocalDatabase.settingsBox.get(_preferredVoiceIdKey) as String?;

  String? loadPreferredVoiceLocale() =>
      LocalDatabase.settingsBox.get(_preferredVoiceLocaleKey) as String?;

  Future<void> savePreferredVoice({
    required String? voiceId,
    required String? localeId,
  }) async {
    if (voiceId == null) {
      await LocalDatabase.settingsBox.delete(_preferredVoiceIdKey);
    } else {
      await LocalDatabase.settingsBox.put(_preferredVoiceIdKey, voiceId);
    }
    if (localeId == null) {
      await LocalDatabase.settingsBox.delete(_preferredVoiceLocaleKey);
    } else {
      await LocalDatabase.settingsBox.put(_preferredVoiceLocaleKey, localeId);
    }
  }

  String? loadPreferredVoiceLanguage() =>
      LocalDatabase.settingsBox.get(_preferredVoiceLanguageKey) as String?;

  Future<void> savePreferredVoiceLanguage(String? languageCode) async {
    if (languageCode == null || languageCode.isEmpty) {
      await LocalDatabase.settingsBox.delete(_preferredVoiceLanguageKey);
    } else {
      await LocalDatabase.settingsBox.put(
        _preferredVoiceLanguageKey,
        languageCode,
      );
    }
  }

  bool loadPremiumUnlocked() =>
      LocalDatabase.settingsBox.get(_premiumUnlockedKey) as bool? ?? false;

  Future<void> savePremiumUnlocked(bool unlocked) async {
    await LocalDatabase.settingsBox.put(_premiumUnlockedKey, unlocked);
  }
}

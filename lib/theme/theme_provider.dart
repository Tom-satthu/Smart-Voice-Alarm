import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/data/local_store.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(this._repo) : super(_repo.loadThemeMode());

  final SettingsRepository _repo;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repo.saveThemeMode(mode);
  }

  Future<void> toggleDark(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  bool isDark(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((
  ref,
) {
  return ThemeController(SettingsRepository());
});

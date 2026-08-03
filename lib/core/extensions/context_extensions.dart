import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  MediaQueryData get mq => MediaQuery.of(this);
  bool get isDark => theme.brightness == Brightness.dark;
}

extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DurationFormatX on Duration {
  String get mmss {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get compact {
    if (inMinutes >= 1) {
      final secs = inSeconds.remainder(60);
      return secs == 0 ? '${inMinutes}m' : '${inMinutes}m ${secs}s';
    }
    return '${inSeconds}s';
  }
}

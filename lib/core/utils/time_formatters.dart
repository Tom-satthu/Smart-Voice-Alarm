import 'package:flutter/material.dart';

abstract final class TimeFormatters {
  static String formatTime(TimeOfDay time, {bool use24Hour = true}) {
    if (use24Hour) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    return '$hour:$m $period';
  }

  static String twoDigits(int value) => value.toString().padLeft(2, '0');
}

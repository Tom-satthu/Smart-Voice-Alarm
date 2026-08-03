import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/models/ui_models.dart';

String formatRepeatDays(AppLocalizations l10n, Set<Weekday> days) {
  if (days.isEmpty) return l10n.dayOnce;
  if (days.length == 7) return l10n.dayEveryDay;
  const weekdays = {
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
  };
  const weekends = {Weekday.saturday, Weekday.sunday};
  if (days.containsAll(weekdays) && days.length == 5) return l10n.dayWeekdays;
  if (days.containsAll(weekends) && days.length == 2) return l10n.dayWeekends;

  final labels = <String>[];
  for (final day in Weekday.values) {
    if (!days.contains(day)) continue;
    labels.add(switch (day) {
      Weekday.monday => l10n.dayMon,
      Weekday.tuesday => l10n.dayTue,
      Weekday.wednesday => l10n.dayWed,
      Weekday.thursday => l10n.dayThu,
      Weekday.friday => l10n.dayFri,
      Weekday.saturday => l10n.daySat,
      Weekday.sunday => l10n.daySun,
    });
  }
  return labels.join(', ');
}

String alarmTypeLabel(AppLocalizations l10n, AlarmType type) {
  return switch (type) {
    AlarmType.voice => l10n.alarmTypeVoice,
    AlarmType.ringtone => l10n.alarmTypeRingtone,
    AlarmType.mixed => l10n.alarmTypeMixed,
  };
}

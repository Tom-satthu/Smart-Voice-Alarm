import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/time_formatters.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../home/presentation/widgets/alarm_formatters.dart';

class CreateAlarmScreen extends ConsumerStatefulWidget {
  const CreateAlarmScreen({super.key, this.alarmId});

  final String? alarmId;

  @override
  ConsumerState<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends ConsumerState<CreateAlarmScreen> {
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  Set<Weekday> _repeatDays = {
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
  };
  int _repeatCount = 3;
  AlarmType _type = AlarmType.voice;
  String? _ringtoneName = 'Soft Chime';
  String? _sequenceName = 'Morning motivation';
  String? _copiedFromId;
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;

    final alarms = ref.read(alarmListProvider);
    final existing = widget.alarmId == null
        ? null
        : alarms.where((a) => a.id == widget.alarmId).firstOrNull;
    if (existing == null) return;

    _time = existing.time;
    _repeatDays = Set<Weekday>.from(existing.repeatDays);
    _repeatCount = existing.repeatCount;
    _type = existing.type;
    _ringtoneName = existing.ringtoneName ?? 'Soft Chime';
    _sequenceName = 'Morning motivation';
  }

  void _applyCopy(AlarmUiModel source) {
    setState(() {
      _copiedFromId = source.id;
      _time = source.time;
      _repeatDays = Set<Weekday>.from(source.repeatDays);
      _repeatCount = source.repeatCount;
      _type = source.type;
      _ringtoneName = source.ringtoneName;
      _sequenceName = 'Morning motivation';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.alarmId != null;
    final alarms = ref.watch(alarmListProvider);
    final ringtones = ref.watch(ringtonesProvider);

    return AppScaffold(
      showBack: true,
      title: isEdit ? l10n.editAlarmTitle : l10n.createAlarmTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppConstants.spaceMd,
            bottom: AppConstants.space2xl,
          ),
          children: [
            SectionHeader(title: l10n.alarmTime),
            SurfacePanel(
              child: Column(
                children: [
                  Text(
                    TimeFormatters.formatTime(_time),
                    style: context.textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  SizedBox(
                    height: 160,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: context.theme.brightness,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle:
                              context.textTheme.headlineSmall!,
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: DateTime(
                          2026,
                          1,
                          1,
                          _time.hour,
                          _time.minute,
                        ),
                        onDateTimeChanged: (value) {
                          setState(() {
                            _time = TimeOfDay(
                              hour: value.hour,
                              minute: value.minute,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.alarmRepeat),
            SurfacePanel(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Weekday.values.map((day) {
                  final selected = _repeatDays.contains(day);
                  final label = switch (day) {
                    Weekday.monday => l10n.dayMon,
                    Weekday.tuesday => l10n.dayTue,
                    Weekday.wednesday => l10n.dayWed,
                    Weekday.thursday => l10n.dayThu,
                    Weekday.friday => l10n.dayFri,
                    Weekday.saturday => l10n.daySat,
                    Weekday.sunday => l10n.daySun,
                  };
                  return AppChip(
                    label: label,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _repeatDays.remove(day);
                        } else {
                          _repeatDays.add(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.alarmVoiceSequence),
            SurfacePanel(
              onTap: () => context.push(AppRoutes.voiceSequence),
              child: Row(
                children: [
                  Icon(Icons.queue_music_rounded, color: context.colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sequenceName ?? l10n.alarmNoneSelected,
                          style: context.textTheme.titleSmall,
                        ),
                        Text(
                          l10n.alarmSelectSequence,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.alarmRingtone),
            SurfacePanel(
              child: Column(
                children: ringtones.map((ringtone) {
                  final selected = _ringtoneName == ringtone.name;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(ringtone.name),
                    trailing: selected
                        ? Icon(Icons.check_circle_rounded,
                            color: context.colors.primary)
                        : Icon(
                            Icons.circle_outlined,
                            color: context.colors.outline,
                          ),
                    onTap: () => setState(() => _ringtoneName = ringtone.name),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.alarmRepeatCount),
            SurfacePanel(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.timesLabel(_repeatCount),
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _repeatCount > 1
                        ? () => setState(() => _repeatCount--)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$_repeatCount',
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _repeatCount < 10
                        ? () => setState(() => _repeatCount++)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.alarmCopyFrom),
            SurfacePanel(
              child: alarms.isEmpty
                  ? Text(
                      l10n.alarmNoneSelected,
                      style: context.textTheme.bodyMedium,
                    )
                  : Column(
                      children: alarms.map((alarm) {
                        final selected = _copiedFromId == alarm.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(TimeFormatters.formatTime(alarm.time)),
                          subtitle: Text(
                            '${alarm.label} · ${formatRepeatDays(l10n, alarm.repeatDays)}',
                          ),
                          trailing: selected
                              ? Icon(Icons.check_circle_rounded,
                                  color: context.colors.primary)
                              : null,
                          onTap: () => _applyCopy(alarm),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: 'Alarm type'),
            SurfacePanel(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AlarmType.values.map((type) {
                  return AppChip(
                    label: alarmTypeLabel(l10n, type),
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            PrimaryActionButton(
              label: l10n.alarmSave,
              icon: Icons.check_rounded,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

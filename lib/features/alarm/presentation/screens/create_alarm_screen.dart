import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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
  String _ringtoneName = 'Soft Chime';
  String _label = '';
  String? _voiceSequenceId;
  bool _hydrated = false;
  bool _enabled = true;

  bool get _isEdit => widget.alarmId != null;

  String _ensureSequenceId() {
    _voiceSequenceId ??= const Uuid().v4();
    return _voiceSequenceId!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;

    final existing = widget.alarmId == null
        ? null
        : ref.read(alarmListProvider.notifier).findById(widget.alarmId!);
    if (existing == null) {
      _voiceSequenceId = const Uuid().v4();
      return;
    }

    _time = existing.time;
    _repeatDays = Set<Weekday>.from(existing.repeatDays);
    _repeatCount = existing.repeatCount;
    _type = existing.type;
    _ringtoneName = existing.ringtoneName ?? 'Soft Chime';
    _label = existing.label;
    _voiceSequenceId = existing.voiceSequenceId ?? const Uuid().v4();
    _enabled = existing.isEnabled;
  }

  void _applyCopy(AlarmUiModel source) {
    setState(() {
      _time = source.time;
      _repeatDays = Set<Weekday>.from(source.repeatDays);
      _repeatCount = source.repeatCount;
      _type = source.type;
      _ringtoneName = source.ringtoneName ?? 'Soft Chime';
      _label = source.label;
      _voiceSequenceId = source.voiceSequenceId ?? const Uuid().v4();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).alarmCopied)),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final sequenceId = _ensureSequenceId();
    // Ensure sequence document exists before linking.
    ref.read(voiceSequenceProvider(sequenceId));

    final model = AlarmUiModel(
      id: widget.alarmId ?? const Uuid().v4(),
      time: _time,
      repeatDays: Set<Weekday>.from(_repeatDays),
      isEnabled: _enabled,
      type: _type,
      label: _label.trim().isEmpty ? l10n.alarmDefaultLabel : _label.trim(),
      voiceSequenceId: sequenceId,
      ringtoneName: _ringtoneName,
      repeatCount: _repeatCount,
    );

    final controller = ref.read(alarmListProvider.notifier);
    if (_isEdit) {
      await controller.update(model);
    } else {
      await controller.add(model);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.alarmSaved)));
    context.pop();
  }

  Future<void> _pickRingtone() async {
    final l10n = AppLocalizations.of(context);
    final ringtones = ref.read(ringtonesProvider);
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    l10n.alarmRingtone,
                    style: context.textTheme.titleLarge,
                  ),
                ),
                for (final ringtone in ringtones)
                  ListTile(
                    title: Text(localizedRingtone(l10n, ringtone.name)),
                    trailing: _ringtoneName == ringtone.name
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: context.colors.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, ringtone.name),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) setState(() => _ringtoneName = selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alarms = ref.watch(alarmListProvider);
    final sequenceId = _voiceSequenceId ?? defaultSequenceId;
    final sequence = ref.watch(voiceSequenceProvider(sequenceId));
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppScaffold(
      showBack: true,
      title: _isEdit ? l10n.editAlarmTitle : l10n.createAlarmTitle,
      resizeToAvoidBottomInset: true,
      body: ResponsiveCenter(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  top: AppConstants.spaceMd,
                  bottom: 24 + bottomInset,
                ),
                children: [
                  SectionHeader(title: l10n.alarmTime),
                  SurfacePanel(
                    emphasized: true,
                    child: Column(
                      children: [
                        Text(
                          TimeFormatters.formatTime(_time),
                          style: context.textTheme.displayMedium?.copyWith(
                            letterSpacing: -1.4,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceSm),
                        SizedBox(
                          height: 148,
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                              brightness: context.theme.brightness,
                              textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle:
                                    context.textTheme.titleLarge!,
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
                    onTap: () =>
                        context.push(AppRoutes.voiceSequencePath(sequenceId)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.queue_music_rounded,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sequence.name,
                                style: context.textTheme.titleSmall,
                              ),
                              Text(
                                '${l10n.segmentsLabel(sequence.segments.length)} · ${l10n.alarmSelectSequence}',
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
                  SectionHeader(title: l10n.alarmRingtone),
                  SurfacePanel(
                    onTap: _pickRingtone,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizedRingtone(l10n, _ringtoneName),
                                style: context.textTheme.titleSmall,
                              ),
                              Text(
                                l10n.alarmSelectRingtone,
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
                  SectionHeader(title: l10n.alarmTypeLabel),
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
                  if (alarms.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spaceXl),
                    SectionHeader(title: l10n.alarmCopyFrom),
                    SurfacePanel(
                      child: Column(
                        children: [
                          for (final alarm in alarms.take(5))
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                TimeFormatters.formatTime(alarm.time),
                              ),
                              subtitle: Text(
                                '${alarm.label} · ${formatRepeatDays(l10n, alarm.repeatDays)}',
                              ),
                              onTap: () => _applyCopy(alarm),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            StickyBottomBar(
              child: PrimaryActionButton(
                label: l10n.alarmSave,
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

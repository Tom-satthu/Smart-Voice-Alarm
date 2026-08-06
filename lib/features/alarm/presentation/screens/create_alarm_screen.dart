import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/ios_alarm_scheduler.dart';
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
    Weekday.saturday,
    Weekday.sunday,
  };
  int _repeatCount = 3;
  AlarmType _type = AlarmType.mixed;
  String _ringtoneName = 'Soft Chime';
  String _label = '';
  String? _voiceSequenceId;
  bool _hydrated = false;
  bool _enabled = true;
  bool _committed = false;
  bool _hadPersistedSequence = false;

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
      _hadPersistedSequence = false;
      _registerDraftSequence(_voiceSequenceId!);
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
    _hadPersistedSequence =
        existing.voiceSequenceId != null &&
        ref.read(sequenceRepositoryProvider).findById(_voiceSequenceId!) !=
            null;
    _registerDraftSequence(_voiceSequenceId!);
  }

  void _registerDraftSequence(String sequenceId) {
    // Riverpod forbids provider writes during didChangeDependencies/build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(openDraftSequenceIdsProvider.notifier).update((ids) {
        return {...ids, sequenceId};
      });
      // Touch provider so draft exists in memory without persisting.
      ref.read(voiceSequenceProvider(sequenceId));
    });
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

  Future<bool> _ensureNotificationAccess() async {
    if (kIsWeb) return true;
    final notifications = ref.read(notificationServiceProvider);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final auth = await notifications.iosFanout.scheduler
          .requestAuthorization();
      if (auth['notifications'] == true) return true;
      final alarmKit = auth['alarmKitAuthorization']?.toString();
      if (alarmKit == 'denied') {
        if (!mounted) return false;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.alarmKitDenied)));
      }
    }
    if (await notifications.notificationPermissionGranted) return true;
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationPermission),
        content: Text(l10n.openSystemSettingsHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.notificationPermission),
          ),
        ],
      ),
    );
    if (proceed != true) return false;
    return notifications.requestNotificationPermission();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final sequenceId = _ensureSequenceId();
    final sequenceController = ref.read(
      voiceSequenceProvider(sequenceId).notifier,
    );
    final seq = ref.read(voiceSequenceProvider(sequenceId));
    final repeats = _repeatCount.clamp(1, 20);
    // iOS planner ignores repeatCount (effective 1). Keep stored value for Android.
    final effectiveRepeats =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS ? 1 : repeats;

    // Validate in memory — never persist draft before schedule succeeds.
    if (_type == AlarmType.mixed) {
      if (seq.segments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mixedAlarmNeedsVoiceAndRingtone)),
        );
        return;
      }
      if (_ringtoneName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mixedAlarmNeedsVoiceAndRingtone)),
        );
        return;
      }
    }
    if (_type == AlarmType.voice && seq.segments.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.alarmSelectSequence)));
      return;
    }
    if (_type != AlarmType.ringtone && seq.segments.isNotEmpty) {
      final voiceCount = seq.segments.length.clamp(0, 5);
      final toneCount = _type == AlarmType.voice ? 0 : 1;
      final planned = voiceCount * effectiveRepeats + toneCount;
      if (planned > 64) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.alarmNotificationLimitExceeded)),
        );
        return;
      }
    }

    final wantsEnabled = _isEdit ? _enabled : true;
    final notificationAllowed =
        !wantsEnabled || await _ensureNotificationAccess();
    if (!mounted) return;

    final model = AlarmUiModel(
      id: widget.alarmId ?? const Uuid().v4(),
      time: _time,
      repeatDays: Set<Weekday>.from(_repeatDays),
      isEnabled: wantsEnabled && notificationAllowed,
      type: _type,
      label: _label.trim().isEmpty ? l10n.alarmDefaultLabel : _label.trim(),
      voiceSequenceId: sequenceId,
      ringtoneName: _ringtoneName,
      repeatCount: repeats,
      audioNeedsRegeneration: false,
    );

    final controller = ref.read(alarmListProvider.notifier);
    // Schedule with in-memory draft; persist only on success.
    final result = _isEdit
        ? await controller.update(model, sequenceOverride: seq)
        : await controller.add(model, sequenceOverride: seq);

    if (!mounted) return;
    if (!notificationAllowed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.permissionStatusDenied)));
    }

    if (!result.ok) {
      final detail = [
        if (result.stage != null) 'stage=${result.stage}',
        if (result.errorCode != null) 'code=${result.errorCode}',
        if (result.errorMessage != null) result.errorMessage,
      ].join(' · ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detail.isEmpty ? l10n.audioRenderingError : detail),
        ),
      );
      // Keep draft editable; do not persist alarm/sequence.
      return;
    }

    // Mark draft committed so pop does not discard the now-persisted sequence.
    await sequenceController.commit();
    if (!mounted) return;
    _committed = true;
    ref.read(openDraftSequenceIdsProvider.notifier).update((ids) {
      final next = Set<String>.from(ids)..remove(sequenceId);
      return next;
    });

    if (result.hasWarning && result.warningMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ringtoneFallbackSystemWarning)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.alarmSaved)));
    }
    context.pop();
  }

  Future<void> _discardDraftIfNeeded() async {
    if (_committed) return;
    final sequenceId = _voiceSequenceId;
    if (sequenceId == null) return;
    await ref
        .read(voiceSequenceProvider(sequenceId).notifier)
        .discard(hadPersistedOriginal: _hadPersistedSequence);
    ref.read(openDraftSequenceIdsProvider.notifier).update((ids) {
      final next = Set<String>.from(ids)..remove(sequenceId);
      return next;
    });
    ref.invalidate(voiceSequenceProvider(sequenceId));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _pickRingtone() async {
    final l10n = AppLocalizations.of(context);
    final ringtones = ref.read(ringtonesProvider);
    final audio = ref.read(audioPlayerServiceProvider);
    String? previewing;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> togglePreview(String name, String path) async {
              if (previewing == name) {
                await audio.stop();
                setModalState(() => previewing = null);
                return;
              }
              await audio.stop();
              setModalState(() => previewing = name);
              try {
                await audio.playAsset(path);
              } finally {
                if (context.mounted) {
                  setModalState(() {
                    if (previewing == name) previewing = null;
                  });
                }
              }
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.alarmRingtone,
                              style: context.textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.commonClose,
                            onPressed: () async {
                              await audio.stop();
                              if (context.mounted) Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        l10n.ringtonePreviewHint,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ringtones.length,
                        itemBuilder: (context, index) {
                          final ringtone = ringtones[index];
                          final selected = _ringtoneName == ringtone.name;
                          final playing = previewing == ringtone.name;
                          return ListTile(
                            title: Text(localizedRingtone(l10n, ringtone.name)),
                            selected: selected,
                            leading: Icon(
                              selected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: selected
                                  ? context.colors.primary
                                  : context.colors.onSurfaceVariant,
                            ),
                            trailing: IconButton(
                              tooltip: playing
                                  ? l10n.alarmStop
                                  : l10n.ringtonePreview,
                              onPressed: () => togglePreview(
                                ringtone.name,
                                ringtone.assetPath,
                              ),
                              icon: Icon(
                                playing
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                            ),
                            onTap: () async {
                              await audio.stop();
                              if (context.mounted) {
                                Navigator.pop(context, ringtone.name);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    await audio.stop();
    if (selected != null) setState(() => _ringtoneName = selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alarms = ref.watch(alarmListProvider);
    final sequenceId = _voiceSequenceId ?? defaultSequenceId;
    final sequence = ref.watch(voiceSequenceProvider(sequenceId));
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;
        await _discardDraftIfNeeded();
      },
      child: AppScaffold(
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
                      onTap: _pickTime,
                      emphasized: true,
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TimeFormatters.formatTime(_time),
                                  style: context.textTheme.headlineMedium
                                      ?.copyWith(letterSpacing: -1.0),
                                ),
                                Text(
                                  l10n.alarmSelectTime,
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
                    SectionHeader(title: l10n.alarmRepeat),
                    SurfacePanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          for (final day in Weekday.values)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: _DayToggle(
                                  label: switch (day) {
                                    Weekday.monday => l10n.dayMon,
                                    Weekday.tuesday => l10n.dayTue,
                                    Weekday.wednesday => l10n.dayWed,
                                    Weekday.thursday => l10n.dayThu,
                                    Weekday.friday => l10n.dayFri,
                                    Weekday.saturday => l10n.daySat,
                                    Weekday.sunday => l10n.daySun,
                                  },
                                  selected: _repeatDays.contains(day),
                                  onTap: () {
                                    setState(() {
                                      if (_repeatDays.contains(day)) {
                                        _repeatDays.remove(day);
                                      } else {
                                        _repeatDays.add(day);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                        ],
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
                    if (kIsWeb ||
                        defaultTargetPlatform != TargetPlatform.iOS) ...[
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                    ],
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
                    if (!kIsWeb &&
                        defaultTargetPlatform == TargetPlatform.iOS) ...[
                      const SizedBox(height: AppConstants.spaceXl),
                      const _IosCapabilityCard(),
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
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 40,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  label,
                  maxLines: 1,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IosCapabilityCard extends ConsumerStatefulWidget {
  const _IosCapabilityCard();

  @override
  ConsumerState<_IosCapabilityCard> createState() => _IosCapabilityCardState();
}

class _IosCapabilityCardState extends ConsumerState<_IosCapabilityCard> {
  IosAlarmCapability? _capability;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cap = await ref
          .read(notificationServiceProvider)
          .iosFanout
          .capability();
      if (!mounted) return;
      setState(() => _capability = cap);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final cap = _capability;
    // Only show the compact limited-support notice (hide while loading / full).
    if (cap == null || cap.isFullSupport) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.iosLimitedSupportTitle,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.iosLimitedSupportBody,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.iosAlarmLoudnessHint,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.iosNotificationPathHint,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.commonClose,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () => setState(() => _dismissed = true),
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

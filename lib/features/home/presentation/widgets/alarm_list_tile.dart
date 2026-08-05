import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/time_formatters.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/widgets/app_widgets.dart';
import 'alarm_formatters.dart';

class AlarmListTile extends StatelessWidget {
  const AlarmListTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.canModify = true,
  });

  final AlarmUiModel alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final bool canModify;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = !alarm.isEnabled;

    return SurfacePanel(
      onTap: canModify ? onEdit : null,
      padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  duration: AppConstants.animationFast,
                  opacity: muted ? 0.38 : 1,
                  child: Text(
                    TimeFormatters.formatTime(alarm.time),
                    style: context.textTheme.displaySmall?.copyWith(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.4,
                      height: 1.05,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alarm.label,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: muted
                        ? context.colors.onSurfaceVariant
                        : context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MetaPill(
                      icon: Icons.repeat_rounded,
                      label: formatRepeatDays(l10n, alarm.repeatDays),
                    ),
                    MetaPill(
                      icon: Icons.graphic_eq_rounded,
                      label: alarmTypeLabel(l10n, alarm.type),
                    ),
                  ],
                ),
                if (alarm.audioNeedsRegeneration) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.alarmAudioNeedsRegeneration,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.error,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Semantics(
                label: alarm.isEnabled
                    ? l10n.commonEnabled
                    : l10n.commonDisabled,
                child: Switch.adaptive(
                  value: alarm.isEnabled,
                  onChanged: (_) => onToggle(),
                ),
              ),
              PopupMenuButton<_AlarmMenuAction>(
                tooltip: l10n.homeMore,
                onSelected: (action) {
                  switch (action) {
                    case _AlarmMenuAction.edit:
                      onEdit();
                    case _AlarmMenuAction.duplicate:
                      onDuplicate();
                    case _AlarmMenuAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  if (canModify)
                    PopupMenuItem(
                      value: _AlarmMenuAction.edit,
                      child: Text(l10n.homeEdit),
                    ),
                  if (canModify)
                    PopupMenuItem(
                      value: _AlarmMenuAction.duplicate,
                      child: Text(l10n.homeDuplicate),
                    ),
                  PopupMenuItem(
                    value: _AlarmMenuAction.delete,
                    child: Text(
                      l10n.homeDelete,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _AlarmMenuAction { edit, duplicate, delete }

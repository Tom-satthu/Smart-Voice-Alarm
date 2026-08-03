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
  });

  final AlarmUiModel alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = !alarm.isEnabled;

    return SurfacePanel(
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  duration: AppConstants.animationFast,
                  opacity: muted ? 0.45 : 1,
                  child: Text(
                    TimeFormatters.formatTime(alarm.time),
                    style: context.textTheme.displaySmall?.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(
                      icon: Icons.repeat_rounded,
                      label: formatRepeatDays(l10n, alarm.repeatDays),
                    ),
                    _MetaPill(
                      icon: Icons.graphic_eq_rounded,
                      label: alarmTypeLabel(l10n, alarm.type),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch.adaptive(
                value: alarm.isEnabled,
                onChanged: (_) => onToggle(),
              ),
              PopupMenuButton<_AlarmMenuAction>(
                tooltip: 'More',
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
                  PopupMenuItem(
                    value: _AlarmMenuAction.edit,
                    child: Text(l10n.homeEdit),
                  ),
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class VoiceSegmentTile extends StatelessWidget {
  const VoiceSegmentTile({
    super.key,
    required this.segment,
    required this.index,
    required this.onDelete,
  });

  final VoiceSegmentUiModel segment;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = segment.type == VoiceSegmentType.recording
        ? l10n.voiceTypeRecording
        : l10n.voiceTypeTts;
    final typeIcon = segment.type == VoiceSegmentType.recording
        ? Icons.mic_rounded
        : Icons.record_voice_over_rounded;

    return SurfacePanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: context.colors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(typeIcon, color: context.colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(segment.name, style: context.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '$typeLabel · ${segment.duration.compact}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.voiceSequenceDelete,
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

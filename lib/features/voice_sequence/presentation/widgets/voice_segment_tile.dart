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
    required this.orderNumber,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlayStop,
    required this.onDelete,
  });

  final VoiceSegmentUiModel segment;
  final int index;
  final int orderNumber;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayStop;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = segment.type == VoiceSegmentType.recording
        ? l10n.voiceTypeRecording
        : l10n.voiceTypeTts;
    final subtitle =
        segment.type == VoiceSegmentType.tts &&
            (segment.text?.trim().isNotEmpty ?? false)
        ? segment.text!.trim()
        : segment.name;

    return SurfacePanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$orderNumber',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: context.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$typeLabel · ${segment.duration.compact}'
                  '${isPlaying ? ' · ${l10n.voicePlaying}' : ''}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: isPlaying ? l10n.alarmStop : l10n.segmentPlay,
            onPressed: isLoading ? null : onPlayStop,
            icon: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: context.colors.primary,
                  ),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.homeMore,
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.voiceSequenceDelete),
              ),
            ],
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

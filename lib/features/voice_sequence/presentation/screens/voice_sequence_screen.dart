import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/io_dir_stub.dart'
    if (dart.library.io) '../../../../core/services/io_dir_io.dart' as io_dir;
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../widgets/voice_segment_tile.dart';

class VoiceSequenceScreen extends ConsumerStatefulWidget {
  const VoiceSequenceScreen({super.key, this.sequenceId});

  final String? sequenceId;

  @override
  ConsumerState<VoiceSequenceScreen> createState() =>
      _VoiceSequenceScreenState();
}

class _VoiceSequenceScreenState extends ConsumerState<VoiceSequenceScreen> {
  String? _playingSegmentId;
  bool _loadingPreview = false;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  @override
  void deactivate() {
    ref.read(audioPlayerServiceProvider).stop();
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _stopPreview() async {
    await ref.read(audioPlayerServiceProvider).stop();
    await ref.read(ttsServiceProvider).stop();
    if (mounted) {
      setState(() {
        _playingSegmentId = null;
        _loadingPreview = false;
      });
    }
  }

  Future<void> _togglePreview(VoiceSegmentUiModel segment) async {
    final l10n = AppLocalizations.of(context);
    if (_playingSegmentId == segment.id) {
      await _stopPreview();
      return;
    }

    await _stopPreview();
    if (!mounted) return;
    setState(() {
      _playingSegmentId = segment.id;
      _loadingPreview = true;
    });

    try {
      if (segment.type == VoiceSegmentType.recording) {
        final path = segment.filePath;
        if (kIsWeb || path == null || path.isEmpty) {
          throw StateError(l10n.recordingFileMissing);
        }
        final exists = await io_dir.fileExists(path);
        if (!exists) {
          throw StateError(l10n.recordingFileMissing);
        }
        if (!mounted) return;
        setState(() => _loadingPreview = false);
        await ref.read(audioPlayerServiceProvider).playFile(path);
      } else {
        final text = segment.text?.trim() ?? '';
        if (text.isEmpty) {
          throw StateError(l10n.voiceUnavailable);
        }
        if (!mounted) return;
        setState(() => _loadingPreview = false);
        await ref.read(ttsServiceProvider).preview(
              text: text,
              voiceId: segment.voiceId,
              locale: segment.localeId,
            );
      }
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError ? error.message : '$error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted && _playingSegmentId == segment.id) {
        setState(() {
          _playingSegmentId = null;
          _loadingPreview = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(int index) async {
    final l10n = AppLocalizations.of(context);
    final segments = ref.read(voiceSequenceProvider(_sequenceId)).segments;
    if (index < 0 || index >= segments.length) return;
    final segment = segments[index];
    if (_playingSegmentId == segment.id) {
      await _stopPreview();
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.voiceSequenceDeleteConfirmTitle),
        content: Text(l10n.voiceSequenceDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonRemove),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(voiceSequenceProvider(_sequenceId).notifier).removeAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sequence = ref.watch(voiceSequenceProvider(_sequenceId));
    final segments = sequence.segments;

    return AppScaffold(
      showBack: true,
      title: l10n.voiceSequenceTitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addVoicePath(_sequenceId)),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.voiceSequenceAdd),
      ),
      body: ResponsiveCenter(
        child: segments.isEmpty
            ? EmptyStateView(
                icon: Icons.mic_none_rounded,
                title: l10n.voiceSequenceEmptyTitle,
                subtitle: l10n.voiceSequenceEmptySubtitle,
                actionLabel: l10n.voiceSequenceAdd,
                onAction: () =>
                    context.push(AppRoutes.addVoicePath(_sequenceId)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppConstants.spaceMd,
                      bottom: AppConstants.spaceSm,
                    ),
                    child: SectionHeader(
                      title: sequence.name,
                      subtitle:
                          '${l10n.segmentsLabel(segments.length)} · ${l10n.voiceSequenceReorderHint}',
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: segments.length,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMd,
                          ),
                          color: context.colors.surface,
                          child: child,
                        );
                      },
                      onReorderItem: (oldIndex, newIndex) {
                        ref
                            .read(voiceSequenceProvider(_sequenceId).notifier)
                            .reorder(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final segment = segments[index];
                        return Padding(
                          key: ValueKey(segment.id),
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spaceMd,
                          ),
                          child: VoiceSegmentTile(
                            segment: segment,
                            index: index,
                            orderNumber: index + 1,
                            isPlaying: _playingSegmentId == segment.id &&
                                !_loadingPreview,
                            isLoading: _playingSegmentId == segment.id &&
                                _loadingPreview,
                            onPlayStop: () => _togglePreview(segment),
                            onDelete: () => _confirmDelete(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AddVoiceScreen extends StatelessWidget {
  const AddVoiceScreen({super.key, this.sequenceId});

  final String? sequenceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = sequenceId ?? defaultSequenceId;

    return AppScaffold(
      showBack: true,
      title: l10n.addVoiceTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(top: AppConstants.spaceLg),
          children: [
            _ChoiceCard(
              icon: Icons.mic_rounded,
              title: l10n.addVoiceRecord,
              subtitle: l10n.addVoiceRecordSubtitle,
              onTap: () => context.push(AppRoutes.recordPath(id)),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            _ChoiceCard(
              icon: Icons.record_voice_over_rounded,
              title: l10n.addVoiceTts,
              subtitle: l10n.addVoiceTtsSubtitle,
              onTap: () => context.push(AppRoutes.ttsPath(id)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      onTap: onTap,
      emphasized: true,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: context.colors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: context.colors.primary, size: 28),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/io_dir_stub.dart'
    if (dart.library.io) '../../../../core/services/io_dir_io.dart'
    as io_dir;
import '../../../../core/services/ios_alarm_scheduler.dart';
import '../../../../core/services/saved_voice_usage_service.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../core/services/trial_entitlement_service.dart';
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
    if (!ref.read(alarmEngineProvider).isRunning) {
      ref.read(audioPlayerServiceProvider).stop();
      ref.read(ttsServiceProvider).stop();
    }
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
      final iosScheduler = ref
          .read(notificationServiceProvider)
          .iosFanout
          .scheduler;
      if (!kIsWeb && iosScheduler.isSupported) {
        final path = await _renderNormalizedPreview(
          iosScheduler,
          segment,
          l10n,
        );
        if (!mounted) return;
        setState(() => _loadingPreview = false);
        await ref.read(audioPlayerServiceProvider).playFile(path);
      } else if (segment.type == VoiceSegmentType.recording) {
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
        await ref
            .read(ttsServiceProvider)
            .preview(
              text: text,
              voiceId: segment.voiceId,
              locale: segment.localeId,
            );
      }
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError ? error.message : '$error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted && _playingSegmentId == segment.id) {
        setState(() {
          _playingSegmentId = null;
          _loadingPreview = false;
        });
      }
    }
  }

  Future<String> _renderNormalizedPreview(
    IosAlarmScheduler scheduler,
    VoiceSegmentUiModel segment,
    AppLocalizations l10n,
  ) async {
    final fileName =
        'sva_preview_${segment.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.caf';
    if (segment.type == VoiceSegmentType.tts) {
      final text = segment.text?.trim() ?? '';
      if (text.isEmpty) throw StateError(l10n.voiceUnavailable);
      final rendered = await scheduler.renderSound(
        fileName: fileName,
        ttsText: text,
        ttsLocale: segment.localeId,
        maxSeconds: 20,
      );
      if (rendered.path.isEmpty) throw StateError(l10n.audioRenderingError);
      debugPrint(
        '[SVA-Audio] previewPath=${rendered.path} file=${rendered.fileName} '
        'size=${rendered.byteSize} durationMs=${rendered.durationMs} '
        'hash=${rendered.debugHash}',
      );
      return rendered.path;
    }
    final path = segment.filePath;
    if (path == null || path.isEmpty) {
      throw StateError(l10n.recordingFileMissing);
    }
    final exists = await io_dir.fileExists(path);
    if (!exists) throw StateError(l10n.recordingFileMissing);
    final rendered = await scheduler.renderSound(
      fileName: fileName,
      sourcePath: path,
      maxSeconds: 20,
    );
    if (rendered.path.isEmpty) throw StateError(l10n.audioRenderingError);
    debugPrint(
      '[SVA-Audio] previewPath=${rendered.path} file=${rendered.fileName} '
      'size=${rendered.byteSize} durationMs=${rendered.durationMs} '
      'hash=${rendered.debugHash} source=$path',
    );
    return rendered.path;
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
      await ref
          .read(voiceSequenceProvider(_sequenceId).notifier)
          .removeAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sequence = ref.watch(voiceSequenceProvider(_sequenceId));
    final segments = sequence.segments;
    final entitlement = ref.watch(trialEntitlementProvider);

    return AppScaffold(
      showBack: true,
      title: l10n.voiceSequenceTitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addVoicePath(_sequenceId)),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.voiceSequenceAdd),
      ),
      body: ResponsiveCenter(
        child: Column(
          children: [
            if (entitlement.status == EntitlementStatus.trialActive)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spaceMd),
                child: _TrialStatusCard(entitlement: entitlement),
              ),
            Expanded(
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
                                  .read(
                                    voiceSequenceProvider(_sequenceId).notifier,
                                  )
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
                                  isPlaying:
                                      _playingSegmentId == segment.id &&
                                      !_loadingPreview,
                                  isLoading:
                                      _playingSegmentId == segment.id &&
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
          ],
        ),
      ),
    );
  }
}

class _TrialStatusCard extends StatelessWidget {
  const _TrialStatusCard({required this.entitlement});

  final TrialEntitlementState entitlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final countdown = entitlement.hasLessThanOneDay
        ? l10n.trialLessThanOneDay
        : l10n.trialDaysRemaining(entitlement.countdownDays);
    return SurfacePanel(
      emphasized: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: context.colors.primary),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(child: Text(countdown, style: context.textTheme.titleSmall)),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () => context.push(AppRoutes.premium),
            child: Text(
              l10n.premiumUpgrade,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class AddVoiceScreen extends ConsumerStatefulWidget {
  const AddVoiceScreen({super.key, this.sequenceId});

  final String? sequenceId;

  @override
  ConsumerState<AddVoiceScreen> createState() => _AddVoiceScreenState();
}

class _AddVoiceScreenState extends ConsumerState<AddVoiceScreen> {
  String? _previewId;
  bool _previewLoading = false;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  bool get _hasSequenceContext =>
      widget.sequenceId != null && widget.sequenceId!.trim().isNotEmpty;

  Future<void> _stopPreview() async {
    await ref.read(audioPlayerServiceProvider).stop();
    await ref.read(ttsServiceProvider).stop();
    if (mounted) {
      setState(() {
        _previewId = null;
        _previewLoading = false;
      });
    }
  }

  Future<void> _addSavedVoiceToSequence(VoiceSegmentUiModel voice) async {
    if (!_hasSequenceContext) return;
    final sequenceId = widget.sequenceId!;
    final beforeCount = ref
        .read(voiceSequenceProvider(sequenceId))
        .segments
        .length;
    await ref
        .read(voiceSequenceProvider(sequenceId).notifier)
        .addExistingSavedVoice(voice);
    final after = ref.read(voiceSequenceProvider(sequenceId));
    if (!mounted) return;
    if (after.segments.length != beforeCount + 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).audioRenderingError),
        ),
      );
      return;
    }
    context.pop();
  }

  Future<String> _renderNormalizedPreview(
    IosAlarmScheduler scheduler,
    VoiceSegmentUiModel segment,
    AppLocalizations l10n,
  ) async {
    final fileName =
        'sva_preview_${segment.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.caf';
    if (segment.type == VoiceSegmentType.tts) {
      final text = segment.text?.trim() ?? '';
      if (text.isEmpty) throw StateError(l10n.voiceUnavailable);
      final rendered = await scheduler.renderSound(
        fileName: fileName,
        ttsText: text,
        ttsLocale: segment.localeId,
        maxSeconds: 20,
      );
      if (rendered.path.isEmpty) throw StateError(l10n.audioRenderingError);
      debugPrint(
        '[SVA-Audio] previewPath=${rendered.path} file=${rendered.fileName} '
        'size=${rendered.byteSize} durationMs=${rendered.durationMs} '
        'hash=${rendered.debugHash}',
      );
      return rendered.path;
    }
    final path = segment.filePath;
    if (path == null || path.isEmpty) {
      throw StateError(l10n.recordingFileMissing);
    }
    final exists = await io_dir.fileExists(path);
    if (!exists) throw StateError(l10n.recordingFileMissing);
    final rendered = await scheduler.renderSound(
      fileName: fileName,
      sourcePath: path,
      maxSeconds: 20,
    );
    if (rendered.path.isEmpty) throw StateError(l10n.audioRenderingError);
    debugPrint(
      '[SVA-Audio] previewPath=${rendered.path} file=${rendered.fileName} '
      'size=${rendered.byteSize} durationMs=${rendered.durationMs} '
      'hash=${rendered.debugHash} source=$path',
    );
    return rendered.path;
  }

  Future<void> _togglePreview(VoiceSegmentUiModel voice) async {
    final l10n = AppLocalizations.of(context);
    if (_previewId == voice.id) {
      await _stopPreview();
      return;
    }
    await _stopPreview();
    if (!mounted) return;
    setState(() {
      _previewId = voice.id;
      _previewLoading = true;
    });
    try {
      final iosScheduler = ref
          .read(notificationServiceProvider)
          .iosFanout
          .scheduler;
      if (!kIsWeb && iosScheduler.isSupported) {
        final path = await _renderNormalizedPreview(iosScheduler, voice, l10n);
        if (!mounted) return;
        setState(() => _previewLoading = false);
        await ref.read(audioPlayerServiceProvider).playFile(path);
      } else if (voice.type == VoiceSegmentType.recording) {
        final path = voice.filePath;
        if (kIsWeb || path == null || path.isEmpty) {
          throw StateError(l10n.recordingFileMissing);
        }
        final exists = await io_dir.fileExists(path);
        if (!exists) throw StateError(l10n.recordingFileMissing);
        if (!mounted) return;
        setState(() => _previewLoading = false);
        await ref.read(audioPlayerServiceProvider).playFile(path);
      } else {
        final text = voice.text?.trim() ?? '';
        if (text.isEmpty) throw StateError(l10n.voiceUnavailable);
        if (!mounted) return;
        setState(() => _previewLoading = false);
        await ref
            .read(ttsServiceProvider)
            .preview(
              text: text,
              voiceId: voice.voiceId,
              locale: voice.localeId,
            );
      }
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError ? error.message : '$error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted && _previewId == voice.id) {
        setState(() {
          _previewId = null;
          _previewLoading = false;
        });
      }
    }
  }

  String _formatCreatedAt(BuildContext context, DateTime? createdAt) {
    if (createdAt == null) return '';
    final local = createdAt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  @override
  void deactivate() {
    if (!ref.read(alarmEngineProvider).isRunning) {
      ref.read(audioPlayerServiceProvider).stop();
      ref.read(ttsServiceProvider).stop();
    }
    super.deactivate();
  }

  Future<void> _deleteSavedVoice(VoiceSegmentUiModel voice) async {
    final l10n = AppLocalizations.of(context);
    final draftIds = ref.read(openDraftSequenceIdsProvider);
    final sequence = ref.read(voiceSequenceProvider(_sequenceId));
    final inOpenDraft = sequence.segments.any(
      (s) => s.sourceSavedVoiceId == voice.id || s.id == voice.id,
    );
    final usage = SavedVoiceUsageService(draftSequenceIds: draftIds)
        .usageForWithDraftPresence(
          voice.id,
          inOpenDraft: inOpenDraft && draftIds.contains(_sequenceId),
          openDraftSequenceId: _sequenceId,
        );

    if (usage.activeAlarmIds.isNotEmpty) {
      final body = usage.usageCount == 1
          ? l10n.savedVoiceInUseBodyOne
          : l10n.savedVoiceInUseBodyMany(usage.usageCount);
      final view = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.savedVoiceInUseTitle),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonClose),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.savedVoiceViewAlarms),
            ),
          ],
        ),
      );
      if (view == true && mounted) {
        // Push so Create Alarm / sequence draft stays on the stack.
        await context.push(AppRoutes.savedVoiceUsagePath(voice.id));
      }
      return;
    }

    if (usage.isInOpenDraft) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.savedVoiceInUseTitle),
          content: Text(l10n.savedVoiceInOpenDraftBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.savedVoiceDeleteTitle),
        content: Text(l10n.savedVoiceDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.savedVoiceDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await SavedVoiceUsageService(
      draftSequenceIds: draftIds,
    ).deleteUnused(voice);
    await ref.read(savedVoicesProvider.notifier).refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.savedVoiceDeleted : l10n.savedVoiceInUseTitle),
      ),
    );
  }

  Future<void> _openCleanupUnused() async {
    final l10n = AppLocalizations.of(context);
    final service = SavedVoiceUsageService();
    final unused = service.unusedVoices();
    if (unused.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.savedVoiceCleanupEmpty)));
      return;
    }
    final selected = <String>{for (final v in unused) v.id};
    final bytes = await service.estimateRecordingBytes(unused);
    if (!mounted) return;
    final sizeLabel = bytes >= 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).ceil()} KB';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.savedVoiceCleanupTitle),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.savedVoiceCleanupSubtitle),
                    const SizedBox(height: 8),
                    Text(l10n.savedVoiceCleanupBytes(sizeLabel)),
                    TextButton(
                      onPressed: () => setLocal(() {
                        selected
                          ..clear()
                          ..addAll(unused.map((v) => v.id));
                      }),
                      child: Text(l10n.savedVoiceSelectAll),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final voice in unused)
                            CheckboxListTile(
                              value: selected.contains(voice.id),
                              onChanged: (on) => setLocal(() {
                                if (on == true) {
                                  selected.add(voice.id);
                                } else {
                                  selected.remove(voice.id);
                                }
                              }),
                              title: Text(voice.name),
                              dense: true,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(context, true),
                  child: Text(l10n.savedVoiceCleanupConfirm(selected.length)),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true) return;
    for (final voice in unused.where((v) => selected.contains(v.id))) {
      await service.deleteUnused(voice);
    }
    await ref.read(savedVoicesProvider.notifier).refresh();
  }

  Future<void> _onSavedVoiceMenu(
    VoiceSegmentUiModel voice,
    String action,
  ) async {
    switch (action) {
      case 'preview':
        await _togglePreview(voice);
      case 'add':
        await _addSavedVoiceToSequence(voice);
      case 'delete':
        await _deleteSavedVoice(voice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(savedVoicesProvider);

    return AppScaffold(
      showBack: true,
      title: l10n.addVoiceTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppConstants.spaceLg,
            bottom: AppConstants.space2xl,
          ),
          children: [
            _ChoiceCard(
              icon: Icons.mic_rounded,
              title: l10n.addVoiceRecord,
              subtitle: l10n.addVoiceRecordSubtitle,
              onTap: () async {
                await context.push(AppRoutes.recordPath(_sequenceId));
                await ref.read(savedVoicesProvider.notifier).refresh();
              },
            ),
            const SizedBox(height: AppConstants.spaceMd),
            _ChoiceCard(
              icon: Icons.record_voice_over_rounded,
              title: l10n.addVoiceTts,
              subtitle: l10n.addVoiceTtsSubtitle,
              onTap: () async {
                await context.push(AppRoutes.ttsPath(_sequenceId));
                await ref.read(savedVoicesProvider.notifier).refresh();
              },
            ),
            const SizedBox(height: AppConstants.spaceXl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.savedVoicesTitle,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: _openCleanupUnused,
                  child: Text(l10n.savedVoiceCleanupTitle),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            if (saved.isEmpty)
              Text(
                l10n.savedVoicesEmpty,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              )
            else
              ...saved.map((voice) {
                final playing = _previewId == voice.id && !_previewLoading;
                final loading = _previewId == voice.id && _previewLoading;
                final stamped = _formatCreatedAt(context, voice.createdAt);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                  child: SurfacePanel(
                    child: Row(
                      children: [
                        Icon(
                          voice.type == VoiceSegmentType.recording
                              ? Icons.mic_rounded
                              : Icons.record_voice_over_rounded,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voice.name,
                                style: context.textTheme.titleSmall,
                              ),
                              Text(
                                stamped.isEmpty
                                    ? '${voice.duration.inSeconds}s'
                                    : '${voice.duration.inSeconds}s · $stamped',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontSize: 11.5,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: playing
                              ? l10n.commonClose
                              : l10n.savedVoicePreviewAction,
                          onPressed: () => _togglePreview(voice),
                          icon: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  playing
                                      ? Icons.stop_circle_outlined
                                      : Icons.play_circle_outline_rounded,
                                  color: context.colors.primary,
                                ),
                        ),
                        if (_hasSequenceContext)
                          IconButton(
                            tooltip: l10n.addSavedVoiceToSequence,
                            onPressed: () => _addSavedVoiceToSequence(voice),
                            icon: Icon(
                              Icons.add_circle_outline_rounded,
                              color: context.colors.primary,
                            ),
                          ),
                        PopupMenuButton<String>(
                          tooltip: l10n.homeMore,
                          onSelected: (value) =>
                              _onSavedVoiceMenu(voice, value),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'preview',
                              child: Text(l10n.savedVoicePreviewAction),
                            ),
                            if (_hasSequenceContext)
                              PopupMenuItem(
                                value: 'add',
                                child: Text(l10n.addSavedVoiceToSequence),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.savedVoiceDeleteAction),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';

class TtsScreen extends ConsumerStatefulWidget {
  const TtsScreen({super.key, this.sequenceId});

  final String? sequenceId;

  @override
  ConsumerState<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends ConsumerState<TtsScreen> {
  final _controller = TextEditingController();
  String? _selectedVoiceId;
  String? _selectedLocale;
  bool _previewing = false;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _previewing = true);
    try {
      await ref.read(ttsServiceProvider).preview(
            text: text,
            voiceId: _selectedVoiceId,
            locale: _selectedLocale,
          );
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await ref.read(voiceSequenceProvider(_sequenceId).notifier).add(
          VoiceSegmentUiModel(
            id: const Uuid().v4(),
            name: text.length > 28 ? '${text.substring(0, 28)}…' : text,
            type: VoiceSegmentType.tts,
            duration: Duration(
              seconds: (text.split(RegExp(r'\s+')).length * 0.4).ceil().clamp(
                    3,
                    60,
                  ),
            ),
            text: text,
            voiceId: _selectedVoiceId,
            localeId: _selectedLocale ?? 'en-US',
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ttsSaved)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.voiceSequencePath(_sequenceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicesAsync = ref.watch(ttsVoicesProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppScaffold(
      showBack: true,
      title: l10n.ttsTitle,
      resizeToAvoidBottomInset: true,
      body: ResponsiveCenter(
        child: voicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.ttsVoices)),
          data: (voices) {
            _selectedVoiceId ??= voices.first.id;
            _selectedLocale ??= voices.first.locale;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: AppConstants.spaceMd,
                      bottom: 16 + bottomInset,
                    ),
                    children: [
                      SectionHeader(title: l10n.ttsInputLabel),
                      TextField(
                        controller: _controller,
                        maxLines: 5,
                        minLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration:
                            InputDecoration(hintText: l10n.ttsInputHint),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      SectionHeader(title: l10n.ttsVoices),
                      for (final voice in voices)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spaceSm,
                          ),
                          child: SurfacePanel(
                            onTap: () => setState(() {
                              _selectedVoiceId = voice.id;
                              _selectedLocale = voice.locale;
                            }),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedVoiceId == voice.id
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: _selectedVoiceId == voice.id
                                      ? context.colors.primary
                                      : context.colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        voice.name,
                                        style: context.textTheme.titleSmall,
                                      ),
                                      Text(
                                        voice.locale,
                                        style: context.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                StickyBottomBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              _previewing || _controller.text.trim().isEmpty
                                  ? null
                                  : _preview,
                          icon: _previewing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            _previewing ? l10n.ttsPreviewing : l10n.ttsPreview,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _controller.text.trim().isEmpty ? null : _save,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(l10n.ttsSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, this.sequenceId});

  final String? sequenceId;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

enum _RecordPhase { idle, recording, ready, playing }

class _RecordScreenState extends ConsumerState<RecordScreen> {
  _RecordPhase _phase = _RecordPhase.idle;
  Duration _elapsed = Duration.zero;
  String? _filePath;
  Timer? _ticker;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recordHint)),
      );
      return;
    }

    try {
      final recorder = ref.read(recordingServiceProvider);
      await recorder.start();
      _filePath = recorder.currentPath;
      setState(() {
        _phase = _RecordPhase.recording;
        _elapsed = Duration.zero;
      });
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted || _phase != _RecordPhase.recording) return;
        setState(() => _elapsed = recorder.elapsed);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> _stop() async {
    if (_phase != _RecordPhase.recording) return;
    _ticker?.cancel();
    final path = await ref.read(recordingServiceProvider).stop();
    setState(() {
      _filePath = path ?? _filePath;
      _phase = _RecordPhase.ready;
    });
  }

  Future<void> _play() async {
    final path = _filePath;
    if (path == null) return;
    if (_phase != _RecordPhase.ready && _phase != _RecordPhase.playing) {
      return;
    }
    setState(() => _phase = _RecordPhase.playing);
    try {
      await ref.read(audioPlayerServiceProvider).playFile(path);
    } finally {
      if (mounted) setState(() => _phase = _RecordPhase.ready);
    }
  }

  Future<void> _delete() async {
    await ref.read(recordingServiceProvider).cancel();
    await ref.read(audioPlayerServiceProvider).stop();
    setState(() {
      _phase = _RecordPhase.idle;
      _elapsed = Duration.zero;
      _filePath = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final path = _filePath;
    if (path == null) return;

    await ref.read(voiceSequenceProvider(_sequenceId).notifier).add(
          VoiceSegmentUiModel(
            id: const Uuid().v4(),
            name: l10n.recordDefaultName,
            type: VoiceSegmentType.recording,
            duration: _elapsed == Duration.zero
                ? const Duration(seconds: 1)
                : _elapsed,
            filePath: path,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.recordSaved)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.voiceSequencePath(_sequenceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRecording = _phase == _RecordPhase.recording;
    final canSave =
        _phase == _RecordPhase.ready || _phase == _RecordPhase.playing;

    return AppScaffold(
      showBack: true,
      title: l10n.recordTitle,
      body: AmbientBackground(
        child: ResponsiveCenter(
          child: Column(
            children: [
              const Spacer(),
              Text(
                switch (_phase) {
                  _RecordPhase.idle => l10n.recordHint,
                  _RecordPhase.recording => l10n.recordRecording,
                  _RecordPhase.ready => l10n.recordReady,
                  _RecordPhase.playing => l10n.recordPlaying,
                },
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Text(_elapsed.mmss, style: context.textTheme.displayMedium),
              const SizedBox(height: AppConstants.spaceXl),
              WaveVisualizer(
                active: isRecording || _phase == _RecordPhase.playing,
              ),
              const Spacer(),
              _RoundAction(
                icon: isRecording
                    ? Icons.stop_rounded
                    : Icons.fiber_manual_record_rounded,
                label: isRecording ? l10n.recordStop : l10n.recordStart,
                color: isRecording
                    ? context.colors.error
                    : context.colors.primary,
                onTap: isRecording ? _stop : _start,
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canSave ? _play : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.recordPlay),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canSave ? _save : null,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.recordSave),
                    ),
                  ),
                ],
              ),
              if (canSave) ...[
                const SizedBox(height: AppConstants.spaceMd),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.commonRemove),
                ),
              ],
              const SizedBox(height: AppConstants.space2xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 92,
              height: 92,
              child: Icon(icon, color: Colors.white, size: 38),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: context.textTheme.labelLarge),
      ],
    );
  }
}

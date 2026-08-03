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
  const TtsScreen({super.key});

  @override
  ConsumerState<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends ConsumerState<TtsScreen> {
  final _controller = TextEditingController();
  String? _selectedVoiceId;
  bool _previewing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    if (_controller.text.trim().isEmpty || _selectedVoiceId == null) return;
    setState(() => _previewing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (mounted) setState(() => _previewing = false);
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedVoiceId == null) return;

    ref
        .read(voiceSequenceProvider.notifier)
        .add(
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
          ),
        );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ttsSaved)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.voiceSequence);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voices = ref.watch(ttsVoicesProvider);
    _selectedVoiceId ??= voices.first.id;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppScaffold(
      showBack: true,
      title: l10n.ttsTitle,
      resizeToAvoidBottomInset: true,
      body: ResponsiveCenter(
        child: Column(
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
                    decoration: InputDecoration(hintText: l10n.ttsInputHint),
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
                        onTap: () =>
                            setState(() => _selectedVoiceId = voice.id),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                      onPressed: _previewing || _controller.text.trim().isEmpty
                          ? null
                          : _preview,
                      icon: _previewing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                      onPressed: _controller.text.trim().isEmpty ? null : _save,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.ttsSave),
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

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

enum _RecordPhase { idle, recording, ready, playing }

class _RecordScreenState extends ConsumerState<RecordScreen> {
  _RecordPhase _phase = _RecordPhase.idle;
  Duration _elapsed = Duration.zero;

  Future<void> _start() async {
    setState(() {
      _phase = _RecordPhase.recording;
      _elapsed = Duration.zero;
    });
    for (
      var i = 0;
      i < 50 && mounted && _phase == _RecordPhase.recording;
      i++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted || _phase != _RecordPhase.recording) return;
      setState(() => _elapsed = Duration(milliseconds: (i + 1) * 100));
    }
    if (mounted && _phase == _RecordPhase.recording) {
      setState(() => _phase = _RecordPhase.ready);
    }
  }

  void _stop() {
    if (_phase == _RecordPhase.recording) {
      setState(() => _phase = _RecordPhase.ready);
    }
  }

  Future<void> _play() async {
    if (_phase != _RecordPhase.ready && _phase != _RecordPhase.playing) {
      return;
    }
    setState(() => _phase = _RecordPhase.playing);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _phase = _RecordPhase.ready);
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    ref
        .read(voiceSequenceProvider.notifier)
        .add(
          VoiceSegmentUiModel(
            id: const Uuid().v4(),
            name: l10n.recordDefaultName,
            type: VoiceSegmentType.recording,
            duration: _elapsed == Duration.zero
                ? const Duration(seconds: 4)
                : _elapsed,
          ),
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.recordSaved)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.voiceSequence);
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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_display_names.dart';
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

class _TtsScreenState extends ConsumerState<TtsScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  String? _selectedVoiceId;
  String? _selectedLocale;
  bool _previewing = false;
  bool _hydratedVoice = false;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(usableTtsVoicesProvider);
      ref.invalidate(ttsVoicesProvider);
    }
  }

  Future<void> _ensureVoiceSelection(List<TtsVoiceUiModel> voices) async {
    if (_hydratedVoice || voices.isEmpty) return;
    _hydratedVoice = true;
    final preferred = ref.read(preferredVoiceProvider);
    final resolved = _pickVoice(
      voices,
      preferredId: _selectedVoiceId ?? preferred.id,
      preferredLocale: _selectedLocale ?? preferred.locale,
    );
    if (!mounted) return;
    setState(() {
      _selectedVoiceId = resolved.id;
      _selectedLocale = resolved.locale;
    });
    if (preferred.id != null && preferred.id != resolved.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).ttsVoiceFallback),
        ),
      );
    }
  }

  TtsVoiceUiModel _pickVoice(
    List<TtsVoiceUiModel> voices, {
    String? preferredId,
    String? preferredLocale,
  }) {
    if (preferredId != null) {
      for (final voice in voices) {
        if (voice.id == preferredId) return voice;
      }
    }
    final locale = preferredLocale ?? 'en-US';
    for (final voice in voices) {
      if (voice.locale.toLowerCase() == locale.toLowerCase()) return voice;
    }
    return voices.first;
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

    final voices = await ref.read(usableTtsVoicesProvider.future);
    final resolved = voices.isEmpty
        ? TtsVoiceUiModel(
            id: 'default|en-US',
            name: l10n.voiceSystemDefault,
            locale: 'en-US',
          )
        : _pickVoice(
            voices,
            preferredId: _selectedVoiceId,
            preferredLocale: _selectedLocale,
          );

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
            voiceId: resolved.id,
            localeId: resolved.locale,
          ),
        );

    await ref.read(preferredVoiceProvider.notifier).setVoice(
          id: resolved.id,
          locale: resolved.locale,
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

  String? _qualityLabel(AppLocalizations l10n, TtsVoiceQuality? quality) {
    if (quality == null) return null;
    return switch (quality) {
      TtsVoiceQuality.defaultQuality => l10n.voiceQualityDefault,
      TtsVoiceQuality.enhanced => l10n.voiceQualityEnhanced,
      TtsVoiceQuality.premium => l10n.voiceQualityPremium,
    };
  }

  String _voiceDisplayName(AppLocalizations l10n, TtsVoiceUiModel voice) {
    if (voice.id.startsWith('default|') || voice.name == 'System Default') {
      return l10n.voiceSystemDefault;
    }
    return voice.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicesAsync = ref.watch(usableTtsVoicesProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppScaffold(
      showBack: true,
      title: l10n.ttsTitle,
      resizeToAvoidBottomInset: true,
      body: ResponsiveCenter(
        child: voicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.ttsNoVoicesTitle)),
          data: (voices) {
            if (voices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.spaceXl),
                child: EmptyStateView(
                  icon: Icons.record_voice_over_outlined,
                  title: l10n.ttsNoVoicesTitle,
                  subtitle: l10n.ttsNoVoicesBody,
                  actionLabel: l10n.ttsOpenVoiceSettings,
                  onAction: () => context.push(AppRoutes.voiceSpeech),
                ),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _ensureVoiceSelection(voices);
            });
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
                            emphasized: _selectedVoiceId == voice.id,
                            onTap: () => setState(() {
                              _selectedVoiceId = voice.id;
                              _selectedLocale = voice.locale;
                            }),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
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
                                  child: VoiceIdentityBlock(
                                    languageLabel: LocaleDisplayNames.friendly(
                                      voice.locale,
                                    ),
                                    voiceName: _voiceDisplayName(l10n, voice),
                                    qualityLabel: _qualityLabel(
                                      l10n,
                                      voice.quality,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.voiceSpeech),
                        child: Text(l10n.ttsOpenVoiceSettings),
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

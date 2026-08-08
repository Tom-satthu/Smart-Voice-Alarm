import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_display_names.dart';
import '../../../../core/localization/voice_catalog.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/recording_limits.dart';
import '../../../../core/services/recording_service.dart';
import '../../../../core/services/tts_text_limits.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';
import '../../../../shared/widgets/voice_browser.dart';

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
  String? _selectedVoiceName;
  TtsVoiceQuality? _selectedQuality;
  bool _previewing = false;
  bool _saving = false;
  bool _hydratedVoice = false;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  int get _maxChars => TtsTextLimits.maxCharsForLocale(_selectedLocale);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    if (!ref.read(alarmEngineProvider).isRunning) {
      ref.read(ttsServiceProvider).stop();
    }
    super.deactivate();
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
    final fellBack = preferred.id != null && preferred.id != resolved.id;
    setState(() {
      _selectedVoiceId = resolved.id;
      _selectedLocale = resolved.locale;
      _selectedVoiceName = resolved.name;
      _selectedQuality = resolved.quality;
    });
    if (fellBack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).ttsVoiceFallback)),
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
    final lang = locale.split(RegExp('[-_]')).first.toLowerCase();
    for (final voice in voices) {
      if (voice.locale.toLowerCase().startsWith(lang)) return voice;
    }
    return voices.first;
  }

  String? _qualityLabel(AppLocalizations l10n, TtsVoiceQuality? quality) {
    if (quality == null) return null;
    return switch (quality) {
      TtsVoiceQuality.defaultQuality => l10n.voiceQualityDefault,
      TtsVoiceQuality.enhanced => l10n.voiceQualityEnhanced,
      TtsVoiceQuality.premium => l10n.voiceQualityPremium,
    };
  }

  Future<void> _openVoicePicker(List<TtsVoiceUiModel> voices) async {
    await ref.read(ttsServiceProvider).stop();
    if (!mounted) return;
    final picked = await showVoicePicker(
      context: context,
      voices: voices,
      selectedVoiceId: _selectedVoiceId,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedVoiceId = picked.id;
      _selectedLocale = picked.locale;
      _selectedVoiceName = picked.name;
      _selectedQuality = picked.quality;
      final max = TtsTextLimits.maxCharsForLocale(picked.locale);
      if (_controller.text.characters.length > max) {
        _controller.text = _controller.text.characters.take(max).toString();
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
    });
  }

  void _onTextChanged(String value) {
    final max = _maxChars;
    if (value.characters.length > max) {
      final clipped = value.characters.take(max).toString();
      _controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).ttsCharLimitReached),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final pasted = data?.text;
    if (pasted == null || pasted.isEmpty || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final max = _maxChars;
    final current = _controller.text;
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : current.length;
    final end = selection.isValid ? selection.end : current.length;
    final before = current.substring(0, start.clamp(0, current.length));
    final after = current.substring(end.clamp(0, current.length));
    final room = max - (before.characters.length + after.characters.length);
    if (pasted.characters.length <= room) {
      final next = before + pasted + after;
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: (before + pasted).length),
      );
      setState(() {});
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ttsPasteTooLongTitle),
        content: Text(l10n.ttsPasteTooLongBody(max)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.ttsPasteInsertPartial),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final allowed = pasted.characters.take(room.clamp(0, max)).toString();
    final next = before + allowed + after;
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: (before + allowed).length),
    );
    setState(() {});
  }

  Future<void> _preview() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_previewing) {
      await ref.read(ttsServiceProvider).stop();
      if (mounted) setState(() => _previewing = false);
      return;
    }
    setState(() => _previewing = true);
    try {
      await ref
          .read(ttsServiceProvider)
          .preview(
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
    if (text.isEmpty || _saving) return;
    if (text.characters.length > _maxChars) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ttsCharLimitReached)));
      return;
    }

    setState(() => _saving = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ttsDurationChecking)));

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final measure = await ref
            .read(notificationServiceProvider)
            .iosFanout
            .scheduler
            .measureTtsDuration(
              text: text,
              locale: _selectedLocale,
              maxSeconds: kMaxTtsSoundSeconds,
            );
        if (measure['withinLimit'] != true) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.ttsTooLongDuration)));
          return;
        }
      }

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

      final estimatedSeconds = (text.split(RegExp(r'\s+')).length * 0.4)
          .ceil()
          .clamp(3, 20);

      await ref
          .read(voiceSequenceProvider(_sequenceId).notifier)
          .add(
            VoiceSegmentUiModel(
              id: const Uuid().v4(),
              name: text.length > 28 ? '${text.substring(0, 28)}…' : text,
              type: VoiceSegmentType.tts,
              duration: Duration(seconds: estimatedSeconds),
              text: text,
              voiceId: resolved.id,
              localeId: resolved.locale,
              createdAt: DateTime.now(),
            ),
          );
      await ref.read(savedVoicesProvider.notifier).refresh();

      await ref
          .read(preferredVoiceProvider.notifier)
          .setVoice(
            id: resolved.id,
            locale: resolved.locale,
            language: VoiceCatalog.languageCodeOf(resolved.locale),
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicesAsync = ref.watch(usableTtsVoicesProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final used = _controller.text.characters.length;
    final max = _maxChars;

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
            final voiceLabel = _selectedVoiceName == null
                ? l10n.voiceSelect
                : (_selectedVoiceName == 'System Default'
                      ? l10n.voiceSystemDefault
                      : _selectedVoiceName!);
            final quality = _qualityLabel(l10n, _selectedQuality);
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
                        maxLength: max,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: l10n.ttsInputHint,
                          counterText: l10n.ttsCharCounter(used, max),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(max),
                        ],
                        contextMenuBuilder: (context, editableTextState) {
                          final items = editableTextState.contextMenuButtonItems
                              .where(
                                (item) =>
                                    item.type != ContextMenuButtonType.paste,
                              )
                              .toList();
                          items.add(
                            ContextMenuButtonItem(
                              onPressed: () {
                                editableTextState.hideToolbar();
                                unawaited(_handlePaste());
                              },
                              label: MaterialLocalizations.of(
                                context,
                              ).pasteButtonLabel,
                            ),
                          );
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            buttonItems: items,
                            anchors: editableTextState.contextMenuAnchors,
                          );
                        },
                        onChanged: _onTextChanged,
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      SectionHeader(title: l10n.ttsSelectedVoice),
                      SurfacePanel(
                        onTap: () => _openVoicePicker(voices),
                        emphasized: true,
                        child: Row(
                          children: [
                            Icon(
                              Icons.record_voice_over_rounded,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: VoiceIdentityBlock(
                                languageLabel: LocaleDisplayNames.friendly(
                                  _selectedLocale ?? 'en-US',
                                ),
                                voiceName: voiceLabel,
                                qualityLabel: quality,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ],
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
                          onPressed: _controller.text.trim().isEmpty || _saving
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
                              : Icon(
                                  _previewing
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                          label: Text(
                            _previewing ? l10n.voicePlaying : l10n.ttsPreview,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _controller.text.trim().isEmpty || _saving
                              ? null
                              : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
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

class _RecordScreenState extends ConsumerState<RecordScreen>
    with WidgetsBindingObserver {
  _RecordPhase _phase = _RecordPhase.idle;
  Duration _elapsed = Duration.zero;
  String? _filePath;
  Timer? _ticker;
  bool _autoStopped = false;
  bool _sourceLongerThanLimit = false;

  String get _sequenceId => widget.sequenceId ?? defaultSequenceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    if (!ref.read(alarmEngineProvider).isRunning) {
      ref.read(audioPlayerServiceProvider).stop();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    unawaited(_abandonUnsavedRecording());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_cancelForBackground());
    }
  }

  Future<void> _abandonUnsavedRecording() async {
    await ref.read(audioPlayerServiceProvider).stop();
    await ref.read(recordingServiceProvider).cancel();
  }

  Future<void> _cancelForBackground() async {
    if (_phase != _RecordPhase.recording) return;
    _ticker?.cancel();
    await _abandonUnsavedRecording();
    if (!mounted) return;
    setState(() {
      _phase = _RecordPhase.idle;
      _elapsed = Duration.zero;
      _filePath = null;
      _autoStopped = false;
    });
  }

  Future<bool> _requestMicrophoneAccess() async {
    final recorder = ref.read(recordingServiceProvider);
    final current = await recorder.microphoneAccess();
    if (current == MicrophoneAccess.granted) return true;
    if (!mounted) return false;

    if (current == MicrophoneAccess.permanentlyDenied ||
        current == MicrophoneAccess.restricted) {
      return _showMicrophoneBlocked(permanent: true);
    }

    final l10n = AppLocalizations.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recordPermissionTitle),
        content: Text(l10n.recordPermissionRationale),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.recordStart),
          ),
        ],
      ),
    );
    if (proceed != true) return false;

    final requested = await recorder.microphoneAccess(request: true);
    if (requested == MicrophoneAccess.granted) return true;
    if (!mounted) return false;
    return _showMicrophoneBlocked(
      permanent:
          requested == MicrophoneAccess.permanentlyDenied ||
          requested == MicrophoneAccess.restricted,
    );
  }

  Future<bool> _showMicrophoneBlocked({required bool permanent}) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recordPermissionTitle),
        content: Text(
          permanent
              ? l10n.recordPermissionPermanentlyDenied
              : l10n.recordPermissionDenied,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          if (permanent)
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: Text(l10n.openSystemSettings),
            ),
        ],
      ),
    );
    return false;
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recordHint)));
      return;
    }

    try {
      final recorder = ref.read(recordingServiceProvider);
      await ref.read(audioPlayerServiceProvider).stop();
      if (!await _requestMicrophoneAccess()) return;
      await recorder.start();
      _filePath = recorder.currentPath;
      _autoStopped = false;
      setState(() {
        _phase = _RecordPhase.recording;
        _elapsed = Duration.zero;
        _sourceLongerThanLimit = false;
      });
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted || _phase != _RecordPhase.recording) return;
        final elapsed = recorder.elapsed;
        setState(() => _elapsed = elapsed);
        if (elapsed >= kMaxRecordingDuration &&
            recorder.status == RecordingStatus.recording) {
          unawaited(_stop(auto: true));
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _stop({bool auto = false}) async {
    if (_phase != _RecordPhase.recording) return;
    _ticker?.cancel();
    try {
      final path = await ref.read(recordingServiceProvider).stop();
      if (!mounted) return;
      setState(() {
        _filePath = path ?? _filePath;
        _phase = _RecordPhase.ready;
        _elapsed = _elapsed > kMaxRecordingDuration
            ? kMaxRecordingDuration
            : _elapsed;
        _autoStopped = auto;
        if (auto) {
          _elapsed = kMaxRecordingDuration;
        }
      });
      if (auto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).recordAutoStopped),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _filePath = null;
        _phase = _RecordPhase.idle;
        _elapsed = Duration.zero;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).recordReady)),
      );
    }
  }

  Future<void> _play() async {
    final path = _filePath;
    if (path == null) return;
    if (_phase == _RecordPhase.playing) {
      await ref.read(audioPlayerServiceProvider).stop();
      if (mounted) setState(() => _phase = _RecordPhase.ready);
      return;
    }
    if (_phase != _RecordPhase.ready) return;
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
      _autoStopped = false;
      _sourceLongerThanLimit = false;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final path = _filePath;
    if (path == null) return;

    await ref
        .read(voiceSequenceProvider(_sequenceId).notifier)
        .add(
          VoiceSegmentUiModel(
            id: const Uuid().v4(),
            name: l10n.recordDefaultName,
            type: VoiceSegmentType.recording,
            duration: _elapsed == Duration.zero
                ? const Duration(seconds: 1)
                : _elapsed,
            filePath: path,
            createdAt: DateTime.now(),
          ),
        );
    await ref.read(savedVoicesProvider.notifier).refresh();
    ref.read(recordingServiceProvider).retainCurrentFile();
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
    final usedSec = (_elapsed.inMilliseconds / 1000).ceil().clamp(
      0,
      kMaxRecordingDuration.inSeconds,
    );
    final maxSec = kMaxRecordingDuration.inSeconds;

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
              Text(
                l10n.recordTimerLabel(usedSec, maxSec),
                style: context.textTheme.displayMedium,
              ),
              if (_autoStopped || _sourceLongerThanLimit) ...[
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  l10n.recordLongClipWarning,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],
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
                onTap: isRecording ? () => unawaited(_stop()) : _start,
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canSave ? _play : null,
                      icon: Icon(
                        _phase == _RecordPhase.playing
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        _phase == _RecordPhase.playing
                            ? l10n.alarmStop
                            : l10n.recordPlay,
                      ),
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

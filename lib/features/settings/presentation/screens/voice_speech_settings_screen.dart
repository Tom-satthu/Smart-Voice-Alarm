import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_display_names.dart';
import '../../../../core/localization/voice_catalog.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/tts_platform_bridge.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/voice_browser.dart';

class VoiceSpeechSettingsScreen extends ConsumerStatefulWidget {
  const VoiceSpeechSettingsScreen({super.key});

  @override
  ConsumerState<VoiceSpeechSettingsScreen> createState() =>
      _VoiceSpeechSettingsScreenState();
}

class _VoiceSpeechSettingsScreenState
    extends ConsumerState<VoiceSpeechSettingsScreen>
    with WidgetsBindingObserver {
  bool _busy = false;
  bool _awaitingDownloadReturn = false;
  Set<String> _snapshotBeforeDownload = {};
  String? _snapshotEngineVoiceId;
  String? _snapshotEngineLocale;
  Set<String> _newlyInstalledIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingDownloadReturn) {
      _awaitingDownloadReturn = false;
      unawaited(_afterDownloadReturn());
    }
  }

  Future<List<TtsVoiceUiModel>> _scanVoices() async {
    final voices = await ref.read(ttsServiceProvider).reloadVoices();
    ref.invalidate(ttsVoicesProvider);
    ref.invalidate(usableTtsVoicesProvider);
    await ref.read(ttsVoicesProvider.future);
    return voices.where((v) => v.isUsable).toList();
  }

  Future<void> _captureDownloadSnapshot(List<TtsVoiceUiModel> current) async {
    _snapshotBeforeDownload = current.map((v) => v.id).toSet();
    final engine = await ref.read(ttsServiceProvider).loadEngineVoice();
    _snapshotEngineVoiceId = engine?.id;
    _snapshotEngineLocale = engine?.locale;
  }

  Future<void> _rescan() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final voices = await _scanVoices();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voicesRescanResult(voices.length))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _afterDownloadReturn() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final voices = await _scanVoices();
      final engine = await ref.read(ttsServiceProvider).loadEngineVoice();
      if (!mounted) return;

      final afterIds = voices.map((v) => v.id).toSet();
      final discovered = afterIds.difference(_snapshotBeforeDownload);
      final engineChanged =
          engine != null &&
          ((_snapshotEngineVoiceId != null &&
                  engine.id != _snapshotEngineVoiceId) ||
              (_snapshotEngineLocale != null &&
                  VoiceCatalog.normalizeLocaleTag(engine.locale) !=
                      VoiceCatalog.normalizeLocaleTag(_snapshotEngineLocale!)));

      setState(() => _newlyInstalledIds = discovered);

      if (discovered.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voicesNewFound(discovered.length))),
        );
        return;
      }

      if (engine != null && engineChanged) {
        final matched = _matchEngineVoice(voices, engine);
        final locale = VoiceCatalog.normalizeLocaleTag(
          matched?.locale ?? engine.locale,
        );
        final language = VoiceCatalog.languageCodeOf(locale);
        await ref
            .read(preferredVoiceProvider.notifier)
            .setVoice(
              id: matched?.id ?? 'system-default|$locale',
              locale: locale,
              language: language,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.voicesSystemUpdated(LocaleDisplayNames.friendly(language)),
            ),
          ),
        );
        return;
      }

      final preferred = ref.read(preferredVoiceProvider);
      final locale = VoiceCatalog.normalizeLocaleTag(
        _snapshotEngineLocale ?? preferred.locale ?? 'en-US',
      );
      await ref
          .read(preferredVoiceProvider.notifier)
          .setVoice(
            id: 'system-default|$locale',
            locale: locale,
            language: VoiceCatalog.languageCodeOf(locale),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.voicesNoChange)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  TtsVoiceUiModel? _matchEngineVoice(
    List<TtsVoiceUiModel> voices,
    TtsEngineVoiceInfo engine,
  ) {
    for (final voice in voices) {
      if (voice.id == engine.id) return voice;
    }
    final engineName = engine.name.toLowerCase();
    final engineLocale = VoiceCatalog.normalizeLocaleTag(engine.locale);
    for (final voice in voices) {
      if (voice.name.toLowerCase() == engineName &&
          VoiceCatalog.normalizeLocaleTag(voice.locale) == engineLocale) {
        return voice;
      }
    }
    return null;
  }

  Future<void> _saveVoice(TtsVoiceUiModel voice) async {
    final l10n = AppLocalizations.of(context);
    final locale = VoiceCatalog.normalizeLocaleTag(voice.locale);
    await ref
        .read(preferredVoiceProvider.notifier)
        .setVoice(
          id: voice.id,
          locale: locale,
          language: VoiceCatalog.languageCodeOf(locale),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.voicesSelectedSaved(
            VoiceCatalog.friendlyLabels(
                  ref.read(ttsVoicesProvider).asData?.value ?? [voice],
                  labelFor: l10n.voiceFriendlyName,
                )[voice.id] ??
                l10n.voiceFriendlyName('01'),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadMore() async {
    final l10n = AppLocalizations.of(context);
    final bridge = ref.read(ttsPlatformBridgeProvider);

    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.voicesWebUnavailable)));
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.voicesIosGuideTitle),
          content: Text(l10n.voicesIosGuideBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonOpen),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
      final current =
          ref.read(ttsVoicesProvider).asData?.value ??
          const <TtsVoiceUiModel>[];
      await _captureDownloadSnapshot(current.where((v) => v.isUsable).toList());
      _awaitingDownloadReturn = true;
      final opened = await bridge.openDownloadMoreVoices();
      if (!opened) {
        _awaitingDownloadReturn = false;
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.voicesOpenManagerFailed)));
        }
      }
      return;
    }

    final current =
        ref.read(ttsVoicesProvider).asData?.value ?? const <TtsVoiceUiModel>[];
    setState(() => _busy = true);
    try {
      await _captureDownloadSnapshot(current.where((v) => v.isUsable).toList());
      _awaitingDownloadReturn = true;
      final opened = await bridge.openDownloadMoreVoices();
      if (!opened) {
        _awaitingDownloadReturn = false;
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.voicesOpenManagerFailed)));
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  TtsVoiceUiModel? _resolveSelected(
    List<TtsVoiceUiModel> voices,
    String? preferredId,
    String? preferredLocale,
  ) {
    if (preferredId != null) {
      for (final voice in voices) {
        if (voice.id == preferredId) return voice;
      }
      final preferredName = preferredId.contains('|')
          ? preferredId.split('|').first
          : preferredId;
      for (final voice in voices) {
        if (voice.name == preferredName ||
            voice.id.split('|').first == preferredName) {
          if (preferredLocale == null ||
              VoiceCatalog.languageCodeOf(voice.locale) ==
                  VoiceCatalog.languageCodeOf(preferredLocale)) {
            return voice;
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicesAsync = ref.watch(ttsVoicesProvider);
    final preferred = ref.watch(preferredVoiceProvider);
    final canManage = ref
        .watch(ttsPlatformBridgeProvider)
        .canManageSystemVoicePacks;

    return AppScaffold(
      showBack: true,
      title: l10n.voicesTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppConstants.spaceMd,
            bottom: AppConstants.space2xl,
          ),
          children: [
            voicesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Text(l10n.voicesEmpty),
              data: (voices) {
                final usable = voices.where((v) => v.isUsable).toList();
                final labels = VoiceCatalog.friendlyLabels(
                  usable,
                  labelFor: l10n.voiceFriendlyName,
                );
                final selected = _resolveSelected(
                  usable,
                  preferred.id,
                  preferred.locale,
                );
                final newVoices =
                    usable
                        .where((v) => _newlyInstalledIds.contains(v.id))
                        .toList()
                      ..sort((a, b) => a.id.compareTo(b.id));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(title: l10n.voicesCurrentVoice),
                    if (selected == null)
                      Text(
                        l10n.voicesEmpty,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      )
                    else
                      SelectedVoiceCard(
                        voice: selected,
                        friendlyName: selected.isSystemDefault
                            ? l10n.voiceSystemDefault
                            : labels[selected.id] ??
                                  l10n.voiceFriendlyName('01'),
                      ),
                    if (newVoices.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spaceXl),
                      SectionHeader(title: l10n.voicesNewlyInstalled),
                      for (final voice in newVoices)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spaceSm,
                          ),
                          child: _NewVoiceTile(
                            voice: voice,
                            name:
                                labels[voice.id] ??
                                l10n.voiceFriendlyName('01'),
                            selected: preferred.id == voice.id,
                            onSelect: () => _saveVoice(voice),
                          ),
                        ),
                    ],
                    const SizedBox(height: AppConstants.spaceXl),
                    _DownloadVoicesCard(
                      busy: _busy,
                      enabled: canManage && !kIsWeb,
                      label: l10n.voicesDownloadMore,
                      subtitle: l10n.voicesDownloadHint,
                      onTap: _downloadMore,
                    ),
                    if (kIsWeb) ...[
                      const SizedBox(height: AppConstants.spaceMd),
                      Text(
                        l10n.voicesWebUnavailable,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.spaceXl),
                    SectionHeader(
                      title: l10n.voicesOnDevice,
                      trailing: TextButton(
                        onPressed: _busy ? null : _rescan,
                        child: Text(l10n.voicesRescan),
                      ),
                    ),
                    if (usable.isEmpty)
                      EmptyStateView(
                        icon: Icons.record_voice_over_outlined,
                        title: l10n.voicesEmpty,
                        subtitle: l10n.voicesOfflineHint,
                        actionLabel: l10n.voicesEmptyCta,
                        onAction: canManage ? _downloadMore : null,
                      )
                    else
                      VoiceBrowser(
                        voices: usable,
                        selectedVoiceId: preferred.id ?? selected?.id,
                        showAvailability: true,
                        friendlyLabels: labels,
                        newlyInstalledIds: _newlyInstalledIds,
                        initiallyExpandedLanguage:
                            preferred.language ??
                            (selected == null
                                ? null
                                : VoiceCatalog.languageCodeOf(selected.locale)),
                        onSelected: _saveVoice,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NewVoiceTile extends ConsumerStatefulWidget {
  const _NewVoiceTile({
    required this.voice,
    required this.name,
    required this.selected,
    required this.onSelect,
  });

  final TtsVoiceUiModel voice;
  final String name;
  final bool selected;
  final VoidCallback onSelect;

  @override
  ConsumerState<_NewVoiceTile> createState() => _NewVoiceTileState();
}

class _NewVoiceTileState extends ConsumerState<_NewVoiceTile> {
  bool _playing = false;

  @override
  void deactivate() {
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  Future<void> _preview() async {
    if (_playing) {
      await ref.read(ttsServiceProvider).stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    try {
      await ref
          .read(ttsServiceProvider)
          .preview(
            text: VoiceCatalog.previewSampleForLocale(widget.voice.locale),
            voiceId: widget.voice.id,
            locale: widget.voice.locale,
          );
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SurfacePanel(
      emphasized: widget.selected,
      onTap: widget.onSelect,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Row(
        children: [
          Icon(
            widget.selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: widget.selected
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.name,
                        style: context.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.voicesNewBadge,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _playing ? l10n.alarmStop : l10n.ttsPreview,
            onPressed: _preview,
            icon: Icon(
              _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadVoicesCard extends StatelessWidget {
  const _DownloadVoicesCard({
    required this.busy,
    required this.enabled,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final bool busy;
  final bool enabled;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && !busy ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: 0.16),
                colors.tertiary.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

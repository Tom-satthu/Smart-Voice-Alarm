import 'dart:async';

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
    _newlyInstalledIds = ref.read(settingsRepositoryProvider).loadNewVoiceIds();
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
      final before =
          ref.read(ttsVoicesProvider).asData?.value ??
          const <TtsVoiceUiModel>[];
      final voices = await _scanVoices();
      await _rememberNewVoices(before: before, after: voices);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voicesRescanResult(voices.length))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rememberNewVoices({
    required Iterable<TtsVoiceUiModel> before,
    required Iterable<TtsVoiceUiModel> after,
  }) async {
    final discovered = VoiceCatalog.newlyInstalledIds(
      before: before,
      after: after,
    );
    if (discovered.isEmpty) return;
    _newlyInstalledIds = {..._newlyInstalledIds, ...discovered};
    await ref
        .read(settingsRepositoryProvider)
        .saveNewVoiceIds(_newlyInstalledIds);
    if (mounted) setState(() {});
  }

  Future<void> _afterDownloadReturn() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final voices = await _scanVoices();
      final engine = await ref.read(ttsServiceProvider).loadEngineVoice();
      if (!mounted) return;

      final snapshot = voices
          .where((voice) => _snapshotBeforeDownload.contains(voice.id))
          .toList();
      final discovered = VoiceCatalog.newlyInstalledIds(
        before: snapshot,
        after: voices,
      );
      final engineChanged =
          engine != null &&
          ((_snapshotEngineVoiceId != null &&
                  engine.id != _snapshotEngineVoiceId) ||
              (_snapshotEngineLocale != null &&
                  VoiceCatalog.normalizeLocaleTag(engine.locale) !=
                      VoiceCatalog.normalizeLocaleTag(_snapshotEngineLocale!)));

      if (discovered.isNotEmpty) {
        _newlyInstalledIds = {..._newlyInstalledIds, ...discovered};
        await ref
            .read(settingsRepositoryProvider)
            .saveNewVoiceIds(_newlyInstalledIds);
        if (!mounted) return;
        setState(() {});
      }

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
              id:
                  matched?.id ??
                  'system-default|${VoiceCatalog.languageCodeOf(locale)}',
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
            id: 'system-default|${VoiceCatalog.languageCodeOf(locale)}',
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
            voice.isSystemDefault
                ? l10n.voiceSystemDefault
                : VoiceCatalog.friendlyLabels(
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
        .watch(ttsServiceProvider)
        .capabilities
        .supportsVoiceManagement;

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        showBack: true,
        title: l10n.voicesTitle,
        bottom: TabBar(
          tabs: [
            Tab(text: l10n.voicesOnDevice),
            Tab(text: l10n.voicesNewlyInstalled),
          ],
        ),
        body: ResponsiveCenter(
          child: voicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(l10n.voicesEmpty)),
            data: (voices) {
              final usable = voices.where((voice) => voice.isUsable).toList();
              final labels = VoiceCatalog.friendlyLabels(
                usable,
                labelFor: l10n.voiceFriendlyName,
              );
              final selected = _resolveSelected(
                usable,
                preferred.id,
                preferred.locale,
              );
              final newVoices = usable
                  .where(
                    (voice) =>
                        !voice.isSystemDefault &&
                        _newlyInstalledIds.contains(voice.id),
                  )
                  .toList();
              final padding = const EdgeInsets.fromLTRB(
                AppConstants.spaceMd,
                AppConstants.spaceMd,
                AppConstants.spaceMd,
                AppConstants.space2xl,
              );
              final expandedLanguage =
                  preferred.language ??
                  (selected == null
                      ? null
                      : VoiceCatalog.languageCodeOf(selected.locale));

              return TabBarView(
                children: [
                  ListView(
                    padding: padding,
                    children: [
                      SectionHeader(title: l10n.voicesCurrentVoice),
                      if (selected != null)
                        SelectedVoiceCard(
                          voice: selected,
                          friendlyName: selected.isSystemDefault
                              ? l10n.voiceSystemDefault
                              : labels[selected.id] ??
                                    l10n.voiceFriendlyName('01'),
                        ),
                      if (canManage) ...[
                        const SizedBox(height: AppConstants.spaceMd),
                        _DownloadVoicesCard(
                          busy: _busy,
                          enabled: true,
                          label: l10n.voicesDownloadMore,
                          subtitle: l10n.voicesDownloadHint,
                          onTap: _downloadMore,
                        ),
                      ],
                      const SizedBox(height: AppConstants.spaceLg),
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
                          actionLabel: canManage ? l10n.voicesEmptyCta : null,
                          onAction: canManage ? _downloadMore : null,
                        )
                      else
                        VoiceBrowser(
                          voices: usable,
                          selectedVoiceId: preferred.id ?? selected?.id,
                          showAvailability: true,
                          friendlyLabels: labels,
                          newlyInstalledIds: _newlyInstalledIds,
                          initiallyExpandedLanguage: expandedLanguage,
                          onSelected: _saveVoice,
                        ),
                    ],
                  ),
                  ListView(
                    padding: padding,
                    children: [
                      if (newVoices.isEmpty)
                        EmptyStateView(
                          icon: Icons.new_releases_outlined,
                          title: l10n.voicesNewlyInstalled,
                          subtitle: l10n.voicesNoChange,
                        )
                      else
                        VoiceBrowser(
                          voices: newVoices,
                          selectedVoiceId: preferred.id,
                          showAvailability: true,
                          friendlyLabels: labels,
                          newlyInstalledIds: _newlyInstalledIds,
                          initiallyExpandedLanguage: expandedLanguage,
                          onSelected: _saveVoice,
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
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

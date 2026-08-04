import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_display_names.dart';
import '../../../../core/localization/voice_catalog.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/resolved_system_voice.dart';
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
  Map<String, ResolvedSystemVoiceState> _snapshotByLocale = {};
  Set<String> _newlyInstalledIds = {};
  List<SystemVoiceChangeEvent> _systemChangeEvents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final settings = ref.read(settingsRepositoryProvider);
    _newlyInstalledIds = settings.loadNewVoiceIds();
    _systemChangeEvents = settings.loadSystemVoiceChangeEvents();
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

  String? get _appLocaleTag =>
      ref.read(localeProvider).toLanguageTag();

  String get _systemLocaleTag =>
      WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();

  Future<List<TtsVoiceUiModel>> _scanVoices({
    Map<String, ResolvedSystemVoiceState>? resolvedDefaults,
  }) async {
    final preferred = ref.read(preferredVoiceProvider);
    final voices = await ref.read(ttsServiceProvider).reloadVoices(
          preferredLocale: preferred.locale,
          appLocale: _appLocaleTag,
          systemLocale: _systemLocaleTag,
          resolvedDefaults: resolvedDefaults,
        );
    ref.invalidate(ttsVoicesProvider);
    ref.invalidate(usableTtsVoicesProvider);
    await ref.read(ttsVoicesProvider.future);
    return voices.where((v) => v.isUsable).toList();
  }

  List<String> _localesToProbe(List<TtsVoiceUiModel> voices) {
    final preferred = ref.read(preferredVoiceProvider);
    return VoiceCatalog.localesForSystemDefaultProbe(
      voices: voices,
      preferredLocale: preferred.locale,
      appLocale: _appLocaleTag,
      systemLocale: _systemLocaleTag,
    );
  }

  Future<Map<String, ResolvedSystemVoiceState>> _probeLocales(
    List<TtsVoiceUiModel> voices,
  ) async {
    final locales = _localesToProbe(voices);
    if (locales.isEmpty) return const {};
    return ref.read(ttsServiceProvider).probeSystemDefaults(locales);
  }

  Future<void> _captureDownloadSnapshot(List<TtsVoiceUiModel> current) async {
    _snapshotBeforeDownload = current
        .where((voice) => !voice.isSystemDefault && voice.isUsable)
        .map((voice) => voice.id)
        .toSet();
    _snapshotByLocale = await _probeLocales(current);
  }

  Future<void> _rescan() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final before =
          ref.read(ttsVoicesProvider).asData?.value ??
          const <TtsVoiceUiModel>[];
      final probed = await _probeLocales(before.where((v) => v.isUsable).toList());
      final voices = await _scanVoices(resolvedDefaults: probed);
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

  Future<void> _persistSystemEvents(List<SystemVoiceChangeEvent> events) async {
    _systemChangeEvents = events;
    await ref
        .read(settingsRepositoryProvider)
        .saveSystemVoiceChangeEvents(events);
    if (mounted) setState(() {});
  }

  Future<void> _afterDownloadReturn() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final beforeSnapshot = _snapshotBeforeDownload;
      final beforeLocales = Map<String, ResolvedSystemVoiceState>.from(
        _snapshotByLocale,
      );

      // First reload list, then probe defaults with the fresh locale set.
      final voices = await _scanVoices();
      final afterLocales = await _probeLocales(voices);
      // Rebuild with probed defaults so "Giọng của thiết bị" uses platform data.
      final refreshed = await _scanVoices(resolvedDefaults: afterLocales);
      if (!mounted) return;

      final beforeVoices = refreshed
          .where((voice) => beforeSnapshot.contains(voice.id))
          .toList();
      final discovered = VoiceCatalog.newlyInstalledIds(
        before: beforeVoices.isEmpty
            ? beforeSnapshot.map(
                (id) => TtsVoiceUiModel(id: id, name: id, locale: 'und'),
              )
            : beforeVoices,
        after: refreshed,
      );

      // Prefer ID-only diff against the captured ID set.
      final discoveredIds = refreshed
          .where(
            (voice) =>
                !voice.isSystemDefault &&
                voice.isUsable &&
                !beforeSnapshot.contains(voice.id),
          )
          .map((voice) => voice.id)
          .toSet();
      final newIds = discovered.isNotEmpty ? discovered : discoveredIds;

      final changedLocales = <String>[];
      for (final entry in afterLocales.entries) {
        ResolvedSystemVoiceState? before = beforeLocales[entry.key];
        if (before == null) {
          final language = VoiceCatalog.languageCodeOf(entry.key);
          for (final candidate in beforeLocales.entries) {
            if (VoiceCatalog.languageCodeOf(candidate.key) == language) {
              before = candidate.value;
              break;
            }
          }
        }
        if (before == null) {
          if (entry.value.hasResolvedVoice) {
            changedLocales.add(entry.key);
          }
          continue;
        }
        if (before.fingerprint != entry.value.fingerprint) {
          changedLocales.add(entry.key);
        }
      }

      if (newIds.isNotEmpty) {
        _newlyInstalledIds = {..._newlyInstalledIds, ...newIds};
        await ref
            .read(settingsRepositoryProvider)
            .saveNewVoiceIds(_newlyInstalledIds);
        if (changedLocales.isNotEmpty) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final events = [
            for (final locale in changedLocales)
              SystemVoiceChangeEvent(
                locale: VoiceCatalog.normalizeLocaleTag(locale),
                language: VoiceCatalog.languageCodeOf(locale),
                timestampMs: now,
              ),
            ..._systemChangeEvents,
          ];
          final byLanguage = <String, SystemVoiceChangeEvent>{};
          for (final event in events) {
            byLanguage.putIfAbsent(event.language, () => event);
          }
          await _persistSystemEvents(byLanguage.values.toList());
        }
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voicesNewFound(newIds.length))),
        );
        return;
      }

      if (changedLocales.isNotEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final events = [
          for (final locale in changedLocales)
            SystemVoiceChangeEvent(
              locale: VoiceCatalog.normalizeLocaleTag(locale),
              language: VoiceCatalog.languageCodeOf(locale),
              timestampMs: now,
            ),
          ..._systemChangeEvents,
        ];
        final byLanguage = <String, SystemVoiceChangeEvent>{};
        for (final event in events) {
          byLanguage.putIfAbsent(event.language, () => event);
        }
        await _persistSystemEvents(byLanguage.values.toList());

        final preferred = ref.read(preferredVoiceProvider);
        final preferredLanguage = preferred.language ??
            (preferred.locale == null
                ? null
                : VoiceCatalog.languageCodeOf(preferred.locale!));
        final matchedChange = changedLocales.firstWhere(
          (locale) =>
              preferredLanguage != null &&
              VoiceCatalog.languageCodeOf(locale) == preferredLanguage,
          orElse: () => changedLocales.first,
        );
        final language = VoiceCatalog.languageCodeOf(matchedChange);
        final locale = VoiceCatalog.normalizeLocaleTag(matchedChange);
        if (preferred.id == null ||
            preferred.id!.startsWith('system-default|') ||
            preferredLanguage == language) {
          await ref.read(preferredVoiceProvider.notifier).setVoice(
                id: 'system-default|$language',
                locale: locale,
                language: language,
              );
        }
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.voicesSystemUpdated(LocaleDisplayNames.friendly(language)),
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voicesSettingsRefreshed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveVoice(TtsVoiceUiModel voice) async {
    final l10n = AppLocalizations.of(context);
    final locale = VoiceCatalog.normalizeLocaleTag(voice.locale);
    await ref.read(preferredVoiceProvider.notifier).setVoice(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.voicesOpenManagerFailed)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearSystemEvents() async {
    await _persistSystemEvents(const []);
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
      if (preferredId.startsWith('system-default|')) {
        final language = preferredId.split('|').last;
        for (final voice in voices) {
          if (voice.isSystemDefault &&
              VoiceCatalog.languageCodeOf(voice.locale) == language) {
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
              final expandedLanguage = preferred.language ??
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
                      if (_systemChangeEvents.isNotEmpty) ...[
                        SectionHeader(
                          title: l10n.voicesSystemChanges,
                          trailing: TextButton(
                            onPressed: _clearSystemEvents,
                            child: Text(l10n.commonClear),
                          ),
                        ),
                        for (final event in _systemChangeEvents)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spaceSm,
                            ),
                            child: SurfacePanel(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                l10n.voicesSystemChangeEvent(
                                  LocaleDisplayNames.friendly(event.language),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: AppConstants.spaceMd),
                      ],
                      if (newVoices.isEmpty && _systemChangeEvents.isEmpty)
                        EmptyStateView(
                          icon: Icons.new_releases_outlined,
                          title: l10n.voicesNewlyInstalled,
                          subtitle: l10n.voicesNewlyInstalledEmpty,
                        )
                      else if (newVoices.isNotEmpty)
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

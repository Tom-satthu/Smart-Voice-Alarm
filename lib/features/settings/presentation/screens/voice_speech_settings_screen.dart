import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_display_names.dart';
import '../../../../core/localization/voice_catalog.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/resolved_system_voice.dart';
import '../../../../core/services/voice_load_context.dart';
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
    extends ConsumerState<VoiceSpeechSettingsScreen> {
  bool _scanning = false;
  bool _hasScanned = false;
  bool _openingSettings = false;
  int _scanGeneration = 0;
  List<TtsVoiceUiModel> _scannedVoices = const [];
  String? _scanError;
  DateTime? _lastScannedAt;
  final Set<String> _expandedLanguages = {};
  bool _expansionSeeded = false;
  String? _previewingVoiceId;
  String? _lastAutoExpandedForSelected;

  @override
  void deactivate() {
    if (!ref.read(alarmEngineProvider).isRunning) {
      ref.read(ttsServiceProvider).stop();
    }
    super.deactivate();
  }

  VoiceLoadContext _loadContext() {
    final preferred = ref.read(preferredVoiceProvider);
    return VoiceLoadContext(
      preferredLocale: preferred.locale,
      appLocale: ref.read(localeProvider).toLanguageTag(),
      systemLocale:
          WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
    );
  }

  Future<void> _scanDeviceVoices() async {
    final generation = ++_scanGeneration;
    final preferredBefore = ref.read(preferredVoiceProvider);
    setState(() {
      _scanning = true;
      _scanError = null;
      _previewingVoiceId = null;
    });

    try {
      if (!ref.read(alarmEngineProvider).isRunning) {
        await ref.read(ttsServiceProvider).stop();
      }

      final context = _loadContext();
      final tts = ref.read(ttsServiceProvider);

      // Authoritative pass: reload with full context, then probe defaults once
      // and rebuild with the same context (no empty invalidate/reload).
      final initial = await tts.reloadVoices(
        preferredLocale: context.preferredLocale,
        appLocale: context.appLocale,
        systemLocale: context.systemLocale,
      );
      final locales = VoiceCatalog.localesForSystemDefaultProbe(
        voices: initial.where((v) => v.isUsable),
        preferredLocale: context.preferredLocale,
        appLocale: context.appLocale,
        systemLocale: context.systemLocale,
      );
      Map<String, ResolvedSystemVoiceState> probed = const {};
      if (locales.isNotEmpty) {
        probed = await tts.probeSystemDefaults(locales);
      }
      final voices = probed.isEmpty
          ? initial
          : await tts.reloadVoices(
              preferredLocale: context.preferredLocale,
              appLocale: context.appLocale,
              systemLocale: context.systemLocale,
              resolvedDefaults: probed,
            );

      if (!mounted || generation != _scanGeneration) return;

      final preferred = ref.read(preferredVoiceProvider);
      final usable = voices.where((voice) => voice.isUsable).toList();
      final labels = VoiceCatalog.friendlyLabels(
        usable,
        labelFor: AppLocalizations.of(this.context).voiceFriendlyName,
      );
      final sorted = VoiceCatalog.sortForDeviceDiscovery(
        voices: usable,
        selectedId: preferred.id,
        preferredLanguage: preferred.language ??
            (preferred.locale == null
                ? null
                : VoiceCatalog.languageCodeOf(preferred.locale!)),
        appLanguage: VoiceCatalog.languageCodeOf(context.appLocale ?? ''),
        friendlyLabels: labels,
      );

      setState(() {
        _scannedVoices = sorted;
        _hasScanned = true;
        _lastScannedAt = DateTime.now();
        _scanning = false;
        _scanError = null;
        _syncExpansionAfterScan(
          voices: sorted,
          selectedId: preferred.id,
          selectedLanguage: preferred.language ?? preferred.locale,
          appLocale: context.appLocale,
        );
      });

      // If a concrete preferred voice vanished from the device, fall back once.
      // A normal scan never rewrites a still-present selection.
      final normalizedPreferred =
          VoiceCatalog.normalizeSystemDefaultVoiceId(preferred.id) ??
              preferred.id;
      final stillPresent = preferred.id != null &&
          sorted.any(
            (voice) =>
                voice.id == preferred.id || voice.id == normalizedPreferred,
          );
      if (!stillPresent && preferred.id != null) {
        final resolved = VoiceCatalog.resolvePreferredVoice(
          voices: sorted,
          preferredId: preferred.id,
          preferredLanguage: preferred.language,
        );
        if (resolved != null && resolved.id != preferred.id) {
          await ref.read(preferredVoiceProvider.notifier).setVoice(
                id: resolved.id,
                locale: resolved.locale,
                language: VoiceCatalog.languageCodeOf(resolved.locale),
              );
        }
      } else {
        // Confirm scan did not mutate preferred when the voice is still present.
        final after = ref.read(preferredVoiceProvider);
        if (after.id != preferredBefore.id ||
            after.locale != preferredBefore.locale) {
          debugPrint(
            'scanDeviceVoices: preferred changed unexpectedly '
            '${preferredBefore.id} -> ${after.id}',
          );
        }
      }
    } catch (error, stack) {
      debugPrint('scanDeviceVoices failed: $error\n$stack');
      if (!mounted || generation != _scanGeneration) return;
      setState(() {
        _scanning = false;
        _scanError = AppLocalizations.of(context).scanVoicesFailed;
      });
    }
  }

  void _syncExpansionAfterScan({
    required List<TtsVoiceUiModel> voices,
    String? selectedId,
    String? selectedLanguage,
    String? appLocale,
  }) {
    final groups = VoiceCatalog.groupForDeviceDiscovery(
      voices: voices,
      selectedId: selectedId,
      selectedLanguage: selectedLanguage,
      appLocale: appLocale,
    );
    final alive = groups.map((group) => group.languageCode).toSet();
    _expandedLanguages.removeWhere((code) => !alive.contains(code));
    if (!_expansionSeeded || _expandedLanguages.isEmpty) {
      final open = VoiceCatalog.defaultExpandedLanguage(
        groups: groups,
        selectedLanguage: selectedLanguage,
        appLanguage: appLocale,
      );
      if (open != null) {
        _expandedLanguages.add(open);
        _lastAutoExpandedForSelected = open;
      }
      _expansionSeeded = true;
    }
  }

  void _ensureSelectedLanguageExpanded(String? selectedLanguage) {
    if (selectedLanguage == null || selectedLanguage.isEmpty) return;
    final key = VoiceCatalog.discoveryGroupKey(selectedLanguage);
    if (_lastAutoExpandedForSelected == key) return;
    if (_expandedLanguages.contains(key)) {
      _lastAutoExpandedForSelected = key;
      return;
    }
    _expandedLanguages.add(key);
    _lastAutoExpandedForSelected = key;
  }

  Future<void> _togglePreview(TtsVoiceUiModel voice) async {
    if (_previewingVoiceId == voice.id) {
      await ref.read(ttsServiceProvider).stop();
      if (mounted) setState(() => _previewingVoiceId = null);
      return;
    }
    await ref.read(ttsServiceProvider).stop();
    if (!mounted) return;
    setState(() => _previewingVoiceId = voice.id);
    try {
      await ref.read(ttsServiceProvider).preview(
            text: VoiceCatalog.previewSampleForLocale(voice.locale),
            voiceId: voice.id,
            locale: voice.locale,
          );
    } finally {
      if (mounted && _previewingVoiceId == voice.id) {
        setState(() => _previewingVoiceId = null);
      }
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
    // Keep selected item near the top without a second platform scan.
    if (_hasScanned && _scannedVoices.isNotEmpty) {
      final labels = VoiceCatalog.friendlyLabels(
        _scannedVoices,
        labelFor: l10n.voiceFriendlyName,
      );
      setState(() {
        _scannedVoices = VoiceCatalog.sortForDeviceDiscovery(
          voices: _scannedVoices,
          selectedId: voice.id,
          preferredLanguage: VoiceCatalog.languageCodeOf(locale),
          appLanguage: VoiceCatalog.languageCodeOf(
            ref.read(localeProvider).toLanguageTag(),
          ),
          friendlyLabels: labels,
        );
        _ensureSelectedLanguageExpanded(locale);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.voicesSelectedSaved(
            voice.isSystemDefault
                ? l10n.voiceSystemDefault
                : VoiceCatalog.friendlyLabels(
                        _scannedVoices.isNotEmpty
                            ? _scannedVoices
                            : [voice],
                        labelFor: l10n.voiceFriendlyName,
                      )[voice.id] ??
                      l10n.voiceFriendlyName('01'),
          ),
        ),
      ),
    );
  }

  Future<void> _openVoiceSettings() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _openingSettings = true);
    try {
      final opened =
          await ref.read(ttsPlatformBridgeProvider).openSystemTtsSettings();
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voicesOpenManagerFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _openingSettings = false);
    }
  }

  String _friendlyName(
    AppLocalizations l10n,
    TtsVoiceUiModel voice,
    Map<String, String> labels,
  ) {
    if (voice.isSystemDefault) return l10n.voiceSystemDefault;
    return labels[voice.id] ?? l10n.voiceFriendlyName('01');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preferred = ref.watch(preferredVoiceProvider);
    final voicesAsync = ref.watch(ttsVoicesProvider);
    final canOpenSettings = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    final catalogForCurrent = _hasScanned
        ? _scannedVoices
        : (voicesAsync.asData?.value ?? const <TtsVoiceUiModel>[])
            .where((v) => v.isUsable)
            .toList();
    final labels = VoiceCatalog.friendlyLabels(
      [
        ...catalogForCurrent,
        ..._scannedVoices,
      ],
      labelFor: l10n.voiceFriendlyName,
    );
    final selected = VoiceCatalog.resolvePreferredVoice(
      voices: catalogForCurrent,
      preferredId: preferred.id,
      preferredLanguage: preferred.language,
    );

    if (_hasScanned) {
      final selectedLang =
          preferred.language ?? preferred.locale ?? selected?.locale;
      if (selectedLang != null) {
        final key = VoiceCatalog.discoveryGroupKey(selectedLang);
        if (_lastAutoExpandedForSelected != key &&
            !_expandedLanguages.contains(key)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _ensureSelectedLanguageExpanded(selectedLang));
          });
        }
      }
    }

    return AppScaffold(
      showBack: true,
      title: l10n.voicesTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.space2xl,
          ),
          children: [
            SectionHeader(title: l10n.currentVoice),
            if (selected != null)
              SelectedVoiceCard(
                voice: selected,
                friendlyName: _friendlyName(l10n, selected, labels),
                showInUseLabel: true,
              )
            else if (preferred.id != null || preferred.locale != null)
              SurfacePanel(
                padding: const EdgeInsets.all(16),
                child: Text(
                  preferred.locale == null
                      ? l10n.scanVoicesHint
                      : LocaleDisplayNames.friendly(preferred.locale!),
                  style: context.textTheme.bodyMedium,
                ),
              )
            else
              SurfacePanel(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.scanVoicesHint,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: AppConstants.spaceLg),
            _ScanVoicesButton(
              busy: _scanning,
              label: l10n.scanDeviceVoices,
              onPressed: _scanning ? null : _scanDeviceVoices,
            ),
            if (_lastScannedAt != null) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                l10n.lastScanned(
                  TimeOfDay.fromDateTime(_lastScannedAt!).format(context),
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            if (_scanError != null) ...[
              const SizedBox(height: AppConstants.spaceMd),
              SurfacePanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_scanError!, style: context.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _scanning ? null : _scanDeviceVoices,
                      child: Text(l10n.scanDeviceVoices),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceLg),
            SectionHeader(title: l10n.availableDeviceVoices),
            if (!_hasScanned && !_scanning)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                child: Text(
                  l10n.scanVoicesHint,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              )
            else if (_scanning && !_hasScanned)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasScanned && _scannedVoices.isEmpty)
              EmptyStateView(
                icon: Icons.record_voice_over_outlined,
                title: l10n.noDeviceVoicesFound,
                subtitle: l10n.voicesOfflineHint,
              )
            else if (_hasScanned)
              _GroupedDeviceVoiceList(
                voices: _scannedVoices,
                labels: labels,
                selectedId: preferred.id ?? selected?.id,
                selectedLanguage: preferred.language ??
                    preferred.locale ??
                    selected?.locale,
                appLocale: ref.watch(localeProvider).toLanguageTag(),
                systemLocale: WidgetsBinding
                    .instance.platformDispatcher.locale
                    .toLanguageTag(),
                expandedLanguages: _expandedLanguages,
                previewingVoiceId: _previewingVoiceId,
                onToggleExpanded: (languageCode) {
                  setState(() {
                    if (_expandedLanguages.contains(languageCode)) {
                      _expandedLanguages.remove(languageCode);
                    } else {
                      _expandedLanguages.add(languageCode);
                    }
                  });
                },
                onSelect: _saveVoice,
                onPreview: _togglePreview,
                friendlyNameFor: (voice) => _friendlyName(l10n, voice, labels),
              ),
            const SizedBox(height: AppConstants.spaceLg),
            SectionHeader(title: l10n.voiceSetupGuide),
            _VoiceSetupGuideCard(
              openingSettings: _openingSettings,
              canOpenSettings: canOpenSettings,
              onOpenSettings: _openVoiceSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanVoicesButton extends StatelessWidget {
  const _ScanVoicesButton({
    required this.busy,
    required this.label,
    required this.onPressed,
  });

  final bool busy;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
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
                            Icons.radar_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Text(
                      label,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.refresh_rounded, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupedDeviceVoiceList extends StatelessWidget {
  const _GroupedDeviceVoiceList({
    required this.voices,
    required this.labels,
    required this.selectedId,
    required this.selectedLanguage,
    required this.appLocale,
    required this.systemLocale,
    required this.expandedLanguages,
    required this.previewingVoiceId,
    required this.onToggleExpanded,
    required this.onSelect,
    required this.onPreview,
    required this.friendlyNameFor,
  });

  final List<TtsVoiceUiModel> voices;
  final Map<String, String> labels;
  final String? selectedId;
  final String? selectedLanguage;
  final String appLocale;
  final String systemLocale;
  final Set<String> expandedLanguages;
  final String? previewingVoiceId;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<TtsVoiceUiModel> onSelect;
  final ValueChanged<TtsVoiceUiModel> onPreview;
  final String Function(TtsVoiceUiModel voice) friendlyNameFor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final groups = VoiceCatalog.groupForDeviceDiscovery(
      voices: voices,
      selectedId: selectedId,
      selectedLanguage: selectedLanguage,
      appLocale: appLocale,
      systemLocale: systemLocale,
      friendlyLabels: labels,
      languageLabelFor: (code) => code == VoiceCatalog.otherLanguageKey
          ? l10n.otherLanguages
          : LocaleDisplayNames.friendly(code),
    );

    return SurfacePanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) ...[
            if (groupIndex > 0)
              Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)),
            _LanguageGroupSection(
              group: groups[groupIndex],
              languageLabel: groups[groupIndex].isOther
                  ? l10n.otherLanguages
                  : LocaleDisplayNames.friendly(groups[groupIndex].languageCode),
              expanded: expandedLanguages.contains(groups[groupIndex].languageCode),
              selectedId: selectedId,
              previewingVoiceId: previewingVoiceId,
              onToggleExpanded: onToggleExpanded,
              onSelect: onSelect,
              onPreview: onPreview,
              friendlyNameFor: friendlyNameFor,
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageGroupSection extends StatelessWidget {
  const _LanguageGroupSection({
    required this.group,
    required this.languageLabel,
    required this.expanded,
    required this.selectedId,
    required this.previewingVoiceId,
    required this.onToggleExpanded,
    required this.onSelect,
    required this.onPreview,
    required this.friendlyNameFor,
  });

  final DeviceVoiceLanguageGroup group;
  final String languageLabel;
  final bool expanded;
  final String? selectedId;
  final String? previewingVoiceId;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<TtsVoiceUiModel> onSelect;
  final ValueChanged<TtsVoiceUiModel> onPreview;
  final String Function(TtsVoiceUiModel voice) friendlyNameFor;

  bool get _containsSelected {
    final normalized = VoiceCatalog.normalizeSystemDefaultVoiceId(selectedId);
    return group.voices.any(
      (voice) => voice.id == selectedId || voice.id == normalized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final countLabel = l10n.voicesInLanguage(group.voiceCount);
    final semanticsLabel = [
      languageLabel,
      countLabel,
      expanded ? l10n.collapseLanguageVoices : l10n.expandLanguageVoices,
      if (_containsSelected) l10n.voiceInUse,
    ].join(', ');

    return Column(
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          label: semanticsLabel,
          child: InkWell(
            onTap: () => onToggleExpanded(group.languageCode),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      expanded
                          ? Icons.expand_more_rounded
                          : Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$languageLabel · $countLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_containsSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          for (var i = 0; i < group.voices.length; i++) ...[
            Divider(height: 1, indent: 16, color: colors.outlineVariant.withValues(alpha: 0.45)),
            _CompactVoiceRow(
              voice: group.voices[i],
              friendlyName: friendlyNameFor(group.voices[i]),
              selected: group.voices[i].id == selectedId ||
                  group.voices[i].id ==
                      VoiceCatalog.normalizeSystemDefaultVoiceId(selectedId),
              previewing: previewingVoiceId == group.voices[i].id,
              onSelect: () => onSelect(group.voices[i]),
              onPreview: () => onPreview(group.voices[i]),
            ),
          ],
      ],
    );
  }
}

class _CompactVoiceRow extends StatelessWidget {
  const _CompactVoiceRow({
    required this.voice,
    required this.friendlyName,
    required this.selected,
    required this.previewing,
    required this.onSelect,
    required this.onPreview,
  });

  final TtsVoiceUiModel voice;
  final String friendlyName;
  final bool selected;
  final bool previewing;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  String _meta(AppLocalizations l10n) {
    final parts = <String>[
      VoiceCatalog.normalizeLocaleTag(voice.locale),
    ];
    final engine = voice.platformEngine?.trim();
    if (engine != null && engine.isNotEmpty) {
      parts.add(engine.contains('.') ? engine.split('.').last : engine);
    }
    if (voice.isSystemDefault) {
      parts.add(l10n.voiceSystemDefault);
    } else if (voice.availability == TtsVoiceAvailability.networkRequired) {
      parts.add(l10n.voiceAvailabilityNetwork);
    } else if (voice.availability == TtsVoiceAvailability.installedOffline) {
      parts.add(l10n.voiceAvailabilityOffline);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final previewLabel = l10n.voicePreviewNamed(friendlyName);
    return Semantics(
      button: true,
      selected: selected,
      label: [
        friendlyName,
        _meta(l10n),
        if (selected) l10n.voiceInUse,
      ].join(', '),
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.record_voice_over_outlined,
                  size: 20,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friendlyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _meta(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: previewLabel,
                excludeSemantics: true,
                child: IconButton(
                  tooltip: previewing ? l10n.alarmStop : previewLabel,
                  onPressed: onPreview,
                  visualDensity: VisualDensity.compact,
                  icon: previewing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                ),
              ),
              TextButton(
                onPressed: onSelect,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(selected ? l10n.voiceInUse : l10n.voiceSelect),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceSetupGuideCard extends StatelessWidget {
  const _VoiceSetupGuideCard({
    required this.openingSettings,
    required this.canOpenSettings,
    required this.onOpenSettings,
  });

  final bool openingSettings;
  final bool canOpenSettings;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String body;
    if (kIsWeb) {
      body = l10n.webVoiceAvailabilityInfo;
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      body = l10n.iosVoiceSetupSteps;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      body = l10n.androidVoiceSetupSteps;
    } else {
      body = l10n.webVoiceAvailabilityInfo;
    }

    return SurfacePanel(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            style: context.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (canOpenSettings) ...[
            const SizedBox(height: AppConstants.spaceMd),
            Semantics(
              button: true,
              label: l10n.openVoiceSettings,
              child: OutlinedButton.icon(
                onPressed: openingSettings ? null : onOpenSettings,
                icon: openingSettings
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.settings_voice_rounded),
                label: Text(l10n.openVoiceSettings),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


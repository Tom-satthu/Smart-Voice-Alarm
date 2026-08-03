import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/localization/locale_display_names.dart';
import '../../core/localization/voice_catalog.dart';
import '../../localization/generated/app_localizations.dart';
import '../../shared/models/ui_models.dart';
import '../../shared/providers/prototype_providers.dart';
import 'app_widgets.dart';

typedef VoiceSelectedCallback = void Function(TtsVoiceUiModel voice);

/// Level-1 language list. Opening a language shows a dedicated picker sheet.
class VoiceBrowser extends ConsumerStatefulWidget {
  const VoiceBrowser({
    super.key,
    required this.voices,
    required this.selectedVoiceId,
    required this.onSelected,
    this.showAvailability = false,
    this.header,
  });

  final List<TtsVoiceUiModel> voices;
  final String? selectedVoiceId;
  final VoiceSelectedCallback onSelected;
  final bool showAvailability;
  final Widget? header;

  @override
  ConsumerState<VoiceBrowser> createState() => _VoiceBrowserState();
}

class _VoiceBrowserState extends ConsumerState<VoiceBrowser> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openLanguage(
    VoiceLanguageGroup group,
    AppLocalizations l10n,
  ) async {
    final selected = await showModalBottomSheet<TtsVoiceUiModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return VoiceLanguagePickerSheet(
          group: group,
          selectedVoiceId: widget.selectedVoiceId,
          showAvailability: widget.showAvailability,
          qualityLabel: (q) => _qualityLabel(l10n, q),
          availabilityLabel: (v) => _availabilityLabel(l10n, v),
          voiceName: (v) => _voiceName(l10n, v),
        );
      },
    );
    if (selected == null || !mounted) return;
    widget.onSelected(selected);
    await ref.read(preferredVoiceProvider.notifier).setVoice(
          id: selected.id,
          locale: selected.locale,
          language: group.languageCode,
        );
  }

  String? _qualityLabel(AppLocalizations l10n, TtsVoiceQuality? quality) {
    if (quality == null) return null;
    return switch (quality) {
      TtsVoiceQuality.defaultQuality => l10n.voiceQualityDefault,
      TtsVoiceQuality.enhanced => l10n.voiceQualityEnhanced,
      TtsVoiceQuality.premium => l10n.voiceQualityPremium,
    };
  }

  String? _availabilityLabel(
    AppLocalizations l10n,
    TtsVoiceUiModel voice,
  ) {
    if (!widget.showAvailability) return null;
    return switch (voice.availability) {
      TtsVoiceAvailability.installedOffline => l10n.voiceAvailabilityOffline,
      TtsVoiceAvailability.networkRequired => l10n.voiceAvailabilityNetwork,
      TtsVoiceAvailability.notInstalled => l10n.voiceAvailabilityMissing,
    };
  }

  String _voiceName(AppLocalizations l10n, TtsVoiceUiModel voice) {
    if (voice.id.startsWith('default|') || voice.name == 'System Default') {
      return l10n.voiceSystemDefault;
    }
    return voice.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preferred = ref.watch(preferredVoiceProvider);
    final appLocale = ref.watch(localeProvider);
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final groups = VoiceCatalog.group(
      widget.voices,
      preferredLanguage: preferred.language,
      appLanguage: appLocale.languageCode,
      systemLanguage: systemLocale.languageCode,
      query: _search.text,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.header != null) ...[
          widget.header!,
          const SizedBox(height: AppConstants.spaceMd),
        ],
        TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: l10n.voicesSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
            child: Text(
              l10n.voicesEmpty,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          )
        else if (_search.text.trim().isNotEmpty)
          _VoiceFlatResults(
            groups: groups,
            selectedVoiceId: widget.selectedVoiceId,
            showAvailability: widget.showAvailability,
            qualityLabel: (q) => _qualityLabel(l10n, q),
            availabilityLabel: (v) => _availabilityLabel(l10n, v),
            voiceName: (v) => _voiceName(l10n, v),
            onSelected: (voice) async {
              widget.onSelected(voice);
              await ref.read(preferredVoiceProvider.notifier).setVoice(
                    id: voice.id,
                    locale: voice.locale,
                    language: VoiceCatalog.languageCodeOf(voice.locale),
                  );
            },
          )
        else ...[
          SectionHeader(title: l10n.voicesLanguages),
          for (final group in groups)
            Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
              child: SurfacePanel(
                onTap: () => _openLanguage(group, l10n),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.languageLabel,
                            style: context.textTheme.titleSmall,
                          ),
                          Text(
                            l10n.voicesLanguageCount(group.voiceCount),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Full voice list for one language (level 2).
class VoiceLanguagePickerSheet extends ConsumerStatefulWidget {
  const VoiceLanguagePickerSheet({
    super.key,
    required this.group,
    required this.selectedVoiceId,
    required this.showAvailability,
    required this.qualityLabel,
    required this.availabilityLabel,
    required this.voiceName,
  });

  final VoiceLanguageGroup group;
  final String? selectedVoiceId;
  final bool showAvailability;
  final String? Function(TtsVoiceQuality?) qualityLabel;
  final String? Function(TtsVoiceUiModel) availabilityLabel;
  final String Function(TtsVoiceUiModel) voiceName;

  @override
  ConsumerState<VoiceLanguagePickerSheet> createState() =>
      _VoiceLanguagePickerSheetState();
}

enum _PreviewPhase { idle, loading, playing }

class _VoiceLanguagePickerSheetState
    extends ConsumerState<VoiceLanguagePickerSheet> {
  String? _previewVoiceId;
  _PreviewPhase _phase = _PreviewPhase.idle;

  @override
  void deactivate() {
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  Future<void> _stopPreview() async {
    await ref.read(ttsServiceProvider).stop();
    if (mounted) {
      setState(() {
        _previewVoiceId = null;
        _phase = _PreviewPhase.idle;
      });
    }
  }

  Future<void> _preview(TtsVoiceUiModel voice, String sample) async {
    if (_previewVoiceId == voice.id && _phase != _PreviewPhase.idle) {
      await _stopPreview();
      return;
    }
    await _stopPreview();
    if (!mounted) return;
    setState(() {
      _previewVoiceId = voice.id;
      _phase = _PreviewPhase.loading;
    });
    try {
      setState(() => _phase = _PreviewPhase.playing);
      await ref.read(ttsServiceProvider).preview(
            text: sample,
            voiceId: voice.id,
            locale: voice.locale,
          );
    } finally {
      if (mounted && _previewVoiceId == voice.id) {
        setState(() {
          _previewVoiceId = null;
          _phase = _PreviewPhase.idle;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.85;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.group.languageLabel,
                    style: context.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.voicesSelectVoiceHint,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final locale in widget.group.locales) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      locale.localeLabel,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  for (final voice in locale.voices)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppConstants.spaceSm),
                      child: SurfacePanel(
                        emphasized: widget.selectedVoiceId == voice.id,
                        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                        child: Row(
                          children: [
                            Icon(
                              widget.selectedVoiceId == voice.id
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: widget.selectedVoiceId == voice.id
                                  ? context.colors.primary
                                  : context.colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: VoiceIdentityBlock(
                                languageLabel: LocaleDisplayNames.friendly(
                                  voice.locale,
                                ),
                                voiceName: widget.voiceName(voice),
                                qualityLabel: widget.qualityLabel(voice.quality),
                                availabilityLabel:
                                    widget.availabilityLabel(voice),
                              ),
                            ),
                            IconButton(
                              tooltip: _previewVoiceId == voice.id &&
                                      _phase != _PreviewPhase.idle
                                  ? l10n.alarmStop
                                  : l10n.ttsPreview,
                              onPressed: voice.isUsable
                                  ? () => _preview(
                                        voice,
                                        l10n.voicePreviewSample,
                                      )
                                  : null,
                              icon: _previewVoiceId == voice.id &&
                                      _phase == _PreviewPhase.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _previewVoiceId == voice.id &&
                                              _phase == _PreviewPhase.playing
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                            ),
                            TextButton(
                              onPressed: voice.isUsable
                                  ? () => Navigator.pop(context, voice)
                                  : null,
                              child: Text(
                                widget.selectedVoiceId == voice.id
                                    ? l10n.commonDone
                                    : l10n.voiceSelect,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceFlatResults extends ConsumerStatefulWidget {
  const _VoiceFlatResults({
    required this.groups,
    required this.selectedVoiceId,
    required this.showAvailability,
    required this.qualityLabel,
    required this.availabilityLabel,
    required this.voiceName,
    required this.onSelected,
  });

  final List<VoiceLanguageGroup> groups;
  final String? selectedVoiceId;
  final bool showAvailability;
  final String? Function(TtsVoiceQuality?) qualityLabel;
  final String? Function(TtsVoiceUiModel) availabilityLabel;
  final String Function(TtsVoiceUiModel) voiceName;
  final ValueChanged<TtsVoiceUiModel> onSelected;

  @override
  ConsumerState<_VoiceFlatResults> createState() => _VoiceFlatResultsState();
}

class _VoiceFlatResultsState extends ConsumerState<_VoiceFlatResults> {
  String? _previewVoiceId;
  _PreviewPhase _phase = _PreviewPhase.idle;

  @override
  void deactivate() {
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  Future<void> _preview(TtsVoiceUiModel voice, String sample) async {
    if (_previewVoiceId == voice.id && _phase != _PreviewPhase.idle) {
      await ref.read(ttsServiceProvider).stop();
      if (mounted) {
        setState(() {
          _previewVoiceId = null;
          _phase = _PreviewPhase.idle;
        });
      }
      return;
    }
    await ref.read(ttsServiceProvider).stop();
    if (!mounted) return;
    setState(() {
      _previewVoiceId = voice.id;
      _phase = _PreviewPhase.loading;
    });
    try {
      setState(() => _phase = _PreviewPhase.playing);
      await ref.read(ttsServiceProvider).preview(
            text: sample,
            voiceId: voice.id,
            locale: voice.locale,
          );
    } finally {
      if (mounted && _previewVoiceId == voice.id) {
        setState(() {
          _previewVoiceId = null;
          _phase = _PreviewPhase.idle;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final group in widget.groups)
          for (final locale in group.locales)
            for (final voice in locale.voices)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                child: SurfacePanel(
                  emphasized: widget.selectedVoiceId == voice.id,
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: voice.isUsable
                              ? () => widget.onSelected(voice)
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                widget.selectedVoiceId == voice.id
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: widget.selectedVoiceId == voice.id
                                    ? context.colors.primary
                                    : context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: VoiceIdentityBlock(
                                  languageLabel: LocaleDisplayNames.friendly(
                                    voice.locale,
                                  ),
                                  voiceName: widget.voiceName(voice),
                                  qualityLabel:
                                      widget.qualityLabel(voice.quality),
                                  availabilityLabel:
                                      widget.availabilityLabel(voice),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.ttsPreview,
                        onPressed: voice.isUsable
                            ? () => _preview(voice, l10n.voicePreviewSample)
                            : null,
                        icon: Icon(
                          _previewVoiceId == voice.id &&
                                  _phase == _PreviewPhase.playing
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

/// Opens the language → voice picker and returns the chosen voice.
Future<TtsVoiceUiModel?> showVoicePicker({
  required BuildContext context,
  required List<TtsVoiceUiModel> voices,
  String? selectedVoiceId,
  bool showAvailability = false,
}) {
  return showModalBottomSheet<TtsVoiceUiModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _VoicePickerHost(
        voices: voices,
        selectedVoiceId: selectedVoiceId,
        showAvailability: showAvailability,
      );
    },
  );
}

class _VoicePickerHost extends ConsumerStatefulWidget {
  const _VoicePickerHost({
    required this.voices,
    required this.selectedVoiceId,
    required this.showAvailability,
  });

  final List<TtsVoiceUiModel> voices;
  final String? selectedVoiceId;
  final bool showAvailability;

  @override
  ConsumerState<_VoicePickerHost> createState() => _VoicePickerHostState();
}

class _VoicePickerHostState extends ConsumerState<_VoicePickerHost> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.9;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: ListView(
          children: [
            VoiceBrowser(
              voices: widget.voices,
              selectedVoiceId: widget.selectedVoiceId,
              showAvailability: widget.showAvailability,
              onSelected: (voice) => Navigator.pop(context, voice),
            ),
          ],
        ),
      ),
    );
  }
}

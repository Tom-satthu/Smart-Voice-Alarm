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

enum _PreviewPhase { idle, loading, playing }

/// Inline device-voice browser: languages expand to show selectable voices.
class VoiceBrowser extends ConsumerStatefulWidget {
  const VoiceBrowser({
    super.key,
    required this.voices,
    required this.selectedVoiceId,
    required this.onSelected,
    this.showAvailability = false,
    this.header,
    this.friendlyLabels = const {},
    this.newlyInstalledIds = const {},
    this.initiallyExpandedLanguage,
  });

  final List<TtsVoiceUiModel> voices;
  final String? selectedVoiceId;
  final VoiceSelectedCallback onSelected;
  final bool showAvailability;
  final Widget? header;
  final Map<String, String> friendlyLabels;
  final Set<String> newlyInstalledIds;
  final String? initiallyExpandedLanguage;

  @override
  ConsumerState<VoiceBrowser> createState() => _VoiceBrowserState();
}

class _VoiceBrowserState extends ConsumerState<VoiceBrowser> {
  final _search = TextEditingController();
  final Set<String> _expanded = {};
  String? _previewVoiceId;
  _PreviewPhase _phase = _PreviewPhase.idle;

  @override
  void initState() {
    super.initState();
    final seed = widget.initiallyExpandedLanguage;
    if (seed != null && seed.isNotEmpty) {
      _expanded.add(seed);
    }
  }

  @override
  void didUpdateWidget(covariant VoiceBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    final seed = widget.initiallyExpandedLanguage;
    if (seed != null &&
        seed.isNotEmpty &&
        seed != oldWidget.initiallyExpandedLanguage) {
      _expanded.add(seed);
    }
  }

  @override
  void deactivate() {
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _voiceName(AppLocalizations l10n, TtsVoiceUiModel voice) {
    if (voice.isSystemDefault || voice.name == 'System Default') {
      return l10n.voiceSystemDefault;
    }
    return widget.friendlyLabels[voice.id] ?? l10n.voiceFriendlyName('01');
  }

  String? _availabilityLabel(AppLocalizations l10n, TtsVoiceUiModel voice) {
    if (voice.isSystemDefault) return l10n.voiceSystemDefaultHint;
    if (!widget.showAvailability) return null;
    return switch (voice.availability) {
      TtsVoiceAvailability.installedOffline => l10n.voiceAvailabilityOffline,
      TtsVoiceAvailability.networkRequired => l10n.voiceAvailabilityNetwork,
      TtsVoiceAvailability.notInstalled => l10n.voiceAvailabilityMissing,
    };
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

  Future<void> _preview(TtsVoiceUiModel voice) async {
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
      if (mounted) setState(() => _phase = _PreviewPhase.playing);
      await ref
          .read(ttsServiceProvider)
          .preview(
            text: VoiceCatalog.previewSampleForLocale(voice.locale),
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

  Future<void> _select(TtsVoiceUiModel voice) async {
    widget.onSelected(voice);
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
        else
          for (final group in groups)
            _LanguageSection(
              group: group,
              expanded:
                  _search.text.trim().isNotEmpty ||
                  _expanded.contains(group.languageCode),
              onToggle: () {
                setState(() {
                  if (_expanded.contains(group.languageCode)) {
                    _expanded.remove(group.languageCode);
                  } else {
                    _expanded.add(group.languageCode);
                  }
                });
              },
              selectedVoiceId: widget.selectedVoiceId,
              newlyInstalledIds: widget.newlyInstalledIds,
              voiceName: (v) => _voiceName(l10n, v),
              availabilityLabel: (v) => _availabilityLabel(l10n, v),
              previewVoiceId: _previewVoiceId,
              previewPhase: _phase,
              onSelect: _select,
              onPreview: _preview,
              voiceCountLabel: l10n.voicesLanguageCount(group.voiceCount),
              newBadge: l10n.voicesNewBadge,
            ),
      ],
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({
    required this.group,
    required this.expanded,
    required this.onToggle,
    required this.selectedVoiceId,
    required this.newlyInstalledIds,
    required this.voiceName,
    required this.availabilityLabel,
    required this.previewVoiceId,
    required this.previewPhase,
    required this.onSelect,
    required this.onPreview,
    required this.voiceCountLabel,
    required this.newBadge,
  });

  final VoiceLanguageGroup group;
  final bool expanded;
  final VoidCallback onToggle;
  final String? selectedVoiceId;
  final Set<String> newlyInstalledIds;
  final String Function(TtsVoiceUiModel) voiceName;
  final String? Function(TtsVoiceUiModel) availabilityLabel;
  final String? previewVoiceId;
  final _PreviewPhase previewPhase;
  final ValueChanged<TtsVoiceUiModel> onSelect;
  final ValueChanged<TtsVoiceUiModel> onPreview;
  final String voiceCountLabel;
  final String newBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurfacePanel(
            onTap: onToggle,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      Text(voiceCountLabel, style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: AppConstants.spaceSm),
            for (final locale in group.locales) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  locale.localeLabel,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              for (final voice in locale.voices)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                  child: _VoiceRow(
                    voice: voice,
                    selected: selectedVoiceId == voice.id,
                    isNew: newlyInstalledIds.contains(voice.id),
                    name: voiceName(voice),
                    availability: availabilityLabel(voice),
                    previewVoiceId: previewVoiceId,
                    previewPhase: previewPhase,
                    newBadge: newBadge,
                    onSelect: () => onSelect(voice),
                    onPreview: () => onPreview(voice),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  const _VoiceRow({
    required this.voice,
    required this.selected,
    required this.isNew,
    required this.name,
    required this.availability,
    required this.previewVoiceId,
    required this.previewPhase,
    required this.newBadge,
    required this.onSelect,
    required this.onPreview,
  });

  final TtsVoiceUiModel voice;
  final bool selected;
  final bool isNew;
  final String name;
  final String? availability;
  final String? previewVoiceId;
  final _PreviewPhase previewPhase;
  final String newBadge;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playing =
        previewVoiceId == voice.id && previewPhase == _PreviewPhase.playing;
    final loading =
        previewVoiceId == voice.id && previewPhase == _PreviewPhase.loading;

    return SurfacePanel(
      emphasized: selected,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: voice.isUsable ? onSelect : null,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: context.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  newBadge,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (availability != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            availability!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: playing ? l10n.alarmStop : l10n.ttsPreview,
            onPressed: voice.isUsable ? onPreview : null,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}

/// Opens an inline voice browser sheet and returns the chosen voice.
Future<TtsVoiceUiModel?> showVoicePicker({
  required BuildContext context,
  required List<TtsVoiceUiModel> voices,
  String? selectedVoiceId,
  bool showAvailability = false,
}) {
  final l10n = AppLocalizations.of(context);
  final labels = VoiceCatalog.friendlyLabels(
    voices,
    labelFor: l10n.voiceFriendlyName,
  );
  return showModalBottomSheet<TtsVoiceUiModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height * 0.9;
      return SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            children: [
              VoiceBrowser(
                voices: voices,
                selectedVoiceId: selectedVoiceId,
                showAvailability: showAvailability,
                friendlyLabels: labels,
                initiallyExpandedLanguage: selectedVoiceId == null
                    ? null
                    : VoiceCatalog.languageCodeOf(
                        voices
                            .firstWhere(
                              (v) => v.id == selectedVoiceId,
                              orElse: () => voices.first,
                            )
                            .locale,
                      ),
                onSelected: (voice) => Navigator.pop(context, voice),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Compact selected-voice summary card with preview.
class SelectedVoiceCard extends ConsumerStatefulWidget {
  const SelectedVoiceCard({
    super.key,
    required this.voice,
    required this.friendlyName,
  });

  final TtsVoiceUiModel voice;
  final String friendlyName;

  @override
  ConsumerState<SelectedVoiceCard> createState() => _SelectedVoiceCardState();
}

class _SelectedVoiceCardState extends ConsumerState<SelectedVoiceCard> {
  _PreviewPhase _phase = _PreviewPhase.idle;

  @override
  void deactivate() {
    ref.read(ttsServiceProvider).stop();
    super.deactivate();
  }

  Future<void> _togglePreview() async {
    if (_phase != _PreviewPhase.idle) {
      await ref.read(ttsServiceProvider).stop();
      if (mounted) setState(() => _phase = _PreviewPhase.idle);
      return;
    }
    setState(() => _phase = _PreviewPhase.loading);
    try {
      setState(() => _phase = _PreviewPhase.playing);
      await ref
          .read(ttsServiceProvider)
          .preview(
            text: VoiceCatalog.previewSampleForLocale(widget.voice.locale),
            voiceId: widget.voice.id,
            locale: widget.voice.locale,
          );
    } finally {
      if (mounted) setState(() => _phase = _PreviewPhase.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playing = _phase == _PreviewPhase.playing;
    return SurfacePanel(
      emphasized: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Icon(Icons.record_voice_over_rounded, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleDisplayNames.friendly(widget.voice.locale),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.friendlyName, style: context.textTheme.titleSmall),
              ],
            ),
          ),
          IconButton(
            tooltip: playing ? l10n.alarmStop : l10n.ttsPreview,
            onPressed: _togglePreview,
            icon: _phase == _PreviewPhase.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}

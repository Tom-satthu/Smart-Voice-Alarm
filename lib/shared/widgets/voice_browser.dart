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

/// Language → locale → voice browser used by Voices settings and TTS picker.
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
  String? _language;

  @override
  void initState() {
    super.initState();
    final preferred = ref.read(preferredVoiceProvider);
    _language = preferred.language;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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

    final effectiveLanguage = _language ?? preferred.language;
    final selectedGroup = groups.isEmpty
        ? null
        : groups.firstWhere(
            (g) => g.languageCode == effectiveLanguage,
            orElse: () => groups.first,
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
                emphasized: selectedGroup?.languageCode == group.languageCode,
                onTap: () async {
                  setState(() => _language = group.languageCode);
                  await ref
                      .read(preferredVoiceProvider.notifier)
                      .setLanguage(group.languageCode);
                },
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
                      selectedGroup?.languageCode == group.languageCode
                          ? Icons.expand_more_rounded
                          : Icons.chevron_right_rounded,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          if (selectedGroup != null) ...[
            const SizedBox(height: AppConstants.spaceMd),
            SectionHeader(
              title: selectedGroup.languageLabel,
              subtitle: l10n.voicesSelectVoiceHint,
            ),
            for (final locale in selectedGroup.locales) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
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
                  child: SurfacePanel(
                    emphasized: widget.selectedVoiceId == voice.id,
                    onTap: voice.isUsable
                        ? () async {
                            widget.onSelected(voice);
                            await ref
                                .read(preferredVoiceProvider.notifier)
                                .setVoice(
                                  id: voice.id,
                                  locale: voice.locale,
                                  language: selectedGroup.languageCode,
                                );
                          }
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                            voiceName: _voiceName(l10n, voice),
                            qualityLabel: _qualityLabel(l10n, voice.quality),
                            availabilityLabel:
                                _availabilityLabel(l10n, voice),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ],
      ],
    );
  }
}

class _VoiceFlatResults extends StatelessWidget {
  const _VoiceFlatResults({
    required this.groups,
    required this.selectedVoiceId,
    required this.qualityLabel,
    required this.availabilityLabel,
    required this.voiceName,
    required this.onSelected,
  });

  final List<VoiceLanguageGroup> groups;
  final String? selectedVoiceId;
  final String? Function(TtsVoiceQuality?) qualityLabel;
  final String? Function(TtsVoiceUiModel) availabilityLabel;
  final String Function(TtsVoiceUiModel) voiceName;
  final ValueChanged<TtsVoiceUiModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final group in groups)
          for (final locale in group.locales)
            for (final voice in locale.voices)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                child: SurfacePanel(
                  emphasized: selectedVoiceId == voice.id,
                  onTap: voice.isUsable ? () => onSelected(voice) : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedVoiceId == voice.id
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selectedVoiceId == voice.id
                            ? context.colors.primary
                            : context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: VoiceIdentityBlock(
                          languageLabel: LocaleDisplayNames.friendly(
                            voice.locale,
                          ),
                          voiceName: voiceName(voice),
                          qualityLabel: qualityLabel(voice.quality),
                          availabilityLabel: availabilityLabel(voice),
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

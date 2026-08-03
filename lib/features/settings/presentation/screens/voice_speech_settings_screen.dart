import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(ttsVoicesProvider);
      ref.invalidate(usableTtsVoicesProvider);
    }
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await ref.read(ttsPlatformBridgeProvider).checkTtsData();
      }
      ref.invalidate(ttsVoicesProvider);
      ref.invalidate(usableTtsVoicesProvider);
      await ref.read(ttsVoicesProvider.future);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadMore() async {
    final l10n = AppLocalizations.of(context);
    final bridge = ref.read(ttsPlatformBridgeProvider);

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voiceSpeechWebUnavailable)),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final opened = await bridge.openDownloadMoreVoices();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.voiceSpeechIosGuideTitle),
          content: Text(l10n.voiceSpeechIosGuideBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonDone),
            ),
          ],
        ),
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voiceSpeechIosGuideBody)),
        );
      }
      return;
    }

    final opened = await bridge.openDownloadMoreVoices();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? l10n.voiceSpeechAndroidGuide
              : l10n.voiceSpeechAndroidGuide,
        ),
      ),
    );
  }

  String _qualityLabel(AppLocalizations l10n, TtsVoiceQuality quality) {
    return switch (quality) {
      TtsVoiceQuality.defaultQuality => l10n.voiceQualityDefault,
      TtsVoiceQuality.enhanced => l10n.voiceQualityEnhanced,
      TtsVoiceQuality.premium => l10n.voiceQualityPremium,
    };
  }

  String _availabilityLabel(
    AppLocalizations l10n,
    TtsVoiceAvailability availability,
  ) {
    return switch (availability) {
      TtsVoiceAvailability.installedOffline => l10n.voiceAvailabilityOffline,
      TtsVoiceAvailability.networkRequired => l10n.voiceAvailabilityNetwork,
      TtsVoiceAvailability.notInstalled => l10n.voiceAvailabilityMissing,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicesAsync = ref.watch(ttsVoicesProvider);
    final preferred = ref.watch(preferredVoiceProvider);
    final canManage = ref.watch(ttsPlatformBridgeProvider).canManageSystemVoicePacks;

    return AppScaffold(
      showBack: true,
      title: l10n.voiceSpeechTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppConstants.spaceMd,
            bottom: AppConstants.space2xl,
          ),
          children: [
            SectionHeader(title: l10n.voiceSpeechSystemVoices),
            Text(
              l10n.voiceSpeechOfflineHint,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _refresh,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(l10n.voiceSpeechRefresh),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canManage ? _downloadMore : null,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l10n.voiceSpeechDownloadMore),
                  ),
                ),
              ],
            ),
            if (kIsWeb) ...[
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                l10n.voiceSpeechWebUnavailable,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceXl),
            voicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(l10n.voiceSpeechEmpty),
              data: (voices) {
                if (voices.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.record_voice_over_outlined,
                    title: l10n.voiceSpeechEmpty,
                    subtitle: l10n.voiceSpeechOfflineHint,
                    actionLabel: l10n.voiceSpeechEmptyCta,
                    onAction: canManage ? _downloadMore : null,
                  );
                }
                return Column(
                  children: [
                    for (final voice in voices)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spaceSm,
                        ),
                        child: SurfacePanel(
                          onTap: voice.isUsable
                              ? () {
                                  ref
                                      .read(preferredVoiceProvider.notifier)
                                      .setVoice(
                                        id: voice.id,
                                        locale: voice.locale,
                                      );
                                }
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                preferred.id == voice.id
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: preferred.id == voice.id
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
                                      '${voice.locale} · ${_qualityLabel(l10n, voice.quality)} · ${_availabilityLabel(l10n, voice.availability)}',
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (!voice.isUsable)
                                Icon(
                                  Icons.cloud_off_outlined,
                                  color: context.colors.onSurfaceVariant,
                                ),
                            ],
                          ),
                        ),
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

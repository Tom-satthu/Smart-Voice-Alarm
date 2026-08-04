import 'dart:async';

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

  Future<void> _reloadVoiceList() async {
    await ref.read(ttsServiceProvider).reloadVoices();
    // Give Samsung / Google TTS engines a moment to publish new packs.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await ref.read(ttsServiceProvider).reloadVoices();
    ref.invalidate(ttsVoicesProvider);
    ref.invalidate(usableTtsVoicesProvider);
    await ref.read(ttsVoicesProvider.future);
  }

  Future<void> _afterDownloadReturn() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await _reloadVoiceList();
      if (!mounted) return;
      final voices = await ref.read(ttsVoicesProvider.future);
      if (!mounted) return;
      if (voices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voicesEmpty)),
        );
        return;
      }
      final picked = await showVoicePicker(
        context: context,
        voices: voices,
        selectedVoiceId: ref.read(preferredVoiceProvider).id,
        showAvailability: true,
      );
      if (!mounted) return;
      if (picked == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voicesRefreshed(voices.length))),
        );
        return;
      }
      await _saveVoice(picked);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveVoice(TtsVoiceUiModel voice) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(preferredVoiceProvider.notifier).setVoice(
          id: voice.id,
          locale: voice.locale,
        );
    ref.invalidate(ttsVoicesProvider);
    await ref.read(ttsVoicesProvider.future);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.voicesSelectedSaved(voice.name))),
    );
  }

  Future<void> _downloadMore() async {
    final l10n = AppLocalizations.of(context);
    final bridge = ref.read(ttsPlatformBridgeProvider);

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voicesWebUnavailable)),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final opened = await bridge.openDownloadMoreVoices();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.voicesIosGuideTitle),
          content: Text(l10n.voicesIosGuideBody),
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
          SnackBar(content: Text(l10n.voicesIosGuideBody)),
        );
      }
      return;
    }

    _awaitingDownloadReturn = true;
    setState(() => _busy = true);
    try {
      await bridge.openDownloadMoreVoices();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voicesAsync = ref.watch(ttsVoicesProvider);
    final preferred = ref.watch(preferredVoiceProvider);
    final canManage =
        ref.watch(ttsPlatformBridgeProvider).canManageSystemVoicePacks;

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
            SectionHeader(
              title: l10n.voicesSystemVoices,
              subtitle: l10n.voicesOfflineHint,
            ),
            _DownloadVoicesCard(
              busy: _busy,
              enabled: canManage,
              label: l10n.voicesDownloadMore,
              subtitle: l10n.voicesDownloadThenSelect,
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
            voicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(l10n.voicesEmpty),
              data: (voices) {
                if (voices.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.record_voice_over_outlined,
                    title: l10n.voicesEmpty,
                    subtitle: l10n.voicesOfflineHint,
                    actionLabel: l10n.voicesEmptyCta,
                    onAction: canManage ? _downloadMore : null,
                  );
                }
                return VoiceBrowser(
                  voices: voices,
                  selectedVoiceId: preferred.id,
                  showAvailability: true,
                  onSelected: (voice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.voicesSelectedSaved(voice.name)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
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
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.28),
            ),
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
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../localization/generated/app_localizations.dart';
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

    await bridge.openDownloadMoreVoices();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.voicesAndroidGuide)),
    );
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
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: canManage ? _downloadMore : null,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l10n.voicesDownloadMore),
                  ),
                ),
                const SizedBox(width: 12),
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
                    label: Text(l10n.voicesRefresh),
                  ),
                ),
              ],
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
                  onSelected: (_) {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

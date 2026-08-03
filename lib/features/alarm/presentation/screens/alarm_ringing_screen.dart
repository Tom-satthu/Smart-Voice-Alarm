import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/alarm_engine.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';

class AlarmRingingScreen extends ConsumerStatefulWidget {
  const AlarmRingingScreen({super.key, required this.alarmId});

  final String alarmId;

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen> {
  late final AlarmEngine _engine;
  AlarmEnginePhase _phase = AlarmEnginePhase.idle;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(alarmEngineProvider);
    _engine.phaseStream.listen((phase) {
      if (!mounted) return;
      setState(() => _phase = phase);
      if (phase == AlarmEnginePhase.completed ||
          phase == AlarmEnginePhase.idle && !_engine.isRunning) {
        // Stay on screen until user dismisses.
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _engine.enqueue(widget.alarmId);
    });
  }

  Future<void> _dismiss() async {
    await _engine.stop();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alarm = ref.watch(alarmListProvider.notifier).findById(widget.alarmId);
    final title = alarm?.label ?? l10n.appName;
    final active = _phase == AlarmEnginePhase.playingVoice ||
        _phase == AlarmEnginePhase.playingRingtone;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceXl),
            child: Column(
              children: [
                const Spacer(),
                const BrandMark(size: 88, animated: true),
                const SizedBox(height: AppConstants.spaceXl),
                Text(title, style: context.textTheme.headlineLarge),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  _phase == AlarmEnginePhase.playingRingtone
                      ? l10n.alarmTypeRingtone
                      : l10n.alarmTypeVoice,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXl),
                WaveVisualizer(active: active),
                if (_engine.statusText != null) ...[
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(
                    _engine.statusText!,
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(),
                PrimaryActionButton(
                  label: l10n.commonDone,
                  icon: Icons.alarm_off_rounded,
                  onPressed: _dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

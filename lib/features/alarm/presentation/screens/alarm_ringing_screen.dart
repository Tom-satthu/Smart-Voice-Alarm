import 'dart:async';

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
  String? _activeId;
  StreamSubscription<AlarmEnginePhase>? _phaseSub;
  StreamSubscription<String?>? _activeSub;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(alarmEngineProvider);
    _activeId = widget.alarmId;
    _phaseSub = _engine.phaseStream.listen((phase) {
      if (!mounted) return;
      setState(() => _phase = phase);
    });
    _activeSub = _engine.activeAlarmStream.listen((id) {
      if (!mounted) return;
      setState(() => _activeId = id ?? _activeId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _engine.enqueue(widget.alarmId);
    });
  }

  @override
  void dispose() {
    _phaseSub?.cancel();
    _activeSub?.cancel();
    super.dispose();
  }

  Future<void> _stopCurrent() async {
    await _engine.stopCurrent();
    if (!mounted) return;
    // Give the queue a moment to promote the next alarm.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    if (_engine.isRunning && _engine.activeAlarmId != null) {
      setState(() => _activeId = _engine.activeAlarmId);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _stopAll() async {
    await _engine.stopAll();
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
    final id = _activeId ?? widget.alarmId;
    final alarm = ref.watch(alarmListProvider.notifier).findById(id);
    final title = alarm?.label ?? l10n.appName;
    final active = _phase == AlarmEnginePhase.playingVoice ||
        _phase == AlarmEnginePhase.playingRingtone;
    final queued = _engine.queuedCount;

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
                if (queued > 0) ...[
                  const SizedBox(height: AppConstants.spaceSm),
                  Text(
                    l10n.alarmQueueWaiting(queued),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
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
                  label: l10n.alarmStop,
                  icon: Icons.alarm_off_rounded,
                  onPressed: _stopCurrent,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                OutlinedButton.icon(
                  onPressed: _stopAll,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l10n.alarmStopAll),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

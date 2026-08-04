import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/alarm_math_challenge.dart';

class AlarmRingingScreen extends ConsumerStatefulWidget {
  const AlarmRingingScreen({
    super.key,
    required this.alarmId,
    this.openDismissChallenge = false,
  });

  final String alarmId;
  final bool openDismissChallenge;

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen> {
  late final AlarmEngine _engine;
  AlarmEnginePhase _phase = AlarmEnginePhase.idle;
  String? _activeId;
  StreamSubscription<AlarmEnginePhase>? _phaseSub;
  StreamSubscription<String?>? _activeSub;
  bool _showChallenge = false;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(alarmEngineProvider);
    _activeId = widget.alarmId;
    _showChallenge = widget.openDismissChallenge;
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
  void didUpdateWidget(covariant AlarmRingingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openDismissChallenge && !oldWidget.openDismissChallenge) {
      setState(() => _showChallenge = true);
    }
  }

  @override
  void dispose() {
    _phaseSub?.cancel();
    _activeSub?.cancel();
    super.dispose();
  }

  void _requestStop() {
    setState(() => _showChallenge = true);
  }

  /// Ends this alarm session: stop all playback, clear ringing route, and leave
  /// the app UI so the user does not land on Home/Settings with toggles.
  Future<void> _completeDismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    await _engine.stopAll();
    await ref.read(notificationServiceProvider).native.stopForegroundAlarm();
    if (!mounted) return;
    // Reset route so a later resume is not stuck on /ringing.
    context.go(AppRoutes.home);
    if (!kIsWeb) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = _activeId ?? widget.alarmId;
    final alarm = ref.watch(alarmListProvider.notifier).findById(id);
    final title = alarm?.label ?? l10n.appName;
    final active =
        _phase == AlarmEnginePhase.playingVoice ||
        _phase == AlarmEnginePhase.playingRingtone;
    final queued = _engine.queuedCount;

    final body = _showChallenge
        ? Scaffold(
            resizeToAvoidBottomInset: true,
            body: AlarmMathChallenge(
              onCancel: () => setState(() => _showChallenge = false),
              onSolved: _completeDismiss,
            ),
          )
        : Scaffold(
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
                        onPressed: _requestStop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_showChallenge) {
          setState(() => _showChallenge = false);
        }
        // While ringing, ignore system back — dismiss requires the challenge.
      },
      child: body,
    );
  }
}

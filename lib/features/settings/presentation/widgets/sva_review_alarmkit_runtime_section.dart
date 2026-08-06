import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/ios_alarm_scheduler.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Review-only AlarmKit runtime state card with recovery actions.
class SvaReviewAlarmKitRuntimeSection extends ConsumerStatefulWidget {
  const SvaReviewAlarmKitRuntimeSection({super.key, required this.visible});

  final bool visible;

  @visibleForTesting
  static const sectionTitle = 'AlarmKit runtime';

  @override
  ConsumerState<SvaReviewAlarmKitRuntimeSection> createState() =>
      _SvaReviewAlarmKitRuntimeSectionState();
}

class _SvaReviewAlarmKitRuntimeSectionState
    extends ConsumerState<SvaReviewAlarmKitRuntimeSection> {
  Map<String, dynamic> _state = const {};
  bool _loading = false;
  String? _testParentId;

  IosAlarmScheduler get _scheduler =>
      ref.read(notificationServiceProvider).iosFanout.scheduler;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
  }

  Future<void> _refresh() async {
    if (!widget.visible) return;
    setState(() => _loading = true);
    final raw = await _scheduler.passiveAlarmKitDiagnostics();
    if (!mounted) return;
    setState(() {
      _state = raw;
      _loading = false;
    });
  }

  String get _summary {
    if (_loading) return 'Loading runtime state…';
    final lines = <String>[
      'iOS=${_state['runtimeVersionEligible'] == true ? '26+' : 'legacy'}',
      'eligible=${_state['runtimeVersionEligible']}',
      'linked=${_state['frameworkLinked']}',
      'auth=${_state['cachedAuthorization'] ?? _state['authorization']}',
      'probe=${_state['probeEverSucceeded']}',
      'userDisabled=${_state['userDisabled']}',
      'diagOff=${_state['diagnosticForceOff']}',
      'sessionFailed=${_state['sessionProbeFailed']}',
      'backend=${_state['selectedBackend']}',
      'reason=${_state['backendSelectionReason']}',
      'probeErr=${_state['lastProbeError'] ?? ''}',
      'scheduleErr=${_state['lastScheduleError'] ?? ''}',
      'mappings=${_state['mappingCount'] ?? 0}',
      'pending=${_state['fanoutPendingCount'] ?? 0}',
    ];
    return lines.join('\n');
  }

  Future<void> _copyDiagnostics() async {
    await Clipboard.setData(ClipboardData(text: _summary));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Runtime diagnostics copied')));
  }

  Future<void> _resetLegacy() async {
    await _scheduler.debugClearAlarmKitKillSwitch();
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Legacy AlarmKit locks cleared')),
    );
  }

  Future<void> _probe() async {
    final result = await _scheduler.probeAlarmKitPassive();
    debugPrint('[SVA-Review] probe=$result');
    await _refresh();
  }

  Future<void> _requestAuth() async {
    final result = await _scheduler.requestAlarmKitAuthorization();
    debugPrint('[SVA-Review] requestAuth=$result');
    await _refresh();
  }

  Future<void> _scheduleTest() async {
    const parent = 'sva-diag-alarmkit-test';
    _testParentId = parent;
    final start = DateTime.now().add(const Duration(seconds: 60));
    final child = 'sva-diag-child-${start.millisecondsSinceEpoch}';
    await _scheduler.scheduleSegments(
      segments: [
        IosAlarmSegment(
          parentAlarmId: parent,
          occurrenceId: 'diag-occ',
          segmentIndex: 0,
          childId: child,
          startAt: start,
          soundFileName: '',
          duration: const Duration(seconds: 5),
          label: 'Diag test',
        ),
      ],
      title: 'AlarmKit diag test',
      body: 'Solve to stop',
      backend: 'alarmKit',
    );
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AlarmKit test scheduled ~60s')),
    );
  }

  Future<void> _cancelTest() async {
    final parent = _testParentId ?? 'sva-diag-alarmkit-test';
    await _scheduler.cancelParent(parent);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.spaceMd),
        const SectionHeader(
          title: SvaReviewAlarmKitRuntimeSection.sectionTitle,
        ),
        SettingTile(
          icon: Icons.memory_outlined,
          title: 'Runtime state',
          subtitle: _summary,
          onTap: _copyDiagnostics,
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _actionChip('Reset legacy', _resetLegacy),
            _actionChip('Probe', _probe),
            _actionChip('Request auth', _requestAuth),
            _actionChip('Test 60s', _scheduleTest),
            _actionChip('Cancel test', _cancelTest),
            _actionChip('Copy', _copyDiagnostics),
          ],
        ),
      ],
    );
  }

  Widget _actionChip(String label, VoidCallback onTap) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/ios_alarm_scheduler.dart';
import '../../../../shared/data/local_store.dart';
import '../../../../shared/models/ui_models.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Review-only AlarmKit runtime state card with recovery + sound probes.
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
  Map<String, dynamic> _lastSound = const {};
  bool _loading = false;
  String? _testParentId;
  String _soundMode = 'withExtension';

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
    final sound = await _scheduler.lastSoundDiagnostics();
    final mode = await _scheduler.getAlarmKitSoundNameMode();
    if (!mounted) return;
    setState(() {
      _state = raw;
      _lastSound = sound;
      _soundMode = mode;
      _loading = false;
    });
  }

  String get _summary {
    if (_loading) return 'Loading runtime state…';
    final sound = _lastSound;
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
      'soundMode=$_soundMode',
      'lastNamed=${sound['alertSoundNameExact'] ?? ''}',
      'lastExists=${sound['renderedExists']}',
      'lastPlayable=${sound['avPlayerPlayable']}',
      'lastDefault=${sound['usedDefault']}',
      'lastWarn=${sound['warningCode'] ?? ''}',
      'lastFmt=${sound['formatDescription'] ?? ''}',
      'lastSize=${sound['fileSize'] ?? ''}',
      'mappings=${_state['mappingCount'] ?? 0}',
    ];
    return lines.join('\n');
  }

  Future<void> _copyDiagnostics() async {
    final buf = StringBuffer(_summary)
      ..writeln()
      ..writeln('lastSound=$_lastSound');
    await Clipboard.setData(ClipboardData(text: buf.toString()));
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

  Future<void> _setMode(String mode) async {
    await _scheduler.setAlarmKitSoundNameMode(mode);
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sound name mode=$mode')));
  }

  Future<void> _scheduleTest({required String soundFileName}) async {
    const parent = 'sva-diag-alarmkit-test';
    _testParentId = parent;
    final start = DateTime.now().add(const Duration(seconds: 60));
    final child = 'sva-diag-child-${start.millisecondsSinceEpoch}';
    final outcome = await _scheduler.scheduleSegments(
      segments: [
        IosAlarmSegment(
          parentAlarmId: parent,
          occurrenceId: 'diag-occ',
          segmentIndex: 0,
          childId: child,
          startAt: start,
          soundFileName: soundFileName,
          duration: const Duration(seconds: 5),
          label: soundFileName.isEmpty ? 'system_default' : 'recording',
        ),
      ],
      title: 'AlarmKit sound probe',
      body: 'Solve to stop',
      backend: 'alarmKit',
      soundNameMode: _soundMode,
    );
    debugPrint('[SVA-Review] scheduleTest=$outcome');
    await _refresh();
    if (!mounted) return;
    final named = outcome['soundDiagnostics'] is Map
        ? (outcome['soundDiagnostics'] as Map)['alertSoundNameExact']
        : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'AlarmKit ~60s named=${named ?? '(default)'} mode=$_soundMode',
        ),
      ),
    );
  }

  Future<void> _cancelTest() async {
    final parent = _testParentId ?? 'sva-diag-alarmkit-test';
    await _scheduler.cancelParent(parent);
    await _refresh();
  }

  /// Renders a user recording through the production pipeline, then schedules
  /// one AlarmKit alarm in ~60s (no default sound).
  Future<void> _testRecordedVoice() async {
    final voices = SavedVoiceRepository().loadAll();
    final recording = voices.cast<VoiceSegmentUiModel?>().firstWhere(
      (v) =>
          v?.type == VoiceSegmentType.recording &&
          (v?.filePath?.isNotEmpty ?? false),
      orElse: () => null,
    );
    if (recording == null || recording.filePath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved recording found — record a voice first'),
        ),
      );
      return;
    }

    final fileName = 'sva_diag_rec_${const Uuid().v4().substring(0, 8)}.caf';
    try {
      final rendered = await _scheduler.renderSound(
        fileName: fileName,
        sourcePath: recording.filePath,
        maxSeconds: 20,
      );
      final diag = await _scheduler.diagnoseSoundFile(
        fileName: rendered.fileName,
        sourceType: 'recording',
      );
      debugPrint('[SVA-Review] recorded render diag=$diag');
      if (diag['avPlayerPlayable'] != true || diag['renderedExists'] != true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Render invalid exists=${diag['renderedExists']} '
              'playable=${diag['avPlayerPlayable']} warn=${diag['warningCode']}',
            ),
          ),
        );
        await _refresh();
        return;
      }
      await _scheduleTest(soundFileName: rendered.fileName);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Recorded voice AlarmKit probe'),
          content: SelectableText(
            'mode=$_soundMode\n'
            'file=${rendered.fileName}\n'
            'named=${diag['alertSoundNameExact']}\n'
            'exists=${diag['renderedExists']}\n'
            'size=${diag['fileSize']}\n'
            'durMs=${diag['durationMs']}\n'
            'fmt=${diag['formatDescription']}\n'
            'playable=${diag['avPlayerPlayable']}\n'
            'Listen in ~60s. Note if you hear YOUR voice or system default.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('[SVA-Review] recorded probe failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recorded probe failed: $e')));
    }
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
            _actionChip('Mode .caf', () => _setMode('withExtension')),
            _actionChip('Mode bare', () => _setMode('withoutExtension')),
            _actionChip('Test recorded voice 60s', _testRecordedVoice),
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

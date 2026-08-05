import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Simple arithmetic challenge used to dismiss a ringing alarm.
class AlarmMathChallenge extends StatefulWidget {
  const AlarmMathChallenge({
    super.key,
    required this.onSolved,
    required this.onCancel,
  });

  final Future<void> Function() onSolved;
  final VoidCallback onCancel;

  @override
  State<AlarmMathChallenge> createState() => _AlarmMathChallengeState();
}

class _AlarmMathChallengeState extends State<AlarmMathChallenge> {
  late int _a;
  late int _b;
  late bool _addition;
  late int _answer;
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _roll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _roll() {
    final rng = Random();
    _addition = rng.nextBool();
    if (_addition) {
      _a = 2 + rng.nextInt(12);
      _b = 2 + rng.nextInt(12);
      _answer = _a + _b;
    } else {
      _a = 8 + rng.nextInt(12);
      _b = 1 + rng.nextInt(_a - 1);
      _answer = _a - _b;
    }
    _controller.clear();
    _error = null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value != _answer) {
      setState(() {
        _error = l10n.alarmDismissWrong;
        _roll();
      });
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      await widget.onSolved();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expression = _addition ? '$_a + $_b' : '$_a − $_b';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: context.colors.surface.withValues(alpha: 0.97),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppConstants.spaceLg,
                AppConstants.spaceSm,
                AppConstants.spaceLg,
                AppConstants.spaceLg + bottomInset,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: l10n.commonBack,
                          onPressed: _submitting ? null : widget.onCancel,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      Text(
                        l10n.alarmDismissTitle,
                        style: context.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        l10n.alarmDismissHint,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      SurfacePanel(
                        emphasized: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceLg,
                          vertical: AppConstants.spaceXl,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            expression,
                            style: context.textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      TextField(
                        controller: _controller,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                        ],
                        decoration: InputDecoration(
                          hintText: l10n.alarmDismissAnswerHint,
                          errorText: _error,
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      PrimaryActionButton(
                        label: l10n.alarmDismissCheck,
                        icon: Icons.check_rounded,
                        onPressed: _submitting ? null : _submit,
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

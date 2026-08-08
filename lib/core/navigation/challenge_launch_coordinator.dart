import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../services/ios_alarm_scheduler.dart';
import 'challenge_session.dart';
import 'root_navigator.dart';

/// Durable Math Challenge launch coordinator — survives cold/warm start races.
class ChallengeLaunchCoordinator {
  ChallengeLaunchCoordinator._();

  static final instance = ChallengeLaunchCoordinator._();

  final Map<String, IosPendingChallenge> _queue = {};
  bool _routerReady = false;
  Timer? _retryTimer;
  IosAlarmScheduler? _scheduler;
  int _retryAttempts = 0;

  static const _maxRetries = 120;
  static const _retryDelay = Duration(milliseconds: 50);

  void bindScheduler(IosAlarmScheduler scheduler) {
    _scheduler = scheduler;
  }

  String _key(IosPendingChallenge challenge) =>
      '${challenge.parentAlarmId}|${challenge.occurrenceId}';

  void enqueue(IosPendingChallenge challenge) {
    if (!challenge.openChallenge || challenge.parentAlarmId.isEmpty) return;
    final key = _key(challenge);
    _queue[key] = challenge;
    debugPrint(
      '[SVA-Challenge] coordinator enqueue key=$key routerReady=$_routerReady',
    );
    _scheduleRetry();
  }

  void markRouterReady() {
    if (_routerReady) return;
    _routerReady = true;
    _retryAttempts = 0;
    debugPrint('[SVA-Challenge] coordinator router ready');
    _scheduleRetry(immediate: true);
  }

  void resetForTests() {
    _queue.clear();
    _routerReady = false;
    _retryAttempts = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  bool isQueued(String parentAlarmId, String occurrenceId) =>
      _queue.containsKey('$parentAlarmId|$occurrenceId');

  void _scheduleRetry({bool immediate = false}) {
    _retryTimer?.cancel();
    if (immediate) {
      scheduleMicrotask(_tryNavigate);
      return;
    }
    _retryTimer = Timer(_retryDelay, _tryNavigate);
  }

  void _tryNavigate() {
    if (!_routerReady || _queue.isEmpty) return;

    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      _retryAttempts++;
      if (_retryAttempts < _maxRetries) _scheduleRetry();
      return;
    }

    GoRouter router;
    try {
      router = GoRouter.of(ctx);
    } catch (_) {
      _retryAttempts++;
      if (_retryAttempts < _maxRetries) _scheduleRetry();
      return;
    }

    for (final challenge in _queue.values.toList()) {
      final path = AppRoutes.ringingPath(
        challenge.parentAlarmId,
        challenge: true,
        occurrenceId: challenge.occurrenceId,
      );
      final current = router.state.uri.toString();
      if (current == path) {
        unawaited(
          acknowledgeOpened(challenge.parentAlarmId, challenge.occurrenceId),
        );
        _queue.remove(_key(challenge));
        continue;
      }
      markChallengeOpen(challenge.parentAlarmId, challenge.occurrenceId);
      router.go(path);
      debugPrint(
        '[SVA-Challenge] coordinator navigated to $path from $current',
      );
      unawaited(
        acknowledgeOpened(challenge.parentAlarmId, challenge.occurrenceId),
      );
      _queue.remove(_key(challenge));
    }
    _retryAttempts = 0;
  }

  Future<void> acknowledgeOpened(
    String parentAlarmId,
    String occurrenceId,
  ) async {
    final scheduler = _scheduler;
    if (scheduler == null || !scheduler.isSupported) return;
    await scheduler.acknowledgePendingChallenge(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
    );
  }

  Future<void> clearAfterSolved({
    required String parentAlarmId,
    required String occurrenceId,
  }) async {
    clearChallengeKey(parentAlarmId, occurrenceId);
    _queue.remove('$parentAlarmId|$occurrenceId');
    final scheduler = _scheduler;
    if (scheduler == null || !scheduler.isSupported) return;
    await scheduler.clearPendingChallengeAfterSolve(
      parentAlarmId: parentAlarmId,
      occurrenceId: occurrenceId,
    );
  }

  /// Cold start: enqueue peeked pending and return initial route when applicable.
  String? initialLocationFor(IosPendingChallenge? pending) {
    if (pending == null || pending.parentAlarmId.isEmpty) return null;
    enqueue(pending);
    return AppRoutes.ringingPath(
      pending.parentAlarmId,
      challenge: true,
      occurrenceId: pending.occurrenceId,
    );
  }
}

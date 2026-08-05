import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'core/navigation/challenge_session.dart';
import 'core/navigation/root_navigator.dart';
import 'core/services/ios_alarm_scheduler.dart';
import 'core/services/notification_service.dart';
import 'router/routes.dart';
import 'shared/data/local_store.dart';
import 'shared/providers/prototype_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[SVA-Startup] begin');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Light startup only: local store + notification handlers + pending route.
  await LocalDatabase.initFlutter();
  await seedPrototypeDataIfNeeded();

  final notifications = NotificationService();
  await notifications.init();
  debugPrint('[SVA-Startup] store+notifications ready');

  final container = ProviderContainer(
    overrides: [notificationServiceProvider.overrideWithValue(notifications)],
  );

  notifications.onAlarmTriggered = (alarmId) {
    unawaited(_openRinging(container, alarmId));
  };

  notifications.onIosChallenge = (challenge) {
    unawaited(_openIosChallenge(container, challenge, consumePending: false));
  };

  final native = notifications.native;
  native.onAlarmTriggered = (alarmId) {
    notifications.onAlarmTriggered?.call(alarmId);
  };
  native.onRequestDismissChallenge = (alarmId) {
    unawaited(_openRinging(container, alarmId, challenge: true));
  };
  native.onNativeAlarmStopped = () {
    unawaited(container.read(alarmEngineProvider).stopAll());
  };
  native.attachPlatformHandlers();

  String? initialLocation;
  try {
    final iosPending = await notifications.consumeIosPendingChallenge();
    if (iosPending != null && iosPending.parentAlarmId.isNotEmpty) {
      initialLocation = AppRoutes.ringingPath(
        iosPending.parentAlarmId,
        challenge: iosPending.openChallenge,
        occurrenceId: iosPending.occurrenceId,
      );
      markChallengeOpen(iosPending.parentAlarmId, iosPending.occurrenceId);
    } else {
      final launchAlarmId = await notifications.consumeLaunchAlarmId();
      final launchChallenge = await notifications
          .consumeLaunchDismissChallenge();
      if (launchAlarmId != null) {
        initialLocation = AppRoutes.ringingPath(
          launchAlarmId,
          challenge: launchChallenge,
        );
      }
    }
  } catch (error, stack) {
    debugPrint('[SVA-Startup] launch routing failed: $error\n$stack');
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint(details.toString());
    }
  };

  // CRITICAL: never await iOS audio render / fan-out rebuild before first frame.
  // Android may still sync schedules after UI is up via the same post-frame path.
  debugPrint('[SVA-Startup] runApp');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: SmartVoiceAlarmApp(initialLocation: initialLocation),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_postUiStartup(container, notifications));
  });
}

/// Runs after the first Flutter frame. Must not block UI or abort the process.
Future<void> _postUiStartup(
  ProviderContainer container,
  NotificationService notifications,
) async {
  debugPrint('[SVA-Startup] post-frame reconcile begin');
  try {
    // Reminder is FLN-only and does not touch native audio renderers.
    await container.read(reminderSettingsProvider.notifier).ensureScheduled();
  } catch (error, stack) {
    debugPrint('[SVA-Startup] reminder schedule failed: $error\n$stack');
  }

  final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  if (isIos) {
    try {
      await notifications.reconcileIosAlarmsWithoutRender(
        container.read(alarmListProvider),
      );
    } catch (error, stack) {
      debugPrint('[SVA-Startup] iOS light reconcile failed: $error\n$stack');
    }
  } else {
    // Non-iOS: full reschedule is safe (Android native AlarmManager path).
    try {
      await notifications.rescheduleAll(container.read(alarmListProvider));
    } catch (error, stack) {
      debugPrint('[SVA-Startup] non-iOS reschedule failed: $error\n$stack');
    }
  }
  debugPrint('[SVA-Startup] post-frame reconcile done');
}

Future<void> _openIosChallenge(
  ProviderContainer container,
  IosPendingChallenge challenge, {
  required bool consumePending,
}) async {
  if (!markChallengeOpen(challenge.parentAlarmId, challenge.occurrenceId)) {
    return;
  }
  if (consumePending) {
    await container
        .read(notificationServiceProvider)
        .consumeIosPendingChallenge();
  }
  await _openRinging(
    container,
    challenge.parentAlarmId,
    challenge: challenge.openChallenge,
    occurrenceId: challenge.occurrenceId,
    skipEngineEnqueue: true,
  );
}

Future<void> _openRinging(
  ProviderContainer container,
  String alarmId, {
  bool challenge = false,
  String? occurrenceId,
  bool skipEngineEnqueue = false,
}) async {
  final engine = container.read(alarmEngineProvider);
  final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  if (!skipEngineEnqueue && !isIos) {
    unawaited(engine.enqueue(alarmId));
  }
  final ctx = rootNavigatorKey.currentContext;
  final path = AppRoutes.ringingPath(
    alarmId,
    challenge: challenge,
    occurrenceId: occurrenceId,
  );
  if (ctx != null && ctx.mounted) {
    final current = GoRouter.of(ctx).state.uri.toString();
    if (current.contains('/ringing/') &&
        current.contains(alarmId) &&
        challenge) {
      GoRouter.of(ctx).go(path);
      return;
    }
    GoRouter.of(ctx).go(path);
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final later = rootNavigatorKey.currentContext;
      if (later != null && later.mounted) {
        GoRouter.of(later).go(path);
      }
    });
  }
}

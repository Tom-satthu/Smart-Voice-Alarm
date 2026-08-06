import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'core/debug/sva_build_stamp.dart';
import 'core/navigation/challenge_session.dart';
import 'core/navigation/root_navigator.dart';
import 'core/services/ios_alarm_scheduler.dart';
import 'core/services/notification_service.dart';
import 'core/services/saved_voice_usage_service.dart';
import 'router/routes.dart';
import 'shared/data/local_store.dart';
import 'shared/providers/prototype_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SvaBuildStamp.logStartup();
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
    debugPrint(
      '[SVA-Challenge] pendingConsumed=${iosPending != null} '
      'parentAlarmId=${iosPending?.parentAlarmId ?? ''} '
      'occurrenceId=${iosPending?.occurrenceId ?? ''}',
    );
    if (iosPending != null && iosPending.parentAlarmId.isNotEmpty) {
      initialLocation = AppRoutes.ringingPath(
        iosPending.parentAlarmId,
        challenge: true,
        occurrenceId: iosPending.occurrenceId,
      );
      markChallengeOpen(iosPending.parentAlarmId, iosPending.occurrenceId);
      debugPrint('[SVA-Challenge] initialRoute=$initialLocation');
    } else {
      final launchAlarmId = await notifications.consumeLaunchAlarmId();
      final launchChallenge = await notifications
          .consumeLaunchDismissChallenge();
      if (launchAlarmId != null) {
        initialLocation = AppRoutes.ringingPath(
          launchAlarmId,
          challenge: launchChallenge,
        );
        debugPrint(
          '[SVA-Challenge] initialRoute=$initialLocation '
          '(launchAlarm challenge=$launchChallenge)',
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
    debugPrint('[SVA-Launch] first frame');
    unawaited(_postUiStartup(container, notifications));
    if (SvaBuildStamp.reviewBuild || SvaBuildStamp.hasDartStamp) {
      unawaited(
        SvaBuildStamp.fetchNativeStamp().then((native) {
          debugPrint(
            '[SVA-Build] native ${SvaBuildStamp.formatForSettings(native: native)}',
          );
        }),
      );
    }
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
    try {
      final linked = await SavedVoiceUsageService().migrateSourceLinks();
      debugPrint('[SVA-Startup] saved-voice links migrated=$linked');
      final orphans = await SavedVoiceUsageService().migrateOrphanSequences();
      debugPrint('[SVA-Startup] orphan sequences noted=$orphans');
    } catch (error, stack) {
      debugPrint('[SVA-Startup] saved-voice migration failed: $error\n$stack');
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

  if (SvaBuildStamp.autoProbe && isIos) {
    unawaited(_runReviewAutoProbe(notifications));
  }
}

Future<void> _openIosChallenge(
  ProviderContainer container,
  IosPendingChallenge challenge, {
  required bool consumePending,
}) async {
  // Do not use markChallengeOpen as a gate for the first navigation.
  markChallengeOpen(challenge.parentAlarmId, challenge.occurrenceId);
  if (consumePending) {
    await container
        .read(notificationServiceProvider)
        .consumeIosPendingChallenge();
    debugPrint('[SVA-Challenge] pendingConsumed=true');
  }
  final path = AppRoutes.ringingPath(
    challenge.parentAlarmId,
    challenge: true,
    occurrenceId: challenge.occurrenceId,
  );
  debugPrint(
    '[SVA-Challenge] parentAlarmId=${challenge.parentAlarmId} '
    'occurrenceId=${challenge.occurrenceId} initialRoute=$path',
  );
  await _openRinging(
    container,
    challenge.parentAlarmId,
    challenge: true,
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
  debugPrint(
    '[SVA-Challenge] routerLocation target=$path challenge=$challenge',
  );
  if (ctx != null && ctx.mounted) {
    GoRouter.of(ctx).go(path);
    debugPrint(
      '[SVA-Challenge] routerLocation now=${GoRouter.of(ctx).state.uri}',
    );
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final later = rootNavigatorKey.currentContext;
      if (later != null && later.mounted) {
        GoRouter.of(later).go(path);
        debugPrint(
          '[SVA-Challenge] routerLocation deferred=${GoRouter.of(later).state.uri}',
        );
      }
    });
  }
}

/// Review-only automated staged probe (SVA_DIAG_AUTO_PROBE=1, not production).
Future<void> _runReviewAutoProbe(NotificationService notifications) async {
  final scheduler = notifications.iosFanout.scheduler;
  try {
    final counters = await scheduler.alarmKitStartupCounters();
    debugPrint('[SVA-ReviewProbe] startup counters=$counters');
    final probe = await scheduler.probeAlarmKitPassive();
    debugPrint('[SVA-ReviewProbe] passive probe=$probe');
    if (probe['ok'] != true) return;
    final auth = await scheduler.requestAlarmKitAuthorization();
    debugPrint('[SVA-ReviewProbe] authorization=$auth');
  } catch (error, stack) {
    debugPrint('[SVA-ReviewProbe] failed: $error\n$stack');
  }
}

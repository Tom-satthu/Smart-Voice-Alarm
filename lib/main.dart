import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'core/debug/sva_build_stamp.dart';
import 'core/debug/sva_startup_timing.dart';
import 'core/navigation/challenge_launch_coordinator.dart';
import 'core/navigation/root_navigator.dart';
import 'core/services/ios_alarm_scheduler.dart';
import 'core/services/notification_service.dart';
import 'core/services/saved_voice_usage_service.dart';
import 'router/routes.dart';
import 'shared/data/local_store.dart';
import 'shared/providers/prototype_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SvaStartupTiming.begin();
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

  await LocalDatabase.initFlutter();
  SvaStartupTiming.mark('database_ready');
  await seedPrototypeDataIfNeeded();
  SvaStartupTiming.mark('seed_ready');

  final notifications = NotificationService();
  SvaStartupTiming.mark('notification_init_begin');
  await notifications.init();
  SvaStartupTiming.mark('notification_init_end');
  debugPrint('[SVA-Startup] store+notifications ready');

  final coordinator = ChallengeLaunchCoordinator.instance;
  coordinator.bindScheduler(notifications.iosFanout.scheduler);

  final container = ProviderContainer(
    overrides: [notificationServiceProvider.overrideWithValue(notifications)],
  );

  notifications.onAlarmTriggered = (alarmId) {
    unawaited(_openRinging(container, alarmId));
  };

  notifications.onIosChallenge = (challenge) {
    coordinator.enqueue(challenge);
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
    final iosPending = await notifications.peekIosPendingChallenge();
    debugPrint(
      '[SVA-Challenge] pendingPeek=${iosPending != null} '
      'parentAlarmId=${iosPending?.parentAlarmId ?? ''} '
      'occurrenceId=${iosPending?.occurrenceId ?? ''}',
    );
    initialLocation = coordinator.initialLocationFor(iosPending);
    if (initialLocation != null) {
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

  debugPrint('[SVA-Startup] runApp');
  SvaStartupTiming.mark('runApp');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: SmartVoiceAlarmApp(initialLocation: initialLocation),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('[SVA-Launch] first frame');
    SvaStartupTiming.mark('first_frame');
    coordinator.markRouterReady();
    unawaited(_postUiStartup(container, notifications));
    if (SvaBuildStamp.reviewBuild || SvaBuildStamp.hasDartStamp) {
      unawaited(
        SvaBuildStamp.fetchNativeStamp().then((nativeStamp) {
          debugPrint(
            '[SVA-Build] native ${SvaBuildStamp.formatForSettings(native: nativeStamp)}',
          );
        }),
      );
    }
  });
}

Future<void> _postUiStartup(
  ProviderContainer container,
  NotificationService notifications,
) async {
  debugPrint('[SVA-Startup] post-frame reconcile begin');
  try {
    await container
        .read(alarmListProvider.notifier)
        .reconcileNativeParentLifecycle();
  } catch (error, stack) {
    debugPrint(
      '[SVA-Startup] parent lifecycle reconcile failed: $error\n$stack',
    );
  }
  try {
    await container.read(reminderSettingsProvider.notifier).ensureScheduled();
  } catch (error, stack) {
    debugPrint('[SVA-Startup] reminder schedule failed: $error\n$stack');
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      await container
          .read(reminderSettingsProvider.notifier)
          .requestPermissionForFirstLaunch();
    } catch (error, stack) {
      debugPrint(
        '[SVA-Startup] first-launch notification permission failed: '
        '$error\n$stack',
      );
    }
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
    // Non-critical migrations — after first frame.
    unawaited(() async {
      try {
        final linked = await SavedVoiceUsageService().migrateSourceLinks();
        debugPrint('[SVA-Startup] saved-voice links migrated=$linked');
        final orphans = await SavedVoiceUsageService().migrateOrphanSequences();
        debugPrint('[SVA-Startup] orphan sequences noted=$orphans');
      } catch (error, stack) {
        debugPrint(
          '[SVA-Startup] saved-voice migration failed: $error\n$stack',
        );
      }
    }());
  } else {
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
  if (challenge && occurrenceId != null && occurrenceId.isNotEmpty) {
    ChallengeLaunchCoordinator.instance.enqueue(
      IosPendingChallenge(
        parentAlarmId: alarmId,
        occurrenceId: occurrenceId,
        childId: '',
        segmentIndex: 0,
        scheduledTimestamp: 0,
      ),
    );
    return;
  }
  final ctx = rootNavigatorKey.currentContext;
  final path = AppRoutes.ringingPath(
    alarmId,
    challenge: challenge,
    occurrenceId: occurrenceId,
  );
  if (ctx != null && ctx.mounted) {
    GoRouter.of(ctx).go(path);
  }
}

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

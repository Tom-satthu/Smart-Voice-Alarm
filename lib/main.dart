import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'core/navigation/root_navigator.dart';
import 'core/services/notification_service.dart';
import 'router/routes.dart';
import 'shared/data/local_store.dart';
import 'shared/providers/prototype_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await seedPrototypeDataIfNeeded();

  final notifications = NotificationService();
  await notifications.init();

  final container = ProviderContainer(
    overrides: [
      notificationServiceProvider.overrideWithValue(notifications),
    ],
  );

  // Sync store entitlement before schedules so free-limit gates are correct.
  await container.read(premiumPurchaseProvider.notifier).init();

  // Sync native / local schedules with persisted alarms.
  await notifications.rescheduleAll(container.read(alarmListProvider));
  await container.read(reminderSettingsProvider.notifier).ensureScheduled();

  notifications.onAlarmTriggered = (alarmId) {
    unawaited(_openRinging(container, alarmId));
  };

  // Native → Flutter: notification tap / full-screen while app is warm, and
  // notification Stop action.
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

  final launchAlarmId = await notifications.consumeLaunchAlarmId();
  final launchChallenge = await notifications.consumeLaunchDismissChallenge();
  if (launchAlarmId != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _openRinging(
          container,
          launchAlarmId,
          challenge: launchChallenge,
        ),
      );
    });
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint(details.toString());
    }
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SmartVoiceAlarmApp(),
    ),
  );
}

Future<void> _openRinging(
  ProviderContainer container,
  String alarmId, {
  bool challenge = false,
}) async {
  final engine = container.read(alarmEngineProvider);
  unawaited(engine.enqueue(alarmId));
  final ctx = rootNavigatorKey.currentContext;
  final path = AppRoutes.ringingPath(alarmId, challenge: challenge);
  if (ctx != null && ctx.mounted) {
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

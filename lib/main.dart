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

  await container.read(reminderSettingsProvider.notifier).ensureScheduled();

  notifications.onAlarmTriggered = (alarmId) {
    unawaited(_openRinging(container, alarmId));
  };

  final launchAlarmId = await notifications.consumeLaunchAlarmId();
  if (launchAlarmId != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_openRinging(container, launchAlarmId));
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

Future<void> _openRinging(ProviderContainer container, String alarmId) async {
  final engine = container.read(alarmEngineProvider);
  unawaited(engine.enqueue(alarmId));
  final ctx = rootNavigatorKey.currentContext;
  if (ctx != null && ctx.mounted) {
    GoRouter.of(ctx).go(AppRoutes.ringingPath(alarmId));
  }
}

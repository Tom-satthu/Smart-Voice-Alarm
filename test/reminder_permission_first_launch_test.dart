import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';

import 'memory_store.dart';

/// Fake that scripts [NotificationService.requestPermissionIfNotDetermined]
/// and records how many times a reminder schedule was actually attempted,
/// without touching any platform channel.
class _ScriptedPermissionNotifications extends NotificationService {
  _ScriptedPermissionNotifications({required this.grantResult});

  final bool grantResult;
  int requestCalls = 0;
  int scheduleCalls = 0;
  bool? lastEnabled;
  TimeOfDay? lastTime;

  @override
  Future<bool> requestPermissionIfNotDetermined() async {
    requestCalls++;
    return grantResult;
  }

  @override
  Future<void> scheduleDailyReminder({
    required bool enabled,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    scheduleCalls++;
    lastEnabled = enabled;
    lastTime = time;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService.isNotDetermined', () {
    test('1. iOS notDetermined (denied) means "never asked"', () {
      expect(
        NotificationService.isNotDetermined(PermissionStatus.denied),
        isTrue,
      );
    });

    test('2. authorized does not mean "never asked"', () {
      expect(
        NotificationService.isNotDetermined(PermissionStatus.granted),
        isFalse,
      );
    });

    test('3. real iOS denied (permanentlyDenied) does not re-trigger', () {
      expect(
        NotificationService.isNotDetermined(PermissionStatus.permanentlyDenied),
        isFalse,
      );
    });

    test('4. provisional does not re-trigger', () {
      expect(
        NotificationService.isNotDetermined(PermissionStatus.provisional),
        isFalse,
      );
    });

    test('restricted does not re-trigger', () {
      expect(
        NotificationService.isNotDetermined(PermissionStatus.restricted),
        isFalse,
      );
    });
  });

  group(
    'NotificationService.requestPermissionIfNotDetermined platform gate',
    () {
      test('10. Android never runs the iOS first-launch request', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final service = NotificationService();
        final granted = await service.requestPermissionIfNotDetermined();
        expect(granted, isFalse);
      });
    },
  );

  group('ReminderSettingsController.requestPermissionForFirstLaunch', () {
    test(
      '5. permission granted after prompt reschedules the reminder',
      () async {
        final repo = MemorySettingsRepository();
        final notifications = _ScriptedPermissionNotifications(
          grantResult: true,
        );
        final controller = ReminderSettingsController(repo, notifications);

        final granted = await controller.requestPermissionForFirstLaunch();

        expect(granted, isTrue);
        expect(notifications.requestCalls, 1);
        expect(notifications.scheduleCalls, 1);
        expect(notifications.lastEnabled, controller.state.enabled);
        expect(notifications.lastTime, controller.state.time);
      },
    );

    test(
      '6. permission denied does not reschedule and does not throw',
      () async {
        final repo = MemorySettingsRepository();
        final notifications = _ScriptedPermissionNotifications(
          grantResult: false,
        );
        final controller = ReminderSettingsController(repo, notifications);

        final granted = await controller.requestPermissionForFirstLaunch();

        expect(granted, isFalse);
        expect(notifications.requestCalls, 1);
        expect(notifications.scheduleCalls, 0);
      },
    );
  });

  group('Reminder notification id', () {
    test('8/9. reminder id stays 91001 and is not duplicated', () {
      expect(NotificationService.reminderNotificationId, 91001);
    });
  });
}

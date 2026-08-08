import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/alarm_lifecycle_service.dart';
import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/features/alarm/presentation/screens/create_alarm_screen.dart';
import 'package:smart_voice_alarm/localization/generated/app_localizations.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';
import 'package:smart_voice_alarm/theme/theme_provider.dart';

import 'memory_store.dart';

class _RecordingNotifications extends NotificationService {
  final List<String> cancelled = [];
  final List<AlarmUiModel> scheduled = [];
  int scheduleCalls = 0;

  @override
  Future<bool> get notificationPermissionGranted async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<void> cancelAlarm(String alarmId) async {
    cancelled.add(alarmId);
  }

  @override
  Future<AlarmScheduleResult> scheduleAlarm(
    AlarmUiModel alarm, {
    VoiceSequenceUiModel? sequenceOverride,
  }) async {
    scheduleCalls++;
    if (!alarm.isEnabled) {
      cancelled.add(alarm.id);
      return AlarmScheduleResult.ok(stage: 'notification_schedule');
    }
    scheduled.add(alarm);
    return AlarmScheduleResult.ok(stage: 'notification_schedule');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlarmUiModel mathChallengeEnabled', () {
    test('13. missing JSON field defaults to true', () {
      final alarm = AlarmUiModel.fromJson({
        'id': 'a1',
        'hour': 7,
        'minute': 0,
        'repeatDays': <String>[],
        'isEnabled': true,
        'type': 'ringtone',
        'label': 'A',
      });
      expect(alarm.mathChallengeEnabled, isTrue);
    });

    test('14. new model default is true', () {
      const alarm = AlarmUiModel(
        id: 'n',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.ringtone,
        label: 'N',
      );
      expect(alarm.mathChallengeEnabled, isTrue);
    });

    test('15. copyWith/toJson round-trip false', () {
      const base = AlarmUiModel(
        id: 'n',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: {},
        isEnabled: true,
        type: AlarmType.ringtone,
        label: 'N',
        mathChallengeEnabled: false,
      );
      final round = AlarmUiModel.fromJson(base.toJson());
      expect(round.mathChallengeEnabled, isFalse);
      expect(
        base.copyWith(mathChallengeEnabled: true).mathChallengeEnabled,
        isTrue,
      );
    });
  });

  group('AlarmLifecycleService one-shot / repeating', () {
    late MemoryAlarmRepository repo;
    late _RecordingNotifications notifications;
    late AlarmListController controller;
    late AlarmLifecycleService lifecycle;

    setUp(() {
      repo = MemoryAlarmRepository(const []);
      notifications = _RecordingNotifications();
      controller = AlarmListController(
        repo,
        notifications,
        MemoryVoiceSequenceRepository([TestSeedData.sequence]),
      );
      lifecycle = AlarmLifecycleService(
        alarms: controller,
        notifications: notifications,
      );
    });

    test(
      '1-2. one-shot solve persists OFF and does not schedule next',
      () async {
        final oneShot = AlarmUiModel(
          id: 'oneshot',
          time: const TimeOfDay(hour: 6, minute: 30),
          repeatDays: const {},
          isEnabled: true,
          type: AlarmType.ringtone,
          label: 'Once',
          ringtoneName: 'Soft Chime',
        );
        await controller.add(oneShot);
        notifications.scheduled.clear();
        notifications.scheduleCalls = 0;

        await lifecycle.completeAlarmOccurrence(
          alarmId: oneShot.id,
          occurrenceId: 'occ-1',
        );

        final saved = controller.findById(oneShot.id);
        expect(saved, isNotNull);
        expect(saved!.isEnabled, isFalse);
        expect(
          notifications.scheduled.where((a) => a.isEnabled),
          isEmpty,
          reason: 'must not schedule next occurrence for one-shot',
        );
      },
    );

    test('3. legacy repeating stays enabled and schedules next', () async {
      final repeating = AlarmUiModel(
        id: 'repeat',
        time: const TimeOfDay(hour: 7, minute: 0),
        repeatDays: {Weekday.monday, Weekday.wednesday},
        isEnabled: true,
        type: AlarmType.ringtone,
        label: 'Repeat',
        ringtoneName: 'Soft Chime',
      );
      await controller.add(repeating);
      notifications.scheduled.clear();
      notifications.scheduleCalls = 0;

      await lifecycle.completeAlarmOccurrence(
        alarmId: repeating.id,
        occurrenceId: 'occ-2',
      );

      final saved = controller.findById(repeating.id);
      expect(saved!.isEnabled, isTrue);
      expect(notifications.scheduled, isNotEmpty);
      expect(notifications.scheduled.last.id, repeating.id);
      expect(notifications.scheduled.last.isEnabled, isTrue);
    });

    test('4. toggle OFF cancels and persists disabled', () async {
      final alarm = AlarmUiModel(
        id: 'tog',
        time: const TimeOfDay(hour: 8, minute: 0),
        repeatDays: const {},
        isEnabled: true,
        type: AlarmType.ringtone,
        label: 'T',
        ringtoneName: 'Soft Chime',
      );
      await controller.add(alarm);
      notifications.cancelled.clear();
      await controller.toggle(alarm.id);
      expect(controller.findById(alarm.id)!.isEnabled, isFalse);
      expect(notifications.cancelled, contains(alarm.id));
    });

    test('10. one-shot remains OFF after reload', () async {
      final oneShot = AlarmUiModel(
        id: 'persist-off',
        time: const TimeOfDay(hour: 5, minute: 0),
        repeatDays: const {},
        isEnabled: true,
        type: AlarmType.ringtone,
        label: 'P',
        ringtoneName: 'Soft Chime',
      );
      await controller.add(oneShot);
      await lifecycle.completeAlarmOccurrence(alarmId: oneShot.id);
      await controller.reload();
      expect(controller.findById(oneShot.id)!.isEnabled, isFalse);
    });
  });

  group('Math challenge UI + locales', () {
    testWidgets('22. switch is below alarm type', (tester) async {
      final settingsRepo = MemorySettingsRepository();
      final alarmRepo = MemoryAlarmRepository(const []);
      final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
      final notifications = _RecordingNotifications();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alarmRepositoryProvider.overrideWithValue(alarmRepo),
            sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
            savedVoiceRepositoryProvider.overrideWithValue(
              MemorySavedVoiceRepository(),
            ),
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            notificationServiceProvider.overrideWithValue(notifications),
            alarmListProvider.overrideWith(
              (ref) => AlarmListController(alarmRepo, notifications, sequenceRepo),
            ),
            themeModeProvider.overrideWith(
              (ref) => ThemeController(settingsRepo),
            ),
            localeProvider.overrideWith(
              (ref) => LocaleController(settingsRepo),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: CreateAlarmScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final typeHeader = find.text('Alarm type');
      await tester.scrollUntilVisible(
        typeHeader,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(typeHeader, findsOneWidget);
      expect(
        find.byKey(const ValueKey('math_challenge_toggle')),
        findsOneWidget,
      );
      final typeY = tester.getTopLeft(typeHeader).dy;
      final challengeY = tester
          .getTopLeft(find.byKey(const ValueKey('math_challenge_toggle')))
          .dy;
      expect(challengeY, greaterThan(typeY));
    });

    test('23. all supported locales have non-empty math challenge strings', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        expect(
          l10n.mathChallengeTitle.trim(),
          isNotEmpty,
          reason: '$locale title',
        );
        expect(
          l10n.mathChallengeDescription.trim(),
          isNotEmpty,
          reason: '$locale description',
        );
      }
    });
  });
}

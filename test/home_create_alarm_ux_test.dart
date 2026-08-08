import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/app/app.dart';
import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/core/services/premium_purchase_service.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';
import 'package:smart_voice_alarm/features/alarm/presentation/screens/create_alarm_screen.dart';
import 'package:smart_voice_alarm/localization/generated/app_localizations.dart';
import 'package:smart_voice_alarm/router/routes.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';
import 'package:smart_voice_alarm/theme/theme_provider.dart';

import 'memory_store.dart';

class _RecordingNotificationService extends NotificationService {
  final List<AlarmUiModel> scheduled = [];

  @override
  Future<bool> get notificationPermissionGranted async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<AlarmScheduleResult> scheduleAlarm(
    AlarmUiModel alarm, {
    VoiceSequenceUiModel? sequenceOverride,
  }) async {
    scheduled.add(alarm);
    return AlarmScheduleResult.ok(stage: 'notification_schedule');
  }
}

class _ActiveTrialController extends TrialEntitlementController {
  _ActiveTrialController(MemorySettingsRepository repository)
    : super(
        trial: TrialEntitlementService(
          store: SettingsTrialEntitlementStore(repository),
        ),
        initializeBilling: () async => const PremiumPurchaseState.initial(),
        refreshBilling: () async => const PremiumPurchaseState.initial(),
      ) {
    state = TrialEntitlementState(
      status: EntitlementStatus.trialActive,
      trialStartedAtUtc: DateTime.utc(2026, 8, 4),
      latestTrustedLocalTimeUtc: DateTime.utc(2026, 8, 4),
      remaining: const Duration(days: 7),
    );
  }

  @override
  Future<void> initializeSuccessfulLaunch() async {}

  @override
  Future<void> refreshOnResume() async {}
}

List<Override> _overrides({
  List<AlarmUiModel>? alarms,
  _RecordingNotificationService? notifications,
}) {
  final alarmRepo = MemoryAlarmRepository(alarms ?? const []);
  final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
  final savedVoiceRepo = MemorySavedVoiceRepository();
  final settingsRepo = MemorySettingsRepository();
  final notif = notifications ?? _RecordingNotificationService();
  return [
    alarmRepositoryProvider.overrideWithValue(alarmRepo),
    sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
    savedVoiceRepositoryProvider.overrideWithValue(savedVoiceRepo),
    settingsRepositoryProvider.overrideWithValue(settingsRepo),
    notificationServiceProvider.overrideWithValue(notif),
    trialEntitlementProvider.overrideWith(
      (ref) => _ActiveTrialController(settingsRepo),
    ),
    alarmListProvider.overrideWith(
      (ref) => AlarmListController(alarmRepo, notif, sequenceRepo),
    ),
    themeModeProvider.overrideWith((ref) => ThemeController(settingsRepo)),
    localeProvider.overrideWith((ref) => LocaleController(settingsRepo)),
    reminderSettingsProvider.overrideWith(
      (ref) => ReminderSettingsController(settingsRepo, notif),
    ),
    savedVoicesProvider.overrideWith(
      (ref) => SavedVoicesController(savedVoiceRepo),
    ),
  ];
}

Future<void> _pumpFrames(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<void> _pumpHome(
  WidgetTester tester, {
  List<AlarmUiModel>? alarms,
  _RecordingNotificationService? notifications,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: ProviderScope(
        overrides: _overrides(alarms: alarms, notifications: notifications),
        child: const SmartVoiceAlarmApp(initialLocation: AppRoutes.home),
      ),
    ),
  );
  await tester.pump();
  await _pumpFrames(tester);
}

Finder get _weekdayChipTexts => find.textContaining(
  RegExp(r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|T2|T3|T4|T5|T6|T7|CN)$'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1. empty alarm list shows one empty-state create CTA, no FAB', (
    tester,
  ) async {
    await _pumpHome(tester, alarms: const []);
    expect(find.text('No alarms yet'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home_empty_create_alarm')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('empty_state_action')), findsOneWidget);
    expect(find.text('Create Alarm'), findsOneWidget);
    expect(find.byKey(const ValueKey('home_create_alarm_fab')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('2. non-empty alarm list shows FAB and hides empty CTA', (
    tester,
  ) async {
    await _pumpHome(tester, alarms: TestSeedData.alarms);
    expect(find.text('No alarms yet'), findsNothing);
    expect(find.byKey(const ValueKey('home_empty_create_alarm')), findsNothing);
    expect(find.byKey(const ValueKey('home_create_alarm_fab')), findsOneWidget);
    expect(find.text('Create Alarm'), findsOneWidget);
  });

  testWidgets('3. loaded empty list never shows FAB with empty CTA', (
    tester,
  ) async {
    await _pumpHome(tester, alarms: const []);
    // AlarmListController loads sync — after first frame, states are exclusive.
    expect(
      find.byKey(const ValueKey('home_empty_create_alarm')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home_create_alarm_fab')), findsNothing);
    expect(find.text('Create Alarm'), findsOneWidget);
  });

  testWidgets('4. empty-state CTA opens New Alarm via shared action', (
    tester,
  ) async {
    await _pumpHome(tester, alarms: const []);
    await tester.tap(find.byKey(const ValueKey('empty_state_action')));
    await _pumpFrames(tester);
    expect(find.text('New Alarm'), findsOneWidget);
    expect(find.text('Save Alarm'), findsOneWidget);
  });

  testWidgets('5. FAB opens the same New Alarm screen', (tester) async {
    await _pumpHome(tester, alarms: TestSeedData.alarms);
    await tester.tap(find.byKey(const ValueKey('home_create_alarm_fab')));
    await _pumpFrames(tester);
    expect(find.text('New Alarm'), findsOneWidget);
    expect(find.text('Save Alarm'), findsOneWidget);
  });

  testWidgets('6. New Alarm screen has no weekday Repeat section', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: CreateAlarmScreen(),
        ),
      ),
    );
    await tester.pump();
    await _pumpFrames(tester);
    expect(find.text('Repeat'), findsNothing);
    expect(_weekdayChipTexts, findsNothing);
    expect(find.text('New Alarm'), findsOneWidget);
  });

  testWidgets('7. Edit Alarm screen has no weekday Repeat section', (
    tester,
  ) async {
    final existing = TestSeedData.alarms.first;
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(alarms: TestSeedData.alarms),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: CreateAlarmScreen(alarmId: existing.id),
        ),
      ),
    );
    await tester.pump();
    await _pumpFrames(tester);
    expect(find.text('Edit Alarm'), findsOneWidget);
    expect(find.text('Repeat'), findsNothing);
    expect(_weekdayChipTexts, findsNothing);
  });

  testWidgets('8. new alarm saves with empty weekday repeat and schedules', (
    tester,
  ) async {
    final notifications = _RecordingNotificationService();
    late AlarmListController controller;
    final alarmRepo = MemoryAlarmRepository(const []);
    final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
    final settingsRepo = MemorySettingsRepository();
    controller = AlarmListController(alarmRepo, notifications, sequenceRepo);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: ProviderScope(
          overrides: [
            ..._overrides(notifications: notifications),
            alarmRepositoryProvider.overrideWithValue(alarmRepo),
            sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            alarmListProvider.overrideWith((ref) => controller),
          ],
          child: const SmartVoiceAlarmApp(initialLocation: AppRoutes.home),
        ),
      ),
    );
    await tester.pump();
    await _pumpFrames(tester);

    await tester.tap(find.byKey(const ValueKey('empty_state_action')));
    await _pumpFrames(tester);
    expect(find.text('New Alarm'), findsOneWidget);

    final ringtoneChip = find.widgetWithText(FilterChip, 'Ringtone');
    await tester.scrollUntilVisible(ringtoneChip, 300);
    await tester.tap(ringtoneChip);
    await _pumpFrames(tester);
    await tester.tap(find.text('Save Alarm'));
    await _pumpFrames(tester);

    expect(notifications.scheduled, isNotEmpty);
    final saved = notifications.scheduled.last;
    expect(saved.repeatDays, isEmpty);
    expect(controller.state.any((a) => a.repeatDays.isEmpty), isTrue);
  });

  testWidgets('9. legacy alarm with weekdays loads, edits, and keeps days', (
    tester,
  ) async {
    final notifications = _RecordingNotificationService();
    final legacy = AlarmUiModel(
      id: 'legacy-weekdays',
      time: const TimeOfDay(hour: 6, minute: 30),
      repeatDays: {Weekday.monday, Weekday.wednesday, Weekday.friday},
      isEnabled: true,
      type: AlarmType.ringtone,
      label: 'Legacy',
      ringtoneName: 'Soft Chime',
      repeatCount: 1,
    );
    late AlarmListController controller;
    final alarmRepo = MemoryAlarmRepository([legacy]);
    final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
    final settingsRepo = MemorySettingsRepository();
    controller = AlarmListController(alarmRepo, notifications, sequenceRepo);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: ProviderScope(
          overrides: [
            ..._overrides(alarms: [legacy], notifications: notifications),
            alarmRepositoryProvider.overrideWithValue(alarmRepo),
            sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            alarmListProvider.overrideWith((ref) => controller),
          ],
          child: const SmartVoiceAlarmApp(initialLocation: AppRoutes.home),
        ),
      ),
    );
    await tester.pump();
    await _pumpFrames(tester);

    expect(find.text('Legacy'), findsOneWidget);
    await tester.tap(find.text('06:30'));
    await _pumpFrames(tester);

    expect(find.text('Edit Alarm'), findsOneWidget);
    expect(find.text('Repeat'), findsNothing);

    await tester.tap(find.text('Save Alarm'));
    await _pumpFrames(tester);

    expect(notifications.scheduled, isNotEmpty);
    final saved = notifications.scheduled.last;
    expect(saved.label, 'Legacy');
    expect(saved.repeatDays, {
      Weekday.monday,
      Weekday.wednesday,
      Weekday.friday,
    });
    final listed = controller.findById(legacy.id);
    expect(listed, isNotNull);
    expect(listed!.repeatDays, {
      Weekday.monday,
      Weekday.wednesday,
      Weekday.friday,
    });
  });
}

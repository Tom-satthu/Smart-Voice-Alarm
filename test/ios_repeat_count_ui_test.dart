import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/core/services/premium_purchase_service.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';
import 'package:smart_voice_alarm/features/alarm/presentation/screens/create_alarm_screen.dart';
import 'package:smart_voice_alarm/localization/generated/app_localizations.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';
import 'package:smart_voice_alarm/theme/theme_provider.dart';

import 'memory_store.dart';

class _GrantedNotificationService extends NotificationService {
  @override
  Future<bool> get notificationPermissionGranted async => true;

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<AlarmScheduleResult> scheduleAlarm(
    AlarmUiModel alarm, {
    VoiceSequenceUiModel? sequenceOverride,
  }) async {
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

List<Override> _overrides() {
  final alarmRepo = MemoryAlarmRepository(const []);
  final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
  final savedVoiceRepo = MemorySavedVoiceRepository();
  final settingsRepo = MemorySettingsRepository();
  final notifications = _GrantedNotificationService();
  return [
    alarmRepositoryProvider.overrideWithValue(alarmRepo),
    sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
    savedVoiceRepositoryProvider.overrideWithValue(savedVoiceRepo),
    settingsRepositoryProvider.overrideWithValue(settingsRepo),
    notificationServiceProvider.overrideWithValue(notifications),
    trialEntitlementProvider.overrideWith(
      (ref) => _ActiveTrialController(settingsRepo),
    ),
    alarmListProvider.overrideWith(
      (ref) => AlarmListController(alarmRepo, notifications, sequenceRepo),
    ),
    themeModeProvider.overrideWith((ref) => ThemeController(settingsRepo)),
    localeProvider.overrideWith((ref) => LocaleController(settingsRepo)),
    reminderSettingsProvider.overrideWith(
      (ref) => ReminderSettingsController(settingsRepo, notifications),
    ),
    savedVoicesProvider.overrideWith(
      (ref) => SavedVoicesController(savedVoiceRepo),
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('repeat count UI platform gate', () {
    testWidgets('24. iOS hides sequence repeats field', (tester) async {
      final previous = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
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
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Sequence repeats'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = previous;
      }
    });

    testWidgets('25. Android shows sequence repeats field', (tester) async {
      final previous = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
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
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Sequence repeats'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = previous;
      }
    });

    test('26. Vietnamese and English validation strings', () async {
      final vi = await AppLocalizations.delegate.load(const Locale('vi'));
      expect(vi.ttsTooLongDuration.isNotEmpty, isTrue);
      expect(vi.recordAutoStopped.isNotEmpty, isTrue);
      expect(vi.ttsCharCounter(10, 160), contains('10'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(en.ttsTooLongDuration.isNotEmpty, isTrue);
      expect(en.recordTimerLabel(20, 20), contains('20'));
    });
  });
}

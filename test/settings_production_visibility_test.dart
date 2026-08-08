import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/app/app.dart';
import 'package:smart_voice_alarm/core/config/release_config.dart';
import 'package:smart_voice_alarm/core/debug/sva_build_stamp.dart';
import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/core/services/premium_purchase_service.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';
import 'package:smart_voice_alarm/features/settings/presentation/widgets/sva_review_alarmkit_runtime_section.dart';
import 'package:smart_voice_alarm/features/settings/presentation/widgets/sva_review_build_stamp_section.dart';
import 'package:smart_voice_alarm/localization/generated/app_localizations.dart';
import 'package:smart_voice_alarm/router/routes.dart';
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

Future<void> _pumpFrames(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<AppLocalizations> _pumpSettings(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(390, 1200)),
      child: ProviderScope(
        overrides: _overrides(),
        child: const SmartVoiceAlarmApp(initialLocation: AppRoutes.settings),
      ),
    ),
  );
  await tester.pump();
  await _pumpFrames(tester);
  return AppLocalizations.of(
    tester.element(find.byKey(const ValueKey('settings_list'))),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings production UI hides review/diagnostics internals', (
    tester,
  ) async {
    final l10n = await _pumpSettings(tester);

    expect(find.byKey(const ValueKey('settings_list')), findsOneWidget);

    // Internal / review-only surfaces must not appear.
    expect(find.text(SvaReviewBuildStampSection.sectionTitle), findsNothing);
    expect(find.text(SvaReviewBuildStampSection.stampTileTitle), findsNothing);
    expect(
      find.text(SvaReviewAlarmKitRuntimeSection.sectionTitle),
      findsNothing,
    );
    expect(find.text(l10n.iosAlarmDiagnosticsTitle), findsNothing);
    expect(find.text('Debug'), findsNothing);
    expect(find.textContaining('BINARY_UUID'), findsNothing);
    expect(find.textContaining('SVA_BUILD='), findsNothing);
    expect(find.textContaining('SVA_DIAG_STAGE'), findsNothing);
    expect(find.textContaining('build SHA'), findsNothing);
    expect(find.textContaining('binary UUID'), findsNothing);

    // User-facing production sections remain.
    Future<void> ensureVisible(Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('settings_list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await _pumpFrames(tester, 2);
    }

    expect(find.text(l10n.settingsLanguage), findsOneWidget);
    expect(find.text(l10n.settingsTheme), findsOneWidget);
    if (ReleaseConfig.showPremium) {
      await ensureVisible(find.text(l10n.settingsPremium).first);
      expect(find.text(l10n.settingsPremium), findsWidgets);
    }
    expect(find.text(l10n.notificationPermission), findsOneWidget);

    await ensureVisible(find.text(l10n.contactSupport));
    expect(find.text(l10n.contactSupport), findsOneWidget);
    await ensureVisible(find.text(l10n.settingsPrivacy));
    expect(find.text(l10n.settingsPrivacy), findsOneWidget);
    await ensureVisible(find.text(l10n.settingsTerms));
    expect(find.text(l10n.settingsTerms), findsOneWidget);
    await ensureVisible(find.text(l10n.settingsAbout));
    expect(find.text(l10n.settingsAbout), findsOneWidget);
    await ensureVisible(find.text(l10n.appVersion));
    expect(find.text(l10n.appVersion), findsOneWidget);
  });

  test('release defaults keep autoProbe and reviewBuild off', () {
    expect(SvaBuildStamp.reviewBuild, isFalse);
    expect(SvaBuildStamp.autoProbe, isFalse);
  });
}

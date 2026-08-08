import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/app/app.dart';
import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/core/services/premium_purchase_service.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';
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
    // Avoid the trial banner so empty-state CTA stays hittable in tests.
    state = const TrialEntitlementState(
      status: EntitlementStatus.subscriptionActive,
    );
  }

  @override
  Future<void> initializeSuccessfulLaunch() async {}

  @override
  Future<void> refreshOnResume() async {}
}

const _emptySequence = VoiceSequenceUiModel(
  id: 'seq-1',
  name: 'Morning motivation',
  segments: [],
);

const _singleSegmentSequence = VoiceSequenceUiModel(
  id: 'seq-1',
  name: 'Morning motivation',
  segments: [
    VoiceSegmentUiModel(
      id: 'seg-only',
      name: 'Only voice',
      type: VoiceSegmentType.tts,
      duration: Duration(seconds: 6),
      text: 'Wake up',
      localeId: 'en-US',
    ),
  ],
);

List<Override> _overrides({
  required VoiceSequenceUiModel sequence,
  VoiceSequenceController? Function(VoiceSequenceController)? capture,
}) {
  final alarmRepo = MemoryAlarmRepository(const []);
  final sequenceRepo = MemoryVoiceSequenceRepository([sequence]);
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
    voiceSequenceProvider.overrideWith((ref, id) {
      final controller = VoiceSequenceController(
        sequenceRepo,
        sequenceRepo.findById(id) ?? sequence,
        savedVoiceRepo,
        true,
      );
      capture?.call(controller);
      return controller;
    }),
  ];
}

Future<void> _pumpFrames(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<void> _pumpVoiceSequence(
  WidgetTester tester, {
  required VoiceSequenceUiModel sequence,
  VoiceSequenceController? Function(VoiceSequenceController)? capture,
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
        overrides: _overrides(sequence: sequence, capture: capture),
        child: SmartVoiceAlarmApp(
          initialLocation: AppRoutes.voiceSequencePath(sequence.id),
        ),
      ),
    ),
  );
  await tester.pump();
  await _pumpFrames(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1. empty segments: one Add Voice CTA, no FAB', (tester) async {
    await _pumpVoiceSequence(tester, sequence: _emptySequence);

    expect(find.byKey(const ValueKey('voice_sequence_empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('empty_state_action')), findsOneWidget);
    expect(find.byKey(const ValueKey('voice_sequence_add_fab')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Add Voice'), findsOneWidget);
  });

  testWidgets('2. non-empty segments: FAB only, no empty CTA', (tester) async {
    await _pumpVoiceSequence(tester, sequence: _singleSegmentSequence);

    expect(find.byKey(const ValueKey('voice_sequence_empty')), findsNothing);
    expect(find.byKey(const ValueKey('empty_state_action')), findsNothing);
    expect(
      find.byKey(const ValueKey('voice_sequence_add_fab')),
      findsOneWidget,
    );
    expect(find.text('Add Voice'), findsOneWidget);
    expect(find.text('Wake up'), findsOneWidget);
  });

  testWidgets('3. empty CTA opens AddVoiceScreen', (tester) async {
    await _pumpVoiceSequence(tester, sequence: _emptySequence);
    await tester.tap(find.byKey(const ValueKey('empty_state_action')));
    await _pumpFrames(tester);
    expect(find.text('Add Voice'), findsWidgets);
    // Record / TTS choices on AddVoiceScreen
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.addVoiceRecord), findsOneWidget);
    expect(find.text(l10n.addVoiceTts), findsOneWidget);
  });

  testWidgets('4. FAB opens the same AddVoiceScreen', (tester) async {
    await _pumpVoiceSequence(tester, sequence: _singleSegmentSequence);
    await tester.tap(find.byKey(const ValueKey('voice_sequence_add_fab')));
    await _pumpFrames(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.addVoiceRecord), findsOneWidget);
    expect(find.text(l10n.addVoiceTts), findsOneWidget);
  });

  testWidgets('5. deleting last voice shows empty CTA and hides FAB', (
    tester,
  ) async {
    await _pumpVoiceSequence(tester, sequence: _singleSegmentSequence);
    expect(
      find.byKey(const ValueKey('voice_sequence_add_fab')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('More options'));
    await _pumpFrames(tester);
    await tester.tap(find.text('Delete'));
    await _pumpFrames(tester);
    await tester.tap(find.text('Remove'));
    await _pumpFrames(tester);

    expect(find.byKey(const ValueKey('voice_sequence_empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('empty_state_action')), findsOneWidget);
    expect(find.byKey(const ValueKey('voice_sequence_add_fab')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Add Voice'), findsOneWidget);
  });

  testWidgets('6. adding first voice shows list and FAB', (tester) async {
    late VoiceSequenceController controller;
    await _pumpVoiceSequence(
      tester,
      sequence: _emptySequence,
      capture: (c) {
        controller = c;
        return c;
      },
    );
    expect(find.byKey(const ValueKey('voice_sequence_empty')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await controller.add(
      const VoiceSegmentUiModel(
        id: 'saved-1',
        name: 'First voice',
        type: VoiceSegmentType.tts,
        duration: Duration(seconds: 4),
        text: 'Hello',
        localeId: 'en-US',
      ),
    );
    await _pumpFrames(tester);

    expect(find.byKey(const ValueKey('voice_sequence_empty')), findsNothing);
    expect(find.byKey(const ValueKey('empty_state_action')), findsNothing);
    expect(
      find.byKey(const ValueKey('voice_sequence_add_fab')),
      findsOneWidget,
    );
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Add Voice'), findsOneWidget);
  });
}

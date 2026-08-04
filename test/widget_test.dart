import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/app/app.dart';
import 'package:smart_voice_alarm/core/services/notification_service.dart';
import 'package:smart_voice_alarm/core/services/premium_purchase_service.dart';
import 'package:smart_voice_alarm/core/services/trial_entitlement_service.dart';
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

List<Override> _memoryOverrides({
  List<AlarmUiModel>? alarms,
  VoiceSequenceUiModel? sequence,
  bool emptyAlarms = false,
}) {
  final alarmRepo = MemoryAlarmRepository(
    emptyAlarms ? const [] : (alarms ?? TestSeedData.alarms),
  );
  final sequenceRepo = MemoryVoiceSequenceRepository([
    sequence ?? TestSeedData.sequence,
  ]);
  final settingsRepo = MemorySettingsRepository();
  final notifications = _GrantedNotificationService();

  return [
    alarmRepositoryProvider.overrideWithValue(alarmRepo),
    sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
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
    voiceSequenceProvider.overrideWith((ref, id) {
      final existing = sequenceRepo.findById(id);
      return VoiceSequenceController(
        sequenceRepo,
        existing ??
            VoiceSequenceUiModel(
              id: id,
              name: 'Voice Sequence',
              segments: const [],
            ),
      );
    }),
  ];
}

Widget _buildApp({
  String initialLocation = AppRoutes.home,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: SmartVoiceAlarmApp(initialLocation: initialLocation),
  );
}

Future<void> _pumpFrames(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  List<Override> extraOverrides = const [],
  bool emptyAlarms = false,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: _buildApp(
        initialLocation: initialLocation,
        overrides: [
          ..._memoryOverrides(emptyAlarms: emptyAlarms),
          ...extraOverrides,
        ],
      ),
    ),
  );
  await tester.pump();
  await _pumpFrames(tester);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await _pumpFrames(tester);
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('1. App boots successfully to splash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _memoryOverrides(),
        child: const SmartVoiceAlarmApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Smart Voice Alarm'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Alarms'), findsOneWidget);
  });

  testWidgets('2. Navigate Home to Create Alarm', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Alarms'), findsOneWidget);
    await _tapVisible(tester, find.text('Create Alarm'));
    expect(find.text('New Alarm'), findsOneWidget);
    expect(find.text('Save Alarm'), findsOneWidget);
  });

  testWidgets('3. Create alarm appears on Home', (tester) async {
    await _pumpApp(tester, emptyAlarms: true);
    expect(find.text('No alarms yet'), findsOneWidget);
    await _tapVisible(tester, find.text('Create Alarm').first);
    await _tapVisible(tester, find.text('Save Alarm'));
    expect(find.text('Alarms'), findsOneWidget);
    expect(find.text('Alarm'), findsWidgets);
  });

  testWidgets('4. Edit alarm updates Home', (tester) async {
    await _pumpApp(tester);
    await _tapVisible(tester, find.text('06:30'));
    expect(find.text('Edit Alarm'), findsOneWidget);
    await _tapVisible(tester, find.text('Save Alarm'));
    expect(find.text('Alarms'), findsOneWidget);
    expect(find.text('Morning focus'), findsOneWidget);
  });

  testWidgets('5. Duplicate alarm opens edit for copy', (tester) async {
    late AlarmListController controller;
    final alarmRepo = MemoryAlarmRepository(TestSeedData.alarms);
    final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
    final settingsRepo = MemorySettingsRepository();
    final notifications = _GrantedNotificationService();
    controller = AlarmListController(alarmRepo, notifications, sequenceRepo);

    await _pumpApp(
      tester,
      extraOverrides: [
        alarmRepositoryProvider.overrideWithValue(alarmRepo),
        sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        notificationServiceProvider.overrideWithValue(notifications),
        alarmListProvider.overrideWith((ref) => controller),
        themeModeProvider.overrideWith((ref) => ThemeController(settingsRepo)),
        localeProvider.overrideWith((ref) => LocaleController(settingsRepo)),
        reminderSettingsProvider.overrideWith(
          (ref) => ReminderSettingsController(settingsRepo, notifications),
        ),
      ],
    );
    final originalCount = controller.state.length;
    await tester.tap(find.byTooltip('More options').first);
    await _pumpFrames(tester);
    await tester.tap(find.text('Duplicate'));
    await _pumpFrames(tester);
    expect(find.text('Edit Alarm'), findsOneWidget);
    expect(controller.state.length, originalCount + 1);
    expect(
      controller.state.any((a) => a.label.toLowerCase().contains('copy')),
      isTrue,
    );
    await _tapVisible(tester, find.text('Save Alarm'));
    expect(find.text('Alarms'), findsOneWidget);
    expect(controller.state.length, 3);
  });

  testWidgets('6. Delete alarm removes it from Home', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('More options').first);
    await _pumpFrames(tester);
    await tester.tap(find.text('Delete'));
    await _pumpFrames(tester);
    expect(find.text('06:30'), findsNothing);
    expect(find.text('07:15'), findsOneWidget);
  });

  testWidgets('7. Toggle alarm switch works', (tester) async {
    await _pumpApp(tester);
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);
    final first = tester.widget<Switch>(switches.first);
    final wasEnabled = first.value;
    await tester.tap(switches.first);
    await _pumpFrames(tester);
    final after = tester.widget<Switch>(switches.first);
    expect(after.value, isNot(wasEnabled));
  });

  testWidgets('8. Open Voice Sequence', (tester) async {
    await _pumpApp(tester, initialLocation: AppRoutes.voiceSequence);
    expect(find.text('Voice Sequence'), findsOneWidget);
    expect(find.text('Wake gently'), findsOneWidget);
  });

  testWidgets('9. Add TTS voice segment to sequence', (tester) async {
    late VoiceSequenceController controller;
    final sequenceRepo = MemoryVoiceSequenceRepository([
      const VoiceSequenceUiModel(
        id: 'seq-1',
        name: 'Morning motivation',
        segments: [],
      ),
    ]);
    await _pumpApp(
      tester,
      initialLocation: AppRoutes.tts,
      extraOverrides: [
        sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
        ttsVoicesProvider.overrideWith(
          (ref) async => const [
            TtsVoiceUiModel(id: 'voice-1', name: 'Ava', locale: 'en-US'),
          ],
        ),
        usableTtsVoicesProvider.overrideWith(
          (ref) async => const [
            TtsVoiceUiModel(id: 'voice-1', name: 'Ava', locale: 'en-US'),
          ],
        ),
        voiceSequenceProvider.overrideWith((ref, id) {
          controller = VoiceSequenceController(
            sequenceRepo,
            sequenceRepo.findById(id)!,
          );
          return controller;
        }),
      ],
    );
    await tester.enterText(
      find.byType(TextField).first,
      'Rise and shine today',
    );
    await tester.pump();
    await _tapVisible(tester, find.text('Save'));
    expect(
      controller.state.segments.any((s) => s.name.contains('Rise and shine')),
      isTrue,
    );
  });

  testWidgets('10. Reorder voice sequence', (tester) async {
    late VoiceSequenceController controller;
    final sequenceRepo = MemoryVoiceSequenceRepository([TestSeedData.sequence]);
    await _pumpApp(
      tester,
      initialLocation: AppRoutes.voiceSequence,
      extraOverrides: [
        sequenceRepositoryProvider.overrideWithValue(sequenceRepo),
        voiceSequenceProvider.overrideWith((ref, id) {
          controller = VoiceSequenceController(
            sequenceRepo,
            sequenceRepo.findById(id)!,
          );
          return controller;
        }),
      ],
    );
    expect(controller.state.segments.first.name, 'Wake gently');
    await controller.reorder(0, 2);
    await _pumpFrames(tester);
    expect(controller.state.segments[0].name, isNot('Wake gently'));
    expect(
      controller.state.segments.map((s) => s.name),
      containsAll(<String>['Wake gently', 'Today matters', 'Hydrate reminder']),
    );
    expect(find.text('Wake gently'), findsOneWidget);
  });

  testWidgets('11. Switch Light and Dark theme', (tester) async {
    await _pumpApp(tester, initialLocation: AppRoutes.settings);
    await _tapVisible(tester, find.text('Theme'));
    await tester.tap(find.text('Dark'));
    await _pumpFrames(tester);

    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.dark,
    );

    await _tapVisible(tester, find.text('Theme'));
    await tester.tap(find.text('Light'));
    await _pumpFrames(tester);
    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.light,
    );
  });

  testWidgets('12. Open Settings', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('Settings'));
    await _pumpFrames(tester);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Voices'), findsWidgets);
    expect(find.text('Premium'), findsWidgets);
    expect(find.textContaining('GitHub'), findsNothing);
    expect(
      find.text('Get a gentle nudge if no alarm is scheduled'),
      findsWidgets,
    );
  });

  testWidgets(
    '13. Premium route shows annual subscription without fake price',
    (tester) async {
      await _pumpApp(tester, initialLocation: AppRoutes.premium);
      expect(find.text('Premium for one year'), findsOneWidget);
      expect(find.text('Subscribe to Premium for one year'), findsOneWidget);
      expect(find.textContaining(r'$2.99'), findsNothing);
      expect(find.textContaining('Free includes up to 3 alarms'), findsNothing);
    },
  );

  testWidgets('14. No overflow on common phone size', (tester) async {
    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('A RenderFlex overflowed')) {
        overflows.add(message);
      }
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await _pumpApp(tester, size: const Size(375, 667));
    await _tapVisible(tester, find.text('Create Alarm'));
    await tester.pageBack();
    await _pumpFrames(tester);
    await tester.tap(find.byTooltip('Settings'));
    await _pumpFrames(tester);
    expect(overflows, isEmpty);
  });

  testWidgets('15. Premium stays compact on a small phone', (tester) async {
    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('A RenderFlex overflowed')) {
        overflows.add(message);
      }
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    await _pumpApp(
      tester,
      initialLocation: AppRoutes.premium,
      size: const Size(320, 568),
    );

    expect(find.text('Subscribe to Premium for one year'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Open-source licenses'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Restore transactions'), findsOneWidget);
    expect(find.text('Manage subscription'), findsOneWidget);
    expect(overflows, isEmpty);
  });
}

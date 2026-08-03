import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/app/app.dart';
import 'package:smart_voice_alarm/router/routes.dart';
import 'package:smart_voice_alarm/shared/providers/prototype_providers.dart';

Widget _buildApp({
  String initialLocation = AppRoutes.home,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: SmartVoiceAlarmApp(initialLocation: initialLocation),
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  List<Override> overrides = const [],
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
      child: _buildApp(initialLocation: initialLocation, overrides: overrides),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('1. App boots successfully to splash', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartVoiceAlarmApp()));
    await tester.pump();
    expect(find.text('Smart Voice Alarm'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
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
    await _pumpApp(
      tester,
      overrides: [
        alarmListProvider.overrideWith((ref) {
          final controller = AlarmListController();
          controller.clearAll();
          return controller;
        }),
      ],
    );
    expect(find.text('No alarms yet'), findsOneWidget);
    await _tapVisible(tester, find.text('Create Alarm').first);
    await _tapVisible(tester, find.text('Save Alarm'));
    expect(find.text('Alarms'), findsOneWidget);
    expect(find.text('1 alarm ready'), findsOneWidget);
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
    await _pumpApp(
      tester,
      overrides: [
        alarmListProvider.overrideWith((ref) {
          controller = AlarmListController();
          return controller;
        }),
      ],
    );
    final originalCount = controller.state.length;
    await tester.tap(find.byTooltip('More options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Alarm'), findsOneWidget);
    expect(controller.state.length, originalCount + 1);
    expect(controller.state.last.label.toLowerCase(), contains('copy'));
    await _tapVisible(tester, find.text('Save Alarm'));
    expect(find.text('4 alarms ready'), findsOneWidget);
  });

  testWidgets('6. Delete alarm removes it from Home', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('More options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('2 alarms ready'), findsOneWidget);
  });

  testWidgets('7. Toggle alarm switch works', (tester) async {
    await _pumpApp(tester);
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);
    final first = tester.widget<Switch>(switches.first);
    final wasEnabled = first.value;
    await tester.tap(switches.first);
    await tester.pumpAndSettle();
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
    await _pumpApp(
      tester,
      initialLocation: AppRoutes.tts,
      overrides: [
        voiceSequenceProvider.overrideWith((ref) {
          controller = VoiceSequenceController();
          return controller;
        }),
      ],
    );
    await tester.enterText(find.byType(TextField), 'Rise and shine today');
    await tester.pump();
    await _tapVisible(tester, find.text('Save'));
    expect(
      controller.state.segments.any((s) => s.name.contains('Rise and shine')),
      isTrue,
    );
  });

  testWidgets('10. Reorder voice sequence', (tester) async {
    late VoiceSequenceController controller;
    await _pumpApp(
      tester,
      initialLocation: AppRoutes.voiceSequence,
      overrides: [
        voiceSequenceProvider.overrideWith((ref) {
          controller = VoiceSequenceController();
          return controller;
        }),
      ],
    );
    expect(controller.state.segments.first.name, 'Wake gently');
    controller.reorder(0, 2);
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.dark,
    );

    await _tapVisible(tester, find.text('Theme'));
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.light,
    );
  });

  testWidgets('12. Open Settings', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Reminder to set alarm'), findsWidgets);
  });

  testWidgets('13. Open Premium', (tester) async {
    await _pumpApp(tester, initialLocation: AppRoutes.premium);
    expect(find.text('Unlock Lifetime'), findsOneWidget);
    expect(find.text('One purchase. Yours forever.'), findsOneWidget);
  });

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
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(overflows, isEmpty);
  });
}

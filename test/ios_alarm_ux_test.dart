import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/services/ios_alarm_segment_planner.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';
import 'package:smart_voice_alarm/core/services/platform_attribution.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';
import 'package:smart_voice_alarm/shared/widgets/app_widgets.dart';

void main() {
  group('IosAlarmSegmentPlanner', () {
    test('uses actualDuration + silence between segments', () {
      final planner = IosAlarmSegmentPlanner();
      final alarm = AlarmUiModel(
        id: 'a1',
        time: const TimeOfDay(hour: 7, minute: 0),
        repeatDays: Weekday.values.toSet(),
        isEnabled: true,
        type: AlarmType.mixed,
        label: 'Test',
        repeatCount: 1,
      );
      final start = DateTime(2026, 8, 5, 7, 0);
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: start,
        voiceClips: [
          preparedClip(
            fileName: 'v0.caf',
            duration: const Duration(seconds: 10),
          ),
          preparedClip(
            fileName: 'v1.caf',
            duration: const Duration(seconds: 8),
          ),
        ],
        ringtoneClips: [
          preparedClip(
            fileName: 'r0.caf',
            duration: const Duration(seconds: 12),
          ),
        ],
        maxCyclesOverride: 1,
      );

      final segments = plan.segments;
      expect(segments.length, 6);
      expect(segments[0].startAt, start);
      expect(segments[1].role, IosSegmentRole.silence);
      expect(
        segments[2].startAt,
        start.add(const Duration(seconds: 10)).add(const Duration(seconds: 5)),
      );
      expect(
        segments[4].startAt,
        start
            .add(const Duration(seconds: 10))
            .add(const Duration(seconds: 5))
            .add(const Duration(seconds: 8))
            .add(const Duration(seconds: 5)),
      );
      expect(
        segments[4].duration,
        const Duration(seconds: 10) + const Duration(milliseconds: 1250),
      );
    });

    test('clamps oversized voice clips to content max + trailing', () {
      final planner = IosAlarmSegmentPlanner();
      final alarm = AlarmUiModel(
        id: 'a1',
        time: const TimeOfDay(hour: 7, minute: 0),
        repeatDays: const {},
        isEnabled: true,
        type: AlarmType.voice,
        label: 'Test',
        repeatCount: 1,
      );
      final plan = planner.plan(
        alarm: alarm,
        occurrenceId: 'occ',
        occurrenceStart: DateTime(2026, 8, 5, 7),
        voiceClips: [
          preparedClip(
            fileName: 'long.caf',
            duration: const Duration(seconds: 45),
          ),
        ],
        ringtoneClips: const [],
        maxCyclesOverride: 1,
      );
      expect(
        plan.segments.first.duration,
        const Duration(seconds: 20) +
            const Duration(milliseconds: 1250) +
            const Duration(seconds: 1),
      );
    });
  });

  group('new alarm defaults', () {
    test('expected defaults are 7 days and Combined', () {
      final days = {
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
        Weekday.saturday,
        Weekday.sunday,
      };
      expect(days.length, 7);
      expect(AlarmType.mixed, isNot(AlarmType.voice));
    });
  });

  group('PlatformAttribution', () {
    test('Android stays Nguyen Duc', () {
      expect(
        PlatformAttribution.developerNameFor(TargetPlatform.android),
        'Nguyên Đức',
      );
    });

    test('iOS is Tran Thi Cam My', () {
      expect(
        PlatformAttribution.developerNameFor(TargetPlatform.iOS),
        'Trần Thị Cẩm Mỹ',
      );
    });
  });

  testWidgets('SurfacePanel with ListTile does not throw ink assertion', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details);
    addTearDown(() => FlutterError.onError = old);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingTile(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Tap me',
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    final listTileInk = errors.where(
      (e) => e.exceptionAsString().contains('ListTile background color'),
    );
    expect(listTileInk, isEmpty);
  });
}

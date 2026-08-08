import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';

void main() {
  group('AlarmKit startup safety (Dart contract)', () {
    test('passive capability defaults to fan-out backend', () {
      final cap = IosAlarmCapability.fromMap({
        'iosVersion': '26.5.2',
        'runtimeVersionEligible': true,
        'usesAlarmKit': false,
        'supportsFullVoiceAlarm': false,
        'alarmKitAuthorization': 'unknown',
        'alarmKitDisabled': false,
        'alarmKitRuntimeEnabled': false,
      });
      expect(cap.shouldUseAlarmKitBackend, isFalse);
      expect(
        AlarmScheduleBackend.notificationFanout,
        isNot(equals(AlarmScheduleBackend.alarmKit)),
      );
    });

    test('cached disabled session never selects AlarmKit', () {
      const cap = IosAlarmCapability(
        usesAlarmKit: true,
        alarmKitAuthorization: 'authorized',
        iosVersion: '26.5.2',
        runtimeVersionEligible: true,
        alarmKitRuntimeEnabled: true,
        alarmKitDisabled: true,
        supportsFullVoiceAlarm: true,
      );
      expect(cap.shouldUseAlarmKitBackend, isFalse);
    });

    test(
      'IosAlarmScheduler is disabled under FLUTTER_TEST (no native startup)',
      () {
        final scheduler = IosAlarmScheduler();
        expect(scheduler.isSupported, isFalse);
      },
    );
  });
}

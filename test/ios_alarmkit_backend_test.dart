import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/services/alarm_schedule_result.dart';
import 'package:smart_voice_alarm/core/services/ios_alarm_scheduler.dart';

void main() {
  group('AlarmKit backend selection', () {
    test('iOS 26 authorized selects AlarmKit', () {
      const cap = IosAlarmCapability(
        usesAlarmKit: true,
        alarmKitAuthorization: 'authorized',
        iosVersion: '26.5.2',
        supportsFullVoiceAlarm: true,
      );
      expect(cap.shouldUseAlarmKitBackend, isTrue);
      expect(cap.isFullSupport, isTrue);
    });

    test('iOS 26 denied selects fan-out', () {
      const cap = IosAlarmCapability(
        usesAlarmKit: true,
        alarmKitAuthorization: 'denied',
        iosVersion: '26.5.2',
        supportsFullVoiceAlarm: true,
      );
      expect(cap.shouldUseAlarmKitBackend, isFalse);
    });

    test('old iOS capability is not AlarmKit', () {
      const cap = IosAlarmCapability(
        usesAlarmKit: false,
        alarmKitAuthorization: 'unavailable',
        iosVersion: '18.0',
        supportsFullVoiceAlarm: false,
      );
      expect(cap.shouldUseAlarmKitBackend, isFalse);
      expect(cap.isFullSupport, isFalse);
    });

    test('backends are mutually exclusive labels', () {
      expect(
        AlarmScheduleBackend.alarmKit,
        isNot(equals(AlarmScheduleBackend.notificationFanout)),
      );
    });

    test('schedule result carries backend', () {
      final ok = AlarmScheduleResult.ok(
        backend: AlarmScheduleBackend.alarmKit,
        stage: 'alarmkit_schedule',
        scheduledIds: const ['a', 'b'],
      );
      expect(ok.backend, AlarmScheduleBackend.alarmKit);
      expect(ok.scheduledIds, hasLength(2));

      final fail = AlarmScheduleResult.fail(
        errorCode: 'alarmkit_schedule_failed',
        errorMessage: 'rolled back',
        stage: 'alarmkit_schedule',
        backend: AlarmScheduleBackend.alarmKit,
      );
      expect(fail.ok, isFalse);
      expect(fail.backend, AlarmScheduleBackend.alarmKit);
    });

    test('fromMap supportsFullVoiceAlarm', () {
      final cap = IosAlarmCapability.fromMap({
        'usesAlarmKit': true,
        'supportsFullVoiceAlarm': true,
        'alarmKitAuthorization': 'authorized',
        'iosVersion': '26.0',
      });
      expect(cap.supportsFullVoiceAlarm, isTrue);
      expect(cap.shouldUseAlarmKitBackend, isTrue);
    });
  });
}

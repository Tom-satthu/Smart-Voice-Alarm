import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/alarm_kit_timeline_config.dart';

void main() {
  test('timeline constants for trailing silence and product gap', () {
    expect(AlarmKitTimelineConfig.trailingSilence.inMilliseconds, 1250);
    expect(AlarmKitTimelineConfig.silenceGap, const Duration(seconds: 5));
    expect(
      AlarmKitTimelineConfig.trailingSilence,
      isNot(AlarmKitTimelineConfig.silenceGap),
    );
    expect(
      AlarmKitTimelineConfig.ringtoneDuration,
      const Duration(seconds: 10),
    );
    expect(
      AlarmKitTimelineConfig.maxVoiceContentDuration,
      const Duration(seconds: 20),
    );
    expect(AlarmKitTimelineConfig.minScheduleLead.inMilliseconds, 600);
  });
}

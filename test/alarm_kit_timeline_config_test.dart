import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/alarm_kit_timeline_config.dart';

void main() {
  test('transition padding and gap are independent constants', () {
    expect(AlarmKitTimelineConfig.transitionPadding.inMilliseconds, 1250);
    expect(AlarmKitTimelineConfig.silenceGap.inSeconds, 5);
    expect(
      AlarmKitTimelineConfig.transitionPadding,
      isNot(AlarmKitTimelineConfig.silenceGap),
    );
    expect(AlarmKitTimelineConfig.minScheduleLead.inMilliseconds, 600);
    expect(AlarmKitTimelineConfig.maxChildren, 64);
  });
}

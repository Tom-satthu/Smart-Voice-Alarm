import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/recording_limits.dart';
import 'package:smart_voice_alarm/core/services/tts_text_limits.dart';

void main() {
  group('recording limits', () {
    test('17. timer label reaches 20/20', () {
      expect(recordingTimerLabel(const Duration(seconds: 20)), '20/20');
      expect(recordingTimerLabel(const Duration(seconds: 25)), '20/20');
    });

    test('18. early stop keeps actual duration label', () {
      expect(recordingTimerLabel(const Duration(seconds: 7)), '7/20');
    });
  });

  group('tts text limits', () {
    test('19. character counter by locale', () {
      expect(
        TtsTextLimits.maxCharsForLocale('vi-VN'),
        TtsTextLimits.viVnMaxChars,
      );
      expect(
        TtsTextLimits.maxCharsForLocale('en-US'),
        TtsTextLimits.enUsMaxChars,
      );
      expect(
        TtsTextLimits.maxCharsForLocale('fr-FR'),
        TtsTextLimits.fallbackMaxChars,
      );
    });

    test('20. typing beyond max is capped', () {
      final max = TtsTextLimits.maxCharsForLocale('en-US');
      final text = 'a' * (max + 10);
      expect(text.substring(0, max).length, max);
    });

    test('21. paste overflow room calculation', () {
      final max = TtsTextLimits.viVnMaxChars;
      const before = 'hello';
      const after = '';
      final room = max - (before.length + after.length);
      final pasted = 'x' * (room + 40);
      expect(pasted.length > room, isTrue);
      final allowed = pasted.substring(0, room);
      expect(allowed.length, room);
      expect((before + allowed + after).length, max);
    });

    test('22-23. duration gate constants', () {
      expect(kMaxTtsSoundSeconds, 20);
      expect(kMaxRecordingDuration.inSeconds, 20);
    });
  });
}

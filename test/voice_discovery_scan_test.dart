import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/services/voice_load_context.dart';

void main() {
  test('scan generation ignores stale results', () {
    var appliedGeneration = 0;
    var appliedKey = '';

    void applyResult({
      required int generation,
      required int latestGeneration,
      required VoiceLoadContext context,
    }) {
      if (generation != latestGeneration) return;
      appliedGeneration = generation;
      appliedKey = context.cacheKey;
    }

    const first = VoiceLoadContext(
      preferredLocale: 'en-US',
      appLocale: 'en-US',
      systemLocale: 'en-US',
    );
    const second = VoiceLoadContext(
      preferredLocale: 'vi-VN',
      appLocale: 'vi-VN',
      systemLocale: 'vi-VN',
    );

    var latest = 1;
    applyResult(generation: 1, latestGeneration: latest, context: first);
    latest = 2;
    // Stale completion from first scan must not win.
    applyResult(generation: 1, latestGeneration: latest, context: first);
    expect(appliedGeneration, 1);
    expect(appliedKey, first.cacheKey);

    applyResult(generation: 2, latestGeneration: latest, context: second);
    expect(appliedGeneration, 2);
    expect(appliedKey, second.cacheKey);
  });

  test('VoiceLoadContext distinguishes empty vs filled locales', () {
    const empty = VoiceLoadContext();
    const filled = VoiceLoadContext(
      preferredLocale: 'vi-VN',
      appLocale: 'en-US',
      systemLocale: 'fr-FR',
    );
    expect(empty.cacheKey, isNot(filled.cacheKey));
    expect(filled.cacheKey.contains('vi-VN'), isTrue);
  });
}

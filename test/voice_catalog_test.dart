import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/localization/locale_codes.dart';
import 'package:smart_voice_alarm/core/localization/voice_catalog.dart';
import 'package:smart_voice_alarm/core/services/tts_service.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  test('keeps the platform locale separate from the normalized UI locale', () {
    const voice = TtsVoiceUiModel(
      id: 'engine|voice-vietnamese|vie-VNM',
      name: 'Vietnamese voice',
      locale: 'vi-VN',
      platformName: 'voice-vietnamese',
      platformLocale: 'vie-VNM',
    );

    expect(LocaleCodes.normalizeLocaleTag(voice.platformLocale), 'vi-VN');
    expect(voice.locale, 'vi-VN');
    expect(voice.platformLocale, 'vie-VNM');
  });

  test('system default has a stable id and is not numbered as a voice', () {
    final system = TtsService.systemDefaultVoice('vie-VNM');
    const selectable = TtsVoiceUiModel(
      id: 'engine|voice-vietnamese|vie-VNM',
      name: 'Vietnamese voice',
      locale: 'vi-VN',
    );

    final labels = VoiceCatalog.friendlyLabels([
      system,
      selectable,
    ], labelFor: (number) => 'Voice $number');

    expect(system.id, 'system-default|vi');
    expect(system.isSystemDefault, isTrue);
    expect(labels[system.id], isNull);
    expect(labels[selectable.id], 'Voice 01');
  });

  test(
    'deduplicates aliases by resolved platform voice and prefers offline',
    () {
      const networkAlias = TtsVoiceUiModel(
        id: 'engine|alias-network|en-US',
        name: 'Alias network',
        locale: 'en-US',
        platformEngine: 'engine',
        resolvedIdentifier: 'resolved-a',
        availability: TtsVoiceAvailability.networkRequired,
      );
      const offlineAlias = TtsVoiceUiModel(
        id: 'engine|alias-local|en-US',
        name: 'Alias local',
        locale: 'en-US',
        platformEngine: 'engine',
        resolvedIdentifier: 'resolved-a',
      );

      expect(VoiceCatalog.deduplicate([networkAlias, offlineAlias]), [
        offlineAlias,
      ]);
    },
  );

  test('adds at most one system default and one group per language', () {
    const voices = [
      TtsVoiceUiModel(id: 'en-us', name: 'US', locale: 'en-US'),
      TtsVoiceUiModel(id: 'en-gb', name: 'UK', locale: 'en-GB'),
    ];

    final defaults = VoiceCatalog.systemDefaultsForLanguages(voices);
    final groups = VoiceCatalog.group([...voices, ...defaults]);
    final labels = VoiceCatalog.friendlyLabels(
      voices,
      labelFor: (number) => 'Voice $number',
    );

    expect(defaults.map((voice) => voice.id), ['system-default|en']);
    expect(groups, hasLength(1));
    expect(groups.single.voiceCount, 3);
    expect(labels['en-gb'], 'Voice 01');
    expect(labels['en-us'], 'Voice 02');
  });

  test('newly installed excludes defaults and unusable voices', () {
    const oldVoice = TtsVoiceUiModel(id: 'old', name: 'Old', locale: 'en-US');
    const newVoice = TtsVoiceUiModel(id: 'new', name: 'New', locale: 'en-US');
    const missing = TtsVoiceUiModel(
      id: 'missing',
      name: 'Missing',
      locale: 'en-US',
      isUsable: false,
    );
    final system = TtsService.systemDefaultVoice('en-US');

    expect(
      VoiceCatalog.newlyInstalledIds(
        before: const [oldVoice],
        after: [oldVoice, newVoice, missing, system],
      ),
      {'new'},
    );
  });
}

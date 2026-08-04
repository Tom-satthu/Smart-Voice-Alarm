import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/localization/voice_catalog.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  const enUs = TtsVoiceUiModel(
    id: 'g|us|en-US',
    name: 'US',
    locale: 'en-US',
    platformEngine: 'com.google.tts',
    platformName: 'us',
  );
  const enGb = TtsVoiceUiModel(
    id: 'g|gb|en-GB',
    name: 'GB',
    locale: 'en-GB',
    platformEngine: 'com.google.tts',
    platformName: 'gb',
  );
  const zhCn = TtsVoiceUiModel(
    id: 'g|cn|zh-CN',
    name: 'CN',
    locale: 'zh-CN',
    platformEngine: 'com.google.tts',
    platformName: 'cn',
  );
  const zhTw = TtsVoiceUiModel(
    id: 'g|tw|zh-TW',
    name: 'TW',
    locale: 'zh-TW',
    platformEngine: 'com.google.tts',
    platformName: 'tw',
  );
  const vi = TtsVoiceUiModel(
    id: 's|vi|vi-VN',
    name: 'VI',
    locale: 'vi-VN',
    platformEngine: 'com.samsung.SMT',
    platformName: 'vi',
  );
  const malformed = TtsVoiceUiModel(
    id: 'x|bad|!!!',
    name: 'Bad',
    locale: '!!!',
    platformEngine: 'com.example',
    platformName: 'bad',
  );
  final systemEn = VoiceCatalog.systemDefaultsForLanguages(const [enUs]).single;

  test('groups by normalized language and keeps regions together', () {
    final groups = VoiceCatalog.groupForDeviceDiscovery(
      voices: const [enUs, enGb, zhCn, zhTw, vi, malformed],
      selectedId: vi.id,
      appLocale: 'en-US',
      systemLocale: 'fr-FR',
    );

    expect(groups.map((g) => g.languageCode).toList(), [
      'vi',
      'en',
      'zh',
      VoiceCatalog.otherLanguageKey,
    ]);
    expect(
      groups.firstWhere((g) => g.languageCode == 'en').voices.map((v) => v.id),
      containsAll([enUs.id, enGb.id]),
    );
    expect(
      groups.firstWhere((g) => g.languageCode == 'zh').voices.map((v) => v.id),
      containsAll([zhCn.id, zhTw.id]),
    );
    expect(
      groups
          .firstWhere((g) => g.languageCode == VoiceCatalog.otherLanguageKey)
          .voices
          .single
          .id,
      malformed.id,
    );
  });

  test('each voice appears once across groups', () {
    final groups = VoiceCatalog.groupForDeviceDiscovery(
      voices: const [enUs, enUs, enGb, vi],
      selectedId: enUs.id,
    );
    final ids = groups.expand((g) => g.voices).map((v) => v.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('selected language group is first and default expansion prefers it', () {
    final groups = VoiceCatalog.groupForDeviceDiscovery(
      voices: const [enUs, vi, zhCn],
      selectedId: zhCn.id,
      appLocale: 'vi-VN',
    );
    expect(groups.first.languageCode, 'zh');
    expect(
      VoiceCatalog.defaultExpandedLanguage(
        groups: groups,
        selectedLanguage: 'zh-CN',
        appLanguage: 'vi-VN',
      ),
      'zh',
    );
  });

  test('sorts selected then system-default then offline within a group', () {
    const network = TtsVoiceUiModel(
      id: 'g|net|en-US',
      name: 'Net',
      locale: 'en-US',
      platformEngine: 'com.google.tts',
      platformName: 'net',
      availability: TtsVoiceAvailability.networkRequired,
    );
    final sorted = VoiceCatalog.sortVoicesInLanguageGroup(
      voices: [network, enUs, systemEn],
      selectedId: enUs.id,
      appLocale: 'en-US',
      friendlyLabels: {
        enUs.id: 'Voice 01',
        network.id: 'Voice 02',
      },
    );
    expect(sorted.map((v) => v.id).toList(), [
      enUs.id,
      systemEn.id,
      network.id,
    ]);
  });

  test('default expansion falls back to app language then first group', () {
    final groups = VoiceCatalog.groupForDeviceDiscovery(
      voices: const [enUs, vi],
      appLocale: 'vi-VN',
    );
    expect(
      VoiceCatalog.defaultExpandedLanguage(
        groups: groups,
        appLanguage: 'vi-VN',
      ),
      'vi',
    );
    expect(
      VoiceCatalog.defaultExpandedLanguage(groups: groups),
      groups.first.languageCode,
    );
  });

  test('discoveryGroupKey treats empty and garbage as other', () {
    expect(VoiceCatalog.discoveryGroupKey(''), VoiceCatalog.otherLanguageKey);
    expect(VoiceCatalog.discoveryGroupKey('und'), VoiceCatalog.otherLanguageKey);
    expect(VoiceCatalog.discoveryGroupKey('!!!'), VoiceCatalog.otherLanguageKey);
    expect(VoiceCatalog.discoveryGroupKey('en-US'), 'en');
    expect(VoiceCatalog.discoveryGroupKey('zh-TW'), 'zh');
  });
}

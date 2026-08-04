import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/localization/locale_codes.dart';
import 'package:smart_voice_alarm/core/localization/voice_catalog.dart';
import 'package:smart_voice_alarm/core/services/tts_service.dart';
import 'package:smart_voice_alarm/shared/models/ui_models.dart';

void main() {
  test('keeps the platform locale separate from the normalized UI locale', () {
    const voice = TtsVoiceUiModel(
      id: 'samsung-vietnamese|vie-VNM',
      name: 'Samsung Vietnamese',
      locale: 'vi-VN',
      platformName: 'samsung-vietnamese',
      platformLocale: 'vie-VNM',
    );

    expect(LocaleCodes.normalizeLocaleTag(voice.platformLocale), 'vi-VN');
    expect(voice.locale, 'vi-VN');
    expect(voice.platformLocale, 'vie-VNM');
  });

  test('system default has a stable id and is not numbered as a voice', () {
    final system = TtsService.systemDefaultVoice('vie-VNM');
    const selectable = TtsVoiceUiModel(
      id: 'samsung-vietnamese|vie-VNM',
      name: 'Samsung Vietnamese',
      locale: 'vi-VN',
    );

    final labels = VoiceCatalog.friendlyLabels([
      system,
      selectable,
    ], labelFor: (number) => 'Voice $number');

    expect(system.id, 'system-default|vi-VN');
    expect(system.isSystemDefault, isTrue);
    expect(labels[system.id], isNull);
    expect(labels[selectable.id], 'Voice 01');
  });
}

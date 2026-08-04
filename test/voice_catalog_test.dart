import 'package:flutter_test/flutter_test.dart';
import 'package:smart_voice_alarm/core/localization/locale_codes.dart';
import 'package:smart_voice_alarm/core/localization/voice_catalog.dart';
import 'package:smart_voice_alarm/core/services/resolved_system_voice.dart';
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

  test('system-default locale prefers preferred then app/system then platform', () {
    const us = TtsVoiceUiModel(
      id: 'e|us|en-US',
      name: 'US',
      locale: 'en-US',
      platformLocale: 'en-US',
      platformEngine: 'com.google.tts',
    );
    const gb = TtsVoiceUiModel(
      id: 'e|gb|en-GB',
      name: 'UK',
      locale: 'en-GB',
      platformLocale: 'en-GB',
      platformEngine: 'com.google.tts',
    );

    final preferred = VoiceCatalog.systemDefaultsForLanguages(
      const [us, gb],
      preferredLocale: 'en-GB',
    ).single;
    expect(preferred.platformLocale, 'en-GB');
    expect(preferred.platformEngine, 'com.google.tts');

    final app = VoiceCatalog.systemDefaultsForLanguages(
      const [us, gb],
      appLocale: 'en-US',
    ).single;
    expect(app.platformLocale, 'en-US');

    final platform = VoiceCatalog.systemDefaultsForLanguages(
      const [us, gb],
      resolvedByLocale: {
        'en-GB': const ResolvedSystemVoiceState(
          requestedLocale: 'en-GB',
          resolvedVoiceName: 'gb-default',
          resolvedLocale: 'en-GB',
          enginePackage: 'com.samsung.tts',
        ),
      },
    ).single;
    expect(platform.platformLocale, 'en-GB');
    expect(platform.platformEngine, 'com.samsung.tts');
  });

  test('localesForSystemDefaultProbe dedupes preferred, listed, app, system', () {
    const voices = [
      TtsVoiceUiModel(
        id: 'a',
        name: 'A',
        locale: 'vi-VN',
        platformLocale: 'vie-VNM',
      ),
      TtsVoiceUiModel(
        id: 'b',
        name: 'B',
        locale: 'en-US',
        platformLocale: 'en-US',
      ),
      TtsVoiceUiModel(
        id: 'sys',
        name: 'System',
        locale: 'vi-VN',
        isSystemDefault: true,
      ),
    ];

    final locales = VoiceCatalog.localesForSystemDefaultProbe(
      voices: voices,
      preferredLocale: 'en-GB',
      appLocale: 'vi-VN',
      systemLocale: 'en-US',
    );

    expect(locales, containsAll(['vie-VNM', 'en-US', 'en-GB', 'vi-VN']));
    expect(locales.toSet().length, locales.length);
  });

  test('stable ids include engine and newly installed excludes system-default', () {
    const oldVoice = TtsVoiceUiModel(
      id: 'com.google.tts|old|en-US',
      name: 'Old',
      locale: 'en-US',
      platformEngine: 'com.google.tts',
    );
    const newVoice = TtsVoiceUiModel(
      id: 'com.google.tts|new|en-US',
      name: 'New',
      locale: 'en-US',
      platformEngine: 'com.google.tts',
    );
    const missing = TtsVoiceUiModel(
      id: 'missing',
      name: 'Missing',
      locale: 'en-US',
      isUsable: false,
    );
    final system = TtsService.systemDefaultVoice('en-US');

    expect(oldVoice.id.split('|').first, 'com.google.tts');
    expect(
      VoiceCatalog.newlyInstalledIds(
        before: const [oldVoice],
        after: [oldVoice, newVoice, missing, system],
      ),
      {'com.google.tts|new|en-US'},
    );
  });

  test('concrete speak plan sets voice; system-default does not', () {
    const concrete = TtsVoiceUiModel(
      id: 'engine|name|en-US',
      name: 'Name',
      locale: 'en-US',
      platformName: 'name',
      platformLocale: 'en-US',
      platformEngine: 'com.google.tts',
    );
    final system = VoiceCatalog.systemDefaultsForLanguages(const [concrete]).single;

    final concretePlan = VoiceCatalog.speakPlanFor(concrete);
    expect(concretePlan.engine, 'com.google.tts');
    expect(concretePlan.shouldSetVoice, isTrue);
    expect(concretePlan.voiceName, 'name');
    expect(concretePlan.recreateEngine, isFalse);

    final systemPlan = VoiceCatalog.speakPlanFor(system);
    expect(systemPlan.shouldSetVoice, isFalse);
    expect(systemPlan.voiceName, isNull);
    expect(systemPlan.recreateEngine, isTrue);
    expect(systemPlan.languageLocale, isNotEmpty);
  });

  test('system voice change events serialize for persistence', () {
    const event = SystemVoiceChangeEvent(
      locale: 'vi-VN',
      language: 'vi',
      timestampMs: 123,
    );
    final roundTrip = SystemVoiceChangeEvent.fromJson(event.toJson());
    expect(roundTrip.locale, 'vi-VN');
    expect(roundTrip.language, 'vi');
    expect(roundTrip.timestampMs, 123);
    expect(roundTrip.type, 'system_default_changed');
  });

  test('resolved system voice fingerprint detects per-locale changes', () {
    const before = ResolvedSystemVoiceState(
      requestedLocale: 'vi-VN',
      resolvedVoiceName: 'vi-female',
      resolvedLocale: 'vi-VN',
      enginePackage: 'com.samsung.SMT',
    );
    const after = ResolvedSystemVoiceState(
      requestedLocale: 'vi-VN',
      resolvedVoiceName: 'vi-male',
      resolvedLocale: 'vi-VN',
      enginePackage: 'com.samsung.SMT',
    );
    const en = ResolvedSystemVoiceState(
      requestedLocale: 'en-US',
      resolvedVoiceName: 'en-us',
      resolvedLocale: 'en-US',
      enginePackage: 'com.google.tts',
    );

    expect(before.fingerprint, isNot(after.fingerprint));
    expect(before.fingerprint, isNot(en.fingerprint));
  });

  test('no duplicate language rows for system defaults', () {
    const voices = [
      TtsVoiceUiModel(id: '1', name: 'A', locale: 'vi-VN', platformLocale: 'vi-VN'),
      TtsVoiceUiModel(id: '2', name: 'B', locale: 'vi-VN', platformLocale: 'vi-VN'),
      TtsVoiceUiModel(id: '3', name: 'C', locale: 'en-US', platformLocale: 'en-US'),
    ];
    final defaults = VoiceCatalog.systemDefaultsForLanguages(voices);
    expect(defaults.map((v) => v.id).toSet(), {
      'system-default|vi',
      'system-default|en',
    });
    expect(defaults, hasLength(2));
  });

  test('exact-locale snapshot ignores siblings and newly probed locales', () {
    const enUs = ResolvedSystemVoiceState(
      requestedLocale: 'en-US',
      resolvedVoiceName: 'en-us',
      resolvedLocale: 'en-US',
      enginePackage: 'com.google.tts',
    );
    const enUsChanged = ResolvedSystemVoiceState(
      requestedLocale: 'en-US',
      resolvedVoiceName: 'en-us-b',
      resolvedLocale: 'en-US',
      enginePackage: 'com.google.tts',
    );
    const enGb = ResolvedSystemVoiceState(
      requestedLocale: 'en-GB',
      resolvedVoiceName: 'en-gb',
      resolvedLocale: 'en-GB',
      enginePackage: 'com.google.tts',
    );
    const vi = ResolvedSystemVoiceState(
      requestedLocale: 'vi-VN',
      resolvedVoiceName: 'vi',
      resolvedLocale: 'vi-VN',
      enginePackage: 'com.samsung.SMT',
    );

    expect(
      VoiceCatalog.changedSystemDefaultLocales(
        before: const {'en-US': enUs},
        after: const {'en-US': enUs, 'en-GB': enGb},
      ),
      isEmpty,
    );
    expect(
      VoiceCatalog.changedSystemDefaultLocales(
        before: const {'en-US': enUs},
        after: const {'en-US': enUsChanged},
      ),
      ['en-US'],
    );
    expect(
      VoiceCatalog.changedSystemDefaultLocales(
        before: const {},
        after: const {'vi-VN': vi},
      ),
      isEmpty,
    );
  });

  test('legacy system-default id normalizes to language scope', () {
    expect(
      VoiceCatalog.normalizeSystemDefaultVoiceId('system-default|en-US'),
      'system-default|en',
    );
    expect(
      VoiceCatalog.normalizeSystemDefaultVoiceId('system-default|en'),
      'system-default|en',
    );
    expect(
      VoiceCatalog.normalizeSystemDefaultVoiceId('engine|voice|en-US'),
      'engine|voice|en-US',
    );
  });

  test('preferred retarget only for matching system-default language', () {
    expect(
      VoiceCatalog.preferredSystemDefaultLanguageToRetarget(
        preferredId: 'engine|voice|en-US',
        preferredLanguage: 'en',
        changedLocales: const ['en-US'],
      ),
      isNull,
    );
    expect(
      VoiceCatalog.preferredSystemDefaultLanguageToRetarget(
        preferredId: 'system-default|en',
        preferredLanguage: 'en',
        changedLocales: const ['vi-VN'],
      ),
      isNull,
    );
    expect(
      VoiceCatalog.preferredSystemDefaultLanguageToRetarget(
        preferredId: 'system-default|en',
        preferredLanguage: 'en',
        changedLocales: const ['en-US', 'vi-VN'],
      ),
      'en',
    );
    expect(
      VoiceCatalog.preferredSystemDefaultLanguageToRetarget(
        preferredId: 'system-default|en-US',
        preferredLanguage: null,
        changedLocales: const ['en-GB'],
      ),
      'en',
    );
  });

  test('corrupted system voice change event json does not throw', () {
    final event = SystemVoiceChangeEvent.fromJson(const {});
    expect(event.locale, '');
    expect(event.language, '');
    expect(event.timestampMs, 0);
  });
}

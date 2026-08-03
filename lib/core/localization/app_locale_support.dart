import 'package:flutter/material.dart';

import '../../localization/generated/app_localizations.dart';

/// Resolves device / stored locales to a supported app locale.
abstract final class AppLocaleSupport {
  static const supported = AppLocalizations.supportedLocales;

  static Locale resolve(Locale? deviceLocale, [Locale? preferred]) {
    if (preferred != null) {
      final match = _match(preferred);
      if (match != null) return match;
    }
    if (deviceLocale != null) {
      final match = _match(deviceLocale);
      if (match != null) return match;
    }
    return const Locale('en');
  }

  static Locale? _match(Locale locale) {
    // Prefer exact language + country (e.g. zh_TW before zh).
    for (final supported in supported) {
      if (supported.languageCode == locale.languageCode &&
          supported.countryCode != null &&
          supported.countryCode!.isNotEmpty &&
          supported.countryCode == locale.countryCode) {
        return supported;
      }
    }

    // Chinese regional fallbacks.
    if (locale.languageCode == 'zh') {
      const traditional = {'TW', 'HK', 'MO'};
      if (locale.countryCode != null &&
          traditional.contains(locale.countryCode)) {
        return const Locale('zh', 'TW');
      }
      return const Locale('zh');
    }

    // Language-only supported entries (en, es, …).
    for (final supported in supported) {
      if (supported.languageCode == locale.languageCode &&
          (supported.countryCode == null || supported.countryCode!.isEmpty)) {
        return supported;
      }
    }

    for (final supported in supported) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return null;
  }

  static String displayName(AppLocalizations l10n, Locale locale) {
    final tag = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    return switch (tag) {
      'en' => l10n.languageEnglish,
      'es' => l10n.languageSpanish,
      'pt' => l10n.languagePortuguese,
      'fr' => l10n.languageFrench,
      'de' => l10n.languageGerman,
      'it' => l10n.languageItalian,
      'nl' => l10n.languageDutch,
      'ja' => l10n.languageJapanese,
      'ko' => l10n.languageKorean,
      'zh_TW' => l10n.languageChineseTraditional,
      'zh' => l10n.languageChineseSimplified,
      'id' => l10n.languageIndonesian,
      'vi' => l10n.languageVietnamese,
      _ => locale.toLanguageTag(),
    };
  }

  static String localeStorageCode(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }

  static Locale parseStorageCode(String code) {
    final parts = code.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }
}

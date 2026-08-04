// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Wach auf mit deiner eigenen Stimme';

  @override
  String get homeTitle => 'Alarme';

  @override
  String get homeEmptyTitle => 'Noch keine Alarme';

  @override
  String get homeEmptySubtitle =>
      'Erstelle deinen ersten Sprachalarm und wache mit Worten auf, die zählen.';

  @override
  String get homeCreateAlarm => 'Alarm erstellen';

  @override
  String get homeEdit => 'Bearbeiten';

  @override
  String get homeDuplicate => 'Duplizieren';

  @override
  String get homeDelete => 'Löschen';

  @override
  String get homeMore => 'Weitere Optionen';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Alarme bereit',
      one: '1 Alarm bereit',
      zero: 'Keine Alarme',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Guten Morgen';

  @override
  String get homeGoodAfternoon => 'Guten Tag';

  @override
  String get homeGoodEvening => 'Guten Abend';

  @override
  String get alarmTypeVoice => 'Stimme';

  @override
  String get alarmTypeRingtone => 'Klingelton';

  @override
  String get alarmTypeMixed => 'Gemischt';

  @override
  String get alarmTypeLabel => 'Alarmtyp';

  @override
  String get createAlarmTitle => 'Neuer Alarm';

  @override
  String get editAlarmTitle => 'Alarm bearbeiten';

  @override
  String get alarmTime => 'Uhrzeit';

  @override
  String get alarmHour => 'Stunde';

  @override
  String get alarmMinute => 'Minute';

  @override
  String get alarmRepeat => 'Wiederholen';

  @override
  String get alarmVoiceSequence => 'Sprachsequenz';

  @override
  String get alarmRingtone => 'Klingelton nach der Stimme';

  @override
  String get alarmRepeatCount => 'Sequenz-Wiederholungen';

  @override
  String get alarmCopyFrom => 'Von anderem Alarm kopieren';

  @override
  String get alarmSave => 'Alarm speichern';

  @override
  String get alarmSelectSequence => 'Tippen, um Sequenz zu bearbeiten';

  @override
  String get alarmSelectRingtone => 'Ton auswählen';

  @override
  String get alarmNoneSelected => 'Nichts ausgewählt';

  @override
  String get alarmCopied => 'Einstellungen kopiert';

  @override
  String get alarmSaved => 'Alarm gespeichert';

  @override
  String get alarmDeleted => 'Alarm gelöscht';

  @override
  String get alarmDuplicated => 'Alarm dupliziert';

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Mi';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'So';

  @override
  String get dayEveryDay => 'Jeden Tag';

  @override
  String get dayWeekdays => 'Wochentage';

  @override
  String get dayWeekends => 'Wochenenden';

  @override
  String get dayOnce => 'Einmal';

  @override
  String get voiceSequenceTitle => 'Sprachsequenz';

  @override
  String get voiceSequenceEmptyTitle => 'Erstelle deine Wecknachricht';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Füge Aufnahmen oder gesprochenen Text in der gewünschten Reihenfolge hinzu.';

  @override
  String get voiceSequenceAdd => 'Stimme hinzufügen';

  @override
  String get voiceSequenceDelete => 'Löschen';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Segment entfernen?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Dadurch wird das Segment aus der Sequenz entfernt.';

  @override
  String get voiceSequenceReorderHint => 'Zum Neuordnen ziehen';

  @override
  String get voiceSegmentName => 'Name';

  @override
  String get voiceSegmentType => 'Typ';

  @override
  String get voiceSegmentDuration => 'Dauer';

  @override
  String voiceSegmentOrder(int number) {
    return 'Schritt $number';
  }

  @override
  String get voiceTypeRecording => 'Aufnahme';

  @override
  String get voiceTypeTts => 'Text-zu-Sprache';

  @override
  String get addVoiceTitle => 'Stimme hinzufügen';

  @override
  String get addVoiceRecord => 'Stimme aufnehmen';

  @override
  String get addVoiceRecordSubtitle =>
      'Sprich eine kurze Nachricht in dein Mikrofon';

  @override
  String get addVoiceTts => 'Text-zu-Sprache';

  @override
  String get addVoiceTtsSubtitle =>
      'Tippe eine Nachricht und wähle eine Stimme';

  @override
  String get ttsTitle => 'Text-zu-Sprache';

  @override
  String get ttsInputLabel => 'Nachricht';

  @override
  String get ttsInputHint => 'Tippe die Nachricht, die du hören möchtest…';

  @override
  String get ttsVoices => 'Stimmen';

  @override
  String get ttsLanguageLabel => 'Sprache';

  @override
  String get ttsVoiceNameLabel => 'Stimme';

  @override
  String get ttsVoiceQualityLabel => 'Qualität';

  @override
  String get ttsPreview => 'Vorschau';

  @override
  String get ttsPreviewing => 'Vorschau wird abgespielt…';

  @override
  String get ttsSave => 'Speichern';

  @override
  String get ttsSaved => 'Sprachsegment gespeichert';

  @override
  String get recordTitle => 'Stimme aufnehmen';

  @override
  String get recordStart => 'Aufnehmen';

  @override
  String get recordStop => 'Stopp';

  @override
  String get recordPlay => 'Abspielen';

  @override
  String get recordPlaying => 'Wird abgespielt…';

  @override
  String get recordSave => 'Speichern';

  @override
  String get recordHint => 'Tippe auf Aufnehmen, wenn du bereit bist';

  @override
  String get recordRecording => 'Aufnahme läuft…';

  @override
  String get recordReady => 'Bereit zum Speichern';

  @override
  String get recordSaved => 'Aufnahme gespeichert';

  @override
  String get recordDefaultName => 'Sprachaufnahme';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsReminder => 'Erinnerung';

  @override
  String get settingsReminderSubtitle =>
      'Erhalte einen sanften Hinweis, wenn kein Alarm geplant ist';

  @override
  String get settingsReminderTime => 'Erinnerungszeit';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutSubtitle => 'App-Infos und Support';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Unbegrenzte Alarme freischalten';

  @override
  String get settingsVoices => 'Stimmen';

  @override
  String get settingsVoicesSubtitle => 'Systemstimmen für Text-zu-Sprache';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicenses => 'Open-Source-Lizenzen';

  @override
  String get settingsPrivacy => 'Datenschutzrichtlinie';

  @override
  String get settingsTerms => 'Nutzungsbedingungen';

  @override
  String get settingsLegalPlaceholder => 'Dokument anzeigen';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Unbegrenzte Alarme freischalten';

  @override
  String get premiumSubtitle =>
      'Die kostenlose Version enthält bis zu 3 Alarme. Schalte unbegrenzte Alarme mit einem Lifetime-Kauf frei. Keine Abos.';

  @override
  String get premiumPlanFree => 'Kostenlos';

  @override
  String get premiumPlanLifetime => 'Premium lebenslang';

  @override
  String get premiumPlanLifetimePrice => 'Einmaliger Kauf';

  @override
  String get premiumBenefitsTitle => 'Alles in Premium';

  @override
  String get premiumBenefitUnlimited => 'Unbegrenzte Alarme';

  @override
  String get premiumBenefitSequences => 'Sprachsequenzen ohne Funktionssperren';

  @override
  String get premiumBenefitVoices => 'Alle installierten Systemstimmen';

  @override
  String get premiumBenefitThemes =>
      'Themes, Erinnerungen und Aufnahme bleiben kostenlos';

  @override
  String get premiumBenefitSupport => 'Priorisierter Support';

  @override
  String get premiumBenefitNoAds => 'Keine Werbung';

  @override
  String get premiumUnlock => 'Unbegrenzte Alarme freischalten';

  @override
  String get premiumRestore => 'Kauf wiederherstellen';

  @override
  String get premiumThanks =>
      'Danke für deine Unterstützung von Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Produkte müssen in App Store Connect und Google Play Console eingerichtet werden.';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonNext => 'Weiter';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonEnabled => 'An';

  @override
  String get commonDisabled => 'Aus';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get commonOpen => 'Öffnen';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languageDutch => 'Niederländisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languageChineseSimplified => 'Chinesisch (vereinfacht)';

  @override
  String get languageChineseTraditional => 'Chinesisch (traditionell)';

  @override
  String get languageIndonesian => 'Indonesisch';

  @override
  String get languageVietnamese => 'Vietnamesisch';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal',
      one: '1 Mal',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Segmente',
      one: '1 Segment',
      zero: 'Keine Segmente',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Sanftes Glockenspiel';

  @override
  String get ringtoneOceanBreeze => 'Meeresbrise';

  @override
  String get ringtoneNightPulse => 'Nachtpuls';

  @override
  String get ringtoneForestDawn => 'Walddämmerung';

  @override
  String get ringtoneCrystalBell => 'Kristallglocke';

  @override
  String get alarmStop => 'Stopp';

  @override
  String get alarmStopAll => 'Alles stoppen';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Alarme warten',
      one: '1 Alarm wartet',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Stimmen';

  @override
  String get voicesSystemVoices => 'Systemstimmen';

  @override
  String get voicesDownloadMore => 'Weitere Stimmen laden';

  @override
  String get voicesRefresh => 'Stimmen aktualisieren';

  @override
  String get voicesOfflineHint =>
      'Bevorzuge Offline-Stimmen, damit Alarme auch ohne Netzwerkverbindung sprechen.';

  @override
  String get voicesIosGuideTitle => 'Stimmen auf dem iPhone installieren';

  @override
  String get voicesIosGuideBody =>
      'Öffne Einstellungen → Bedienungshilfen → Gesprochene Inhalte → Stimmen, lade die benötigten Stimmen herunter, kehre hierher zurück und tippe auf Stimmen aktualisieren.';

  @override
  String get voicesAndroidGuide =>
      'Öffnet den TTS-Dateninstallierer des Systems. Smart Voice Alarm lädt keine Sprachpakete herunter und hostet sie nicht.';

  @override
  String get voicesWebUnavailable =>
      'Browser verwalten ihre eigenen Stimmen. Download-Pakete sind im Web nicht verfügbar.';

  @override
  String get voicesEmpty => 'Noch keine nutzbaren Stimmen gefunden';

  @override
  String get voicesEmptyCta => 'Weitere Stimmen laden';

  @override
  String get voiceQualityDefault => 'Standard';

  @override
  String get voiceQualityEnhanced => 'Erweitert';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Offline';

  @override
  String get voiceAvailabilityNetwork => 'Netzwerk erforderlich';

  @override
  String get voiceAvailabilityMissing => 'Nicht installiert';

  @override
  String get ttsNoVoicesTitle => 'Keine nutzbaren Stimmen';

  @override
  String get ttsNoVoicesBody =>
      'Lade Systemstimmen herunter und aktualisiere dann die Liste.';

  @override
  String get ttsOpenVoiceSettings => 'Weitere Stimmen laden';

  @override
  String get ttsVoiceFallback =>
      'Die ausgewählte Stimme ist nicht verfügbar. Es wird eine Standardstimme verwendet.';

  @override
  String get reminderNotificationTitle => 'Stelle den Alarm für morgen ein';

  @override
  String get reminderNotificationBody =>
      'Nimm dir einen Moment, um deinen Smart Voice Alarm für morgen zu planen.';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutAppName => 'App-Name';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDeveloper => 'Entwickler';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'GitHub-Repository';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => 'E-Mail-Support';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => 'Demnächst';

  @override
  String get voiceSystemDefault => 'Systemstandard';

  @override
  String get voiceSystemDefaultHint =>
      'Wird in den Geräteeinstellungen verwaltet';

  @override
  String get notificationChannelAlarms => 'Alarme';

  @override
  String get notificationChannelAlarmsDesc => 'Sprachalarm-Benachrichtigungen';

  @override
  String get notificationChannelReminders => 'Erinnerungen';

  @override
  String get notificationChannelRemindersDesc =>
      'Tägliche Erinnerung, den morgigen Alarm einzustellen';

  @override
  String get alarmDefaultLabel => 'Alarm';

  @override
  String get premiumBenefitLifetimeBuy => 'Einmal kaufen. Für immer deins.';

  @override
  String get premiumStatusLoading => 'Store wird geprüft…';

  @override
  String get premiumStatusPurchasing => 'Kauf wird gestartet…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime freigeschaltet';

  @override
  String get premiumStatusRestored => 'Kauf wiederhergestellt';

  @override
  String get premiumStatusCancelled => 'Kauf abgebrochen';

  @override
  String get premiumStatusPending => 'Kauf ausstehend…';

  @override
  String get premiumStatusError =>
      'Kauf fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get premiumWebUnavailable =>
      'In-App-Käufe sind in der Web-Demo nicht verfügbar.';

  @override
  String get premiumStoreUnavailable =>
      'Der Store ist auf diesem Gerät nicht verfügbar.';

  @override
  String get premiumLimitExplainFree =>
      'Die kostenlose Version enthält bis zu 3 Alarme.';

  @override
  String get premiumLimitExplainUnlock =>
      'Schalte unbegrenzte Alarme mit einem Lifetime-Kauf frei.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Bis zu $count Alarme';
  }

  @override
  String get voicesSearchHint => 'Sprachen oder Stimmen suchen';

  @override
  String get voicesLanguages => 'Sprachen';

  @override
  String get voicesSelectVoiceHint => 'Wähle eine Stimme für diese Sprache';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stimmen',
      one: '1 Stimme',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Tippen, um die Zeit zu wählen';

  @override
  String get segmentPlay => 'Abspielen';

  @override
  String get voicePlaying => 'Wird abgespielt';

  @override
  String get voiceSelect => 'Auswählen';

  @override
  String get voiceUnavailable => 'Stimme nicht verfügbar';

  @override
  String get recordingFileMissing =>
      'Aufnahmedatei fehlt. Segment löschen oder erneut aufnehmen.';

  @override
  String get voiceDetails => 'Stimmendetails';

  @override
  String get ttsSelectedVoice => 'Ausgewählte Stimme';

  @override
  String get voicePreviewSample =>
      'Dies ist eine kurze Vorschau dieser Stimme.';

  @override
  String get alarmDismissTitle => 'Losung zum Stoppen';

  @override
  String get alarmDismissHint =>
      'Richtig antworten, um den Alarm auszuschalten.';

  @override
  String get alarmDismissWrong => 'Falsch. Neue Frage.';

  @override
  String get alarmDismissCheck => 'Prufen';

  @override
  String get alarmDismissAnswerHint => 'Ihre Antwort';

  @override
  String voicesRefreshed(int count) {
    return 'Aktualisiert: $count Stimmen gefunden';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Stimme gespeichert: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Öffnen Sie die Sprachverwaltung des Geräts. Kehren Sie danach hierher zurück.';

  @override
  String get voicesRefreshHint =>
      'Stimmen aktualisieren laedt System-TTS-Stimmen nach der Installation neu.';

  @override
  String get ringtonePreview => 'Vorschau';

  @override
  String get ringtonePreviewHint =>
      'Abspielen tippen zum Anhoren, dann Namen tippen zum Auswahlen.';

  @override
  String get voicesCurrentVoice => 'Aktuelle Stimme';

  @override
  String get voicesNewlyInstalled => 'Neu installierte Stimmen';

  @override
  String get voicesOnDevice => 'Stimmen auf diesem Gerät';

  @override
  String get voicesDownloadHint =>
      'Öffnen Sie die Sprachverwaltung des Geräts. Kehren Sie danach hierher zurück.';

  @override
  String get voicesRescan => 'Stimmen erneut scannen';

  @override
  String voicesRescanResult(int count) {
    return '$count nutzbare Stimmen gefunden';
  }

  @override
  String voicesNewFound(int count) {
    return '$count neue Stimmen gefunden.';
  }

  @override
  String get voicesNoNewFound => 'Keine neuen Stimmen erkannt.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Die $language-Stimme wurde aus den Geräteeinstellungen aktualisiert.';
  }

  @override
  String get voicesNoChange => 'Keine Stimmänderungen erkannt.';

  @override
  String get voicesNewBadge => 'Neu';

  @override
  String voiceFriendlyName(String number) {
    return 'Stimme $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Sprachverwaltung konnte nicht geöffnet werden. Öffnen Sie die System-TTS-Einstellungen.';
}

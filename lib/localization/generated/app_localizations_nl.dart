// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Word wakker met je eigen stem';

  @override
  String get homeTitle => 'Alarmen';

  @override
  String get homeEmptyTitle => 'Nog geen alarmen';

  @override
  String get homeEmptySubtitle =>
      'Maak je eerste spraakalarm en word wakker met woorden die ertoe doen.';

  @override
  String get homeCreateAlarm => 'Alarm maken';

  @override
  String get homeEdit => 'Bewerken';

  @override
  String get homeDuplicate => 'Dupliceren';

  @override
  String get homeDelete => 'Verwijderen';

  @override
  String get homeMore => 'Meer opties';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmen gereed',
      one: '1 alarm gereed',
      zero: 'Geen alarmen',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Goedemorgen';

  @override
  String get homeGoodAfternoon => 'Goedemiddag';

  @override
  String get homeGoodEvening => 'Goedenavond';

  @override
  String get alarmTypeVoice => 'Stem';

  @override
  String get alarmTypeRingtone => 'Beltoon';

  @override
  String get alarmTypeMixed => 'Gemengd';

  @override
  String get alarmTypeLabel => 'Alarmtype';

  @override
  String get createAlarmTitle => 'Nieuw alarm';

  @override
  String get editAlarmTitle => 'Alarm bewerken';

  @override
  String get alarmTime => 'Tijd';

  @override
  String get alarmHour => 'Uur';

  @override
  String get alarmMinute => 'Minuut';

  @override
  String get alarmRepeat => 'Herhalen';

  @override
  String get alarmVoiceSequence => 'Spraaksequentie';

  @override
  String get alarmRingtone => 'Beltoon na de stem';

  @override
  String get alarmRepeatCount => 'Sequentieherhalingen';

  @override
  String get alarmCopyFrom => 'Kopiëren van een ander alarm';

  @override
  String get alarmSave => 'Alarm opslaan';

  @override
  String get alarmSelectSequence => 'Tik om de sequentie te bewerken';

  @override
  String get alarmSelectRingtone => 'Kies een geluid';

  @override
  String get alarmNoneSelected => 'Niets geselecteerd';

  @override
  String get alarmCopied => 'Instellingen gekopieerd';

  @override
  String get alarmSaved => 'Alarm opgeslagen';

  @override
  String get alarmDeleted => 'Alarm verwijderd';

  @override
  String get alarmDuplicated => 'Alarm gedupliceerd';

  @override
  String get dayMon => 'Ma';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Wo';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Vr';

  @override
  String get daySat => 'Za';

  @override
  String get daySun => 'Zo';

  @override
  String get dayEveryDay => 'Elke dag';

  @override
  String get dayWeekdays => 'Werkdagen';

  @override
  String get dayWeekends => 'Weekenden';

  @override
  String get dayOnce => 'Eenmaal';

  @override
  String get voiceSequenceTitle => 'Spraaksequentie';

  @override
  String get voiceSequenceEmptyTitle => 'Maak je wekbericht';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Voeg opnames of gesproken tekst toe in de volgorde waarin je ze wilt horen.';

  @override
  String get voiceSequenceAdd => 'Stem toevoegen';

  @override
  String get voiceSequenceDelete => 'Verwijderen';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Segment verwijderen?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Dit verwijdert het segment uit de sequentie.';

  @override
  String get voiceSequenceReorderHint => 'Sleep om te herschikken';

  @override
  String get voiceSegmentName => 'Naam';

  @override
  String get voiceSegmentType => 'Type';

  @override
  String get voiceSegmentDuration => 'Duur';

  @override
  String voiceSegmentOrder(int number) {
    return 'Stap $number';
  }

  @override
  String get voiceTypeRecording => 'Opname';

  @override
  String get voiceTypeTts => 'Tekst-naar-spraak';

  @override
  String get addVoiceTitle => 'Stem toevoegen';

  @override
  String get addVoiceRecord => 'Stem opnemen';

  @override
  String get addVoiceRecordSubtitle =>
      'Spreek een kort bericht in je microfoon';

  @override
  String get addVoiceTts => 'Tekst-naar-spraak';

  @override
  String get addVoiceTtsSubtitle => 'Typ een bericht en kies een stem';

  @override
  String get ttsTitle => 'Tekst-naar-spraak';

  @override
  String get ttsInputLabel => 'Bericht';

  @override
  String get ttsInputHint => 'Typ het bericht dat je wilt horen…';

  @override
  String get ttsVoices => 'Stemmen';

  @override
  String get ttsLanguageLabel => 'Taal';

  @override
  String get ttsVoiceNameLabel => 'Stem';

  @override
  String get ttsVoiceQualityLabel => 'Kwaliteit';

  @override
  String get ttsPreview => 'Voorbeeld';

  @override
  String get ttsPreviewing => 'Voorbeeld afspelen…';

  @override
  String get ttsSave => 'Opslaan';

  @override
  String get ttsSaved => 'Spraaksegment opgeslagen';

  @override
  String get recordTitle => 'Stem opnemen';

  @override
  String get recordStart => 'Opnemen';

  @override
  String get recordStop => 'Stoppen';

  @override
  String get recordPlay => 'Afspelen';

  @override
  String get recordPlaying => 'Afspelen…';

  @override
  String get recordSave => 'Opslaan';

  @override
  String get recordHint => 'Tik op Opnemen wanneer je klaar bent';

  @override
  String get recordRecording => 'Opnemen…';

  @override
  String get recordReady => 'Klaar om op te slaan';

  @override
  String get recordSaved => 'Opname opgeslagen';

  @override
  String get recordDefaultName => 'Spraakopname';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsAppearance => 'Weergave';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsThemeSystem => 'Systeem';

  @override
  String get settingsThemeLight => 'Licht';

  @override
  String get settingsThemeDark => 'Donker';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsReminder => 'Herinnering';

  @override
  String get settingsReminderSubtitle =>
      'Krijg een zachte tip als er geen alarm is gepland';

  @override
  String get settingsReminderTime => 'Herinneringstijd';

  @override
  String get settingsAbout => 'Over';

  @override
  String get settingsAboutSubtitle => 'App-info en ondersteuning';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Ontgrendel onbeperkte alarmen';

  @override
  String get settingsVoices => 'Stemmen';

  @override
  String get settingsVoicesSubtitle => 'Systeemstemmen voor tekst-naar-spraak';

  @override
  String get settingsVersion => 'Versie';

  @override
  String get settingsLicenses => 'Open-sourcelicenties';

  @override
  String get settingsPrivacy => 'Privacybeleid';

  @override
  String get settingsTerms => 'Gebruiksvoorwaarden';

  @override
  String get settingsLegalPlaceholder => 'Document bekijken';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Onbeperkte alarmen ontgrendelen';

  @override
  String get premiumSubtitle =>
      'De gratis versie bevat tot 3 alarmen. Ontgrendel onbeperkte alarmen met één lifetime-aankoop. Geen abonnementen.';

  @override
  String get premiumPlanFree => 'Gratis';

  @override
  String get premiumPlanLifetime => 'Premium levenslang';

  @override
  String get premiumPlanLifetimePrice => 'Eenmalige aankoop';

  @override
  String get premiumBenefitsTitle => 'Alles in Premium';

  @override
  String get premiumBenefitUnlimited => 'Onbeperkte alarmen';

  @override
  String get premiumBenefitSequences =>
      'Spraakreeksen zonder functievergrendelingen';

  @override
  String get premiumBenefitVoices => 'Alle geïnstalleerde systeemstemmen';

  @override
  String get premiumBenefitThemes =>
      'Thema’s, herinneringen en opnemen blijven gratis';

  @override
  String get premiumBenefitSupport => 'Prioritaire ondersteuning';

  @override
  String get premiumBenefitNoAds => 'Geen advertenties';

  @override
  String get premiumUnlock => 'Onbeperkte alarmen ontgrendelen';

  @override
  String get premiumRestore => 'Aankoop herstellen';

  @override
  String get premiumThanks => 'Bedankt voor je steun aan Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Producten moeten worden ingesteld in App Store Connect en Google Play Console.';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonDone => 'Klaar';

  @override
  String get commonBack => 'Terug';

  @override
  String get commonNext => 'Volgende';

  @override
  String get commonClose => 'Sluiten';

  @override
  String get commonEnabled => 'Aan';

  @override
  String get commonDisabled => 'Uit';

  @override
  String get commonRemove => 'Verwijderen';

  @override
  String get commonOpen => 'Openen';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageSpanish => 'Spaans';

  @override
  String get languagePortuguese => 'Portugees';

  @override
  String get languageFrench => 'Frans';

  @override
  String get languageGerman => 'Duits';

  @override
  String get languageItalian => 'Italiaans';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get languageJapanese => 'Japans';

  @override
  String get languageKorean => 'Koreaans';

  @override
  String get languageChineseSimplified => 'Chinees (vereenvoudigd)';

  @override
  String get languageChineseTraditional => 'Chinees (traditioneel)';

  @override
  String get languageIndonesian => 'Indonesisch';

  @override
  String get languageVietnamese => 'Vietnamees';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count keer',
      one: '1 keer',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segmenten',
      one: '1 segment',
      zero: 'Geen segmenten',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Zachte bel';

  @override
  String get ringtoneOceanBreeze => 'Oceaanbries';

  @override
  String get ringtoneNightPulse => 'Nachtpuls';

  @override
  String get ringtoneForestDawn => 'Bosdageraad';

  @override
  String get ringtoneCrystalBell => 'Kristallen bel';

  @override
  String get alarmStop => 'Stoppen';

  @override
  String get alarmStopAll => 'Alles stoppen';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmen wachten',
      one: '1 alarm wacht',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Stemmen';

  @override
  String get voicesSystemVoices => 'Systeemstemmen';

  @override
  String get voicesDownloadMore => 'Meer stemmen downloaden';

  @override
  String get voicesRefresh => 'Stemmen vernieuwen';

  @override
  String get voicesOfflineHint =>
      'Geef de voorkeur aan offline stemmen zodat alarmen nog spreken zonder netwerkverbinding.';

  @override
  String get voicesIosGuideTitle => 'Stemmen installeren op iPhone';

  @override
  String get voicesIosGuideBody =>
      'Open Instellingen → Toegankelijkheid → Gesproken content → Stemmen, download de stemmen die je nodig hebt, kom hier terug en tik op Stemmen vernieuwen.';

  @override
  String get voicesAndroidGuide =>
      'Opent de TTS-gegevensinstaller van het systeem. Smart Voice Alarm downloadt of host geen spraakpakketten.';

  @override
  String get voicesWebUnavailable =>
      'Browsers beheren hun eigen stemmen. Downloadpakketten zijn niet beschikbaar op het web.';

  @override
  String get voicesEmpty => 'Nog geen bruikbare stemmen gevonden';

  @override
  String get voicesEmptyCta => 'Meer stemmen downloaden';

  @override
  String get voiceQualityDefault => 'Standaard';

  @override
  String get voiceQualityEnhanced => 'Verbeterd';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Offline';

  @override
  String get voiceAvailabilityNetwork => 'Netwerk vereist';

  @override
  String get voiceAvailabilityMissing => 'Niet geïnstalleerd';

  @override
  String get ttsNoVoicesTitle => 'Geen bruikbare stemmen';

  @override
  String get ttsNoVoicesBody =>
      'Download systeemstemmen en vernieuw daarna de lijst.';

  @override
  String get ttsOpenVoiceSettings => 'Meer stemmen downloaden';

  @override
  String get ttsVoiceFallback =>
      'De geselecteerde stem is niet beschikbaar. Er wordt een standaardstem gebruikt.';

  @override
  String get reminderNotificationTitle => 'Stel het alarm van morgen in';

  @override
  String get reminderNotificationBody =>
      'Neem even de tijd om je Smart Voice Alarm voor morgen in te plannen.';

  @override
  String get aboutTitle => 'Over';

  @override
  String get aboutAppName => 'Appnaam';

  @override
  String get aboutVersion => 'Versie';

  @override
  String get aboutDeveloper => 'Ontwikkelaar';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'GitHub-repository';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => 'E-mailondersteuning';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => 'Binnenkort';

  @override
  String get voiceSystemDefault => 'Systeemstandaard';

  @override
  String get voiceSystemDefaultHint => 'Beheerd in de apparaatinstellingen';

  @override
  String get notificationChannelAlarms => 'Alarmen';

  @override
  String get notificationChannelAlarmsDesc => 'Spraakalarmmeldingen';

  @override
  String get notificationChannelReminders => 'Herinneringen';

  @override
  String get notificationChannelRemindersDesc =>
      'Dagelijkse herinnering om morgen’s alarm in te stellen';

  @override
  String get alarmDefaultLabel => 'Alarm';

  @override
  String get premiumBenefitLifetimeBuy => 'Koop één keer. Voor altijd van jou.';

  @override
  String get premiumStatusLoading => 'Winkel controleren…';

  @override
  String get premiumStatusPurchasing => 'Aankoop starten…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime ontgrendeld';

  @override
  String get premiumStatusRestored => 'Aankoop hersteld';

  @override
  String get premiumStatusCancelled => 'Aankoop geannuleerd';

  @override
  String get premiumStatusPending => 'Aankoop in behandeling…';

  @override
  String get premiumStatusError => 'Aankoop mislukt. Probeer opnieuw.';

  @override
  String get premiumWebUnavailable =>
      'In-app aankopen zijn niet beschikbaar in de webdemo.';

  @override
  String get premiumStoreUnavailable =>
      'De winkel is niet beschikbaar op dit apparaat.';

  @override
  String get premiumLimitExplainFree => 'De gratis versie bevat tot 3 alarmen.';

  @override
  String get premiumLimitExplainUnlock =>
      'Ontgrendel onbeperkte alarmen met één lifetime-aankoop.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Tot $count alarmen';
  }

  @override
  String get voicesSearchHint => 'Zoek talen of stemmen';

  @override
  String get voicesLanguages => 'Talen';

  @override
  String get voicesSelectVoiceHint => 'Kies een stem voor deze taal';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmen',
      one: '1 stem',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Tik om een tijd te kiezen';

  @override
  String get segmentPlay => 'Afspelen';

  @override
  String get voicePlaying => 'Bezig met afspelen';

  @override
  String get voiceSelect => 'Selecteren';

  @override
  String get voiceUnavailable => 'Stem niet beschikbaar';

  @override
  String get recordingFileMissing =>
      'Opnamebestand ontbreekt. Verwijder dit segment of neem opnieuw op.';

  @override
  String get voiceDetails => 'Stemdetails';

  @override
  String get ttsSelectedVoice => 'Geselecteerde stem';

  @override
  String get voicePreviewSample => 'Dit is een korte preview van deze stem.';

  @override
  String get alarmDismissTitle => 'Los op om te stoppen';

  @override
  String get alarmDismissHint => 'Beantwoord juist om de wekker uit te zetten.';

  @override
  String get alarmDismissWrong => 'Onjuist. Nieuwe vraag.';

  @override
  String get alarmDismissCheck => 'Controleren';

  @override
  String get alarmDismissAnswerHint => 'Jouw antwoord';

  @override
  String voicesRefreshed(int count) {
    return 'Vernieuwd: $count stemmen gevonden';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Stem opgeslagen: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Open het stembeheer van het apparaat. Kom daarna hier terug.';

  @override
  String get voicesRefreshHint =>
      'Stemmen vernieuwen herlaadt systeems TTS-stemmen na installatie.';

  @override
  String get ringtonePreview => 'Voorbeeld';

  @override
  String get ringtonePreviewHint =>
      'Tik op afspelen om te beluisteren, tik op de naam om te kiezen.';

  @override
  String get voicesCurrentVoice => 'Huidige stem';

  @override
  String get voicesNewlyInstalled => 'Nieuw geïnstalleerde stemmen';

  @override
  String get voicesOnDevice => 'Stemmen op dit apparaat';

  @override
  String get voicesDownloadHint =>
      'Open het stembeheer van het apparaat. Kom daarna hier terug.';

  @override
  String get voicesRescan => 'Stemmen opnieuw scannen';

  @override
  String voicesRescanResult(int count) {
    return '$count bruikbare stemmen gevonden';
  }

  @override
  String voicesNewFound(int count) {
    return '$count nieuwe stemmen gevonden.';
  }

  @override
  String get voicesNoNewFound => 'Geen nieuwe stemmen gevonden.';

  @override
  String voicesSystemUpdated(String language) {
    return '$language-stem bijgewerkt vanuit apparaatinstellingen.';
  }

  @override
  String get voicesNoChange => 'Geen stemwijzigingen gevonden.';

  @override
  String get voicesSettingsRefreshed =>
      'Apparaatsteminstellingen zijn vernieuwd.';

  @override
  String get voicesSystemChanges => 'Apparaatstem-updates';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Apparaatinstellingen voor $language-stem zijn bijgewerkt.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Nieuwe stemmen en apparaatupdates verschijnen hier.';

  @override
  String get voicesNewBadge => 'Nieuw';

  @override
  String get commonClear => 'Wissen';

  @override
  String voiceFriendlyName(String number) {
    return 'Stem $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Kon stembeheer niet openen. Open de systeem-TTS-instellingen.';

  @override
  String get currentVoice => 'Huidige stem';

  @override
  String get scanDeviceVoices => 'Stemmen op apparaat scannen';

  @override
  String get availableDeviceVoices => 'Beschikbare stemmen op dit apparaat';

  @override
  String get scanVoicesHint =>
      'Tik op Stemmen scannen om geïnstalleerde stemmen te tonen.';

  @override
  String get noDeviceVoicesFound =>
      'Geen geschikte stemmen gevonden op dit apparaat.';

  @override
  String get scanVoicesFailed => 'Stemmen scannen mislukt. Probeer opnieuw.';

  @override
  String get voiceSetupGuide => 'Stemmen toevoegen';

  @override
  String get openVoiceSettings => 'Steminstellingen openen';

  @override
  String get androidVoiceSetupSteps =>
      '1. Open Instellingen op het apparaat.\n2. Zoek Tekst-naar-spraak of Text-to-speech.\n3. Open de TTS-engine die je gebruikt.\n4. Open talen of stemgegevens.\n5. Installeer een nieuwe stem.\n6. Kom terug en tik op Stemmen scannen.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Open Instellingen.\n2. Open Toegankelijkheid.\n3. Open Gesproken inhoud of Stemmen.\n4. Kies een taal en download een stem.\n5. Kom terug en scan opnieuw.\nMenunamen kunnen per iOS-versie verschillen.';

  @override
  String get webVoiceAvailabilityInfo =>
      'Op het web komen beschikbare stemmen van browser en besturingssysteem.';

  @override
  String lastScanned(String time) {
    return 'Laatst gescand: $time';
  }

  @override
  String get voiceInUse => 'In gebruik';

  @override
  String get otherLanguages => 'Andere talen';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmen',
      one: '1 stem',
      zero: 'Geen stemmen',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Taalstemmen uitklappen';

  @override
  String get collapseLanguageVoices => 'Taalstemmen inklappen';

  @override
  String voicePreviewNamed(String name) {
    return '$name beluisteren';
  }
}

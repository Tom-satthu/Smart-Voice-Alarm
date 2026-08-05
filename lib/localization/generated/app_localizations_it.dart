// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Svegliati con la tua voce';

  @override
  String get homeTitle => 'Sveglie';

  @override
  String get homeEmptyTitle => 'Nessuna sveglia ancora';

  @override
  String get homeEmptySubtitle =>
      'Crea la tua prima sveglia vocale e svegliati con parole che contano.';

  @override
  String get homeCreateAlarm => 'Crea sveglia';

  @override
  String get homeEdit => 'Modifica';

  @override
  String get homeDuplicate => 'Duplica';

  @override
  String get homeDelete => 'Elimina';

  @override
  String get homeMore => 'Altre opzioni';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sveglie pronte',
      one: '1 sveglia pronta',
      zero: 'Nessuna sveglia',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Buongiorno';

  @override
  String get homeGoodAfternoon => 'Buon pomeriggio';

  @override
  String get homeGoodEvening => 'Buonasera';

  @override
  String get alarmTypeVoice => 'Voce';

  @override
  String get alarmTypeRingtone => 'Suoneria';

  @override
  String get alarmTypeMixed => 'Mista';

  @override
  String get alarmTypeLabel => 'Tipo di sveglia';

  @override
  String get createAlarmTitle => 'Nuova sveglia';

  @override
  String get editAlarmTitle => 'Modifica sveglia';

  @override
  String get alarmTime => 'Ora';

  @override
  String get alarmHour => 'Ora';

  @override
  String get alarmMinute => 'Minuto';

  @override
  String get alarmRepeat => 'Ripeti';

  @override
  String get alarmVoiceSequence => 'Sequenza vocale';

  @override
  String get alarmRingtone => 'Suoneria dopo la voce';

  @override
  String get alarmRepeatCount => 'Ripetizioni della sequenza';

  @override
  String get alarmCopyFrom => 'Copia da un’altra sveglia';

  @override
  String get alarmSave => 'Salva sveglia';

  @override
  String get alarmSelectSequence => 'Tocca per modificare la sequenza';

  @override
  String get alarmSelectRingtone => 'Scegli un suono';

  @override
  String get alarmNoneSelected => 'Nessuna selezione';

  @override
  String get alarmCopied => 'Impostazioni copiate';

  @override
  String get alarmSaved => 'Sveglia salvata';

  @override
  String get alarmDeleted => 'Sveglia eliminata';

  @override
  String get alarmDuplicated => 'Sveglia duplicata';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Gio';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sab';

  @override
  String get daySun => 'Dom';

  @override
  String get dayEveryDay => 'Ogni giorno';

  @override
  String get dayWeekdays => 'Giorni feriali';

  @override
  String get dayWeekends => 'Fine settimana';

  @override
  String get dayOnce => 'Una volta';

  @override
  String get voiceSequenceTitle => 'Sequenza vocale';

  @override
  String get voiceSequenceEmptyTitle => 'Crea il tuo messaggio di sveglia';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Aggiungi registrazioni o testo parlato nell’ordine in cui vuoi sentirli.';

  @override
  String get voiceSequenceAdd => 'Aggiungi voce';

  @override
  String get voiceSequenceDelete => 'Elimina';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Rimuovere il segmento?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Questo rimuove il segmento dalla sequenza.';

  @override
  String get voiceSequenceReorderHint => 'Trascina per riordinare';

  @override
  String get voiceSegmentName => 'Nome';

  @override
  String get voiceSegmentType => 'Tipo';

  @override
  String get voiceSegmentDuration => 'Durata';

  @override
  String voiceSegmentOrder(int number) {
    return 'Passo $number';
  }

  @override
  String get voiceTypeRecording => 'Registrazione';

  @override
  String get voiceTypeTts => 'Sintesi vocale';

  @override
  String get addVoiceTitle => 'Aggiungi voce';

  @override
  String get addVoiceRecord => 'Registra voce';

  @override
  String get addVoiceRecordSubtitle =>
      'Pronuncia un breve messaggio nel microfono';

  @override
  String get addVoiceTts => 'Sintesi vocale';

  @override
  String get addVoiceTtsSubtitle => 'Digita un messaggio e scegli una voce';

  @override
  String get ttsTitle => 'Sintesi vocale';

  @override
  String get ttsInputLabel => 'Messaggio';

  @override
  String get ttsInputHint => 'Digita il messaggio che vuoi sentire…';

  @override
  String get ttsVoices => 'Voci';

  @override
  String get ttsLanguageLabel => 'Lingua';

  @override
  String get ttsVoiceNameLabel => 'Voce';

  @override
  String get ttsVoiceQualityLabel => 'Qualità';

  @override
  String get ttsPreview => 'Anteprima';

  @override
  String get ttsPreviewing => 'Riproduzione anteprima…';

  @override
  String get ttsSave => 'Salva';

  @override
  String get ttsSaved => 'Segmento vocale salvato';

  @override
  String get recordTitle => 'Registra voce';

  @override
  String get recordStart => 'Registra';

  @override
  String get recordStop => 'Ferma';

  @override
  String get recordPlay => 'Riproduci';

  @override
  String get recordPlaying => 'Riproduzione…';

  @override
  String get recordSave => 'Salva';

  @override
  String get recordHint => 'Tocca Registra quando sei pronto';

  @override
  String get recordRecording => 'Registrazione…';

  @override
  String get recordReady => 'Pronto per salvare';

  @override
  String get recordSaved => 'Registrazione salvata';

  @override
  String get recordDefaultName => 'Registrazione vocale';

  @override
  String get recordPermissionTitle => 'Accesso al microfono';

  @override
  String get recordPermissionRationale =>
      'L’app richiede l’accesso al microfono per registrare l’audio che userai come sveglia.';

  @override
  String get recordPermissionDenied =>
      'L’accesso al microfono non è stato concesso. Nessuna registrazione è iniziata. Puoi riprovare.';

  @override
  String get recordPermissionPermanentlyDenied =>
      'L’accesso al microfono è bloccato. Apri le impostazioni di sistema e consentilo prima di registrare.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsReminder => 'Promemoria';

  @override
  String get settingsReminderSubtitle =>
      'Ricevi un avviso gentile se non è programmata nessuna sveglia';

  @override
  String get settingsReminderTime => 'Ora del promemoria';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsAboutSubtitle => 'Info sull’app e supporto';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Sblocca sveglie illimitate';

  @override
  String get settingsVoices => 'Voci';

  @override
  String get settingsVoicesSubtitle => 'Voci di sistema per la sintesi vocale';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsLicenses => 'Licenze open source';

  @override
  String get settingsPrivacy => 'Informativa sulla privacy';

  @override
  String get settingsTerms => 'Termini di utilizzo';

  @override
  String get settingsLegalPlaceholder => 'Visualizza documento';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Sblocca sveglie illimitate';

  @override
  String get premiumSubtitle =>
      'La versione gratuita include fino a 3 sveglie. Sblocca sveglie illimitate con un acquisto a vita. Nessun abbonamento.';

  @override
  String get premiumPlanFree => 'Gratis';

  @override
  String get premiumPlanLifetime => 'Premium a vita';

  @override
  String get premiumPlanLifetimePrice => 'Acquisto unico';

  @override
  String get premiumBenefitsTitle => 'Tutto in Premium';

  @override
  String get premiumBenefitUnlimited => 'Sveglie illimitate';

  @override
  String get premiumBenefitSequences => 'Sequenze vocali senza blocchi';

  @override
  String get premiumBenefitVoices => 'Tutte le voci di sistema installate';

  @override
  String get premiumBenefitThemes =>
      'Temi, promemoria e registrazione restano gratuiti';

  @override
  String get premiumBenefitSupport => 'Supporto prioritario';

  @override
  String get premiumBenefitNoAds => 'Senza pubblicità';

  @override
  String get premiumUnlock => 'Sblocca sveglie illimitate';

  @override
  String get premiumRestore => 'Ripristina acquisto';

  @override
  String get premiumThanks => 'Grazie per supportare Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'I prodotti devono essere configurati in App Store Connect e Google Play Console.';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonDone => 'Fatto';

  @override
  String get commonBack => 'Indietro';

  @override
  String get commonNext => 'Avanti';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonEnabled => 'Attivo';

  @override
  String get commonDisabled => 'Disattivo';

  @override
  String get commonRemove => 'Rimuovi';

  @override
  String get commonOpen => 'Apri';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageDutch => 'Olandese';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageChineseSimplified => 'Cinese (semplificato)';

  @override
  String get languageChineseTraditional => 'Cinese (tradizionale)';

  @override
  String get languageIndonesian => 'Indonesiano';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volte',
      one: '1 volta',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segmenti',
      one: '1 segmento',
      zero: 'Nessun segmento',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Campanello soffice';

  @override
  String get ringtoneOceanBreeze => 'Brezza oceanica';

  @override
  String get ringtoneNightPulse => 'Impulso notturno';

  @override
  String get ringtoneForestDawn => 'Alba nel bosco';

  @override
  String get ringtoneCrystalBell => 'Campana di cristallo';

  @override
  String get alarmStop => 'Ferma';

  @override
  String get alarmStopAll => 'Ferma tutto';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sveglie in attesa',
      one: '1 sveglia in attesa',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Voci';

  @override
  String get voicesSystemVoices => 'Voci di sistema';

  @override
  String get voicesDownloadMore => 'Scarica altre voci';

  @override
  String get voicesRefresh => 'Aggiorna voci';

  @override
  String get voicesOfflineHint =>
      'Preferisci le voci offline così le sveglie parlano anche senza connessione di rete.';

  @override
  String get voicesIosGuideTitle => 'Installa voci su iPhone';

  @override
  String get voicesIosGuideBody =>
      'Apri Impostazioni → Accessibilità → Contenuti parlati → Voci, scarica le voci necessarie, poi torna qui e tocca Aggiorna voci.';

  @override
  String get voicesAndroidGuide =>
      'Apre l’installer dei dati TTS di sistema. Smart Voice Alarm non scarica né ospita pacchetti vocali.';

  @override
  String get voicesWebUnavailable =>
      'I browser gestiscono le proprie voci. I pacchetti di download non sono disponibili sul web.';

  @override
  String get voicesEmpty => 'Nessuna voce utilizzabile trovata ancora';

  @override
  String get voicesEmptyCta => 'Scarica altre voci';

  @override
  String get voiceQualityDefault => 'Predefinita';

  @override
  String get voiceQualityEnhanced => 'Migliorata';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Offline';

  @override
  String get voiceAvailabilityNetwork => 'Richiede rete';

  @override
  String get voiceAvailabilityMissing => 'Non installata';

  @override
  String get ttsNoVoicesTitle => 'Nessuna voce utilizzabile';

  @override
  String get ttsNoVoicesBody =>
      'Scarica le voci di sistema, poi aggiorna l’elenco.';

  @override
  String get ttsOpenVoiceSettings => 'Scarica altre voci';

  @override
  String get ttsVoiceFallback =>
      'La voce selezionata non è disponibile. Verrà usata una voce predefinita.';

  @override
  String get reminderNotificationTitle => 'Imposta la sveglia di domani';

  @override
  String get reminderNotificationBody =>
      'Prenditi un momento per programmare il tuo Smart Voice Alarm per domani.';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutAppName => 'Nome app';

  @override
  String get aboutVersion => 'Versione';

  @override
  String get aboutDeveloper => 'Sviluppatore';

  @override
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'Supporto e-mail';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Sito web';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'In arrivo';

  @override
  String get voiceSystemDefault => 'Predefinita di sistema';

  @override
  String get voiceSystemDefaultHint =>
      'Gestita nelle impostazioni del dispositivo';

  @override
  String get notificationChannelAlarms => 'Sveglie';

  @override
  String get notificationChannelAlarmsDesc => 'Avvisi sveglia vocale';

  @override
  String get notificationChannelReminders => 'Promemoria';

  @override
  String get notificationChannelRemindersDesc =>
      'Promemoria giornaliero per impostare la sveglia di domani';

  @override
  String get alarmDefaultLabel => 'Sveglia';

  @override
  String get premiumBenefitLifetimeBuy => 'Compra una volta. Tuo per sempre.';

  @override
  String get premiumStatusLoading => 'Controllo dello store…';

  @override
  String get premiumStatusPurchasing => 'Avvio acquisto…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime sbloccato';

  @override
  String get premiumStatusRestored => 'Acquisto ripristinato';

  @override
  String get premiumStatusCancelled => 'Acquisto annullato';

  @override
  String get premiumStatusPending => 'Acquisto in sospeso…';

  @override
  String get premiumStatusError => 'Acquisto non riuscito. Riprova.';

  @override
  String get premiumWebUnavailable =>
      'Gli acquisti non sono disponibili nella demo web.';

  @override
  String get premiumStoreUnavailable =>
      'Lo store non è disponibile su questo dispositivo.';

  @override
  String get premiumLimitExplainFree =>
      'La versione gratuita include fino a 3 sveglie.';

  @override
  String get premiumLimitExplainUnlock =>
      'Sblocca sveglie illimitate con un acquisto a vita.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Fino a $count sveglie';
  }

  @override
  String get voicesSearchHint => 'Cerca lingue o voci';

  @override
  String get voicesLanguages => 'Lingue';

  @override
  String get voicesSelectVoiceHint => 'Scegli una voce per questa lingua';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci',
      one: '1 voce',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Tocca per scegliere l\'ora';

  @override
  String get segmentPlay => 'Riproduci';

  @override
  String get voicePlaying => 'In riproduzione';

  @override
  String get voiceSelect => 'Seleziona';

  @override
  String get voiceUnavailable => 'Voce non disponibile';

  @override
  String get recordingFileMissing =>
      'File di registrazione mancante. Elimina questo segmento o registra di nuovo.';

  @override
  String get voiceDetails => 'Dettagli voce';

  @override
  String get ttsSelectedVoice => 'Voce selezionata';

  @override
  String get voicePreviewSample =>
      'Questa è una breve anteprima di questa voce.';

  @override
  String get alarmDismissTitle => 'Risolvi per interrompere';

  @override
  String get alarmDismissHint =>
      'Rispondi correttamente per spegnere la sveglia.';

  @override
  String get alarmDismissWrong => 'Errato. Nuova domanda.';

  @override
  String get alarmDismissCheck => 'Verifica';

  @override
  String get alarmDismissAnswerHint => 'La tua risposta';

  @override
  String voicesRefreshed(int count) {
    return 'Aggiornato: $count voci trovate';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Voce salvata: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Apri la gestione voci del dispositivo. Dopo il download, torna qui.';

  @override
  String get voicesRefreshHint =>
      'Aggiorna voci ricarica le voci TTS di sistema dopo l installazione.';

  @override
  String get ringtonePreview => 'Anteprima';

  @override
  String get ringtonePreviewHint =>
      'Tocca play per ascoltare, poi il nome per selezionare.';

  @override
  String get voicesCurrentVoice => 'Voce in uso';

  @override
  String get voicesNewlyInstalled => 'Voci appena installate';

  @override
  String get voicesOnDevice => 'Voci su questo dispositivo';

  @override
  String get voicesDownloadHint =>
      'Apri la gestione voci del dispositivo. Dopo il download, torna qui.';

  @override
  String get voicesRescan => 'Riscansiona voci';

  @override
  String voicesRescanResult(int count) {
    return 'Trovate $count voci utilizzabili';
  }

  @override
  String voicesNewFound(int count) {
    return 'Trovate $count nuove voci.';
  }

  @override
  String get voicesNoNewFound => 'Nessuna nuova voce rilevata.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Voce $language aggiornata dalle impostazioni del dispositivo.';
  }

  @override
  String get voicesNoChange => 'Nessuna modifica alle voci rilevata.';

  @override
  String get voicesSettingsRefreshed =>
      'Impostazioni voce del dispositivo aggiornate.';

  @override
  String get voicesSystemChanges => 'Aggiornamenti voce dispositivo';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Le impostazioni voce $language del dispositivo sono state aggiornate.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Le nuove voci e gli aggiornamenti appariranno qui.';

  @override
  String get voicesNewBadge => 'Nuova';

  @override
  String get commonClear => 'Cancella';

  @override
  String voiceFriendlyName(String number) {
    return 'Voce $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Impossibile aprire la gestione voci. Apri le impostazioni TTS di sistema.';

  @override
  String get currentVoice => 'Voce attuale';

  @override
  String get scanDeviceVoices => 'Scansiona voci sul dispositivo';

  @override
  String get availableDeviceVoices => 'Voci disponibili sul dispositivo';

  @override
  String get scanVoicesHint =>
      'Tocca Scansiona voci sul dispositivo per vedere le voci installate.';

  @override
  String get noDeviceVoicesFound =>
      'Nessuna voce adatta trovata sul dispositivo.';

  @override
  String get scanVoicesFailed => 'Impossibile scansionare le voci. Riprova.';

  @override
  String get voiceSetupGuide => 'Come aggiungere voci';

  @override
  String get openVoiceSettings => 'Apri impostazioni voce';

  @override
  String get androidVoiceSetupSteps =>
      '1. Apri Impostazioni del dispositivo.\n2. Cerca Sintesi vocale o Text-to-speech.\n3. Apri il motore TTS in uso.\n4. Apri lingue o dati vocali.\n5. Installa una nuova voce.\n6. Torna qui e tocca Scansiona voci.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Apri Impostazioni.\n2. Apri Accessibilità.\n3. Apri Contenuti letti o Voci.\n4. Scegli una lingua e scarica una voce.\n5. Torna qui e scansiona di nuovo.\nI nomi dei menu possono variare con iOS.';

  @override
  String get webVoiceAvailabilityInfo =>
      'Sul Web le voci disponibili dipendono dal browser e dal sistema.';

  @override
  String lastScanned(String time) {
    return 'Ultima scansione: $time';
  }

  @override
  String get voiceInUse => 'In uso';

  @override
  String get otherLanguages => 'Altre lingue';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci',
      one: '1 voce',
      zero: 'Nessuna voce',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Espandi voci della lingua';

  @override
  String get collapseLanguageVoices => 'Comprimi voci della lingua';

  @override
  String voicePreviewNamed(String name) {
    return 'Anteprima di $name';
  }

  @override
  String get settingsSoundAndVoice => 'Suono e voce';

  @override
  String get settingsAlarmsSection => 'Sveglie';

  @override
  String get supportAndFeedback => 'Supporto';

  @override
  String get contactSupport => 'Contatti e feedback';

  @override
  String get supportEmailSubject => 'Supporto Smart Voice Alarm';

  @override
  String get emailCopied => 'Email di supporto copiata';

  @override
  String get linkUnavailable => 'Questo link non è ancora disponibile';

  @override
  String get openSourceLicenses => 'Licenze open source';

  @override
  String get appInformation => 'Informazioni sull\'app';

  @override
  String get appVersion => 'Versione app';

  @override
  String get permissionsAndBackground =>
      'Autorizzazioni e attività in background';

  @override
  String get notificationPermission => 'Notifiche';

  @override
  String get exactAlarmPermission => 'Sveglie esatte';

  @override
  String get fullScreenAlarmPermission => 'Sveglie a schermo intero';

  @override
  String get openSystemSettings => 'Apri impostazioni di sistema';

  @override
  String get openSystemSettingsHint =>
      'Gestisci notifiche e autorizzazioni correlate';

  @override
  String get permissionStatusGranted => 'Concessa';

  @override
  String get permissionStatusDenied => 'Non concessa';

  @override
  String get permissionStatusUnknown => 'Sconosciuto';

  @override
  String trialDaysRemaining(int count) {
    return '$count giorni di prova rimanenti';
  }

  @override
  String get trialLessThanOneDay => 'Meno di 1 giorno di prova rimanente';

  @override
  String get premiumUpgrade => 'Passa a Premium';

  @override
  String get premiumAnnualTitle => 'Premium per un anno';

  @override
  String get premiumAnnualDescription =>
      'Continua a usare tutte le funzioni di Smart Voice Alarm dopo la prova di 7 giorni.';

  @override
  String get premiumAnnualPlan => 'Piano Premium annuale';

  @override
  String get premiumAnnualAutoRenew =>
      'Si rinnova automaticamente ogni anno fino alla disdetta.';

  @override
  String get premiumAnnualCancelInPlay =>
      'Gestisci o annulla tramite Google Play.';

  @override
  String get premiumAnnualAccess =>
      'L’accesso completo continua finché l’abbonamento è attivo.';

  @override
  String get premiumSubscribeAnnual => 'Abbonati a Premium per un anno';

  @override
  String get premiumDefer => 'Più tardi';

  @override
  String get premiumRestoreTransactions => 'Ripristina transazioni';

  @override
  String get premiumManageSubscription => 'Gestisci abbonamento';

  @override
  String get premiumProductUnavailable =>
      'L’abbonamento annuale non è ancora disponibile su Google Play.';

  @override
  String get premiumBillingUnavailable =>
      'Google Play Billing non è disponibile.';

  @override
  String get premiumPurchaseActive => 'Premium è attivo';

  @override
  String get premiumTrialExpiredTitle => 'La prova è terminata';

  @override
  String get premiumTrialExpiredBody =>
      'Abbonati per continuare a usare le funzioni principali. Le sveglie esistenti possono ancora suonare ed essere disattivate o eliminate.';

  @override
  String get premiumRetryVerification => 'Riprova';

  @override
  String get premiumViewExistingAlarms => 'Visualizza sveglie esistenti';

  @override
  String get premiumClientVerificationNotice =>
      'Lo stato dell’abbonamento viene verificato su questo dispositivo tramite lo store.';

  @override
  String get premiumUnableToVerify => 'Impossibile verificare l’abbonamento.';

  @override
  String get premiumRestrictedAlarmsTitle => 'Accesso limitato alle sveglie';

  @override
  String get premiumRestrictedAlarmsBody =>
      'Puoi disattivare o eliminare le sveglie esistenti. Abbonati per crearle o modificarle.';

  @override
  String get iosFullVoiceAlarmSupport =>
      'Supporto completo agli allarmi vocali';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'On iOS 26 and later, Smart Voice Alarm uses AlarmKit so voice segments and ringtones can ring with system alarm behavior.';

  @override
  String get iosLimitedSupportTitle => 'Supporto limitato su iOS meno recenti';

  @override
  String get iosLimitedSupportBody =>
      'Le sveglie vocali usano notifiche locali (AlarmKit non è ancora attivo). Apri la notifica o scegli Solve to stop per avviare la sfida. Scorri via senza aprire non ferma i segmenti successivi.';

  @override
  String get iosSilentModeWarning =>
      'Silent Mode may prevent notification alarm sounds from playing on older iOS versions.';

  @override
  String get iosFocusWarning =>
      'Focus modes can affect notification delivery on older iOS versions.';

  @override
  String get ios26Recommendation =>
      'For the most reliable voice alarms, use iOS 26 or later.';

  @override
  String get alarmKitPermission => 'Alarm permission';

  @override
  String get alarmKitDenied =>
      'AlarmKit permission is denied. Enable alarms for Smart Voice Alarm in Settings.';

  @override
  String get alarmKitPermissionBody =>
      'Allow AlarmKit so Smart Voice Alarm can schedule system voice alarms.';

  @override
  String get solveNow => 'Risolvi ora';

  @override
  String get alarmSolveToStop => 'Risolvi per fermare';

  @override
  String get alarmDismissedTitle => 'Allarme archiviato';

  @override
  String get alarmDismissedBody =>
      'All remaining segments for this alarm were cancelled.';

  @override
  String get voiceDurationLimitTitle => 'Voice duration limit';

  @override
  String get voiceDurationLimitBody =>
      'On iOS, each voice segment can be at most 20 seconds. Trim or recreate the voice to continue.';

  @override
  String get trimOrRecreateVoice => 'Trim or recreate voice';

  @override
  String get audioRenderingError =>
      'Could not prepare alarm audio. The alarm was not scheduled.';

  @override
  String get fallbackSoundWarning =>
      'Using a system fallback sound because the selected audio could not be prepared.';

  @override
  String get savedVoicesTitle => 'Voci salvate';

  @override
  String get savedVoicesEmpty =>
      'Saved recordings and TTS voices will appear here after you add them.';

  @override
  String get savedVoiceAdded => 'Voce aggiunta alla sequenza';

  @override
  String get iosCapabilityLearnMore => 'How alarms work on this iPhone';

  @override
  String get alarmAudioNeedsRegeneration =>
      'L\'audio della sveglia vocale deve essere rigenerato.';

  @override
  String get iosAlarmLoudnessHint =>
      'Il volume della sveglia dipende anche da Impostazioni → Suoni e feedback aptico → Suoneria e avvisi.';

  @override
  String get addSavedVoiceToSequence => 'Aggiungi alla sequenza';

  @override
  String get savedVoiceInUseTitle => 'Voice in use';

  @override
  String savedVoiceInUseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This voice is used by $count alarms and cannot be deleted.',
      one: 'This voice is used by 1 alarm and cannot be deleted.',
    );
    return '$_temp0';
  }

  @override
  String get savedVoiceInUseBodyOne =>
      'This voice is used by 1 alarm and cannot be deleted.';

  @override
  String savedVoiceInUseBodyMany(int count) {
    return 'This voice is used by $count alarms and cannot be deleted.';
  }

  @override
  String get savedVoiceInOpenDraftBody =>
      'This voice is in the current unsaved alarm.';

  @override
  String get savedVoiceUsageTitle => 'Alarms using this voice';

  @override
  String get savedVoiceUsageEmpty => 'No alarms currently use this voice.';

  @override
  String get mixedAlarmNeedsVoiceAndRingtone =>
      'Mixed alarms need at least one voice and a ringtone.';

  @override
  String get alarmNotificationLimitExceeded =>
      'Too many notification segments. Lower repeat count or remove some voices.';

  @override
  String get savedVoiceViewAlarms => 'View alarms';

  @override
  String get savedVoiceDeleteTitle => 'Delete saved voice?';

  @override
  String get savedVoiceDeleteBody =>
      'This removes the voice from your library. Alarms are not changed.';

  @override
  String get savedVoiceDeleted => 'Saved voice deleted';

  @override
  String get savedVoiceCleanupTitle => 'Clean up unused voices';

  @override
  String get savedVoiceCleanupSubtitle =>
      'Remove library voices that are not used by any alarm.';

  @override
  String get savedVoiceCleanupEmpty => 'No unused voices to clean up.';

  @override
  String savedVoiceCleanupConfirm(int count) {
    return 'Delete $count unused voices?';
  }

  @override
  String savedVoiceCleanupBytes(String size) {
    return 'About $size of recordings can be freed.';
  }

  @override
  String get savedVoiceSelectAll => 'Select all';

  @override
  String get savedVoiceDeleteAction => 'Delete';

  @override
  String get savedVoicePreviewAction => 'Preview';

  @override
  String get iosNotificationPathHint =>
      'Notification sound volume follows Ringtone and Alerts, which can be quieter than in-app preview even for the same file.';

  @override
  String get debugPlayRenderedCaf => 'Play rendered CAF (debug)';
}

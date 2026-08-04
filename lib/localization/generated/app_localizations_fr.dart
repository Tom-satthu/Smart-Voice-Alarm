// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Réveillez-vous avec votre propre voix';

  @override
  String get homeTitle => 'Alarmes';

  @override
  String get homeEmptyTitle => 'Aucune alarme pour l’instant';

  @override
  String get homeEmptySubtitle =>
      'Créez votre première alarme vocale et réveillez-vous avec des mots qui comptent.';

  @override
  String get homeCreateAlarm => 'Créer une alarme';

  @override
  String get homeEdit => 'Modifier';

  @override
  String get homeDuplicate => 'Dupliquer';

  @override
  String get homeDelete => 'Supprimer';

  @override
  String get homeMore => 'Plus d’options';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmes prêtes',
      one: '1 alarme prête',
      zero: 'Aucune alarme',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Bonjour';

  @override
  String get homeGoodAfternoon => 'Bon après-midi';

  @override
  String get homeGoodEvening => 'Bonsoir';

  @override
  String get alarmTypeVoice => 'Voix';

  @override
  String get alarmTypeRingtone => 'Sonnerie';

  @override
  String get alarmTypeMixed => 'Mixte';

  @override
  String get alarmTypeLabel => 'Type d’alarme';

  @override
  String get createAlarmTitle => 'Nouvelle alarme';

  @override
  String get editAlarmTitle => 'Modifier l’alarme';

  @override
  String get alarmTime => 'Heure';

  @override
  String get alarmHour => 'Heure';

  @override
  String get alarmMinute => 'Minute';

  @override
  String get alarmRepeat => 'Répéter';

  @override
  String get alarmVoiceSequence => 'Séquence vocale';

  @override
  String get alarmRingtone => 'Sonnerie après la voix';

  @override
  String get alarmRepeatCount => 'Répétitions de la séquence';

  @override
  String get alarmCopyFrom => 'Copier depuis une autre alarme';

  @override
  String get alarmSave => 'Enregistrer l’alarme';

  @override
  String get alarmSelectSequence => 'Appuyez pour modifier la séquence';

  @override
  String get alarmSelectRingtone => 'Choisir un son';

  @override
  String get alarmNoneSelected => 'Aucun sélectionné';

  @override
  String get alarmCopied => 'Paramètres copiés';

  @override
  String get alarmSaved => 'Alarme enregistrée';

  @override
  String get alarmDeleted => 'Alarme supprimée';

  @override
  String get alarmDuplicated => 'Alarme dupliquée';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySun => 'Dim';

  @override
  String get dayEveryDay => 'Tous les jours';

  @override
  String get dayWeekdays => 'Jours ouvrés';

  @override
  String get dayWeekends => 'Week-ends';

  @override
  String get dayOnce => 'Une fois';

  @override
  String get voiceSequenceTitle => 'Séquence vocale';

  @override
  String get voiceSequenceEmptyTitle => 'Créez votre message de réveil';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Ajoutez des enregistrements ou du texte parlé dans l’ordre où vous souhaitez les entendre.';

  @override
  String get voiceSequenceAdd => 'Ajouter une voix';

  @override
  String get voiceSequenceDelete => 'Supprimer';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Supprimer le segment ?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Cela retire le segment de la séquence.';

  @override
  String get voiceSequenceReorderHint => 'Faites glisser pour réorganiser';

  @override
  String get voiceSegmentName => 'Nom';

  @override
  String get voiceSegmentType => 'Type';

  @override
  String get voiceSegmentDuration => 'Durée';

  @override
  String voiceSegmentOrder(int number) {
    return 'Étape $number';
  }

  @override
  String get voiceTypeRecording => 'Enregistrement';

  @override
  String get voiceTypeTts => 'Synthèse vocale';

  @override
  String get addVoiceTitle => 'Ajouter une voix';

  @override
  String get addVoiceRecord => 'Enregistrer la voix';

  @override
  String get addVoiceRecordSubtitle =>
      'Dites un court message dans votre micro';

  @override
  String get addVoiceTts => 'Synthèse vocale';

  @override
  String get addVoiceTtsSubtitle =>
      'Saisissez un message et choisissez une voix';

  @override
  String get ttsTitle => 'Synthèse vocale';

  @override
  String get ttsInputLabel => 'Message';

  @override
  String get ttsInputHint => 'Saisissez le message que vous voulez entendre…';

  @override
  String get ttsVoices => 'Voix';

  @override
  String get ttsLanguageLabel => 'Langue';

  @override
  String get ttsVoiceNameLabel => 'Voix';

  @override
  String get ttsVoiceQualityLabel => 'Qualité';

  @override
  String get ttsPreview => 'Aperçu';

  @override
  String get ttsPreviewing => 'Lecture de l’aperçu…';

  @override
  String get ttsSave => 'Enregistrer';

  @override
  String get ttsSaved => 'Segment vocal enregistré';

  @override
  String get recordTitle => 'Enregistrer la voix';

  @override
  String get recordStart => 'Enregistrer';

  @override
  String get recordStop => 'Arrêter';

  @override
  String get recordPlay => 'Lire';

  @override
  String get recordPlaying => 'Lecture…';

  @override
  String get recordSave => 'Enregistrer';

  @override
  String get recordHint => 'Appuyez sur Enregistrer quand vous êtes prêt';

  @override
  String get recordRecording => 'Enregistrement…';

  @override
  String get recordReady => 'Prêt à enregistrer';

  @override
  String get recordSaved => 'Enregistrement sauvegardé';

  @override
  String get recordDefaultName => 'Enregistrement vocal';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsReminder => 'Rappel';

  @override
  String get settingsReminderSubtitle =>
      'Recevez un rappel discret si aucune alarme n’est planifiée';

  @override
  String get settingsReminderTime => 'Heure du rappel';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutSubtitle => 'Infos de l’app et assistance';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Débloquez des alarmes illimitées';

  @override
  String get settingsVoices => 'Voix';

  @override
  String get settingsVoicesSubtitle => 'Voix système pour la synthèse vocale';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicenses => 'Licences open source';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsTerms => 'Conditions d’utilisation';

  @override
  String get settingsLegalPlaceholder => 'Voir le document';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Débloquer des alarmes illimitées';

  @override
  String get premiumSubtitle =>
      'La version gratuite inclut jusqu’à 3 alarmes. Débloquez des alarmes illimitées avec un achat à vie. Sans abonnement.';

  @override
  String get premiumPlanFree => 'Gratuit';

  @override
  String get premiumPlanLifetime => 'Premium à vie';

  @override
  String get premiumPlanLifetimePrice => 'Achat unique';

  @override
  String get premiumBenefitsTitle => 'Tout dans Premium';

  @override
  String get premiumBenefitUnlimited => 'Alarmes illimitées';

  @override
  String get premiumBenefitSequences => 'Séquences vocales sans verrouillage';

  @override
  String get premiumBenefitVoices => 'Toutes les voix système installées';

  @override
  String get premiumBenefitThemes =>
      'Thèmes, rappels et enregistrement restent gratuits';

  @override
  String get premiumBenefitSupport => 'Assistance prioritaire';

  @override
  String get premiumBenefitNoAds => 'Sans publicité';

  @override
  String get premiumUnlock => 'Débloquer des alarmes illimitées';

  @override
  String get premiumRestore => 'Restaurer l’achat';

  @override
  String get premiumThanks => 'Merci de soutenir Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Les produits doivent être configurés dans App Store Connect et Google Play Console.';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonEnabled => 'Activé';

  @override
  String get commonDisabled => 'Désactivé';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonOpen => 'Ouvrir';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageDutch => 'Néerlandais';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageChineseSimplified => 'Chinois (simplifié)';

  @override
  String get languageChineseTraditional => 'Chinois (traditionnel)';

  @override
  String get languageIndonesian => 'Indonésien';

  @override
  String get languageVietnamese => 'Vietnamien';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '1 fois',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segments',
      one: '1 segment',
      zero: 'Aucun segment',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Carillon doux';

  @override
  String get ringtoneOceanBreeze => 'Brise océane';

  @override
  String get ringtoneNightPulse => 'Pulsation nocturne';

  @override
  String get ringtoneForestDawn => 'Aube en forêt';

  @override
  String get ringtoneCrystalBell => 'Cloche de cristal';

  @override
  String get alarmStop => 'Arrêter';

  @override
  String get alarmStopAll => 'Tout arrêter';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmes en attente',
      one: '1 alarme en attente',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Voix';

  @override
  String get voicesSystemVoices => 'Voix système';

  @override
  String get voicesDownloadMore => 'Télécharger plus de voix';

  @override
  String get voicesRefresh => 'Actualiser les voix';

  @override
  String get voicesOfflineHint =>
      'Préférez les voix hors ligne pour que les alarmes parlent même sans connexion réseau.';

  @override
  String get voicesIosGuideTitle => 'Installer des voix sur iPhone';

  @override
  String get voicesIosGuideBody =>
      'Ouvrez Réglages → Accessibilité → Contenu parlé → Voix, téléchargez les voix dont vous avez besoin, puis revenez ici et appuyez sur Actualiser les voix.';

  @override
  String get voicesAndroidGuide =>
      'Ouvre l’installateur de données TTS du système. Smart Voice Alarm ne télécharge ni n’héberge de packs de voix.';

  @override
  String get voicesWebUnavailable =>
      'Les navigateurs gèrent leurs propres voix. Les packs de téléchargement ne sont pas disponibles sur le web.';

  @override
  String get voicesEmpty => 'Aucune voix utilisable trouvée pour l’instant';

  @override
  String get voicesEmptyCta => 'Télécharger plus de voix';

  @override
  String get voiceQualityDefault => 'Par défaut';

  @override
  String get voiceQualityEnhanced => 'Améliorée';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Hors ligne';

  @override
  String get voiceAvailabilityNetwork => 'Nécessite un réseau';

  @override
  String get voiceAvailabilityMissing => 'Non installée';

  @override
  String get ttsNoVoicesTitle => 'Aucune voix utilisable';

  @override
  String get ttsNoVoicesBody =>
      'Téléchargez des voix système, puis actualisez la liste.';

  @override
  String get ttsOpenVoiceSettings => 'Télécharger plus de voix';

  @override
  String get ttsVoiceFallback =>
      'La voix sélectionnée est indisponible. Utilisation d’une voix par défaut.';

  @override
  String get reminderNotificationTitle => 'Réglez l’alarme de demain';

  @override
  String get reminderNotificationBody =>
      'Prenez un moment pour planifier votre Smart Voice Alarm pour demain.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutAppName => 'Nom de l’app';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDeveloper => 'Développeur';

  @override
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutGithub => 'Dépôt GitHub';

  @override
  String get aboutGithubValue => 'github.com/Tom-deptrai/Smart-Voice-Alarm';

  @override
  String get aboutEmail => 'Assistance par e-mail';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Site web';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'Bientôt disponible';

  @override
  String get voiceSystemDefault => 'Voix système';

  @override
  String get voiceSystemDefaultHint => 'Gérée dans les réglages de l’appareil';

  @override
  String get notificationChannelAlarms => 'Alarmes';

  @override
  String get notificationChannelAlarmsDesc => 'Alertes d’alarme vocale';

  @override
  String get notificationChannelReminders => 'Rappels';

  @override
  String get notificationChannelRemindersDesc =>
      'Rappel quotidien pour régler l’alarme de demain';

  @override
  String get alarmDefaultLabel => 'Alarme';

  @override
  String get premiumBenefitLifetimeBuy =>
      'Achetez une fois. À vous pour toujours.';

  @override
  String get premiumStatusLoading => 'Vérification de la boutique…';

  @override
  String get premiumStatusPurchasing => 'Démarrage de l’achat…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime débloqué';

  @override
  String get premiumStatusRestored => 'Achat restauré';

  @override
  String get premiumStatusCancelled => 'Achat annulé';

  @override
  String get premiumStatusPending => 'Achat en attente…';

  @override
  String get premiumStatusError => 'Échec de l’achat. Réessayez.';

  @override
  String get premiumWebUnavailable =>
      'Les achats ne sont pas disponibles sur la démo web.';

  @override
  String get premiumStoreUnavailable =>
      'La boutique est indisponible sur cet appareil.';

  @override
  String get premiumLimitExplainFree =>
      'La version gratuite inclut jusqu’à 3 alarmes.';

  @override
  String get premiumLimitExplainUnlock =>
      'Débloquez des alarmes illimitées avec un achat à vie.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Jusqu’à $count alarmes';
  }

  @override
  String get voicesSearchHint => 'Rechercher des langues ou des voix';

  @override
  String get voicesLanguages => 'Langues';

  @override
  String get voicesSelectVoiceHint => 'Choisissez une voix pour cette langue';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voix',
      one: '1 voix',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Appuyez pour choisir l\'heure';

  @override
  String get segmentPlay => 'Lecture';

  @override
  String get voicePlaying => 'Lecture en cours';

  @override
  String get voiceSelect => 'Sélectionner';

  @override
  String get voiceUnavailable => 'Voix indisponible';

  @override
  String get recordingFileMissing =>
      'Fichier d\'enregistrement manquant. Supprimez ce segment ou enregistrez à nouveau.';

  @override
  String get voiceDetails => 'Détails de la voix';

  @override
  String get ttsSelectedVoice => 'Voix sélectionnée';

  @override
  String get voicePreviewSample => 'Ceci est un court aperçu de cette voix.';

  @override
  String get alarmDismissTitle => 'Resolvez pour arreter';

  @override
  String get alarmDismissHint =>
      'Repondez correctement pour eteindre l alarme.';

  @override
  String get alarmDismissWrong => 'Incorrect. Nouvelle question.';

  @override
  String get alarmDismissCheck => 'Verifier';

  @override
  String get alarmDismissAnswerHint => 'Votre reponse';

  @override
  String voicesRefreshed(int count) {
    return 'Actualise : $count voix trouvees';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Voix enregistree : $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Ouvrez le gestionnaire de voix de l’appareil. Après le téléchargement, revenez ici.';

  @override
  String get voicesRefreshHint =>
      'Actualiser les voix recharge les voix TTS systeme apres installation.';

  @override
  String get ringtonePreview => 'Apercu';

  @override
  String get ringtonePreviewHint =>
      'Appuyez sur lecture pour ecouter, puis sur le nom pour choisir.';

  @override
  String get voicesCurrentVoice => 'Voix actuelle';

  @override
  String get voicesNewlyInstalled => 'Voix nouvellement installées';

  @override
  String get voicesOnDevice => 'Voix sur cet appareil';

  @override
  String get voicesDownloadHint =>
      'Ouvrez le gestionnaire de voix de l’appareil. Après le téléchargement, revenez ici.';

  @override
  String get voicesRescan => 'Rescanner les voix';

  @override
  String voicesRescanResult(int count) {
    return '$count voix utilisables trouvées';
  }

  @override
  String voicesNewFound(int count) {
    return '$count nouvelles voix trouvées.';
  }

  @override
  String get voicesNoNewFound => 'Aucune nouvelle voix détectée.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Voix $language mise à jour depuis les réglages de l\'appareil.';
  }

  @override
  String get voicesNoChange => 'Aucun changement de voix détecté.';

  @override
  String get voicesSettingsRefreshed =>
      'Les réglages de voix de l\'appareil ont été actualisés.';

  @override
  String get voicesSystemChanges => 'Mises à jour des voix de l\'appareil';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Les réglages de voix $language de l\'appareil ont été mis à jour.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Les nouvelles voix et mises à jour apparaîtront ici.';

  @override
  String get voicesNewBadge => 'Nouveau';

  @override
  String get commonClear => 'Effacer';

  @override
  String voiceFriendlyName(String number) {
    return 'Voix $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Impossible d’ouvrir le gestionnaire de voix. Ouvrez les réglages TTS système.';

  @override
  String get currentVoice => 'Voix actuelle';

  @override
  String get scanDeviceVoices => 'Analyser les voix de l\'appareil';

  @override
  String get availableDeviceVoices => 'Voix disponibles sur l\'appareil';

  @override
  String get scanVoicesHint =>
      'Appuyez sur Analyser les voix pour lister les voix installées.';

  @override
  String get noDeviceVoicesFound =>
      'Aucune voix adaptée n\'a été trouvée sur l\'appareil.';

  @override
  String get scanVoicesFailed => 'Impossible d\'analyser les voix. Réessayez.';

  @override
  String get voiceSetupGuide => 'Comment ajouter des voix';

  @override
  String get openVoiceSettings => 'Ouvrir les réglages voix';

  @override
  String get androidVoiceSetupSteps =>
      '1. Ouvrez les Réglages de l\'appareil.\n2. Cherchez Synthèse vocale ou Text-to-speech.\n3. Ouvrez le moteur TTS utilisé.\n4. Ouvrez langues ou données vocales.\n5. Installez une nouvelle voix.\n6. Revenez ici et appuyez sur Analyser les voix.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Ouvrez Réglages.\n2. Ouvrez Accessibilité.\n3. Ouvrez Contenu lu ou Voix.\n4. Choisissez une langue et téléchargez une voix.\n5. Revenez ici et analysez à nouveau.\nLes noms de menus peuvent varier selon iOS.';

  @override
  String get webVoiceAvailabilityInfo =>
      'Sur le Web, les voix disponibles viennent du navigateur et du système.';

  @override
  String lastScanned(String time) {
    return 'Dernière analyse : $time';
  }

  @override
  String get voiceInUse => 'En cours d\'utilisation';

  @override
  String get otherLanguages => 'Autres langues';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voix',
      one: '1 voix',
      zero: 'Aucune voix',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Développer les voix de la langue';

  @override
  String get collapseLanguageVoices => 'Réduire les voix de la langue';

  @override
  String voicePreviewNamed(String name) {
    return 'Écouter $name';
  }

  @override
  String get settingsSoundAndVoice => 'Son et voix';

  @override
  String get settingsAlarmsSection => 'Alarmes';

  @override
  String get supportAndFeedback => 'Assistance';

  @override
  String get contactSupport => 'Contact et commentaires';

  @override
  String get supportEmailSubject => 'Assistance Smart Voice Alarm';

  @override
  String get emailCopied => 'E-mail d\'assistance copié';

  @override
  String get linkUnavailable => 'Ce lien n\'est pas encore disponible';

  @override
  String get openSourceLicenses => 'Licences open source';

  @override
  String get appInformation => 'À propos de l\'application';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get permissionsAndBackground => 'Autorisations et arrière-plan';

  @override
  String get notificationPermission => 'Notifications';

  @override
  String get exactAlarmPermission => 'Alarmes exactes';

  @override
  String get openSystemSettings => 'Ouvrir les réglages système';

  @override
  String get openSystemSettingsHint =>
      'Gérer les notifications et autorisations associées';

  @override
  String get permissionStatusGranted => 'Accordée';

  @override
  String get permissionStatusDenied => 'Non accordée';

  @override
  String get permissionStatusUnknown => 'Inconnu';
}

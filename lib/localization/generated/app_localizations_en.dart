// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Wake up to your own voice';

  @override
  String get homeTitle => 'Alarms';

  @override
  String get homeEmptyTitle => 'No alarms yet';

  @override
  String get homeEmptySubtitle =>
      'Create your first voice alarm and wake up to words that matter.';

  @override
  String get homeCreateAlarm => 'Create Alarm';

  @override
  String get homeEdit => 'Edit';

  @override
  String get homeDuplicate => 'Duplicate';

  @override
  String get homeDelete => 'Delete';

  @override
  String get homeMore => 'More options';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarms ready',
      one: '1 alarm ready',
      zero: 'No alarms',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get alarmTypeVoice => 'Voice';

  @override
  String get alarmTypeRingtone => 'Ringtone';

  @override
  String get alarmTypeMixed => 'Mixed';

  @override
  String get alarmTypeLabel => 'Alarm type';

  @override
  String get mathChallengeTitle => 'Solve math to stop alarm';

  @override
  String get mathChallengeDescription =>
      'When on, you must solve a math problem correctly to stop the alarm.';

  @override
  String get createAlarmTitle => 'New Alarm';

  @override
  String get editAlarmTitle => 'Edit Alarm';

  @override
  String get alarmTime => 'Time';

  @override
  String get alarmHour => 'Hour';

  @override
  String get alarmMinute => 'Minute';

  @override
  String get alarmRepeat => 'Repeat';

  @override
  String get alarmVoiceSequence => 'Voice Sequence';

  @override
  String get alarmRingtone => 'Ringtone after voice';

  @override
  String get alarmRepeatCount => 'Sequence repeats';

  @override
  String get alarmCopyFrom => 'Copy from another alarm';

  @override
  String get alarmSave => 'Save Alarm';

  @override
  String get alarmSelectSequence => 'Tap to edit sequence';

  @override
  String get alarmSelectRingtone => 'Choose a sound';

  @override
  String get alarmNoneSelected => 'None selected';

  @override
  String get alarmCopied => 'Settings copied';

  @override
  String get alarmSaved => 'Alarm saved';

  @override
  String get alarmDeleted => 'Alarm deleted';

  @override
  String get alarmDuplicated => 'Alarm duplicated';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get dayEveryDay => 'Every day';

  @override
  String get dayWeekdays => 'Weekdays';

  @override
  String get dayWeekends => 'Weekends';

  @override
  String get dayOnce => 'Once';

  @override
  String get voiceSequenceTitle => 'Voice Sequence';

  @override
  String get voiceSequenceEmptyTitle => 'Build your wake-up message';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Add recordings or spoken text in the order you want to hear them.';

  @override
  String get voiceSequenceAdd => 'Add Voice';

  @override
  String get voiceSequenceDelete => 'Delete';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Remove segment?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'This removes the segment from the sequence.';

  @override
  String get voiceSequenceReorderHint => 'Drag to reorder';

  @override
  String get voiceSegmentName => 'Name';

  @override
  String get voiceSegmentType => 'Type';

  @override
  String get voiceSegmentDuration => 'Duration';

  @override
  String voiceSegmentOrder(int number) {
    return 'Step $number';
  }

  @override
  String get voiceTypeRecording => 'Recording';

  @override
  String get voiceTypeTts => 'Text to Speech';

  @override
  String get addVoiceTitle => 'Add Voice';

  @override
  String get addVoiceRecord => 'Record Voice';

  @override
  String get addVoiceRecordSubtitle =>
      'Speak a short message into your microphone';

  @override
  String get addVoiceTts => 'Text to Speech';

  @override
  String get addVoiceTtsSubtitle =>
      'Type a message and choose a speaking voice';

  @override
  String get ttsTitle => 'Text to Speech';

  @override
  String get ttsInputLabel => 'Message';

  @override
  String get ttsInputHint => 'Type the message you want to hear…';

  @override
  String get ttsVoices => 'Voices';

  @override
  String get ttsLanguageLabel => 'Language';

  @override
  String get ttsVoiceNameLabel => 'Voice';

  @override
  String get ttsVoiceQualityLabel => 'Quality';

  @override
  String get ttsPreview => 'Preview';

  @override
  String get ttsPreviewing => 'Playing preview…';

  @override
  String get ttsSave => 'Save';

  @override
  String get ttsSaved => 'Voice segment saved';

  @override
  String ttsCharCounter(int used, int max) {
    return '$used/$max characters';
  }

  @override
  String get ttsCharLimitReached =>
      'Character limit reached for this language.';

  @override
  String get ttsPasteTooLongTitle => 'Paste exceeds limit';

  @override
  String ttsPasteTooLongBody(int max) {
    return 'The paste is longer than $max characters. Insert only the first $max characters?';
  }

  @override
  String get ttsPasteInsertPartial => 'Insert partial';

  @override
  String get ttsTooLongDuration =>
      'Spoken audio is longer than 20 seconds. Shorten the text and try again.';

  @override
  String get ttsDurationChecking => 'Checking spoken length…';

  @override
  String get recordTitle => 'Record Voice';

  @override
  String recordTimerLabel(int used, int max) {
    return '$used/$max seconds';
  }

  @override
  String get recordAutoStopped => 'Recording stopped at 20 seconds.';

  @override
  String get recordLongClipWarning =>
      'This recording is longer than 20 seconds. Alarms will use only the first 20 seconds.';

  @override
  String get recordStart => 'Record';

  @override
  String get recordStop => 'Stop';

  @override
  String get recordPlay => 'Play';

  @override
  String get recordPlaying => 'Playing…';

  @override
  String get recordSave => 'Save';

  @override
  String get recordHint => 'Tap Record when you are ready';

  @override
  String get recordRecording => 'Recording…';

  @override
  String get recordReady => 'Ready to save';

  @override
  String get recordSaved => 'Recording saved';

  @override
  String get recordDefaultName => 'Voice recording';

  @override
  String get recordPermissionTitle => 'Microphone access';

  @override
  String get recordPermissionRationale =>
      'The app needs microphone access to record the audio clip you use as an alarm.';

  @override
  String get recordPermissionDenied =>
      'Microphone access was not granted. No recording was started. You can try again when you are ready.';

  @override
  String get recordPermissionPermanentlyDenied =>
      'Microphone access is blocked. Open system settings to allow it before recording.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsReminder => 'Reminder';

  @override
  String get settingsReminderSubtitle =>
      'Get a gentle nudge if no alarm is scheduled';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'App info and support';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Unlock unlimited alarms';

  @override
  String get settingsVoices => 'Voices';

  @override
  String get settingsVoicesSubtitle => 'System voices for text to speech';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicenses => 'Open Source Licenses';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsLegalPlaceholder => 'View document';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Unlock Unlimited Alarms';

  @override
  String get premiumSubtitle =>
      'Free includes up to 3 alarms. Unlock unlimited alarms with one lifetime purchase. No subscriptions.';

  @override
  String get premiumPlanFree => 'Free';

  @override
  String get premiumPlanLifetime => 'Premium Lifetime';

  @override
  String get premiumPlanLifetimePrice => 'One-time purchase';

  @override
  String get premiumBenefitsTitle => 'Everything in Premium';

  @override
  String get premiumBenefitUnlimited => 'Unlimited alarms';

  @override
  String get premiumBenefitSequences => 'Voice sequences without feature locks';

  @override
  String get premiumBenefitVoices => 'All installed system voices';

  @override
  String get premiumBenefitThemes =>
      'Themes, reminders, and recording stay free';

  @override
  String get premiumBenefitSupport => 'Priority support';

  @override
  String get premiumBenefitNoAds => 'No ads, ever';

  @override
  String get premiumUnlock => 'Unlock Unlimited Alarms';

  @override
  String get premiumRestore => 'Restore Purchase';

  @override
  String get premiumThanks => 'Thank you for supporting Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Store products must be configured in App Store Connect and Google Play Console.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDone => 'Done';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonClose => 'Close';

  @override
  String get commonEnabled => 'On';

  @override
  String get commonDisabled => 'Off';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonOpen => 'Open';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageChineseSimplified => 'Chinese (Simplified)';

  @override
  String get languageChineseTraditional => 'Chinese (Traditional)';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
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
      zero: 'No segments',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Soft Chime';

  @override
  String get ringtoneOceanBreeze => 'Ocean Breeze';

  @override
  String get ringtoneNightPulse => 'Night Pulse';

  @override
  String get ringtoneForestDawn => 'Forest Dawn';

  @override
  String get ringtoneCrystalBell => 'Crystal Bell';

  @override
  String get alarmStop => 'Stop';

  @override
  String get alarmStopAll => 'Stop All';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarms waiting',
      one: '1 alarm waiting',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Voices';

  @override
  String get voicesSystemVoices => 'System Voices';

  @override
  String get voicesDownloadMore => 'Download More Voices';

  @override
  String get voicesRefresh => 'Refresh Voices';

  @override
  String get voicesOfflineHint =>
      'Prefer offline voices so alarms still speak without a network connection.';

  @override
  String get voicesIosGuideTitle => 'Install voices on iPhone';

  @override
  String get voicesIosGuideBody =>
      'Open Settings → Accessibility → Spoken Content → Voices, download the voices you need, then return here and tap Refresh Voices.';

  @override
  String get voicesAndroidGuide =>
      'Opens the system TTS data installer. Smart Voice Alarm does not download or host voice packages.';

  @override
  String get voicesWebUnavailable =>
      'Browsers manage their own voices. Download packs are not available on web.';

  @override
  String get voicesEmpty => 'No usable voices found yet';

  @override
  String get voicesEmptyCta => 'Download More Voices';

  @override
  String get voiceQualityDefault => 'Default';

  @override
  String get voiceQualityEnhanced => 'Enhanced';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Offline';

  @override
  String get voiceAvailabilityNetwork => 'Needs network';

  @override
  String get voiceAvailabilityMissing => 'Not installed';

  @override
  String get ttsNoVoicesTitle => 'No usable voices';

  @override
  String get ttsNoVoicesBody =>
      'Download system voices, then refresh the list.';

  @override
  String get ttsOpenVoiceSettings => 'Download More Voices';

  @override
  String get ttsVoiceFallback =>
      'Selected voice is unavailable. Using a default voice instead.';

  @override
  String get reminderNotificationTitle => 'Set tomorrow’s alarm';

  @override
  String get reminderNotificationBody =>
      'Take a moment to schedule your Smart Voice Alarm for tomorrow.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppName => 'App Name';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'Email Support';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'Coming soon';

  @override
  String get voiceSystemDefault => 'System Default';

  @override
  String get voiceSystemDefaultHint => 'Managed in device settings';

  @override
  String get notificationChannelAlarms => 'Alarms';

  @override
  String get notificationChannelAlarmsDesc => 'Voice alarm alerts';

  @override
  String get notificationChannelReminders => 'Reminders';

  @override
  String get notificationChannelRemindersDesc =>
      'Daily reminder to set tomorrow’s alarm';

  @override
  String get alarmDefaultLabel => 'Alarm';

  @override
  String get premiumBenefitLifetimeBuy => 'Buy once. Yours forever.';

  @override
  String get premiumStatusLoading => 'Checking the store…';

  @override
  String get premiumStatusPurchasing => 'Starting purchase…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime unlocked';

  @override
  String get premiumStatusRestored => 'Purchase restored';

  @override
  String get premiumStatusCancelled => 'Purchase cancelled';

  @override
  String get premiumStatusPending => 'Purchase pending…';

  @override
  String get premiumStatusError => 'Purchase failed. Please try again.';

  @override
  String get premiumWebUnavailable =>
      'In-app purchases are not available on the web demo.';

  @override
  String get premiumStoreUnavailable =>
      'The store is unavailable on this device.';

  @override
  String get premiumLimitExplainFree => 'Free includes up to 3 alarms.';

  @override
  String get premiumLimitExplainUnlock =>
      'Unlock unlimited alarms with one lifetime purchase.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Up to $count alarms';
  }

  @override
  String get voicesSearchHint => 'Search languages or voices';

  @override
  String get voicesLanguages => 'Languages';

  @override
  String get voicesSelectVoiceHint => 'Choose a voice for this language';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voices',
      one: '1 voice',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Tap to choose time';

  @override
  String get segmentPlay => 'Play';

  @override
  String get voicePlaying => 'Playing';

  @override
  String get voiceSelect => 'Select';

  @override
  String get voiceUnavailable => 'Voice unavailable';

  @override
  String get recordingFileMissing =>
      'Recording file missing. Delete this segment or record again.';

  @override
  String get voiceDetails => 'Voice details';

  @override
  String get ttsSelectedVoice => 'Selected voice';

  @override
  String get voicePreviewSample => 'This is a short preview of this voice.';

  @override
  String get alarmDismissTitle => 'Solve to stop';

  @override
  String get alarmDismissHint => 'Answer correctly to turn off the alarm.';

  @override
  String get alarmDismissWrong => 'Incorrect. Try a new question.';

  @override
  String get alarmDismissCheck => 'Check answer';

  @override
  String get alarmDismissAnswerHint => 'Your answer';

  @override
  String voicesRefreshed(int count) {
    return 'Refreshed: $count voices found';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Saved voice: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Open your device voice manager. After downloading, return here.';

  @override
  String get voicesRefreshHint =>
      'Rescan Voices reloads system TTS voices after you install new packs.';

  @override
  String get ringtonePreview => 'Preview';

  @override
  String get ringtonePreviewHint =>
      'Tap play to preview, then tap a name to select it.';

  @override
  String get voicesCurrentVoice => 'Current voice';

  @override
  String get voicesNewlyInstalled => 'Newly installed voices';

  @override
  String get voicesOnDevice => 'Voices on this device';

  @override
  String get voicesDownloadHint =>
      'Open your device voice manager. After downloading, return here.';

  @override
  String get voicesRescan => 'Rescan voices';

  @override
  String voicesRescanResult(int count) {
    return 'Found $count usable voices';
  }

  @override
  String voicesNewFound(int count) {
    return 'Found $count new voices.';
  }

  @override
  String get voicesNoNewFound => 'No new voices detected.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Updated the $language voice from device settings.';
  }

  @override
  String get voicesNoChange => 'Device voice settings were refreshed.';

  @override
  String get voicesSettingsRefreshed => 'Device voice settings were refreshed.';

  @override
  String get voicesSystemChanges => 'Device voice updates';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Device $language voice settings were updated.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'New voices and device voice updates will appear here after you install or change them.';

  @override
  String get voicesNewBadge => 'New';

  @override
  String get commonClear => 'Clear';

  @override
  String voiceFriendlyName(String number) {
    return 'Voice $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Could not open the device voice manager. Open system Text-to-speech settings and install voices there.';

  @override
  String get currentVoice => 'Current voice';

  @override
  String get scanDeviceVoices => 'Scan voices on this device';

  @override
  String get availableDeviceVoices => 'Voices available on this device';

  @override
  String get scanVoicesHint =>
      'Tap Scan voices on this device to list the voices currently installed.';

  @override
  String get noDeviceVoicesFound =>
      'No suitable voices were found on this device.';

  @override
  String get scanVoicesFailed => 'Could not scan device voices. Try again.';

  @override
  String get voiceSetupGuide => 'How to add voices';

  @override
  String get openVoiceSettings => 'Open voice settings';

  @override
  String get androidVoiceSetupSteps =>
      '1. Open your device Settings.\n2. Search for Text-to-speech or Text to speech output.\n3. Open the TTS engine you use.\n4. Open languages or install voice data.\n5. Install a new voice.\n6. Return here and tap Scan voices on this device.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Open Settings.\n2. Open Accessibility.\n3. Open Spoken Content or Voices.\n4. Choose a language and download an available voice.\n5. Return here and scan again.\nMenu names can vary by iOS version.';

  @override
  String get webVoiceAvailabilityInfo =>
      'On the web, available voices come from your browser and operating system.';

  @override
  String lastScanned(String time) {
    return 'Last scanned: $time';
  }

  @override
  String get voiceInUse => 'In use';

  @override
  String get otherLanguages => 'Other languages';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voices',
      one: '1 voice',
      zero: 'No voices',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Expand language voices';

  @override
  String get collapseLanguageVoices => 'Collapse language voices';

  @override
  String voicePreviewNamed(String name) {
    return 'Preview $name';
  }

  @override
  String get settingsSoundAndVoice => 'Sound and voice';

  @override
  String get settingsAlarmsSection => 'Alarms';

  @override
  String get supportAndFeedback => 'Support';

  @override
  String get contactSupport => 'Contact and feedback';

  @override
  String get supportEmailSubject => 'Smart Voice Alarm Support';

  @override
  String get emailCopied => 'Support email copied';

  @override
  String get linkUnavailable => 'This link is not available yet';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get appInformation => 'About the app';

  @override
  String get appVersion => 'App version';

  @override
  String get permissionsAndBackground => 'Permissions and background';

  @override
  String get notificationPermission => 'Notifications';

  @override
  String get exactAlarmPermission => 'Exact alarms';

  @override
  String get fullScreenAlarmPermission => 'Full-screen alarms';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get openSystemSettingsHint =>
      'Manage notifications and related permissions';

  @override
  String get permissionStatusGranted => 'Granted';

  @override
  String get permissionStatusDenied => 'Not granted';

  @override
  String get permissionStatusUnknown => 'Unknown';

  @override
  String trialDaysRemaining(int count) {
    return '$count days left in your trial';
  }

  @override
  String get trialLessThanOneDay => 'Less than 1 day left in your trial';

  @override
  String get premiumUpgrade => 'Upgrade to Premium';

  @override
  String get premiumAnnualTitle => 'Premium for one year';

  @override
  String get premiumAnnualDescription =>
      'Continue using every Smart Voice Alarm feature after your 7-day trial.';

  @override
  String get premiumAnnualPlan => 'Premium annual plan';

  @override
  String get premiumAnnualAutoRenew =>
      'Automatically renews every year until cancelled.';

  @override
  String get premiumAnnualCancelInPlay =>
      'Manage or cancel through Google Play.';

  @override
  String get premiumAnnualCancelInAppStore =>
      'Manage or cancel through the App Store.';

  @override
  String get premiumAnnualAccess =>
      'Full access continues while the subscription is active.';

  @override
  String get premiumSubscribeAnnual => 'Subscribe to Premium for one year';

  @override
  String get premiumDefer => 'Maybe later';

  @override
  String get premiumRestoreTransactions => 'Restore transactions';

  @override
  String get premiumManageSubscription => 'Manage subscription';

  @override
  String get premiumProductUnavailable =>
      'The annual subscription is not available from Google Play yet.';

  @override
  String get premiumProductUnavailableAppStore =>
      'The annual subscription is not available from the App Store yet.';

  @override
  String get premiumBillingUnavailable =>
      'Google Play Billing is currently unavailable.';

  @override
  String get premiumBillingUnavailableAppStore =>
      'App Store billing is currently unavailable.';

  @override
  String get premiumPurchaseActive => 'Premium is active';

  @override
  String get premiumTrialExpiredTitle => 'Your trial has ended';

  @override
  String get premiumTrialExpiredBody =>
      'Subscribe to continue using the main features. Existing alarms can still ring and can be disabled or deleted.';

  @override
  String get premiumRetryVerification => 'Try again';

  @override
  String get premiumViewExistingAlarms => 'View existing alarms';

  @override
  String get premiumClientVerificationNotice =>
      'Subscription status is verified on this device through the app store.';

  @override
  String get premiumUnableToVerify => 'Unable to verify subscription status.';

  @override
  String get premiumRestrictedAlarmsTitle => 'Limited alarm access';

  @override
  String get premiumRestrictedAlarmsBody =>
      'You can disable or delete existing alarms. Subscribe to create or edit alarms.';

  @override
  String get iosFullVoiceAlarmSupport => 'Full voice alarm support';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'On iOS 26 and later, Smart Voice Alarm uses AlarmKit so voice segments and ringtones can ring with system alarm behavior.';

  @override
  String get iosLimitedSupportTitle => 'Limited support on older iOS';

  @override
  String get iosLimitedSupportBody =>
      'Voice alarms use local notifications (AlarmKit is not active yet). Open the notification or choose Solve to stop to start the math challenge. Swiping a notification away without opening it will not stop later segments. Silent Mode or Focus may mute or delay sound.';

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
  String get solveNow => 'Solve now';

  @override
  String get alarmSolveToStop => 'Solve to stop';

  @override
  String get alarmDismissedTitle => 'Alarm dismissed';

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
  String get ringtoneFallbackSystemWarning =>
      'Custom ringtone could not be prepared. The system alarm sound will be used.';

  @override
  String get iosAlarmDiagnosticsTitle => 'Run iOS alarm diagnostics';

  @override
  String get iosAlarmDiagnosticsRunning => 'Running diagnostics…';

  @override
  String get iosAlarmDiagnosticsDone =>
      'Diagnostics finished. Report copied when available.';

  @override
  String get iosAlarmDiagnosticsCopy => 'Copy report';

  @override
  String get savedVoicesTitle => 'Saved voices';

  @override
  String get savedVoicesEmpty =>
      'Saved recordings and TTS voices will appear here after you add them.';

  @override
  String get savedVoiceAdded => 'Voice added to sequence';

  @override
  String get iosCapabilityLearnMore => 'How alarms work on this iPhone';

  @override
  String get alarmAudioNeedsRegeneration =>
      'Voice alarm audio needs to be regenerated.';

  @override
  String get iosAlarmLoudnessHint =>
      'Alarm loudness also depends on Settings → Sounds & Haptics → Ringtone and Alerts.';

  @override
  String get addSavedVoiceToSequence => 'Add to sequence';

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

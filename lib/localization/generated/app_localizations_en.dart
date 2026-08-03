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
  String get ttsVoices => 'Voice';

  @override
  String get ttsPreview => 'Preview';

  @override
  String get ttsPreviewing => 'Playing preview…';

  @override
  String get ttsSave => 'Save';

  @override
  String get ttsSaved => 'Voice segment saved';

  @override
  String get recordTitle => 'Record Voice';

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
  String get settingsReminder => 'Reminder to set alarm';

  @override
  String get settingsReminderSubtitle =>
      'Get a gentle nudge if no alarm is scheduled';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsAboutSubtitle(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Unlock lifetime access';

  @override
  String get premiumTitle => 'Go Premium';

  @override
  String get premiumHeadline => 'One purchase. Yours forever.';

  @override
  String get premiumSubtitle =>
      'Support the app and unlock the complete voice alarm toolkit with a single lifetime purchase.';

  @override
  String get premiumBenefitUnlimited => 'Unlimited voice alarms';

  @override
  String get premiumBenefitSequences => 'Longer voice sequences';

  @override
  String get premiumBenefitVoices => 'More speaking voices';

  @override
  String get premiumBenefitThemes => 'Extra appearance options';

  @override
  String get premiumBenefitSupport => 'Priority support';

  @override
  String get premiumUnlock => 'Unlock Lifetime';

  @override
  String get premiumRestore => 'Restore Purchase';

  @override
  String get premiumThanks => 'Thank you for your support';

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
  String get languageEnglish => 'English';

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
  String get settingsVoiceSpeech => 'Voice & Speech';

  @override
  String get settingsVoiceSpeechSubtitle => 'System voices for text to speech';

  @override
  String get voiceSpeechTitle => 'Voice & Speech';

  @override
  String get voiceSpeechSystemVoices => 'System voices';

  @override
  String get voiceSpeechDownloadMore => 'Download more voices';

  @override
  String get voiceSpeechRefresh => 'Refresh voice list';

  @override
  String get voiceSpeechOfflineHint =>
      'Prefer offline voices so alarms still speak without a network connection.';

  @override
  String get voiceSpeechIosGuideTitle => 'Install voices on iPhone';

  @override
  String get voiceSpeechIosGuideBody =>
      'Open Settings → Accessibility → Spoken Content → Voices, download the voices you need, then return here and tap Refresh.';

  @override
  String get voiceSpeechAndroidGuide =>
      'Opens the system TTS data installer. Smart Voice Alarm does not download or host voice packages.';

  @override
  String get voiceSpeechWebUnavailable =>
      'Browsers manage their own voices. Download packs are not available on web.';

  @override
  String get voiceSpeechEmpty => 'No usable voices found yet';

  @override
  String get voiceSpeechEmptyCta => 'Download more voices';

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
  String get ttsOpenVoiceSettings => 'Download more voices';

  @override
  String get ttsVoiceFallback =>
      'Selected voice is unavailable. Using a default voice instead.';
}

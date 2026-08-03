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
  String get alarmTypeVoice => 'Voice';

  @override
  String get alarmTypeRingtone => 'Ringtone';

  @override
  String get alarmTypeMixed => 'Mixed';

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
  String get alarmRingtone => 'Ringtone';

  @override
  String get alarmRepeatCount => 'Repeat count';

  @override
  String get alarmCopyFrom => 'Copy from another alarm';

  @override
  String get alarmSave => 'Save Alarm';

  @override
  String get alarmSelectSequence => 'Select sequence';

  @override
  String get alarmSelectRingtone => 'Select ringtone';

  @override
  String get alarmNoneSelected => 'None selected';

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
  String get voiceSequenceEmptyTitle => 'No segments yet';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Add recordings or text-to-speech clips to build your wake-up message.';

  @override
  String get voiceSequenceAdd => 'Add Segment';

  @override
  String get voiceSequenceDelete => 'Delete';

  @override
  String get voiceSegmentName => 'Name';

  @override
  String get voiceSegmentType => 'Type';

  @override
  String get voiceSegmentDuration => 'Duration';

  @override
  String get voiceTypeRecording => 'Recording';

  @override
  String get voiceTypeTts => 'Text to Speech';

  @override
  String get addVoiceTitle => 'Add Voice';

  @override
  String get addVoiceRecord => 'Record';

  @override
  String get addVoiceRecordSubtitle => 'Capture your voice with the microphone';

  @override
  String get addVoiceTts => 'Text to Speech';

  @override
  String get addVoiceTtsSubtitle => 'Type a message and choose a voice';

  @override
  String get ttsTitle => 'Text to Speech';

  @override
  String get ttsInputHint => 'Type the message you want to hear…';

  @override
  String get ttsVoices => 'Voices';

  @override
  String get ttsPreview => 'Preview';

  @override
  String get ttsSave => 'Save';

  @override
  String get recordTitle => 'Record Voice';

  @override
  String get recordStart => 'Record';

  @override
  String get recordStop => 'Stop';

  @override
  String get recordPlay => 'Play';

  @override
  String get recordSave => 'Save';

  @override
  String get recordHint => 'Tap the button to start recording';

  @override
  String get recordRecording => 'Recording…';

  @override
  String get recordReady => 'Ready to save';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsReminder => 'Reminder';

  @override
  String get settingsReminderSubtitle => 'Gentle nudge before an alarm rings';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsAboutSubtitle(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Unlock lifetime access';

  @override
  String get premiumTitle => 'Go Premium';

  @override
  String get premiumHeadline => 'Wake up, elevated.';

  @override
  String get premiumSubtitle =>
      'Unlock the full voice alarm experience with a one-time purchase.';

  @override
  String get premiumBenefitUnlimited => 'Unlimited voice alarms';

  @override
  String get premiumBenefitSequences => 'Advanced voice sequences';

  @override
  String get premiumBenefitVoices => 'Premium TTS voices';

  @override
  String get premiumBenefitThemes => 'Exclusive themes';

  @override
  String get premiumBenefitSupport => 'Priority support';

  @override
  String get premiumUnlock => 'Unlock Lifetime';

  @override
  String get premiumRestore => 'Restore Purchase';

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
  String get languageEnglish => 'English';

  @override
  String timesLabel(int count) {
    return '$count times';
  }

  @override
  String segmentsLabel(int count) {
    return '$count segments';
  }
}

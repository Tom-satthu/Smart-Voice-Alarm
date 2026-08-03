import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Voice Alarm'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Wake up to your own voice'**
  String get appTagline;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No alarms yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first voice alarm and wake up to words that matter.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeCreateAlarm.
  ///
  /// In en, this message translates to:
  /// **'Create Alarm'**
  String get homeCreateAlarm;

  /// No description provided for @homeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homeEdit;

  /// No description provided for @homeDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get homeDuplicate;

  /// No description provided for @homeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeDelete;

  /// No description provided for @homeMore.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get homeMore;

  /// No description provided for @homeAlarmsReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No alarms} =1{1 alarm ready} other{{count} alarms ready}}'**
  String homeAlarmsReady(int count);

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @alarmTypeVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get alarmTypeVoice;

  /// No description provided for @alarmTypeRingtone.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get alarmTypeRingtone;

  /// No description provided for @alarmTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get alarmTypeMixed;

  /// No description provided for @alarmTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Alarm type'**
  String get alarmTypeLabel;

  /// No description provided for @createAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'New Alarm'**
  String get createAlarmTitle;

  /// No description provided for @editAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Alarm'**
  String get editAlarmTitle;

  /// No description provided for @alarmTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get alarmTime;

  /// No description provided for @alarmHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get alarmHour;

  /// No description provided for @alarmMinute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get alarmMinute;

  /// No description provided for @alarmRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get alarmRepeat;

  /// No description provided for @alarmVoiceSequence.
  ///
  /// In en, this message translates to:
  /// **'Voice Sequence'**
  String get alarmVoiceSequence;

  /// No description provided for @alarmRingtone.
  ///
  /// In en, this message translates to:
  /// **'Ringtone after voice'**
  String get alarmRingtone;

  /// No description provided for @alarmRepeatCount.
  ///
  /// In en, this message translates to:
  /// **'Sequence repeats'**
  String get alarmRepeatCount;

  /// No description provided for @alarmCopyFrom.
  ///
  /// In en, this message translates to:
  /// **'Copy from another alarm'**
  String get alarmCopyFrom;

  /// No description provided for @alarmSave.
  ///
  /// In en, this message translates to:
  /// **'Save Alarm'**
  String get alarmSave;

  /// No description provided for @alarmSelectSequence.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit sequence'**
  String get alarmSelectSequence;

  /// No description provided for @alarmSelectRingtone.
  ///
  /// In en, this message translates to:
  /// **'Choose a sound'**
  String get alarmSelectRingtone;

  /// No description provided for @alarmNoneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get alarmNoneSelected;

  /// No description provided for @alarmCopied.
  ///
  /// In en, this message translates to:
  /// **'Settings copied'**
  String get alarmCopied;

  /// No description provided for @alarmSaved.
  ///
  /// In en, this message translates to:
  /// **'Alarm saved'**
  String get alarmSaved;

  /// No description provided for @alarmDeleted.
  ///
  /// In en, this message translates to:
  /// **'Alarm deleted'**
  String get alarmDeleted;

  /// No description provided for @alarmDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Alarm duplicated'**
  String get alarmDuplicated;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dayEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get dayEveryDay;

  /// No description provided for @dayWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get dayWeekdays;

  /// No description provided for @dayWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get dayWeekends;

  /// No description provided for @dayOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get dayOnce;

  /// No description provided for @voiceSequenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Sequence'**
  String get voiceSequenceTitle;

  /// No description provided for @voiceSequenceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your wake-up message'**
  String get voiceSequenceEmptyTitle;

  /// No description provided for @voiceSequenceEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add recordings or spoken text in the order you want to hear them.'**
  String get voiceSequenceEmptySubtitle;

  /// No description provided for @voiceSequenceAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Voice'**
  String get voiceSequenceAdd;

  /// No description provided for @voiceSequenceDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get voiceSequenceDelete;

  /// No description provided for @voiceSequenceDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove segment?'**
  String get voiceSequenceDeleteConfirmTitle;

  /// No description provided for @voiceSequenceDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the segment from the sequence.'**
  String get voiceSequenceDeleteConfirmBody;

  /// No description provided for @voiceSequenceReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get voiceSequenceReorderHint;

  /// No description provided for @voiceSegmentName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get voiceSegmentName;

  /// No description provided for @voiceSegmentType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get voiceSegmentType;

  /// No description provided for @voiceSegmentDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get voiceSegmentDuration;

  /// No description provided for @voiceSegmentOrder.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String voiceSegmentOrder(int number);

  /// No description provided for @voiceTypeRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get voiceTypeRecording;

  /// No description provided for @voiceTypeTts.
  ///
  /// In en, this message translates to:
  /// **'Text to Speech'**
  String get voiceTypeTts;

  /// No description provided for @addVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Voice'**
  String get addVoiceTitle;

  /// No description provided for @addVoiceRecord.
  ///
  /// In en, this message translates to:
  /// **'Record Voice'**
  String get addVoiceRecord;

  /// No description provided for @addVoiceRecordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak a short message into your microphone'**
  String get addVoiceRecordSubtitle;

  /// No description provided for @addVoiceTts.
  ///
  /// In en, this message translates to:
  /// **'Text to Speech'**
  String get addVoiceTts;

  /// No description provided for @addVoiceTtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a message and choose a speaking voice'**
  String get addVoiceTtsSubtitle;

  /// No description provided for @ttsTitle.
  ///
  /// In en, this message translates to:
  /// **'Text to Speech'**
  String get ttsTitle;

  /// No description provided for @ttsInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get ttsInputLabel;

  /// No description provided for @ttsInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type the message you want to hear…'**
  String get ttsInputHint;

  /// No description provided for @ttsVoices.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoices;

  /// No description provided for @ttsPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get ttsPreview;

  /// No description provided for @ttsPreviewing.
  ///
  /// In en, this message translates to:
  /// **'Playing preview…'**
  String get ttsPreviewing;

  /// No description provided for @ttsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ttsSave;

  /// No description provided for @ttsSaved.
  ///
  /// In en, this message translates to:
  /// **'Voice segment saved'**
  String get ttsSaved;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Voice'**
  String get recordTitle;

  /// No description provided for @recordStart.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordStart;

  /// No description provided for @recordStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get recordStop;

  /// No description provided for @recordPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get recordPlay;

  /// No description provided for @recordPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing…'**
  String get recordPlaying;

  /// No description provided for @recordSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get recordSave;

  /// No description provided for @recordHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Record when you are ready'**
  String get recordHint;

  /// No description provided for @recordRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recordRecording;

  /// No description provided for @recordReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to save'**
  String get recordReady;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved'**
  String get recordSaved;

  /// No description provided for @recordDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Voice recording'**
  String get recordDefaultName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder to set alarm'**
  String get settingsReminder;

  /// No description provided for @settingsReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a gentle nudge if no alarm is scheduled'**
  String get settingsReminderSubtitle;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAboutSubtitle(String version);

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'© Smart Voice Alarm'**
  String get settingsAboutLegalese;

  /// No description provided for @settingsPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsPremium;

  /// No description provided for @settingsPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock lifetime access'**
  String get settingsPremiumSubtitle;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get premiumTitle;

  /// No description provided for @premiumHeadline.
  ///
  /// In en, this message translates to:
  /// **'One purchase. Yours forever.'**
  String get premiumHeadline;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support the app and unlock the complete voice alarm toolkit with a single lifetime purchase.'**
  String get premiumSubtitle;

  /// No description provided for @premiumBenefitUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited voice alarms'**
  String get premiumBenefitUnlimited;

  /// No description provided for @premiumBenefitSequences.
  ///
  /// In en, this message translates to:
  /// **'Longer voice sequences'**
  String get premiumBenefitSequences;

  /// No description provided for @premiumBenefitVoices.
  ///
  /// In en, this message translates to:
  /// **'More speaking voices'**
  String get premiumBenefitVoices;

  /// No description provided for @premiumBenefitThemes.
  ///
  /// In en, this message translates to:
  /// **'Extra appearance options'**
  String get premiumBenefitThemes;

  /// No description provided for @premiumBenefitSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premiumBenefitSupport;

  /// No description provided for @premiumUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock Lifetime'**
  String get premiumUnlock;

  /// No description provided for @premiumRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get premiumRestore;

  /// No description provided for @premiumThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support'**
  String get premiumThanks;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonEnabled.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonEnabled;

  /// No description provided for @commonDisabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonDisabled;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String timesLabel(int count);

  /// No description provided for @segmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No segments} =1{1 segment} other{{count} segments}}'**
  String segmentsLabel(int count);

  /// No description provided for @ringtoneSoftChime.
  ///
  /// In en, this message translates to:
  /// **'Soft Chime'**
  String get ringtoneSoftChime;

  /// No description provided for @ringtoneOceanBreeze.
  ///
  /// In en, this message translates to:
  /// **'Ocean Breeze'**
  String get ringtoneOceanBreeze;

  /// No description provided for @ringtoneNightPulse.
  ///
  /// In en, this message translates to:
  /// **'Night Pulse'**
  String get ringtoneNightPulse;

  /// No description provided for @ringtoneForestDawn.
  ///
  /// In en, this message translates to:
  /// **'Forest Dawn'**
  String get ringtoneForestDawn;

  /// No description provided for @ringtoneCrystalBell.
  ///
  /// In en, this message translates to:
  /// **'Crystal Bell'**
  String get ringtoneCrystalBell;

  /// No description provided for @alarmStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get alarmStop;

  /// No description provided for @alarmStopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop All'**
  String get alarmStopAll;

  /// No description provided for @alarmQueueWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 alarm waiting} other{{count} alarms waiting}}'**
  String alarmQueueWaiting(int count);

  /// No description provided for @settingsVoiceSpeech.
  ///
  /// In en, this message translates to:
  /// **'Voice & Speech'**
  String get settingsVoiceSpeech;

  /// No description provided for @settingsVoiceSpeechSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System voices for text to speech'**
  String get settingsVoiceSpeechSubtitle;

  /// No description provided for @voiceSpeechTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice & Speech'**
  String get voiceSpeechTitle;

  /// No description provided for @voiceSpeechSystemVoices.
  ///
  /// In en, this message translates to:
  /// **'System voices'**
  String get voiceSpeechSystemVoices;

  /// No description provided for @voiceSpeechDownloadMore.
  ///
  /// In en, this message translates to:
  /// **'Download more voices'**
  String get voiceSpeechDownloadMore;

  /// No description provided for @voiceSpeechRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh voice list'**
  String get voiceSpeechRefresh;

  /// No description provided for @voiceSpeechOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Prefer offline voices so alarms still speak without a network connection.'**
  String get voiceSpeechOfflineHint;

  /// No description provided for @voiceSpeechIosGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Install voices on iPhone'**
  String get voiceSpeechIosGuideTitle;

  /// No description provided for @voiceSpeechIosGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Accessibility → Spoken Content → Voices, download the voices you need, then return here and tap Refresh.'**
  String get voiceSpeechIosGuideBody;

  /// No description provided for @voiceSpeechAndroidGuide.
  ///
  /// In en, this message translates to:
  /// **'Opens the system TTS data installer. Smart Voice Alarm does not download or host voice packages.'**
  String get voiceSpeechAndroidGuide;

  /// No description provided for @voiceSpeechWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Browsers manage their own voices. Download packs are not available on web.'**
  String get voiceSpeechWebUnavailable;

  /// No description provided for @voiceSpeechEmpty.
  ///
  /// In en, this message translates to:
  /// **'No usable voices found yet'**
  String get voiceSpeechEmpty;

  /// No description provided for @voiceSpeechEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Download more voices'**
  String get voiceSpeechEmptyCta;

  /// No description provided for @voiceQualityDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get voiceQualityDefault;

  /// No description provided for @voiceQualityEnhanced.
  ///
  /// In en, this message translates to:
  /// **'Enhanced'**
  String get voiceQualityEnhanced;

  /// No description provided for @voiceQualityPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get voiceQualityPremium;

  /// No description provided for @voiceAvailabilityOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get voiceAvailabilityOffline;

  /// No description provided for @voiceAvailabilityNetwork.
  ///
  /// In en, this message translates to:
  /// **'Needs network'**
  String get voiceAvailabilityNetwork;

  /// No description provided for @voiceAvailabilityMissing.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get voiceAvailabilityMissing;

  /// No description provided for @ttsNoVoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'No usable voices'**
  String get ttsNoVoicesTitle;

  /// No description provided for @ttsNoVoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Download system voices, then refresh the list.'**
  String get ttsNoVoicesBody;

  /// No description provided for @ttsOpenVoiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Download more voices'**
  String get ttsOpenVoiceSettings;

  /// No description provided for @ttsVoiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Selected voice is unavailable. Using a default voice instead.'**
  String get ttsVoiceFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

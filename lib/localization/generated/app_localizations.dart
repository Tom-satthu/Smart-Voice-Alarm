import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

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
  /// **'Voices'**
  String get ttsVoices;

  /// No description provided for @ttsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get ttsLanguageLabel;

  /// No description provided for @ttsVoiceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoiceNameLabel;

  /// No description provided for @ttsVoiceQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get ttsVoiceQualityLabel;

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
  /// **'Reminder'**
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
  /// **'App info and support'**
  String get settingsAboutSubtitle;

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
  /// **'Unlock unlimited alarms'**
  String get settingsPremiumSubtitle;

  /// No description provided for @settingsVoices.
  ///
  /// In en, this message translates to:
  /// **'Voices'**
  String get settingsVoices;

  /// No description provided for @settingsVoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System voices for text to speech'**
  String get settingsVoicesSubtitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get settingsLicenses;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTerms;

  /// No description provided for @settingsLegalPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'View document'**
  String get settingsLegalPlaceholder;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Unlock Unlimited Alarms'**
  String get premiumHeadline;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free includes up to 3 alarms. Unlock unlimited alarms with one lifetime purchase. No subscriptions.'**
  String get premiumSubtitle;

  /// No description provided for @premiumPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get premiumPlanFree;

  /// No description provided for @premiumPlanLifetime.
  ///
  /// In en, this message translates to:
  /// **'Premium Lifetime'**
  String get premiumPlanLifetime;

  /// No description provided for @premiumPlanLifetimePrice.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get premiumPlanLifetimePrice;

  /// No description provided for @premiumBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything in Premium'**
  String get premiumBenefitsTitle;

  /// No description provided for @premiumBenefitUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited alarms'**
  String get premiumBenefitUnlimited;

  /// No description provided for @premiumBenefitSequences.
  ///
  /// In en, this message translates to:
  /// **'Voice sequences without feature locks'**
  String get premiumBenefitSequences;

  /// No description provided for @premiumBenefitVoices.
  ///
  /// In en, this message translates to:
  /// **'All installed system voices'**
  String get premiumBenefitVoices;

  /// No description provided for @premiumBenefitThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes, reminders, and recording stay free'**
  String get premiumBenefitThemes;

  /// No description provided for @premiumBenefitSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premiumBenefitSupport;

  /// No description provided for @premiumBenefitNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever'**
  String get premiumBenefitNoAds;

  /// No description provided for @premiumUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock Unlimited Alarms'**
  String get premiumUnlock;

  /// No description provided for @premiumRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get premiumRestore;

  /// No description provided for @premiumThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Smart Voice Alarm.'**
  String get premiumThanks;

  /// No description provided for @premiumComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Store products must be configured in App Store Connect and Google Play Console.'**
  String get premiumComingSoon;

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

  /// No description provided for @commonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageChineseSimplified;

  /// No description provided for @languageChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional)'**
  String get languageChineseTraditional;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

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

  /// No description provided for @voicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Voices'**
  String get voicesTitle;

  /// No description provided for @voicesSystemVoices.
  ///
  /// In en, this message translates to:
  /// **'System Voices'**
  String get voicesSystemVoices;

  /// No description provided for @voicesDownloadMore.
  ///
  /// In en, this message translates to:
  /// **'Download More Voices'**
  String get voicesDownloadMore;

  /// No description provided for @voicesRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Voices'**
  String get voicesRefresh;

  /// No description provided for @voicesOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Prefer offline voices so alarms still speak without a network connection.'**
  String get voicesOfflineHint;

  /// No description provided for @voicesIosGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Install voices on iPhone'**
  String get voicesIosGuideTitle;

  /// No description provided for @voicesIosGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Accessibility → Spoken Content → Voices, download the voices you need, then return here and tap Refresh Voices.'**
  String get voicesIosGuideBody;

  /// No description provided for @voicesAndroidGuide.
  ///
  /// In en, this message translates to:
  /// **'Opens the system TTS data installer. Smart Voice Alarm does not download or host voice packages.'**
  String get voicesAndroidGuide;

  /// No description provided for @voicesWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Browsers manage their own voices. Download packs are not available on web.'**
  String get voicesWebUnavailable;

  /// No description provided for @voicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No usable voices found yet'**
  String get voicesEmpty;

  /// No description provided for @voicesEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Download More Voices'**
  String get voicesEmptyCta;

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
  /// **'Download More Voices'**
  String get ttsOpenVoiceSettings;

  /// No description provided for @ttsVoiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Selected voice is unavailable. Using a default voice instead.'**
  String get ttsVoiceFallback;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set tomorrow’s alarm'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to schedule your Smart Voice Alarm for tomorrow.'**
  String get reminderNotificationBody;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get aboutAppName;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutDeveloperValue.
  ///
  /// In en, this message translates to:
  /// **'Tom Satthu'**
  String get aboutDeveloperValue;

  /// No description provided for @aboutGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get aboutGithub;

  /// No description provided for @aboutGithubValue.
  ///
  /// In en, this message translates to:
  /// **'github.com/Tom-satthu/Smart-Voice-Alarm'**
  String get aboutGithubValue;

  /// No description provided for @aboutEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get aboutEmail;

  /// No description provided for @aboutEmailValue.
  ///
  /// In en, this message translates to:
  /// **'support@smartvoicealarm.app'**
  String get aboutEmailValue;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutWebsiteValue.
  ///
  /// In en, this message translates to:
  /// **'www.smartvoicealarm.app'**
  String get aboutWebsiteValue;

  /// No description provided for @aboutWebsitePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get aboutWebsitePlaceholder;

  /// No description provided for @voiceSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get voiceSystemDefault;

  /// No description provided for @voiceSystemDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Managed in device settings'**
  String get voiceSystemDefaultHint;

  /// No description provided for @notificationChannelAlarms.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get notificationChannelAlarms;

  /// No description provided for @notificationChannelAlarmsDesc.
  ///
  /// In en, this message translates to:
  /// **'Voice alarm alerts'**
  String get notificationChannelAlarmsDesc;

  /// No description provided for @notificationChannelReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationChannelReminders;

  /// No description provided for @notificationChannelRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to set tomorrow’s alarm'**
  String get notificationChannelRemindersDesc;

  /// No description provided for @alarmDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarmDefaultLabel;

  /// No description provided for @premiumBenefitLifetimeBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy once. Yours forever.'**
  String get premiumBenefitLifetimeBuy;

  /// No description provided for @premiumStatusLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking the store…'**
  String get premiumStatusLoading;

  /// No description provided for @premiumStatusPurchasing.
  ///
  /// In en, this message translates to:
  /// **'Starting purchase…'**
  String get premiumStatusPurchasing;

  /// No description provided for @premiumStatusPurchased.
  ///
  /// In en, this message translates to:
  /// **'Premium Lifetime unlocked'**
  String get premiumStatusPurchased;

  /// No description provided for @premiumStatusRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored'**
  String get premiumStatusRestored;

  /// No description provided for @premiumStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled'**
  String get premiumStatusCancelled;

  /// No description provided for @premiumStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Purchase pending…'**
  String get premiumStatusPending;

  /// No description provided for @premiumStatusError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get premiumStatusError;

  /// No description provided for @premiumWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are not available on the web demo.'**
  String get premiumWebUnavailable;

  /// No description provided for @premiumStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store is unavailable on this device.'**
  String get premiumStoreUnavailable;

  /// No description provided for @premiumLimitExplainFree.
  ///
  /// In en, this message translates to:
  /// **'Free includes up to 3 alarms.'**
  String get premiumLimitExplainFree;

  /// No description provided for @premiumLimitExplainUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited alarms with one lifetime purchase.'**
  String get premiumLimitExplainUnlock;

  /// No description provided for @premiumFreeLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} alarms'**
  String premiumFreeLimitLabel(int count);

  /// No description provided for @voicesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages or voices'**
  String get voicesSearchHint;

  /// No description provided for @voicesLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get voicesLanguages;

  /// No description provided for @voicesSelectVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a voice for this language'**
  String get voicesSelectVoiceHint;

  /// No description provided for @voicesLanguageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 voice} other{{count} voices}}'**
  String voicesLanguageCount(int count);

  /// No description provided for @alarmSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose time'**
  String get alarmSelectTime;

  /// No description provided for @segmentPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get segmentPlay;

  /// No description provided for @voicePlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get voicePlaying;

  /// No description provided for @voiceSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get voiceSelect;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice unavailable'**
  String get voiceUnavailable;

  /// No description provided for @recordingFileMissing.
  ///
  /// In en, this message translates to:
  /// **'Recording file missing. Delete this segment or record again.'**
  String get recordingFileMissing;

  /// No description provided for @voiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Voice details'**
  String get voiceDetails;

  /// No description provided for @ttsSelectedVoice.
  ///
  /// In en, this message translates to:
  /// **'Selected voice'**
  String get ttsSelectedVoice;

  /// No description provided for @voicePreviewSample.
  ///
  /// In en, this message translates to:
  /// **'This is a short preview of this voice.'**
  String get voicePreviewSample;

  /// No description provided for @alarmDismissTitle.
  ///
  /// In en, this message translates to:
  /// **'Solve to stop'**
  String get alarmDismissTitle;

  /// No description provided for @alarmDismissHint.
  ///
  /// In en, this message translates to:
  /// **'Answer correctly to turn off the alarm.'**
  String get alarmDismissHint;

  /// No description provided for @alarmDismissWrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect. Try a new question.'**
  String get alarmDismissWrong;

  /// No description provided for @alarmDismissCheck.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get alarmDismissCheck;

  /// No description provided for @alarmDismissAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get alarmDismissAnswerHint;

  /// No description provided for @voicesRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed: {count} voices found'**
  String voicesRefreshed(int count);

  /// No description provided for @voicesSelectedSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved voice: {name}'**
  String voicesSelectedSaved(String name);

  /// No description provided for @voicesDownloadThenSelect.
  ///
  /// In en, this message translates to:
  /// **'Open your device voice manager. After downloading, return here.'**
  String get voicesDownloadThenSelect;

  /// No description provided for @voicesRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Rescan Voices reloads system TTS voices after you install new packs.'**
  String get voicesRefreshHint;

  /// No description provided for @ringtonePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get ringtonePreview;

  /// No description provided for @ringtonePreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap play to preview, then tap a name to select it.'**
  String get ringtonePreviewHint;

  /// No description provided for @voicesCurrentVoice.
  ///
  /// In en, this message translates to:
  /// **'Current voice'**
  String get voicesCurrentVoice;

  /// No description provided for @voicesNewlyInstalled.
  ///
  /// In en, this message translates to:
  /// **'Newly installed voices'**
  String get voicesNewlyInstalled;

  /// No description provided for @voicesOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Voices on this device'**
  String get voicesOnDevice;

  /// No description provided for @voicesDownloadHint.
  ///
  /// In en, this message translates to:
  /// **'Open your device voice manager. After downloading, return here.'**
  String get voicesDownloadHint;

  /// No description provided for @voicesRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan voices'**
  String get voicesRescan;

  /// No description provided for @voicesRescanResult.
  ///
  /// In en, this message translates to:
  /// **'Found {count} usable voices'**
  String voicesRescanResult(int count);

  /// No description provided for @voicesNewFound.
  ///
  /// In en, this message translates to:
  /// **'Found {count} new voices.'**
  String voicesNewFound(int count);

  /// No description provided for @voicesNoNewFound.
  ///
  /// In en, this message translates to:
  /// **'No new voices detected.'**
  String get voicesNoNewFound;

  /// No description provided for @voicesSystemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated the {language} voice from device settings.'**
  String voicesSystemUpdated(String language);

  /// No description provided for @voicesNoChange.
  ///
  /// In en, this message translates to:
  /// **'Device voice settings were refreshed.'**
  String get voicesNoChange;

  /// No description provided for @voicesSettingsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Device voice settings were refreshed.'**
  String get voicesSettingsRefreshed;

  /// No description provided for @voicesSystemChanges.
  ///
  /// In en, this message translates to:
  /// **'Device voice updates'**
  String get voicesSystemChanges;

  /// No description provided for @voicesSystemChangeEvent.
  ///
  /// In en, this message translates to:
  /// **'Device {language} voice settings were updated.'**
  String voicesSystemChangeEvent(String language);

  /// No description provided for @voicesNewlyInstalledEmpty.
  ///
  /// In en, this message translates to:
  /// **'New voices and device voice updates will appear here after you install or change them.'**
  String get voicesNewlyInstalledEmpty;

  /// No description provided for @voicesNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get voicesNewBadge;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @voiceFriendlyName.
  ///
  /// In en, this message translates to:
  /// **'Voice {number}'**
  String voiceFriendlyName(String number);

  /// No description provided for @voicesOpenManagerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the device voice manager. Open system Text-to-speech settings and install voices there.'**
  String get voicesOpenManagerFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pt',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

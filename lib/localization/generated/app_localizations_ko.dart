// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => '내 목소리로 일어나세요';

  @override
  String get homeTitle => '알람';

  @override
  String get homeEmptyTitle => '아직 알람이 없습니다';

  @override
  String get homeEmptySubtitle => '첫 음성 알람을 만들고 의미 있는 말로 일어나세요.';

  @override
  String get homeCreateAlarm => '알람 만들기';

  @override
  String get homeEdit => '편집';

  @override
  String get homeDuplicate => '복제';

  @override
  String get homeDelete => '삭제';

  @override
  String get homeMore => '더보기';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '알람 $count개 준비됨',
      one: '알람 1개 준비됨',
      zero: '알람 없음',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => '좋은 아침입니다';

  @override
  String get homeGoodAfternoon => '좋은 오후입니다';

  @override
  String get homeGoodEvening => '좋은 저녁입니다';

  @override
  String get alarmTypeVoice => '음성';

  @override
  String get alarmTypeRingtone => '벨소리';

  @override
  String get alarmTypeMixed => '혼합';

  @override
  String get alarmTypeLabel => '알람 유형';

  @override
  String get createAlarmTitle => '새 알람';

  @override
  String get editAlarmTitle => '알람 편집';

  @override
  String get alarmTime => '시간';

  @override
  String get alarmHour => '시';

  @override
  String get alarmMinute => '분';

  @override
  String get alarmRepeat => '반복';

  @override
  String get alarmVoiceSequence => '음성 시퀀스';

  @override
  String get alarmRingtone => '음성 후 벨소리';

  @override
  String get alarmRepeatCount => '시퀀스 반복';

  @override
  String get alarmCopyFrom => '다른 알람에서 복사';

  @override
  String get alarmSave => '알람 저장';

  @override
  String get alarmSelectSequence => '탭하여 시퀀스 편집';

  @override
  String get alarmSelectRingtone => '소리 선택';

  @override
  String get alarmNoneSelected => '선택 없음';

  @override
  String get alarmCopied => '설정을 복사했습니다';

  @override
  String get alarmSaved => '알람을 저장했습니다';

  @override
  String get alarmDeleted => '알람을 삭제했습니다';

  @override
  String get alarmDuplicated => '알람을 복제했습니다';

  @override
  String get dayMon => '월';

  @override
  String get dayTue => '화';

  @override
  String get dayWed => '수';

  @override
  String get dayThu => '목';

  @override
  String get dayFri => '금';

  @override
  String get daySat => '토';

  @override
  String get daySun => '일';

  @override
  String get dayEveryDay => '매일';

  @override
  String get dayWeekdays => '평일';

  @override
  String get dayWeekends => '주말';

  @override
  String get dayOnce => '한 번';

  @override
  String get voiceSequenceTitle => '음성 시퀀스';

  @override
  String get voiceSequenceEmptyTitle => '기상 메시지 만들기';

  @override
  String get voiceSequenceEmptySubtitle => '듣고 싶은 순서대로 녹음이나 음성 변환 텍스트를 추가하세요.';

  @override
  String get voiceSequenceAdd => '음성 추가';

  @override
  String get voiceSequenceDelete => '삭제';

  @override
  String get voiceSequenceDeleteConfirmTitle => '세그먼트를 제거할까요?';

  @override
  String get voiceSequenceDeleteConfirmBody => '시퀀스에서 이 세그먼트가 제거됩니다.';

  @override
  String get voiceSequenceReorderHint => '드래그하여 순서 변경';

  @override
  String get voiceSegmentName => '이름';

  @override
  String get voiceSegmentType => '유형';

  @override
  String get voiceSegmentDuration => '길이';

  @override
  String voiceSegmentOrder(int number) {
    return '단계 $number';
  }

  @override
  String get voiceTypeRecording => '녹음';

  @override
  String get voiceTypeTts => '텍스트 음성 변환';

  @override
  String get addVoiceTitle => '음성 추가';

  @override
  String get addVoiceRecord => '음성 녹음';

  @override
  String get addVoiceRecordSubtitle => '마이크에 짧은 메시지를 말하세요';

  @override
  String get addVoiceTts => '텍스트 음성 변환';

  @override
  String get addVoiceTtsSubtitle => '메시지를 입력하고 말하기 음성을 선택하세요';

  @override
  String get ttsTitle => '텍스트 음성 변환';

  @override
  String get ttsInputLabel => '메시지';

  @override
  String get ttsInputHint => '듣고 싶은 메시지를 입력하세요…';

  @override
  String get ttsVoices => '음성';

  @override
  String get ttsLanguageLabel => '언어';

  @override
  String get ttsVoiceNameLabel => '음성';

  @override
  String get ttsVoiceQualityLabel => '품질';

  @override
  String get ttsPreview => '미리듣기';

  @override
  String get ttsPreviewing => '미리듣기 재생 중…';

  @override
  String get ttsSave => '저장';

  @override
  String get ttsSaved => '음성 세그먼트를 저장했습니다';

  @override
  String get recordTitle => '음성 녹음';

  @override
  String get recordStart => '녹음';

  @override
  String get recordStop => '중지';

  @override
  String get recordPlay => '재생';

  @override
  String get recordPlaying => '재생 중…';

  @override
  String get recordSave => '저장';

  @override
  String get recordHint => '준비가 되면 녹음을 탭하세요';

  @override
  String get recordRecording => '녹음 중…';

  @override
  String get recordReady => '저장할 준비 완료';

  @override
  String get recordSaved => '녹음을 저장했습니다';

  @override
  String get recordDefaultName => '음성 녹음';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAppearance => '모양';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsThemeSystem => '시스템';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsReminder => '알림';

  @override
  String get settingsReminderSubtitle => '예약된 알람이 없으면 부드럽게 알려드립니다';

  @override
  String get settingsReminderTime => '알림 시간';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsAboutSubtitle => '앱 정보 및 지원';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => '프리미엄';

  @override
  String get settingsPremiumSubtitle => '무제한 알람 잠금 해제';

  @override
  String get settingsVoices => '음성';

  @override
  String get settingsVoicesSubtitle => '텍스트 음성 변환용 시스템 음성';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsLicenses => '오픈 소스 라이선스';

  @override
  String get settingsPrivacy => '개인정보 처리방침';

  @override
  String get settingsTerms => '이용약관';

  @override
  String get settingsLegalPlaceholder => '문서 보기';

  @override
  String get premiumTitle => '프리미엄';

  @override
  String get premiumHeadline => '무제한 알람 잠금 해제';

  @override
  String get premiumSubtitle =>
      '무료 버전은 알람 최대 3개입니다. 평생 구매 한 번으로 무제한 알람을 잠금 해제하세요. 구독 없음.';

  @override
  String get premiumPlanFree => '무료';

  @override
  String get premiumPlanLifetime => '프리미엄 평생';

  @override
  String get premiumPlanLifetimePrice => '일회성 구매';

  @override
  String get premiumBenefitsTitle => '프리미엄의 모든 것';

  @override
  String get premiumBenefitUnlimited => '무제한 알람';

  @override
  String get premiumBenefitSequences => '기능 잠금 없는 음성 시퀀스';

  @override
  String get premiumBenefitVoices => '설치된 모든 시스템 음성';

  @override
  String get premiumBenefitThemes => '테마, 알림, 녹음은 계속 무료';

  @override
  String get premiumBenefitSupport => '우선 지원';

  @override
  String get premiumBenefitNoAds => '광고 없음';

  @override
  String get premiumUnlock => '무제한 알람 잠금 해제';

  @override
  String get premiumRestore => '구매 복원';

  @override
  String get premiumThanks => 'Smart Voice Alarm을 지원해 주셔서 감사합니다.';

  @override
  String get premiumComingSoon =>
      '상품은 App Store Connect와 Google Play Console에서 설정해야 합니다.';

  @override
  String get commonCancel => '취소';

  @override
  String get commonDone => '완료';

  @override
  String get commonBack => '뒤로';

  @override
  String get commonNext => '다음';

  @override
  String get commonClose => '닫기';

  @override
  String get commonEnabled => '켜짐';

  @override
  String get commonDisabled => '꺼짐';

  @override
  String get commonRemove => '제거';

  @override
  String get commonOpen => '열기';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languagePortuguese => '포르투갈어';

  @override
  String get languageFrench => '프랑스어';

  @override
  String get languageGerman => '독일어';

  @override
  String get languageItalian => '이탈리아어';

  @override
  String get languageDutch => '네덜란드어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChineseSimplified => '중국어(간체)';

  @override
  String get languageChineseTraditional => '중국어(번체)';

  @override
  String get languageIndonesian => '인도네시아어';

  @override
  String get languageVietnamese => '베트남어';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count회',
      one: '1회',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '세그먼트 $count개',
      one: '세그먼트 1개',
      zero: '세그먼트 없음',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => '부드러운 차임';

  @override
  String get ringtoneOceanBreeze => '오션 브리즈';

  @override
  String get ringtoneNightPulse => '나이트 펄스';

  @override
  String get ringtoneForestDawn => '포레스트 던';

  @override
  String get ringtoneCrystalBell => '크리스탈 벨';

  @override
  String get alarmStop => '중지';

  @override
  String get alarmStopAll => '모두 중지';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '대기 중인 알람 $count개',
      one: '대기 중인 알람 1개',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => '음성';

  @override
  String get voicesSystemVoices => '시스템 음성';

  @override
  String get voicesDownloadMore => '더 많은 음성 다운로드';

  @override
  String get voicesRefresh => '음성 새로고침';

  @override
  String get voicesOfflineHint => '네트워크 없이도 알람이 말할 수 있도록 오프라인 음성을 권장합니다.';

  @override
  String get voicesIosGuideTitle => 'iPhone에 음성 설치';

  @override
  String get voicesIosGuideBody =>
      '설정 → 손쉬운 사용 → 음성 콘텐츠 → 음성을 열고 필요한 음성을 다운로드한 다음, 여기로 돌아와 음성 새로고침을 탭하세요.';

  @override
  String get voicesAndroidGuide =>
      '시스템 TTS 데이터 설치 프로그램을 엽니다. Smart Voice Alarm은 음성 패키지를 다운로드하거나 호스팅하지 않습니다.';

  @override
  String get voicesWebUnavailable =>
      '브라우저는 자체 음성을 관리합니다. 웹에서는 다운로드 팩을 사용할 수 없습니다.';

  @override
  String get voicesEmpty => '아직 사용 가능한 음성을 찾지 못했습니다';

  @override
  String get voicesEmptyCta => '더 많은 음성 다운로드';

  @override
  String get voiceQualityDefault => '기본';

  @override
  String get voiceQualityEnhanced => '향상됨';

  @override
  String get voiceQualityPremium => '프리미엄';

  @override
  String get voiceAvailabilityOffline => '오프라인';

  @override
  String get voiceAvailabilityNetwork => '네트워크 필요';

  @override
  String get voiceAvailabilityMissing => '설치되지 않음';

  @override
  String get ttsNoVoicesTitle => '사용 가능한 음성 없음';

  @override
  String get ttsNoVoicesBody => '시스템 음성을 다운로드한 다음 목록을 새로고침하세요.';

  @override
  String get ttsOpenVoiceSettings => '더 많은 음성 다운로드';

  @override
  String get ttsVoiceFallback => '선택한 음성을 사용할 수 없습니다. 기본 음성을 사용합니다.';

  @override
  String get reminderNotificationTitle => '내일 알람 설정';

  @override
  String get reminderNotificationBody =>
      '잠시 시간을 내어 내일의 Smart Voice Alarm을 예약하세요.';

  @override
  String get aboutTitle => '정보';

  @override
  String get aboutAppName => '앱 이름';

  @override
  String get aboutVersion => '버전';

  @override
  String get aboutDeveloper => '개발자';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'GitHub 저장소';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => '이메일 지원';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => '웹사이트';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => '곧 제공';

  @override
  String get voiceSystemDefault => '시스템 기본';

  @override
  String get voiceSystemDefaultHint => '기기 설정에서 관리됩니다';

  @override
  String get notificationChannelAlarms => '알람';

  @override
  String get notificationChannelAlarmsDesc => '음성 알람 알림';

  @override
  String get notificationChannelReminders => '알림';

  @override
  String get notificationChannelRemindersDesc => '내일 알람을 설정하라는 매일 알림';

  @override
  String get alarmDefaultLabel => '알람';

  @override
  String get premiumBenefitLifetimeBuy => '한 번 구매. 영원히 당신 것.';

  @override
  String get premiumStatusLoading => '스토어 확인 중…';

  @override
  String get premiumStatusPurchasing => '구매 시작 중…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime 잠금 해제됨';

  @override
  String get premiumStatusRestored => '구매가 복원됨';

  @override
  String get premiumStatusCancelled => '구매가 취소됨';

  @override
  String get premiumStatusPending => '구매 대기 중…';

  @override
  String get premiumStatusError => '구매에 실패했습니다. 다시 시도하세요.';

  @override
  String get premiumWebUnavailable => '웹 데모에서는 인앱 결제를 사용할 수 없습니다.';

  @override
  String get premiumStoreUnavailable => '이 기기에서는 스토어를 사용할 수 없습니다.';

  @override
  String get premiumLimitExplainFree => '무료 버전은 알람 최대 3개입니다.';

  @override
  String get premiumLimitExplainUnlock => '평생 구매 한 번으로 무제한 알람을 잠금 해제하세요.';

  @override
  String premiumFreeLimitLabel(int count) {
    return '알람 최대 $count개';
  }

  @override
  String get voicesSearchHint => '언어 또는 음성 검색';

  @override
  String get voicesLanguages => '언어';

  @override
  String get voicesSelectVoiceHint => '이 언어의 음성을 선택하세요';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '음성 $count개',
      one: '음성 1개',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => '탭하여 시간 선택';

  @override
  String get segmentPlay => '재생';

  @override
  String get voicePlaying => '재생 중';

  @override
  String get voiceSelect => '선택';

  @override
  String get voiceUnavailable => '음성을 사용할 수 없음';

  @override
  String get recordingFileMissing => '녹음 파일이 없습니다. 이 세그먼트를 삭제하거나 다시 녹음하세요.';

  @override
  String get voiceDetails => '음성 세부정보';

  @override
  String get ttsSelectedVoice => '선택한 음성';

  @override
  String get voicePreviewSample => '이 음성의 짧은 미리듣기입니다.';

  @override
  String get alarmDismissTitle => '풀어서 중지';

  @override
  String get alarmDismissHint => '정답을 맞혀야 알람이 꺼집니다.';

  @override
  String get alarmDismissWrong => '틀렸습니다. 새 문제입니다.';

  @override
  String get alarmDismissCheck => '확인';

  @override
  String get alarmDismissAnswerHint => '답';

  @override
  String voicesRefreshed(int count) {
    return '새로고침됨: 음성 $count개 발견';
  }

  @override
  String voicesSelectedSaved(String name) {
    return '저장된 음성: $name';
  }

  @override
  String get voicesDownloadThenSelect => '기기 음성 관리를 엽니다. 다운로드 후 여기로 돌아오세요.';

  @override
  String get voicesRefreshHint => '음성 새로고침은 팩 설치 후 시스템 TTS 음성을 다시 불러옵니다.';

  @override
  String get ringtonePreview => '미리듣기';

  @override
  String get ringtonePreviewHint => '재생으로 들어보고 이름을 눌러 선택하세요.';

  @override
  String get voicesCurrentVoice => '사용 중인 음성';

  @override
  String get voicesNewlyInstalled => '새로 설치된 음성';

  @override
  String get voicesOnDevice => '이 기기의 음성';

  @override
  String get voicesDownloadHint => '기기 음성 관리를 엽니다. 다운로드 후 여기로 돌아오세요.';

  @override
  String get voicesRescan => '음성 다시 검색';

  @override
  String voicesRescanResult(int count) {
    return '사용 가능한 음성 $count개 발견';
  }

  @override
  String voicesNewFound(int count) {
    return '새 음성 $count개를 찾았습니다.';
  }

  @override
  String get voicesNoNewFound => '새 음성이 감지되지 않았습니다.';

  @override
  String voicesSystemUpdated(String language) {
    return '기기 설정에서 $language 음성을 업데이트했습니다.';
  }

  @override
  String get voicesNoChange => '음성 변경이 감지되지 않았습니다.';

  @override
  String get voicesSettingsRefreshed => '기기 음성 설정을 새로고침했습니다.';

  @override
  String get voicesSystemChanges => '기기 음성 업데이트';

  @override
  String voicesSystemChangeEvent(String language) {
    return '기기의 $language 음성 설정이 업데이트되었습니다.';
  }

  @override
  String get voicesNewlyInstalledEmpty => '새 음성과 기기 업데이트는 여기에 표시됩니다.';

  @override
  String get voicesNewBadge => '신규';

  @override
  String get commonClear => '지우기';

  @override
  String voiceFriendlyName(String number) {
    return '음성 $number';
  }

  @override
  String get voicesOpenManagerFailed => '음성 관리를 열 수 없습니다. 시스템 TTS 설정을 여세요.';

  @override
  String get currentVoice => '현재 음성';

  @override
  String get scanDeviceVoices => '기기 음성 스캔';

  @override
  String get availableDeviceVoices => '기기에 있는 음성';

  @override
  String get scanVoicesHint => '기기 음성 스캔을 눌러 설치된 음성을 확인하세요.';

  @override
  String get noDeviceVoicesFound => '기기에서 적합한 음성을 찾지 못했습니다.';

  @override
  String get scanVoicesFailed => '음성을 스캔할 수 없습니다. 다시 시도하세요.';

  @override
  String get voiceSetupGuide => '음성 추가 방법';

  @override
  String get openVoiceSettings => '음성 설정 열기';

  @override
  String get androidVoiceSetupSteps =>
      '1. 기기 설정을 엽니다.\n2. 텍스트 음성 변환 또는 Text-to-speech를 검색합니다.\n3. 사용 중인 TTS 엔진을 엽니다.\n4. 언어 또는 음성 데이터 화면을 엽니다.\n5. 새 음성을 설치합니다.\n6. 앱으로 돌아와 기기 음성 스캔을 누릅니다.';

  @override
  String get iosVoiceSetupSteps =>
      '1. 설정을 엽니다.\n2. 손쉬운 사용을 엽니다.\n3. 읽어주기 또는 음성을 엽니다.\n4. 언어를 선택하고 음성을 다운로드합니다.\n5. 앱으로 돌아와 다시 스캔합니다.\niOS 버전에 따라 메뉴 이름이 다를 수 있습니다.';

  @override
  String get webVoiceAvailabilityInfo => '웹에서는 브라우저와 운영체제가 제공하는 음성을 사용합니다.';

  @override
  String lastScanned(String time) {
    return '마지막 스캔: $time';
  }

  @override
  String get voiceInUse => '사용 중';

  @override
  String get otherLanguages => '기타 언어';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '음성 $count개',
      one: '음성 1개',
      zero: '음성 없음',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => '언어 음성 펼치기';

  @override
  String get collapseLanguageVoices => '언어 음성 접기';

  @override
  String voicePreviewNamed(String name) {
    return '$name 미리듣기';
  }
}

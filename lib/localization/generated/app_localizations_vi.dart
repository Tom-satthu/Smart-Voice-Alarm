// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Thức dậy với chính giọng nói của bạn';

  @override
  String get homeTitle => 'Báo thức';

  @override
  String get homeEmptyTitle => 'Chưa có báo thức';

  @override
  String get homeEmptySubtitle =>
      'Tạo báo thức giọng nói đầu tiên và thức dậy với những lời thật sự ý nghĩa.';

  @override
  String get homeCreateAlarm => 'Tạo báo thức';

  @override
  String get homeEdit => 'Chỉnh sửa';

  @override
  String get homeDuplicate => 'Nhân bản';

  @override
  String get homeDelete => 'Xóa';

  @override
  String get homeMore => 'Tùy chọn khác';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count báo thức sẵn sàng',
      one: '1 báo thức sẵn sàng',
      zero: 'Không có báo thức',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Chào buổi sáng';

  @override
  String get homeGoodAfternoon => 'Chào buổi chiều';

  @override
  String get homeGoodEvening => 'Chào buổi tối';

  @override
  String get alarmTypeVoice => 'Giọng nói';

  @override
  String get alarmTypeRingtone => 'Nhạc chuông';

  @override
  String get alarmTypeMixed => 'Kết hợp';

  @override
  String get alarmTypeLabel => 'Loại báo thức';

  @override
  String get createAlarmTitle => 'Báo thức mới';

  @override
  String get editAlarmTitle => 'Chỉnh sửa báo thức';

  @override
  String get alarmTime => 'Thời gian';

  @override
  String get alarmHour => 'Giờ';

  @override
  String get alarmMinute => 'Phút';

  @override
  String get alarmRepeat => 'Lặp lại';

  @override
  String get alarmVoiceSequence => 'Chuỗi giọng nói';

  @override
  String get alarmRingtone => 'Nhạc chuông sau giọng nói';

  @override
  String get alarmRepeatCount => 'Số lần lặp chuỗi';

  @override
  String get alarmCopyFrom => 'Sao chép từ báo thức khác';

  @override
  String get alarmSave => 'Lưu báo thức';

  @override
  String get alarmSelectSequence => 'Chạm để chỉnh sửa chuỗi';

  @override
  String get alarmSelectRingtone => 'Chọn âm thanh';

  @override
  String get alarmNoneSelected => 'Chưa chọn';

  @override
  String get alarmCopied => 'Đã sao chép cài đặt';

  @override
  String get alarmSaved => 'Đã lưu báo thức';

  @override
  String get alarmDeleted => 'Đã xóa báo thức';

  @override
  String get alarmDuplicated => 'Đã nhân bản báo thức';

  @override
  String get dayMon => 'T2';

  @override
  String get dayTue => 'T3';

  @override
  String get dayWed => 'T4';

  @override
  String get dayThu => 'T5';

  @override
  String get dayFri => 'T6';

  @override
  String get daySat => 'T7';

  @override
  String get daySun => 'CN';

  @override
  String get dayEveryDay => 'Mỗi ngày';

  @override
  String get dayWeekdays => 'Ngày trong tuần';

  @override
  String get dayWeekends => 'Cuối tuần';

  @override
  String get dayOnce => 'Một lần';

  @override
  String get voiceSequenceTitle => 'Chuỗi giọng nói';

  @override
  String get voiceSequenceEmptyTitle => 'Tạo thông điệp đánh thức';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Thêm bản ghi hoặc văn bản đọc theo thứ tự bạn muốn nghe.';

  @override
  String get voiceSequenceAdd => 'Thêm giọng nói';

  @override
  String get voiceSequenceDelete => 'Xóa';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Xóa đoạn?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Thao tác này sẽ xóa đoạn khỏi chuỗi.';

  @override
  String get voiceSequenceReorderHint => 'Kéo để sắp xếp lại';

  @override
  String get voiceSegmentName => 'Tên';

  @override
  String get voiceSegmentType => 'Loại';

  @override
  String get voiceSegmentDuration => 'Thời lượng';

  @override
  String voiceSegmentOrder(int number) {
    return 'Bước $number';
  }

  @override
  String get voiceTypeRecording => 'Bản ghi';

  @override
  String get voiceTypeTts => 'Chuyển văn bản thành giọng nói';

  @override
  String get addVoiceTitle => 'Thêm giọng nói';

  @override
  String get addVoiceRecord => 'Ghi giọng nói';

  @override
  String get addVoiceRecordSubtitle => 'Nói một thông điệp ngắn vào micro';

  @override
  String get addVoiceTts => 'Chuyển văn bản thành giọng nói';

  @override
  String get addVoiceTtsSubtitle => 'Nhập thông điệp và chọn giọng đọc';

  @override
  String get ttsTitle => 'Chuyển văn bản thành giọng nói';

  @override
  String get ttsInputLabel => 'Thông điệp';

  @override
  String get ttsInputHint => 'Nhập thông điệp bạn muốn nghe…';

  @override
  String get ttsVoices => 'Giọng nói';

  @override
  String get ttsLanguageLabel => 'Ngôn ngữ';

  @override
  String get ttsVoiceNameLabel => 'Giọng';

  @override
  String get ttsVoiceQualityLabel => 'Chất lượng';

  @override
  String get ttsPreview => 'Xem trước';

  @override
  String get ttsPreviewing => 'Đang phát xem trước…';

  @override
  String get ttsSave => 'Lưu';

  @override
  String get ttsSaved => 'Đã lưu đoạn giọng nói';

  @override
  String get recordTitle => 'Ghi giọng nói';

  @override
  String get recordStart => 'Ghi';

  @override
  String get recordStop => 'Dừng';

  @override
  String get recordPlay => 'Phát';

  @override
  String get recordPlaying => 'Đang phát…';

  @override
  String get recordSave => 'Lưu';

  @override
  String get recordHint => 'Chạm Ghi khi bạn sẵn sàng';

  @override
  String get recordRecording => 'Đang ghi…';

  @override
  String get recordReady => 'Sẵn sàng lưu';

  @override
  String get recordSaved => 'Đã lưu bản ghi';

  @override
  String get recordDefaultName => 'Bản ghi giọng nói';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsTheme => 'Chủ đề';

  @override
  String get settingsThemeSystem => 'Hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsReminder => 'Nhắc nhở';

  @override
  String get settingsReminderSubtitle =>
      'Nhận lời nhắc nhẹ nếu chưa có báo thức nào được lên lịch';

  @override
  String get settingsReminderTime => 'Thời gian nhắc nhở';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get settingsAboutSubtitle => 'Thông tin ứng dụng và hỗ trợ';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Mở khóa báo thức không giới hạn';

  @override
  String get settingsVoices => 'Giọng nói';

  @override
  String get settingsVoicesSubtitle =>
      'Giọng hệ thống cho chuyển văn bản thành giọng nói';

  @override
  String get settingsVersion => 'Phiên bản';

  @override
  String get settingsLicenses => 'Giấy phép mã nguồn mở';

  @override
  String get settingsPrivacy => 'Chính sách quyền riêng tư';

  @override
  String get settingsTerms => 'Điều khoản sử dụng';

  @override
  String get settingsLegalPlaceholder => 'Xem tài liệu';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Mở khóa báo thức không giới hạn';

  @override
  String get premiumSubtitle =>
      'Bản Free gồm tối đa 3 báo thức. Mở khóa báo thức không giới hạn với một lần mua trọn đời. Không có subscription.';

  @override
  String get premiumPlanFree => 'Miễn phí';

  @override
  String get premiumPlanLifetime => 'Premium trọn đời';

  @override
  String get premiumPlanLifetimePrice => 'Mua một lần';

  @override
  String get premiumBenefitsTitle => 'Tất cả trong Premium';

  @override
  String get premiumBenefitUnlimited => 'Báo thức không giới hạn';

  @override
  String get premiumBenefitSequences => 'Chuỗi giọng nói không khóa tính năng';

  @override
  String get premiumBenefitVoices => 'Toàn bộ giọng hệ thống đã cài';

  @override
  String get premiumBenefitThemes => 'Theme, reminder và ghi âm vẫn miễn phí';

  @override
  String get premiumBenefitSupport => 'Hỗ trợ ưu tiên';

  @override
  String get premiumBenefitNoAds => 'Không quảng cáo';

  @override
  String get premiumUnlock => 'Mở khóa báo thức không giới hạn';

  @override
  String get premiumRestore => 'Khôi phục mua hàng';

  @override
  String get premiumThanks => 'Cảm ơn bạn đã hỗ trợ Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Sản phẩm cần được cấu hình trên App Store Connect và Google Play Console.';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonEnabled => 'Bật';

  @override
  String get commonDisabled => 'Tắt';

  @override
  String get commonRemove => 'Gỡ';

  @override
  String get commonOpen => 'Mở';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get languageSpanish => 'Tiếng Tây Ban Nha';

  @override
  String get languagePortuguese => 'Tiếng Bồ Đào Nha';

  @override
  String get languageFrench => 'Tiếng Pháp';

  @override
  String get languageGerman => 'Tiếng Đức';

  @override
  String get languageItalian => 'Tiếng Ý';

  @override
  String get languageDutch => 'Tiếng Hà Lan';

  @override
  String get languageJapanese => 'Tiếng Nhật';

  @override
  String get languageKorean => 'Tiếng Hàn';

  @override
  String get languageChineseSimplified => 'Tiếng Trung (Giản thể)';

  @override
  String get languageChineseTraditional => 'Tiếng Trung (Phồn thể)';

  @override
  String get languageIndonesian => 'Tiếng Indonesia';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lần',
      one: '1 lần',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đoạn',
      one: '1 đoạn',
      zero: 'Không có đoạn',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Chuông nhẹ';

  @override
  String get ringtoneOceanBreeze => 'Gió biển';

  @override
  String get ringtoneNightPulse => 'Nhịp đêm';

  @override
  String get ringtoneForestDawn => 'Bình minh rừng';

  @override
  String get ringtoneCrystalBell => 'Chuông pha lê';

  @override
  String get alarmStop => 'Dừng';

  @override
  String get alarmStopAll => 'Dừng tất cả';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count báo thức đang chờ',
      one: '1 báo thức đang chờ',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Giọng nói';

  @override
  String get voicesSystemVoices => 'Giọng hệ thống';

  @override
  String get voicesDownloadMore => 'Tải thêm giọng nói';

  @override
  String get voicesRefresh => 'Làm mới giọng nói';

  @override
  String get voicesOfflineHint =>
      'Nên dùng giọng ngoại tuyến để báo thức vẫn nói được khi không có mạng.';

  @override
  String get voicesIosGuideTitle => 'Cài giọng nói trên iPhone';

  @override
  String get voicesIosGuideBody =>
      'Mở Cài đặt → Trợ năng → Nội dung nói → Giọng nói, tải các giọng bạn cần, rồi quay lại đây và chạm Làm mới giọng nói.';

  @override
  String get voicesAndroidGuide =>
      'Mở trình cài dữ liệu TTS của hệ thống. Smart Voice Alarm không tải xuống hay lưu trữ gói giọng nói.';

  @override
  String get voicesWebUnavailable =>
      'Trình duyệt tự quản lý giọng nói của chúng. Gói tải xuống không khả dụng trên web.';

  @override
  String get voicesEmpty => 'Chưa tìm thấy giọng nói nào dùng được';

  @override
  String get voicesEmptyCta => 'Tải thêm giọng nói';

  @override
  String get voiceQualityDefault => 'Mặc định';

  @override
  String get voiceQualityEnhanced => 'Nâng cao';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Ngoại tuyến';

  @override
  String get voiceAvailabilityNetwork => 'Cần mạng';

  @override
  String get voiceAvailabilityMissing => 'Chưa cài đặt';

  @override
  String get ttsNoVoicesTitle => 'Không có giọng nói dùng được';

  @override
  String get ttsNoVoicesBody => 'Tải giọng hệ thống, rồi làm mới danh sách.';

  @override
  String get ttsOpenVoiceSettings => 'Tải thêm giọng nói';

  @override
  String get ttsVoiceFallback =>
      'Giọng đã chọn không khả dụng. Đang dùng giọng mặc định thay thế.';

  @override
  String get reminderNotificationTitle => 'Đặt báo thức cho ngày mai';

  @override
  String get reminderNotificationBody =>
      'Dành một chút thời gian để lên lịch Smart Voice Alarm cho ngày mai.';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String get aboutAppName => 'Tên ứng dụng';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutDeveloper => 'Nhà phát triển';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'Kho GitHub';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => 'Hỗ trợ qua email';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => 'Trang web';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => 'Sắp ra mắt';

  @override
  String get voiceSystemDefault => 'Mặc định hệ thống';

  @override
  String get notificationChannelAlarms => 'Báo thức';

  @override
  String get notificationChannelAlarmsDesc => 'Thông báo báo thức giọng nói';

  @override
  String get notificationChannelReminders => 'Nhắc nhở';

  @override
  String get notificationChannelRemindersDesc =>
      'Nhắc nhở hàng ngày để đặt báo thức ngày mai';

  @override
  String get alarmDefaultLabel => 'Báo thức';

  @override
  String get premiumBenefitLifetimeBuy => 'Mua một lần. Sở hữu mãi mãi.';

  @override
  String get premiumStatusLoading => 'Đang kiểm tra cửa hàng…';

  @override
  String get premiumStatusPurchasing => 'Đang bắt đầu mua…';

  @override
  String get premiumStatusPurchased => 'Đã mở Premium Lifetime';

  @override
  String get premiumStatusRestored => 'Đã khôi phục mua hàng';

  @override
  String get premiumStatusCancelled => 'Đã hủy mua hàng';

  @override
  String get premiumStatusPending => 'Đang chờ mua hàng…';

  @override
  String get premiumStatusError => 'Mua hàng thất bại. Vui lòng thử lại.';

  @override
  String get premiumWebUnavailable =>
      'Mua trong ứng dụng không khả dụng trên bản demo web.';

  @override
  String get premiumStoreUnavailable =>
      'Cửa hàng không khả dụng trên thiết bị này.';

  @override
  String get premiumLimitExplainFree => 'Bản Free gồm tối đa 3 báo thức.';

  @override
  String get premiumLimitExplainUnlock =>
      'Mở khóa báo thức không giới hạn với một lần mua trọn đời.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Tối đa $count báo thức';
  }

  @override
  String get voicesSearchHint => 'Tìm ngôn ngữ hoặc giọng nói';

  @override
  String get voicesLanguages => 'Ngôn ngữ';

  @override
  String get voicesSelectVoiceHint => 'Chọn một giọng cho ngôn ngữ này';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giọng',
      one: '1 giọng',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Chạm để chọn giờ';

  @override
  String get segmentPlay => 'Phát';

  @override
  String get voicePlaying => 'Đang phát';

  @override
  String get voiceSelect => 'Chọn';

  @override
  String get voiceUnavailable => 'Giọng không khả dụng';

  @override
  String get recordingFileMissing =>
      'Thiếu tệp ghi âm. Xóa đoạn này hoặc ghi lại.';

  @override
  String get voiceDetails => 'Chi tiết giọng';

  @override
  String get ttsSelectedVoice => 'Giọng đã chọn';

  @override
  String get voicePreviewSample => 'Đây là bản xem trước ngắn của giọng này.';

  @override
  String get alarmDismissTitle => 'Giải toán để tắt';

  @override
  String get alarmDismissHint => 'Trả lời đúng để tắt báo thức.';

  @override
  String get alarmDismissWrong => 'Sai rồi. Thử câu mới.';

  @override
  String get alarmDismissCheck => 'Kiểm tra';

  @override
  String get alarmDismissAnswerHint => 'Câu trả lời';

  @override
  String voicesRefreshed(int count) {
    return 'Đã làm mới: tìm thấy $count giọng';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Đã lưu giọng: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Cài gói giọng, quay lại, bấm Làm mới giọng nói, rồi mở ngôn ngữ và bấm Chọn.';

  @override
  String get voicesRefreshHint =>
      'Làm mới giọng nói tải lại danh sách TTS hệ thống sau khi cài gói mới.';

  @override
  String get ringtonePreview => 'Nghe thử';

  @override
  String get ringtonePreviewHint =>
      'Bấm phát để nghe thử, rồi chạm tên để chọn.';
}

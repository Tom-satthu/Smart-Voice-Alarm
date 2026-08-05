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
  String get recordPermissionTitle => 'Quyền microphone';

  @override
  String get recordPermissionRationale =>
      'Ứng dụng cần quyền microphone để ghi đoạn âm thanh bạn dùng làm báo thức.';

  @override
  String get recordPermissionDenied =>
      'Quyền microphone chưa được cấp. Ứng dụng chưa bắt đầu ghi. Bạn có thể thử lại khi sẵn sàng.';

  @override
  String get recordPermissionPermanentlyDenied =>
      'Quyền microphone đang bị chặn. Hãy mở cài đặt hệ thống và cấp quyền trước khi ghi.';

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
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'Hỗ trợ qua email';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Trang web';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'Sắp ra mắt';

  @override
  String get voiceSystemDefault => 'Mặc định hệ thống';

  @override
  String get voiceSystemDefaultHint => 'Được quản lý trong cài đặt điện thoại';

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
      'Mở phần quản lý giọng nói của thiết bị. Sau khi tải xong, quay lại đây.';

  @override
  String get voicesRefreshHint =>
      'Làm mới giọng nói tải lại danh sách TTS hệ thống sau khi cài gói mới.';

  @override
  String get ringtonePreview => 'Nghe thử';

  @override
  String get ringtonePreviewHint =>
      'Bấm phát để nghe thử, rồi chạm tên để chọn.';

  @override
  String get voicesCurrentVoice => 'Giọng đang dùng';

  @override
  String get voicesNewlyInstalled => 'Giọng nói mới cài đặt';

  @override
  String get voicesOnDevice => 'Các giọng trên thiết bị';

  @override
  String get voicesDownloadHint =>
      'Mở phần quản lý giọng nói của thiết bị. Sau khi tải xong, quay lại đây.';

  @override
  String get voicesRescan => 'Quét lại giọng nói';

  @override
  String voicesRescanResult(int count) {
    return 'Tìm thấy $count giọng dùng được';
  }

  @override
  String voicesNewFound(int count) {
    return 'Đã tìm thấy $count giọng nói mới.';
  }

  @override
  String get voicesNoNewFound => 'Không phát hiện giọng nói mới.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Đã cập nhật giọng $language từ cài đặt thiết bị.';
  }

  @override
  String get voicesNoChange => 'Đã làm mới cài đặt giọng nói của thiết bị.';

  @override
  String get voicesSettingsRefreshed =>
      'Đã làm mới cài đặt giọng nói của thiết bị.';

  @override
  String get voicesSystemChanges => 'Cập nhật giọng thiết bị';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Cài đặt giọng $language trên thiết bị vừa được cập nhật.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Giọng mới và cập nhật giọng thiết bị sẽ hiện ở đây sau khi bạn cài hoặc thay đổi.';

  @override
  String get voicesNewBadge => 'Mới';

  @override
  String get commonClear => 'Xóa';

  @override
  String voiceFriendlyName(String number) {
    return 'Giọng nói $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Không mở được quản lý giọng nói. Hãy mở cài đặt Text-to-speech hệ thống để cài giọng.';

  @override
  String get currentVoice => 'Giọng nói đang dùng';

  @override
  String get scanDeviceVoices => 'Quét giọng nói trên thiết bị';

  @override
  String get availableDeviceVoices => 'Giọng nói có sẵn trên thiết bị';

  @override
  String get scanVoicesHint =>
      'Nhấn Quét giọng nói trên thiết bị để xem các giọng hiện có.';

  @override
  String get noDeviceVoicesFound =>
      'Không tìm thấy giọng nói phù hợp trên thiết bị.';

  @override
  String get scanVoicesFailed => 'Không quét được giọng nói. Thử lại.';

  @override
  String get voiceSetupGuide => 'Hướng dẫn thêm giọng nói';

  @override
  String get openVoiceSettings => 'Mở cài đặt giọng nói';

  @override
  String get androidVoiceSetupSteps =>
      '1. Mở Cài đặt của thiết bị.\n2. Tìm Chuyển văn bản thành giọng nói hoặc Text-to-speech.\n3. Chọn công cụ TTS đang dùng.\n4. Mở phần ngôn ngữ hoặc cài dữ liệu giọng nói.\n5. Cài giọng mới.\n6. Quay lại ứng dụng và nhấn Quét giọng nói trên thiết bị.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Mở Cài đặt.\n2. Mở Trợ năng.\n3. Mở Nội dung được đọc hoặc Giọng nói.\n4. Chọn ngôn ngữ và tải giọng có sẵn.\n5. Quay lại ứng dụng và quét lại.\nTên menu có thể khác nhau tùy phiên bản iOS.';

  @override
  String get webVoiceAvailabilityInfo =>
      'Danh sách giọng nói trên Web do trình duyệt và hệ điều hành cung cấp.';

  @override
  String lastScanned(String time) {
    return 'Đã quét: $time';
  }

  @override
  String get voiceInUse => 'Đang dùng';

  @override
  String get otherLanguages => 'Ngôn ngữ khác';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giọng',
      one: '1 giọng',
      zero: 'Không có giọng',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Mở danh sách giọng của ngôn ngữ';

  @override
  String get collapseLanguageVoices => 'Thu gọn danh sách giọng của ngôn ngữ';

  @override
  String voicePreviewNamed(String name) {
    return 'Nghe thử $name';
  }

  @override
  String get settingsSoundAndVoice => 'Âm thanh và giọng nói';

  @override
  String get settingsAlarmsSection => 'Báo thức';

  @override
  String get supportAndFeedback => 'Hỗ trợ';

  @override
  String get contactSupport => 'Liên hệ và phản hồi';

  @override
  String get supportEmailSubject => 'Hỗ trợ Smart Voice Alarm';

  @override
  String get emailCopied => 'Đã sao chép email hỗ trợ';

  @override
  String get linkUnavailable => 'Liên kết chưa khả dụng';

  @override
  String get openSourceLicenses => 'Giấy phép mã nguồn mở';

  @override
  String get appInformation => 'Giới thiệu ứng dụng';

  @override
  String get appVersion => 'Phiên bản ứng dụng';

  @override
  String get permissionsAndBackground => 'Quyền và hoạt động nền';

  @override
  String get notificationPermission => 'Thông báo';

  @override
  String get exactAlarmPermission => 'Báo thức chính xác';

  @override
  String get fullScreenAlarmPermission => 'Báo thức toàn màn hình';

  @override
  String get openSystemSettings => 'Mở cài đặt hệ thống';

  @override
  String get openSystemSettingsHint => 'Quản lý thông báo và quyền liên quan';

  @override
  String get permissionStatusGranted => 'Đã cấp';

  @override
  String get permissionStatusDenied => 'Chưa cấp';

  @override
  String get permissionStatusUnknown => 'Chưa xác định';

  @override
  String trialDaysRemaining(int count) {
    return '$count ngày dùng thử còn lại';
  }

  @override
  String get trialLessThanOneDay => 'Còn dưới 1 ngày dùng thử';

  @override
  String get premiumUpgrade => 'Nâng cấp Premium';

  @override
  String get premiumAnnualTitle => 'Premium trong một năm';

  @override
  String get premiumAnnualDescription =>
      'Tiếp tục sử dụng đầy đủ Smart Voice Alarm sau 7 ngày dùng thử.';

  @override
  String get premiumAnnualPlan => 'Gói Premium 1 năm';

  @override
  String get premiumAnnualAutoRenew =>
      'Tự động gia hạn hằng năm cho đến khi hủy.';

  @override
  String get premiumAnnualCancelInPlay => 'Quản lý hoặc hủy qua Google Play.';

  @override
  String get premiumAnnualAccess =>
      'Duy trì toàn bộ quyền truy cập khi gói đăng ký còn hiệu lực.';

  @override
  String get premiumSubscribeAnnual => 'Đăng ký Premium 1 năm';

  @override
  String get premiumDefer => 'Để sau';

  @override
  String get premiumRestoreTransactions => 'Khôi phục giao dịch';

  @override
  String get premiumManageSubscription => 'Quản lý gói đăng ký';

  @override
  String get premiumProductUnavailable =>
      'Gói đăng ký năm chưa khả dụng trên Google Play.';

  @override
  String get premiumBillingUnavailable =>
      'Google Play Billing hiện không khả dụng.';

  @override
  String get premiumPurchaseActive => 'Premium đang hoạt động';

  @override
  String get premiumTrialExpiredTitle => 'Thời gian dùng thử đã kết thúc';

  @override
  String get premiumTrialExpiredBody =>
      'Đăng ký để tiếp tục dùng các tính năng chính. Báo thức hiện có vẫn có thể reo và có thể được tắt hoặc xóa.';

  @override
  String get premiumRetryVerification => 'Thử lại';

  @override
  String get premiumViewExistingAlarms => 'Xem báo thức hiện có';

  @override
  String get premiumClientVerificationNotice =>
      'Trạng thái đăng ký được xác minh trên thiết bị này qua cửa hàng ứng dụng.';

  @override
  String get premiumUnableToVerify => 'Không thể xác minh trạng thái đăng ký.';

  @override
  String get premiumRestrictedAlarmsTitle => 'Quyền truy cập báo thức giới hạn';

  @override
  String get premiumRestrictedAlarmsBody =>
      'Bạn có thể tắt hoặc xóa báo thức hiện có. Hãy đăng ký để tạo hoặc sửa báo thức.';

  @override
  String get iosFullVoiceAlarmSupport => 'Hỗ trợ báo thức giọng nói đầy đủ';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'Trên iOS 26 trở lên, Smart Voice Alarm dùng AlarmKit để các đoạn giọng nói và nhạc chuông reo theo hành vi báo thức hệ thống.';

  @override
  String get iosLimitedSupportTitle => 'Hỗ trợ hạn chế trên iOS cũ hơn';

  @override
  String get iosLimitedSupportBody =>
      'Trên iOS 13–25, báo thức giọng nói vẫn phát qua âm thanh thông báo. Không có AlarmKit toàn màn hình. Chế độ Im lặng hoặc Focus có thể làm tắt/trễ âm thanh, và vuốt bỏ thông báo mà không giải toán sẽ không dừng các đoạn sau.';

  @override
  String get iosSilentModeWarning =>
      'Chế độ Im lặng có thể khiến âm thanh thông báo báo thức không phát trên iOS cũ.';

  @override
  String get iosFocusWarning =>
      'Chế độ Focus có thể ảnh hưởng việc nhận thông báo trên iOS cũ.';

  @override
  String get ios26Recommendation =>
      'Để báo thức giọng nói đáng tin nhất, hãy dùng iOS 26 trở lên.';

  @override
  String get alarmKitPermission => 'Quyền báo thức';

  @override
  String get alarmKitDenied =>
      'Quyền AlarmKit bị từ chối. Bật báo thức cho Smart Voice Alarm trong Cài đặt.';

  @override
  String get alarmKitPermissionBody =>
      'Cho phép AlarmKit để Smart Voice Alarm lên lịch báo thức giọng nói hệ thống.';

  @override
  String get solveNow => 'Giải ngay';

  @override
  String get alarmSolveToStop => 'Giải toán để dừng';

  @override
  String get alarmDismissedTitle => 'Đã tắt báo thức';

  @override
  String get alarmDismissedBody =>
      'Tất cả các đoạn còn lại của báo thức này đã được hủy.';

  @override
  String get voiceDurationLimitTitle => 'Giới hạn độ dài giọng nói';

  @override
  String get voiceDurationLimitBody =>
      'Trên iOS, mỗi đoạn giọng nói tối đa 20 giây. Hãy cắt ngắn hoặc ghi lại để tiếp tục.';

  @override
  String get trimOrRecreateVoice => 'Cắt hoặc tạo lại giọng nói';

  @override
  String get audioRenderingError =>
      'Không chuẩn bị được âm thanh báo thức. Báo thức chưa được lên lịch.';

  @override
  String get fallbackSoundWarning =>
      'Đang dùng âm thanh dự phòng của hệ thống vì không chuẩn bị được âm thanh đã chọn.';

  @override
  String get savedVoicesTitle => 'Giọng nói đã lưu';

  @override
  String get savedVoicesEmpty =>
      'Bản ghi và TTS đã lưu sẽ hiện ở đây sau khi bạn thêm.';

  @override
  String get savedVoiceAdded => 'Đã thêm giọng nói vào chuỗi';

  @override
  String get iosCapabilityLearnMore =>
      'Cách báo thức hoạt động trên iPhone này';

  @override
  String get alarmAudioNeedsRegeneration =>
      'Âm thanh báo thức giọng nói cần được tạo lại.';

  @override
  String get iosAlarmLoudnessHint =>
      'Độ lớn báo thức cũng phụ thuộc vào Cài đặt → Âm thanh & Cảm ứng → Nhạc chuông và Cảnh báo.';

  @override
  String get addSavedVoiceToSequence => 'Thêm vào chuỗi';
}

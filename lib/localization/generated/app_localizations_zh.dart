// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => '用你自己的声音醒来';

  @override
  String get homeTitle => '闹钟';

  @override
  String get homeEmptyTitle => '还没有闹钟';

  @override
  String get homeEmptySubtitle => '创建你的第一个语音闹钟，用有意义的话语唤醒自己。';

  @override
  String get homeCreateAlarm => '创建闹钟';

  @override
  String get homeEdit => '编辑';

  @override
  String get homeDuplicate => '复制';

  @override
  String get homeDelete => '删除';

  @override
  String get homeMore => '更多选项';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个闹钟已就绪',
      one: '1 个闹钟已就绪',
      zero: '没有闹钟',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => '早上好';

  @override
  String get homeGoodAfternoon => '下午好';

  @override
  String get homeGoodEvening => '晚上好';

  @override
  String get alarmTypeVoice => '语音';

  @override
  String get alarmTypeRingtone => '铃声';

  @override
  String get alarmTypeMixed => '混合';

  @override
  String get alarmTypeLabel => '闹钟类型';

  @override
  String get createAlarmTitle => '新建闹钟';

  @override
  String get editAlarmTitle => '编辑闹钟';

  @override
  String get alarmTime => '时间';

  @override
  String get alarmHour => '小时';

  @override
  String get alarmMinute => '分钟';

  @override
  String get alarmRepeat => '重复';

  @override
  String get alarmVoiceSequence => '语音序列';

  @override
  String get alarmRingtone => '语音后的铃声';

  @override
  String get alarmRepeatCount => '序列重复次数';

  @override
  String get alarmCopyFrom => '从其他闹钟复制';

  @override
  String get alarmSave => '保存闹钟';

  @override
  String get alarmSelectSequence => '点按以编辑序列';

  @override
  String get alarmSelectRingtone => '选择声音';

  @override
  String get alarmNoneSelected => '未选择';

  @override
  String get alarmCopied => '设置已复制';

  @override
  String get alarmSaved => '闹钟已保存';

  @override
  String get alarmDeleted => '闹钟已删除';

  @override
  String get alarmDuplicated => '闹钟已复制';

  @override
  String get dayMon => '一';

  @override
  String get dayTue => '二';

  @override
  String get dayWed => '三';

  @override
  String get dayThu => '四';

  @override
  String get dayFri => '五';

  @override
  String get daySat => '六';

  @override
  String get daySun => '日';

  @override
  String get dayEveryDay => '每天';

  @override
  String get dayWeekdays => '工作日';

  @override
  String get dayWeekends => '周末';

  @override
  String get dayOnce => '一次';

  @override
  String get voiceSequenceTitle => '语音序列';

  @override
  String get voiceSequenceEmptyTitle => '创建你的唤醒消息';

  @override
  String get voiceSequenceEmptySubtitle => '按你希望听到的顺序添加录音或朗读文本。';

  @override
  String get voiceSequenceAdd => '添加语音';

  @override
  String get voiceSequenceDelete => '删除';

  @override
  String get voiceSequenceDeleteConfirmTitle => '移除片段？';

  @override
  String get voiceSequenceDeleteConfirmBody => '这将从序列中移除该片段。';

  @override
  String get voiceSequenceReorderHint => '拖动以重新排序';

  @override
  String get voiceSegmentName => '名称';

  @override
  String get voiceSegmentType => '类型';

  @override
  String get voiceSegmentDuration => '时长';

  @override
  String voiceSegmentOrder(int number) {
    return '步骤 $number';
  }

  @override
  String get voiceTypeRecording => '录音';

  @override
  String get voiceTypeTts => '文字转语音';

  @override
  String get addVoiceTitle => '添加语音';

  @override
  String get addVoiceRecord => '录制语音';

  @override
  String get addVoiceRecordSubtitle => '对着麦克风说一句简短的话';

  @override
  String get addVoiceTts => '文字转语音';

  @override
  String get addVoiceTtsSubtitle => '输入消息并选择朗读声音';

  @override
  String get ttsTitle => '文字转语音';

  @override
  String get ttsInputLabel => '消息';

  @override
  String get ttsInputHint => '输入你想听到的消息…';

  @override
  String get ttsVoices => '声音';

  @override
  String get ttsLanguageLabel => '语言';

  @override
  String get ttsVoiceNameLabel => '声音';

  @override
  String get ttsVoiceQualityLabel => '质量';

  @override
  String get ttsPreview => '预览';

  @override
  String get ttsPreviewing => '正在播放预览…';

  @override
  String get ttsSave => '保存';

  @override
  String get ttsSaved => '语音片段已保存';

  @override
  String get recordTitle => '录制语音';

  @override
  String get recordStart => '录制';

  @override
  String get recordStop => '停止';

  @override
  String get recordPlay => '播放';

  @override
  String get recordPlaying => '播放中…';

  @override
  String get recordSave => '保存';

  @override
  String get recordHint => '准备好后点按录制';

  @override
  String get recordRecording => '正在录制…';

  @override
  String get recordReady => '可以保存';

  @override
  String get recordSaved => '录音已保存';

  @override
  String get recordDefaultName => '语音录音';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsReminder => '提醒';

  @override
  String get settingsReminderSubtitle => '如果没有安排闹钟，会收到温和提醒';

  @override
  String get settingsReminderTime => '提醒时间';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutSubtitle => '应用信息与支持';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => '高级版';

  @override
  String get settingsPremiumSubtitle => '解锁无限闹钟';

  @override
  String get settingsVoices => '声音';

  @override
  String get settingsVoicesSubtitle => '用于文字转语音的系统声音';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsLicenses => '开源许可证';

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get settingsTerms => '使用条款';

  @override
  String get settingsLegalPlaceholder => '查看文档';

  @override
  String get premiumTitle => '高级版';

  @override
  String get premiumHeadline => '解锁无限闹钟';

  @override
  String get premiumSubtitle => '免费版最多 3 个闹钟。一次终身购买即可解锁无限闹钟。无订阅。';

  @override
  String get premiumPlanFree => '免费';

  @override
  String get premiumPlanLifetime => '高级终身版';

  @override
  String get premiumPlanLifetimePrice => '一次性购买';

  @override
  String get premiumBenefitsTitle => '高级版全部权益';

  @override
  String get premiumBenefitUnlimited => '无限闹钟';

  @override
  String get premiumBenefitSequences => '语音序列无功能锁定';

  @override
  String get premiumBenefitVoices => '全部已安装的系统语音';

  @override
  String get premiumBenefitThemes => '主题、提醒和录音保持免费';

  @override
  String get premiumBenefitSupport => '优先支持';

  @override
  String get premiumBenefitNoAds => '无广告';

  @override
  String get premiumUnlock => '解锁无限闹钟';

  @override
  String get premiumRestore => '恢复购买';

  @override
  String get premiumThanks => '感谢支持 Smart Voice Alarm。';

  @override
  String get premiumComingSoon =>
      '需在 App Store Connect 与 Google Play Console 中配置商品。';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDone => '完成';

  @override
  String get commonBack => '返回';

  @override
  String get commonNext => '下一步';

  @override
  String get commonClose => '关闭';

  @override
  String get commonEnabled => '开';

  @override
  String get commonDisabled => '关';

  @override
  String get commonRemove => '移除';

  @override
  String get commonOpen => '打开';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languagePortuguese => '葡萄牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageItalian => '意大利语';

  @override
  String get languageDutch => '荷兰语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageChineseSimplified => '中文（简体）';

  @override
  String get languageChineseTraditional => '中文（繁体）';

  @override
  String get languageIndonesian => '印尼语';

  @override
  String get languageVietnamese => '越南语';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
      one: '1 次',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个片段',
      one: '1 个片段',
      zero: '没有片段',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => '轻柔铃声';

  @override
  String get ringtoneOceanBreeze => '海风';

  @override
  String get ringtoneNightPulse => '夜脉';

  @override
  String get ringtoneForestDawn => '林间黎明';

  @override
  String get ringtoneCrystalBell => '水晶铃';

  @override
  String get alarmStop => '停止';

  @override
  String get alarmStopAll => '全部停止';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个闹钟等待中',
      one: '1 个闹钟等待中',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => '声音';

  @override
  String get voicesSystemVoices => '系统声音';

  @override
  String get voicesDownloadMore => '下载更多声音';

  @override
  String get voicesRefresh => '刷新声音';

  @override
  String get voicesOfflineHint => '建议使用离线声音，这样即使没有网络连接，闹钟仍能播报。';

  @override
  String get voicesIosGuideTitle => '在 iPhone 上安装声音';

  @override
  String get voicesIosGuideBody =>
      '打开“设置”→“辅助功能”→“朗读内容”→“声音”，下载所需声音，然后返回此处并点按“刷新声音”。';

  @override
  String get voicesAndroidGuide =>
      '将打开系统 TTS 数据安装程序。Smart Voice Alarm 不会下载或托管语音包。';

  @override
  String get voicesWebUnavailable => '浏览器自行管理声音。网页版无法提供下载包。';

  @override
  String get voicesEmpty => '尚未找到可用声音';

  @override
  String get voicesEmptyCta => '下载更多声音';

  @override
  String get voiceQualityDefault => '默认';

  @override
  String get voiceQualityEnhanced => '增强';

  @override
  String get voiceQualityPremium => '高级';

  @override
  String get voiceAvailabilityOffline => '离线';

  @override
  String get voiceAvailabilityNetwork => '需要网络';

  @override
  String get voiceAvailabilityMissing => '未安装';

  @override
  String get ttsNoVoicesTitle => '没有可用声音';

  @override
  String get ttsNoVoicesBody => '下载系统声音，然后刷新列表。';

  @override
  String get ttsOpenVoiceSettings => '下载更多声音';

  @override
  String get ttsVoiceFallback => '所选声音不可用。将改用默认声音。';

  @override
  String get reminderNotificationTitle => '设置明天的闹钟';

  @override
  String get reminderNotificationBody => '花一点时间，为明天安排好你的 Smart Voice Alarm。';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutAppName => '应用名称';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutDeveloper => '开发者';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'GitHub 仓库';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => '电子邮件支持';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => '网站';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => '即将推出';

  @override
  String get voiceSystemDefault => '系统默认';

  @override
  String get notificationChannelAlarms => '闹钟';

  @override
  String get notificationChannelAlarmsDesc => '语音闹钟提醒';

  @override
  String get notificationChannelReminders => '提醒';

  @override
  String get notificationChannelRemindersDesc => '每天提醒设置明天的闹钟';

  @override
  String get alarmDefaultLabel => '闹钟';

  @override
  String get premiumBenefitLifetimeBuy => '买一次，永久拥有。';

  @override
  String get premiumStatusLoading => '正在检查商店…';

  @override
  String get premiumStatusPurchasing => '正在开始购买…';

  @override
  String get premiumStatusPurchased => '已解锁 Premium Lifetime';

  @override
  String get premiumStatusRestored => '已恢复购买';

  @override
  String get premiumStatusCancelled => '已取消购买';

  @override
  String get premiumStatusPending => '购买处理中…';

  @override
  String get premiumStatusError => '购买失败，请重试。';

  @override
  String get premiumWebUnavailable => '网页演示不支持应用内购买。';

  @override
  String get premiumStoreUnavailable => '此设备无法使用商店。';

  @override
  String get premiumLimitExplainFree => '免费版最多包含 3 个闹钟。';

  @override
  String get premiumLimitExplainUnlock => '一次终身购买即可解锁无限闹钟。';

  @override
  String premiumFreeLimitLabel(int count) {
    return '最多 $count 个闹钟';
  }

  @override
  String get voicesSearchHint => '搜索语言或语音';

  @override
  String get voicesLanguages => '语言';

  @override
  String get voicesSelectVoiceHint => '为此语言选择语音';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个语音',
      one: '1 个语音',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => '点按选择时间';

  @override
  String get segmentPlay => '播放';

  @override
  String get voicePlaying => '正在播放';

  @override
  String get voiceSelect => '选择';

  @override
  String get voiceUnavailable => '语音不可用';

  @override
  String get recordingFileMissing => '录音文件缺失。请删除此片段或重新录制。';

  @override
  String get voiceDetails => '语音详情';

  @override
  String get ttsSelectedVoice => '已选语音';

  @override
  String get voicePreviewSample => '这是此语音的简短预览。';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => '用你自己的聲音醒來';

  @override
  String get homeTitle => '鬧鐘';

  @override
  String get homeEmptyTitle => '還沒有鬧鐘';

  @override
  String get homeEmptySubtitle => '建立你的第一個語音鬧鐘，用有意義的話語喚醒自己。';

  @override
  String get homeCreateAlarm => '建立鬧鐘';

  @override
  String get homeEdit => '編輯';

  @override
  String get homeDuplicate => '複製';

  @override
  String get homeDelete => '刪除';

  @override
  String get homeMore => '更多選項';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個鬧鐘已就緒',
      one: '1 個鬧鐘已就緒',
      zero: '沒有鬧鐘',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => '早安';

  @override
  String get homeGoodAfternoon => '午安';

  @override
  String get homeGoodEvening => '晚安';

  @override
  String get alarmTypeVoice => '語音';

  @override
  String get alarmTypeRingtone => '鈴聲';

  @override
  String get alarmTypeMixed => '混合';

  @override
  String get alarmTypeLabel => '鬧鐘類型';

  @override
  String get createAlarmTitle => '新增鬧鐘';

  @override
  String get editAlarmTitle => '編輯鬧鐘';

  @override
  String get alarmTime => '時間';

  @override
  String get alarmHour => '小時';

  @override
  String get alarmMinute => '分鐘';

  @override
  String get alarmRepeat => '重複';

  @override
  String get alarmVoiceSequence => '語音序列';

  @override
  String get alarmRingtone => '語音後的鈴聲';

  @override
  String get alarmRepeatCount => '序列重複次數';

  @override
  String get alarmCopyFrom => '從其他鬧鐘複製';

  @override
  String get alarmSave => '儲存鬧鐘';

  @override
  String get alarmSelectSequence => '點一下以編輯序列';

  @override
  String get alarmSelectRingtone => '選擇聲音';

  @override
  String get alarmNoneSelected => '未選取';

  @override
  String get alarmCopied => '設定已複製';

  @override
  String get alarmSaved => '鬧鐘已儲存';

  @override
  String get alarmDeleted => '鬧鐘已刪除';

  @override
  String get alarmDuplicated => '鬧鐘已複製';

  @override
  String get dayMon => '一';

  @override
  String get dayTue => '二';

  @override
  String get dayWed => '三';

  @override
  String get dayThu => '四';

  @override
  String get dayFri => '五';

  @override
  String get daySat => '六';

  @override
  String get daySun => '日';

  @override
  String get dayEveryDay => '每天';

  @override
  String get dayWeekdays => '平日';

  @override
  String get dayWeekends => '週末';

  @override
  String get dayOnce => '一次';

  @override
  String get voiceSequenceTitle => '語音序列';

  @override
  String get voiceSequenceEmptyTitle => '建立你的喚醒訊息';

  @override
  String get voiceSequenceEmptySubtitle => '依你希望聽到的順序加入錄音或朗讀文字。';

  @override
  String get voiceSequenceAdd => '加入語音';

  @override
  String get voiceSequenceDelete => '刪除';

  @override
  String get voiceSequenceDeleteConfirmTitle => '移除片段？';

  @override
  String get voiceSequenceDeleteConfirmBody => '這會從序列中移除此片段。';

  @override
  String get voiceSequenceReorderHint => '拖曳以重新排序';

  @override
  String get voiceSegmentName => '名稱';

  @override
  String get voiceSegmentType => '類型';

  @override
  String get voiceSegmentDuration => '時長';

  @override
  String voiceSegmentOrder(int number) {
    return '步驟 $number';
  }

  @override
  String get voiceTypeRecording => '錄音';

  @override
  String get voiceTypeTts => '文字轉語音';

  @override
  String get addVoiceTitle => '加入語音';

  @override
  String get addVoiceRecord => '錄製語音';

  @override
  String get addVoiceRecordSubtitle => '對著麥克風說一句簡短的話';

  @override
  String get addVoiceTts => '文字轉語音';

  @override
  String get addVoiceTtsSubtitle => '輸入訊息並選擇朗讀聲音';

  @override
  String get ttsTitle => '文字轉語音';

  @override
  String get ttsInputLabel => '訊息';

  @override
  String get ttsInputHint => '輸入你想聽到的訊息…';

  @override
  String get ttsVoices => '聲音';

  @override
  String get ttsLanguageLabel => '語言';

  @override
  String get ttsVoiceNameLabel => '聲音';

  @override
  String get ttsVoiceQualityLabel => '品質';

  @override
  String get ttsPreview => '預覽';

  @override
  String get ttsPreviewing => '正在播放預覽…';

  @override
  String get ttsSave => '儲存';

  @override
  String get ttsSaved => '語音片段已儲存';

  @override
  String get recordTitle => '錄製語音';

  @override
  String get recordStart => '錄製';

  @override
  String get recordStop => '停止';

  @override
  String get recordPlay => '播放';

  @override
  String get recordPlaying => '播放中…';

  @override
  String get recordSave => '儲存';

  @override
  String get recordHint => '準備好後點一下錄製';

  @override
  String get recordRecording => '正在錄製…';

  @override
  String get recordReady => '可以儲存';

  @override
  String get recordSaved => '錄音已儲存';

  @override
  String get recordDefaultName => '語音錄音';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsTheme => '主題';

  @override
  String get settingsThemeSystem => '系統';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsReminder => '提醒';

  @override
  String get settingsReminderSubtitle => '如果沒有安排鬧鐘，會收到溫和提醒';

  @override
  String get settingsReminderTime => '提醒時間';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsAboutSubtitle => 'App 資訊與支援';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => '進階版';

  @override
  String get settingsPremiumSubtitle => '解鎖無限鬧鐘';

  @override
  String get settingsVoices => '聲音';

  @override
  String get settingsVoicesSubtitle => '用於文字轉語音的系統聲音';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsLicenses => '開放原始碼授權';

  @override
  String get settingsPrivacy => '隱私權政策';

  @override
  String get settingsTerms => '使用條款';

  @override
  String get settingsLegalPlaceholder => '查看文件';

  @override
  String get premiumTitle => '進階版';

  @override
  String get premiumHeadline => '解鎖無限鬧鐘';

  @override
  String get premiumSubtitle => '免費版最多 3 個鬧鐘。一次終身購買即可解鎖無限鬧鐘。無訂閱。';

  @override
  String get premiumPlanFree => '免費';

  @override
  String get premiumPlanLifetime => '進階終身版';

  @override
  String get premiumPlanLifetimePrice => '一次購買';

  @override
  String get premiumBenefitsTitle => '進階版全部權益';

  @override
  String get premiumBenefitUnlimited => '無限鬧鐘';

  @override
  String get premiumBenefitSequences => '語音序列無功能鎖定';

  @override
  String get premiumBenefitVoices => '全部已安裝的系統語音';

  @override
  String get premiumBenefitThemes => '主題、提醒和錄音保持免費';

  @override
  String get premiumBenefitSupport => '優先支援';

  @override
  String get premiumBenefitNoAds => '無廣告';

  @override
  String get premiumUnlock => '解鎖無限鬧鐘';

  @override
  String get premiumRestore => '恢復購買';

  @override
  String get premiumThanks => '感謝支持 Smart Voice Alarm。';

  @override
  String get premiumComingSoon =>
      '需在 App Store Connect 與 Google Play Console 中設定商品。';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDone => '完成';

  @override
  String get commonBack => '返回';

  @override
  String get commonNext => '下一步';

  @override
  String get commonClose => '關閉';

  @override
  String get commonEnabled => '開';

  @override
  String get commonDisabled => '關';

  @override
  String get commonRemove => '移除';

  @override
  String get commonOpen => '開啟';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => '西班牙語';

  @override
  String get languagePortuguese => '葡萄牙語';

  @override
  String get languageFrench => '法語';

  @override
  String get languageGerman => '德語';

  @override
  String get languageItalian => '義大利語';

  @override
  String get languageDutch => '荷蘭語';

  @override
  String get languageJapanese => '日語';

  @override
  String get languageKorean => '韓語';

  @override
  String get languageChineseSimplified => '中文（簡體）';

  @override
  String get languageChineseTraditional => '中文（繁體）';

  @override
  String get languageIndonesian => '印尼語';

  @override
  String get languageVietnamese => '越南語';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次',
      one: '1 次',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個片段',
      one: '1 個片段',
      zero: '沒有片段',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => '輕柔鈴聲';

  @override
  String get ringtoneOceanBreeze => '海風';

  @override
  String get ringtoneNightPulse => '夜脈';

  @override
  String get ringtoneForestDawn => '林間黎明';

  @override
  String get ringtoneCrystalBell => '水晶鈴';

  @override
  String get alarmStop => '停止';

  @override
  String get alarmStopAll => '全部停止';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個鬧鐘等待中',
      one: '1 個鬧鐘等待中',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => '聲音';

  @override
  String get voicesSystemVoices => '系統聲音';

  @override
  String get voicesDownloadMore => '下載更多聲音';

  @override
  String get voicesRefresh => '重新整理聲音';

  @override
  String get voicesOfflineHint => '建議使用離線聲音，這樣即使沒有網路連線，鬧鐘仍能播報。';

  @override
  String get voicesIosGuideTitle => '在 iPhone 上安裝聲音';

  @override
  String get voicesIosGuideBody =>
      '打開「設定」→「輔助使用」→「朗讀內容」→「聲音」，下載所需聲音，然後返回此處並點一下「重新整理聲音」。';

  @override
  String get voicesAndroidGuide =>
      '將開啟系統 TTS 資料安裝程式。Smart Voice Alarm 不會下載或託管語音套件。';

  @override
  String get voicesWebUnavailable => '瀏覽器自行管理聲音。網頁版無法提供下載套件。';

  @override
  String get voicesEmpty => '尚未找到可用聲音';

  @override
  String get voicesEmptyCta => '下載更多聲音';

  @override
  String get voiceQualityDefault => '預設';

  @override
  String get voiceQualityEnhanced => '增強';

  @override
  String get voiceQualityPremium => '進階';

  @override
  String get voiceAvailabilityOffline => '離線';

  @override
  String get voiceAvailabilityNetwork => '需要網路';

  @override
  String get voiceAvailabilityMissing => '未安裝';

  @override
  String get ttsNoVoicesTitle => '沒有可用聲音';

  @override
  String get ttsNoVoicesBody => '下載系統聲音，然後重新整理列表。';

  @override
  String get ttsOpenVoiceSettings => '下載更多聲音';

  @override
  String get ttsVoiceFallback => '所選聲音無法使用。將改用預設聲音。';

  @override
  String get reminderNotificationTitle => '設定明天的鬧鐘';

  @override
  String get reminderNotificationBody => '花一點時間，為明天安排好你的 Smart Voice Alarm。';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutAppName => 'App 名稱';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutDeveloper => '開發者';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'GitHub 存放庫';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => '電子郵件支援';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => '網站';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => '即將推出';

  @override
  String get voiceSystemDefault => '系統預設';

  @override
  String get notificationChannelAlarms => '鬧鐘';

  @override
  String get notificationChannelAlarmsDesc => '語音鬧鐘提醒';

  @override
  String get notificationChannelReminders => '提醒';

  @override
  String get notificationChannelRemindersDesc => '每日提醒設定明天的鬧鐘';

  @override
  String get alarmDefaultLabel => '鬧鐘';

  @override
  String get premiumBenefitLifetimeBuy => '買一次，永久擁有。';

  @override
  String get premiumStatusLoading => '正在檢查商店…';

  @override
  String get premiumStatusPurchasing => '正在開始購買…';

  @override
  String get premiumStatusPurchased => '已解鎖 Premium Lifetime';

  @override
  String get premiumStatusRestored => '已恢復購買';

  @override
  String get premiumStatusCancelled => '已取消購買';

  @override
  String get premiumStatusPending => '購買處理中…';

  @override
  String get premiumStatusError => '購買失敗，請再試一次。';

  @override
  String get premiumWebUnavailable => '網頁示範不支援應用程式內購買。';

  @override
  String get premiumStoreUnavailable => '此裝置無法使用商店。';

  @override
  String get premiumLimitExplainFree => '免費版最多包含 3 個鬧鐘。';

  @override
  String get premiumLimitExplainUnlock => '一次終身購買即可解鎖無限鬧鐘。';

  @override
  String premiumFreeLimitLabel(int count) {
    return '最多 $count 個鬧鐘';
  }

  @override
  String get voicesSearchHint => '搜尋語言或語音';

  @override
  String get voicesLanguages => '語言';

  @override
  String get voicesSelectVoiceHint => '為此語言選擇語音';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個語音',
      one: '1 個語音',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => '點一下以選擇時間';

  @override
  String get segmentPlay => '播放';

  @override
  String get voicePlaying => '播放中';

  @override
  String get voiceSelect => '選擇';

  @override
  String get voiceUnavailable => '語音無法使用';

  @override
  String get recordingFileMissing => '缺少錄音檔。請刪除此區段或重新錄音。';

  @override
  String get voiceDetails => '語音詳細資料';

  @override
  String get ttsSelectedVoice => '已選語音';

  @override
  String get voicePreviewSample => '這是此語音的簡短預覽。';
}

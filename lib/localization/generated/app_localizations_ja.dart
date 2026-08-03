// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => '自分の声で目覚める';

  @override
  String get homeTitle => 'アラーム';

  @override
  String get homeEmptyTitle => 'まだアラームがありません';

  @override
  String get homeEmptySubtitle => '最初の音声アラームを作成して、大切な言葉で目覚めましょう。';

  @override
  String get homeCreateAlarm => 'アラームを作成';

  @override
  String get homeEdit => '編集';

  @override
  String get homeDuplicate => '複製';

  @override
  String get homeDelete => '削除';

  @override
  String get homeMore => 'その他のオプション';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アラーム$count件の準備完了',
      one: 'アラーム1件の準備完了',
      zero: 'アラームなし',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'おはようございます';

  @override
  String get homeGoodAfternoon => 'こんにちは';

  @override
  String get homeGoodEvening => 'こんばんは';

  @override
  String get alarmTypeVoice => '音声';

  @override
  String get alarmTypeRingtone => '着信音';

  @override
  String get alarmTypeMixed => '混合';

  @override
  String get alarmTypeLabel => 'アラームの種類';

  @override
  String get createAlarmTitle => '新しいアラーム';

  @override
  String get editAlarmTitle => 'アラームを編集';

  @override
  String get alarmTime => '時刻';

  @override
  String get alarmHour => '時';

  @override
  String get alarmMinute => '分';

  @override
  String get alarmRepeat => '繰り返し';

  @override
  String get alarmVoiceSequence => '音声シーケンス';

  @override
  String get alarmRingtone => '音声の後の着信音';

  @override
  String get alarmRepeatCount => 'シーケンスの繰り返し';

  @override
  String get alarmCopyFrom => '別のアラームからコピー';

  @override
  String get alarmSave => 'アラームを保存';

  @override
  String get alarmSelectSequence => 'タップしてシーケンスを編集';

  @override
  String get alarmSelectRingtone => 'サウンドを選択';

  @override
  String get alarmNoneSelected => '未選択';

  @override
  String get alarmCopied => '設定をコピーしました';

  @override
  String get alarmSaved => 'アラームを保存しました';

  @override
  String get alarmDeleted => 'アラームを削除しました';

  @override
  String get alarmDuplicated => 'アラームを複製しました';

  @override
  String get dayMon => '月';

  @override
  String get dayTue => '火';

  @override
  String get dayWed => '水';

  @override
  String get dayThu => '木';

  @override
  String get dayFri => '金';

  @override
  String get daySat => '土';

  @override
  String get daySun => '日';

  @override
  String get dayEveryDay => '毎日';

  @override
  String get dayWeekdays => '平日';

  @override
  String get dayWeekends => '週末';

  @override
  String get dayOnce => '1回のみ';

  @override
  String get voiceSequenceTitle => '音声シーケンス';

  @override
  String get voiceSequenceEmptyTitle => '目覚ましメッセージを作成';

  @override
  String get voiceSequenceEmptySubtitle => '聞きたい順番で録音や読み上げテキストを追加します。';

  @override
  String get voiceSequenceAdd => '音声を追加';

  @override
  String get voiceSequenceDelete => '削除';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'セグメントを削除しますか？';

  @override
  String get voiceSequenceDeleteConfirmBody => 'この操作でシーケンスからセグメントが削除されます。';

  @override
  String get voiceSequenceReorderHint => 'ドラッグして並べ替え';

  @override
  String get voiceSegmentName => '名前';

  @override
  String get voiceSegmentType => '種類';

  @override
  String get voiceSegmentDuration => '長さ';

  @override
  String voiceSegmentOrder(int number) {
    return 'ステップ $number';
  }

  @override
  String get voiceTypeRecording => '録音';

  @override
  String get voiceTypeTts => 'テキスト読み上げ';

  @override
  String get addVoiceTitle => '音声を追加';

  @override
  String get addVoiceRecord => '音声を録音';

  @override
  String get addVoiceRecordSubtitle => 'マイクに短いメッセージを話してください';

  @override
  String get addVoiceTts => 'テキスト読み上げ';

  @override
  String get addVoiceTtsSubtitle => 'メッセージを入力して読み上げ音声を選択';

  @override
  String get ttsTitle => 'テキスト読み上げ';

  @override
  String get ttsInputLabel => 'メッセージ';

  @override
  String get ttsInputHint => '聞きたいメッセージを入力…';

  @override
  String get ttsVoices => '音声';

  @override
  String get ttsLanguageLabel => '言語';

  @override
  String get ttsVoiceNameLabel => '音声';

  @override
  String get ttsVoiceQualityLabel => '品質';

  @override
  String get ttsPreview => 'プレビュー';

  @override
  String get ttsPreviewing => 'プレビュー再生中…';

  @override
  String get ttsSave => '保存';

  @override
  String get ttsSaved => '音声セグメントを保存しました';

  @override
  String get recordTitle => '音声を録音';

  @override
  String get recordStart => '録音';

  @override
  String get recordStop => '停止';

  @override
  String get recordPlay => '再生';

  @override
  String get recordPlaying => '再生中…';

  @override
  String get recordSave => '保存';

  @override
  String get recordHint => '準備ができたら録音をタップ';

  @override
  String get recordRecording => '録音中…';

  @override
  String get recordReady => '保存の準備完了';

  @override
  String get recordSaved => '録音を保存しました';

  @override
  String get recordDefaultName => '音声録音';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeSystem => 'システム';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsReminder => 'リマインダー';

  @override
  String get settingsReminderSubtitle => 'アラームが設定されていないときにやさしくお知らせ';

  @override
  String get settingsReminderTime => 'リマインダー時刻';

  @override
  String get settingsAbout => '情報';

  @override
  String get settingsAboutSubtitle => 'アプリ情報とサポート';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'プレミアム';

  @override
  String get settingsPremiumSubtitle => '生涯アクセスを解除';

  @override
  String get settingsVoices => '音声';

  @override
  String get settingsVoicesSubtitle => 'テキスト読み上げ用のシステム音声';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsLicenses => 'オープンソースライセンス';

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get settingsTerms => '利用規約';

  @override
  String get settingsLegalPlaceholder => 'コンテンツは近日公開予定です。';

  @override
  String get premiumTitle => 'プレミアム';

  @override
  String get premiumHeadline => '一度の購入。ずっとあなたのもの。';

  @override
  String get premiumSubtitle =>
      '一度きりの生涯購入で、Smart Voice Alarmのすべての体験を解除。サブスクリプションはありません。';

  @override
  String get premiumPlanFree => '無料';

  @override
  String get premiumPlanLifetime => 'プレミアム生涯版';

  @override
  String get premiumPlanLifetimePrice => '一回限りの解除';

  @override
  String get premiumBenefitsTitle => 'プレミアムのすべて';

  @override
  String get premiumBenefitUnlimited => '無制限の音声アラーム';

  @override
  String get premiumBenefitSequences => 'より長い音声シーケンス';

  @override
  String get premiumBenefitVoices => '読み上げ音声へのフルアクセス';

  @override
  String get premiumBenefitThemes => '追加の外観オプション';

  @override
  String get premiumBenefitSupport => '優先サポート';

  @override
  String get premiumBenefitNoAds => '広告なしの体験';

  @override
  String get premiumUnlock => '生涯版を解除';

  @override
  String get premiumRestore => '購入を復元';

  @override
  String get premiumThanks => '購入機能は今後のアップデートで利用可能になります。ご支援ありがとうございます。';

  @override
  String get premiumComingSoon => 'アプリ内購入を準備中です。現時点では課金されません。';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonDone => '完了';

  @override
  String get commonBack => '戻る';

  @override
  String get commonNext => '次へ';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonEnabled => 'オン';

  @override
  String get commonDisabled => 'オフ';

  @override
  String get commonRemove => '削除';

  @override
  String get commonOpen => '開く';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languagePortuguese => 'ポルトガル語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get languageItalian => 'イタリア語';

  @override
  String get languageDutch => 'オランダ語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageChineseSimplified => '中国語（簡体字）';

  @override
  String get languageChineseTraditional => '中国語（繁体字）';

  @override
  String get languageIndonesian => 'インドネシア語';

  @override
  String get languageVietnamese => 'ベトナム語';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回',
      one: '1回',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'セグメント$count件',
      one: 'セグメント1件',
      zero: 'セグメントなし',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'ソフトチャイム';

  @override
  String get ringtoneOceanBreeze => 'オーシャンブリーズ';

  @override
  String get ringtoneNightPulse => 'ナイトパルス';

  @override
  String get ringtoneForestDawn => 'フォレストドーン';

  @override
  String get ringtoneCrystalBell => 'クリスタルベル';

  @override
  String get alarmStop => '停止';

  @override
  String get alarmStopAll => 'すべて停止';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '待機中のアラーム$count件',
      one: '待機中のアラーム1件',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => '音声';

  @override
  String get voicesSystemVoices => 'システム音声';

  @override
  String get voicesDownloadMore => 'さらに音声をダウンロード';

  @override
  String get voicesRefresh => '音声を更新';

  @override
  String get voicesOfflineHint => 'ネットワークなしでもアラームが話せるよう、オフライン音声をおすすめします。';

  @override
  String get voicesIosGuideTitle => 'iPhoneに音声をインストール';

  @override
  String get voicesIosGuideBody =>
      '設定 → アクセシビリティ → 読み上げコンテンツ → 声 を開き、必要な音声をダウンロードしてから、ここに戻って「音声を更新」をタップしてください。';

  @override
  String get voicesAndroidGuide =>
      'システムのTTSデータインストーラーを開きます。Smart Voice Alarmは音声パッケージをダウンロードまたはホストしません。';

  @override
  String get voicesWebUnavailable => 'ブラウザは独自の音声を管理します。Webではダウンロードパックは利用できません。';

  @override
  String get voicesEmpty => '利用可能な音声がまだ見つかりません';

  @override
  String get voicesEmptyCta => 'さらに音声をダウンロード';

  @override
  String get voiceQualityDefault => '標準';

  @override
  String get voiceQualityEnhanced => '強化';

  @override
  String get voiceQualityPremium => 'プレミアム';

  @override
  String get voiceAvailabilityOffline => 'オフライン';

  @override
  String get voiceAvailabilityNetwork => 'ネットワークが必要';

  @override
  String get voiceAvailabilityMissing => '未インストール';

  @override
  String get ttsNoVoicesTitle => '利用可能な音声がありません';

  @override
  String get ttsNoVoicesBody => 'システム音声をダウンロードしてから、リストを更新してください。';

  @override
  String get ttsOpenVoiceSettings => 'さらに音声をダウンロード';

  @override
  String get ttsVoiceFallback => '選択した音声は利用できません。代わりにデフォルトの音声を使用します。';

  @override
  String get reminderNotificationTitle => '明日のアラームを設定';

  @override
  String get reminderNotificationBody =>
      '少し時間を取って、明日のSmart Voice Alarmをスケジュールしましょう。';

  @override
  String get aboutTitle => '情報';

  @override
  String get aboutAppName => 'アプリ名';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutDeveloper => '開発者';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'GitHubリポジトリ';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => 'メールサポート';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => 'ウェブサイト';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => '近日公開';

  @override
  String get voiceSystemDefault => 'システムデフォルト';

  @override
  String get notificationChannelAlarms => 'アラーム';

  @override
  String get notificationChannelAlarmsDesc => '音声アラームの通知';

  @override
  String get notificationChannelReminders => 'リマインダー';

  @override
  String get notificationChannelRemindersDesc => '明日のアラームを設定する毎日のリマインダー';

  @override
  String get alarmDefaultLabel => 'アラーム';
}

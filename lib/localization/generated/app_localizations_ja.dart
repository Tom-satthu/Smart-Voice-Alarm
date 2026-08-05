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
  String get recordPermissionTitle => 'マイクへのアクセス';

  @override
  String get recordPermissionRationale => 'アラームに使用する音声を録音するため、マイクへのアクセスが必要です。';

  @override
  String get recordPermissionDenied =>
      'マイクへのアクセスが許可されていません。録音は開始されませんでした。もう一度お試しいただけます。';

  @override
  String get recordPermissionPermanentlyDenied =>
      'マイクへのアクセスがブロックされています。録音前にシステム設定で許可してください。';

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
  String get settingsPremiumSubtitle => '無制限のアラームを解除';

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
  String get settingsLegalPlaceholder => '文書を表示';

  @override
  String get premiumTitle => 'プレミアム';

  @override
  String get premiumHeadline => '無制限アラームを解除';

  @override
  String get premiumSubtitle => '無料版はアラーム最大3件。買い切り1回で無制限に。サブスクリプションはありません。';

  @override
  String get premiumPlanFree => '無料';

  @override
  String get premiumPlanLifetime => 'プレミアム生涯版';

  @override
  String get premiumPlanLifetimePrice => '買い切り';

  @override
  String get premiumBenefitsTitle => 'プレミアムのすべて';

  @override
  String get premiumBenefitUnlimited => '無制限アラーム';

  @override
  String get premiumBenefitSequences => '機能ロックのない音声シーケンス';

  @override
  String get premiumBenefitVoices => 'インストール済みのすべてのシステム音声';

  @override
  String get premiumBenefitThemes => 'テーマ・リマインダー・録音は無料のまま';

  @override
  String get premiumBenefitSupport => '優先サポート';

  @override
  String get premiumBenefitNoAds => '広告なし';

  @override
  String get premiumUnlock => '無制限アラームを解除';

  @override
  String get premiumRestore => '購入を復元';

  @override
  String get premiumThanks => 'Smart Voice Alarmを応援いただきありがとうございます。';

  @override
  String get premiumComingSoon =>
      '商品は App Store Connect と Google Play Console で設定してください。';

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
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'メールサポート';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'ウェブサイト';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => '近日公開';

  @override
  String get voiceSystemDefault => 'システムデフォルト';

  @override
  String get voiceSystemDefaultHint => 'デバイスの設定で管理されます';

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

  @override
  String get premiumBenefitLifetimeBuy => '一度の購入。ずっとあなたのもの。';

  @override
  String get premiumStatusLoading => 'ストアを確認中…';

  @override
  String get premiumStatusPurchasing => '購入を開始中…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime が解除されました';

  @override
  String get premiumStatusRestored => '購入を復元しました';

  @override
  String get premiumStatusCancelled => '購入がキャンセルされました';

  @override
  String get premiumStatusPending => '購入処理中…';

  @override
  String get premiumStatusError => '購入に失敗しました。もう一度お試しください。';

  @override
  String get premiumWebUnavailable => 'Webデモではアプリ内課金は利用できません。';

  @override
  String get premiumStoreUnavailable => 'この端末ではストアを利用できません。';

  @override
  String get premiumLimitExplainFree => '無料版はアラーム最大3件です。';

  @override
  String get premiumLimitExplainUnlock => '買い切り1回でアラームを無制限に。';

  @override
  String premiumFreeLimitLabel(int count) {
    return '最大 $count 件のアラーム';
  }

  @override
  String get voicesSearchHint => '言語や音声を検索';

  @override
  String get voicesLanguages => '言語';

  @override
  String get voicesSelectVoiceHint => 'この言語の音声を選択';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '音声 $count',
      one: '音声 1',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'タップして時刻を選択';

  @override
  String get segmentPlay => '再生';

  @override
  String get voicePlaying => '再生中';

  @override
  String get voiceSelect => '選択';

  @override
  String get voiceUnavailable => '音声を利用できません';

  @override
  String get recordingFileMissing => '録音ファイルがありません。このセグメントを削除するか、再録音してください。';

  @override
  String get voiceDetails => '音声の詳細';

  @override
  String get ttsSelectedVoice => '選択中の音声';

  @override
  String get voicePreviewSample => 'これはこの音声の短いプレビューです。';

  @override
  String get alarmDismissTitle => '解いて停止';

  @override
  String get alarmDismissHint => '正しく答えるとアラームが止まります。';

  @override
  String get alarmDismissWrong => '不正解です。別の問題です。';

  @override
  String get alarmDismissCheck => '確認';

  @override
  String get alarmDismissAnswerHint => '答え';

  @override
  String voicesRefreshed(int count) {
    return '更新しました: $count 件の音声';
  }

  @override
  String voicesSelectedSaved(String name) {
    return '保存した音声: $name';
  }

  @override
  String get voicesDownloadThenSelect => '端末の音声管理を開きます。ダウンロード後、ここに戻ってください。';

  @override
  String get voicesRefreshHint => '音声を更新すると、インストール後のシステムTTS音声を再読み込みします。';

  @override
  String get ringtonePreview => 'プレビュー';

  @override
  String get ringtonePreviewHint => '再生で試聴し、名前をタップして選択します。';

  @override
  String get voicesCurrentVoice => '使用中の音声';

  @override
  String get voicesNewlyInstalled => '新しくインストールした音声';

  @override
  String get voicesOnDevice => 'この端末の音声';

  @override
  String get voicesDownloadHint => '端末の音声管理を開きます。ダウンロード後、ここに戻ってください。';

  @override
  String get voicesRescan => '音声を再スキャン';

  @override
  String voicesRescanResult(int count) {
    return '利用可能な音声が $count 件見つかりました';
  }

  @override
  String voicesNewFound(int count) {
    return '新しい音声が $count 件見つかりました。';
  }

  @override
  String get voicesNoNewFound => '新しい音声は検出されませんでした。';

  @override
  String voicesSystemUpdated(String language) {
    return '端末設定から$languageの音声を更新しました。';
  }

  @override
  String get voicesNoChange => '音声の変更は検出されませんでした。';

  @override
  String get voicesSettingsRefreshed => '端末の音声設定を更新しました。';

  @override
  String get voicesSystemChanges => '端末の音声更新';

  @override
  String voicesSystemChangeEvent(String language) {
    return '端末の$language音声設定が更新されました。';
  }

  @override
  String get voicesNewlyInstalledEmpty => '新しい音声や端末の更新はここに表示されます。';

  @override
  String get voicesNewBadge => '新規';

  @override
  String get commonClear => 'クリア';

  @override
  String voiceFriendlyName(String number) {
    return '音声 $number';
  }

  @override
  String get voicesOpenManagerFailed => '音声管理を開けませんでした。システムの読み上げ設定を開いてください。';

  @override
  String get currentVoice => '現在の音声';

  @override
  String get scanDeviceVoices => '端末の音声をスキャン';

  @override
  String get availableDeviceVoices => '端末で利用できる音声';

  @override
  String get scanVoicesHint => '「端末の音声をスキャン」をタップして、インストール済みの音声を表示します。';

  @override
  String get noDeviceVoicesFound => '端末に適した音声が見つかりませんでした。';

  @override
  String get scanVoicesFailed => '音声をスキャンできませんでした。もう一度お試しください。';

  @override
  String get voiceSetupGuide => '音声の追加方法';

  @override
  String get openVoiceSettings => '音声設定を開く';

  @override
  String get androidVoiceSetupSteps =>
      '1. 端末の設定を開きます。\n2. テキスト読み上げ / Text-to-speech を探します。\n3. 使用中の TTS エンジンを開きます。\n4. 言語または音声データの画面を開きます。\n5. 新しい音声をインストールします。\n6. アプリに戻り、端末の音声をスキャンします。';

  @override
  String get iosVoiceSetupSteps =>
      '1. 設定を開きます。\n2. アクセシビリティを開きます。\n3. 読み上げコンテンツまたは声を開きます。\n4. 言語を選び、利用可能な音声をダウンロードします。\n5. アプリに戻り、再度スキャンします。\niOS のバージョンによってメニュー名は異なる場合があります。';

  @override
  String get webVoiceAvailabilityInfo => 'Web では、利用可能な音声はブラウザと OS が提供します。';

  @override
  String lastScanned(String time) {
    return '最終スキャン: $time';
  }

  @override
  String get voiceInUse => '使用中';

  @override
  String get otherLanguages => 'その他の言語';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '音声 $count',
      one: '音声 1',
      zero: '音声なし',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => '言語の音声を展開';

  @override
  String get collapseLanguageVoices => '言語の音声を折りたたむ';

  @override
  String voicePreviewNamed(String name) {
    return '$name をプレビュー';
  }

  @override
  String get settingsSoundAndVoice => '音と音声';

  @override
  String get settingsAlarmsSection => 'アラーム';

  @override
  String get supportAndFeedback => 'サポート';

  @override
  String get contactSupport => 'お問い合わせとフィードバック';

  @override
  String get supportEmailSubject => 'Smart Voice Alarm サポート';

  @override
  String get emailCopied => 'サポートメールをコピーしました';

  @override
  String get linkUnavailable => 'このリンクはまだ利用できません';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get appInformation => 'アプリ情報';

  @override
  String get appVersion => 'アプリのバージョン';

  @override
  String get permissionsAndBackground => '権限とバックグラウンド';

  @override
  String get notificationPermission => '通知';

  @override
  String get exactAlarmPermission => '正確なアラーム';

  @override
  String get fullScreenAlarmPermission => '全画面アラーム';

  @override
  String get openSystemSettings => 'システム設定を開く';

  @override
  String get openSystemSettingsHint => '通知と関連権限を管理';

  @override
  String get permissionStatusGranted => '許可済み';

  @override
  String get permissionStatusDenied => '未許可';

  @override
  String get permissionStatusUnknown => '不明';

  @override
  String trialDaysRemaining(int count) {
    return '$count 日間の試用期間が残っています';
  }

  @override
  String get trialLessThanOneDay => '試用期間は残り1日未満です';

  @override
  String get premiumUpgrade => 'Premiumにアップグレード';

  @override
  String get premiumAnnualTitle => '1年間のPremium';

  @override
  String get premiumAnnualDescription =>
      '7日間の試用後もSmart Voice Alarmの全機能を利用できます。';

  @override
  String get premiumAnnualPlan => 'Premium年間プラン';

  @override
  String get premiumAnnualAutoRenew => 'キャンセルするまで毎年自動更新されます。';

  @override
  String get premiumAnnualCancelInPlay => 'Google Playで管理またはキャンセルできます。';

  @override
  String get premiumAnnualAccess => 'サブスクリプションが有効な間は全機能を利用できます。';

  @override
  String get premiumSubscribeAnnual => 'Premiumを1年間購読';

  @override
  String get premiumDefer => '後で';

  @override
  String get premiumRestoreTransactions => '購入を復元';

  @override
  String get premiumManageSubscription => 'サブスクリプションを管理';

  @override
  String get premiumProductUnavailable => '年間サブスクリプションはまだGoogle Playで利用できません。';

  @override
  String get premiumBillingUnavailable => 'Google Play Billingを現在利用できません。';

  @override
  String get premiumPurchaseActive => 'Premiumは有効です';

  @override
  String get premiumTrialExpiredTitle => '試用期間が終了しました';

  @override
  String get premiumTrialExpiredBody =>
      '主な機能を引き続き利用するには購読してください。既存のアラームは鳴動し、無効化または削除できます。';

  @override
  String get premiumRetryVerification => '再試行';

  @override
  String get premiumViewExistingAlarms => '既存のアラームを表示';

  @override
  String get premiumClientVerificationNotice =>
      'サブスクリプション状態はこの端末でストアを通じて確認されます。';

  @override
  String get premiumUnableToVerify => 'サブスクリプション状態を確認できません。';

  @override
  String get premiumRestrictedAlarmsTitle => 'アラームへの制限付きアクセス';

  @override
  String get premiumRestrictedAlarmsBody =>
      '既存のアラームを無効化または削除できます。作成や編集には購読が必要です。';

  @override
  String get iosFullVoiceAlarmSupport => '音声アラームのフル対応';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'On iOS 26 and later, Smart Voice Alarm uses AlarmKit so voice segments and ringtones can ring with system alarm behavior.';

  @override
  String get iosLimitedSupportTitle => '古いiOSでは制限あり';

  @override
  String get iosLimitedSupportBody =>
      'On iOS 13–25, voice alarms still play through notification sounds. There is no AlarmKit full-screen experience. Silent Mode or Focus may mute or delay sound, and dismissing a notification without solving the challenge will not stop later segments.';

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
  String get solveNow => '今すぐ解く';

  @override
  String get alarmSolveToStop => '解いて停止';

  @override
  String get alarmDismissedTitle => 'アラームを解除しました';

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
  String get savedVoicesTitle => '保存した音声';

  @override
  String get savedVoicesEmpty =>
      'Saved recordings and TTS voices will appear here after you add them.';

  @override
  String get savedVoiceAdded => 'シーケンスに追加しました';

  @override
  String get iosCapabilityLearnMore => 'How alarms work on this iPhone';
}

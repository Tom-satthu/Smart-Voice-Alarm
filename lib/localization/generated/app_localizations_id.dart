// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Bangun dengan suara Anda sendiri';

  @override
  String get homeTitle => 'Alarm';

  @override
  String get homeEmptyTitle => 'Belum ada alarm';

  @override
  String get homeEmptySubtitle =>
      'Buat alarm suara pertama Anda dan bangun dengan kata-kata yang berarti.';

  @override
  String get homeCreateAlarm => 'Buat Alarm';

  @override
  String get homeEdit => 'Edit';

  @override
  String get homeDuplicate => 'Duplikat';

  @override
  String get homeDelete => 'Hapus';

  @override
  String get homeMore => 'Opsi lainnya';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarm siap',
      one: '1 alarm siap',
      zero: 'Tidak ada alarm',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Selamat pagi';

  @override
  String get homeGoodAfternoon => 'Selamat siang';

  @override
  String get homeGoodEvening => 'Selamat malam';

  @override
  String get alarmTypeVoice => 'Suara';

  @override
  String get alarmTypeRingtone => 'Nada dering';

  @override
  String get alarmTypeMixed => 'Campuran';

  @override
  String get alarmTypeLabel => 'Jenis alarm';

  @override
  String get createAlarmTitle => 'Alarm Baru';

  @override
  String get editAlarmTitle => 'Edit Alarm';

  @override
  String get alarmTime => 'Waktu';

  @override
  String get alarmHour => 'Jam';

  @override
  String get alarmMinute => 'Menit';

  @override
  String get alarmRepeat => 'Ulangi';

  @override
  String get alarmVoiceSequence => 'Urutan Suara';

  @override
  String get alarmRingtone => 'Nada dering setelah suara';

  @override
  String get alarmRepeatCount => 'Pengulangan urutan';

  @override
  String get alarmCopyFrom => 'Salin dari alarm lain';

  @override
  String get alarmSave => 'Simpan Alarm';

  @override
  String get alarmSelectSequence => 'Ketuk untuk mengedit urutan';

  @override
  String get alarmSelectRingtone => 'Pilih suara';

  @override
  String get alarmNoneSelected => 'Tidak ada yang dipilih';

  @override
  String get alarmCopied => 'Pengaturan disalin';

  @override
  String get alarmSaved => 'Alarm disimpan';

  @override
  String get alarmDeleted => 'Alarm dihapus';

  @override
  String get alarmDuplicated => 'Alarm diduplikasi';

  @override
  String get dayMon => 'Sen';

  @override
  String get dayTue => 'Sel';

  @override
  String get dayWed => 'Rab';

  @override
  String get dayThu => 'Kam';

  @override
  String get dayFri => 'Jum';

  @override
  String get daySat => 'Sab';

  @override
  String get daySun => 'Min';

  @override
  String get dayEveryDay => 'Setiap hari';

  @override
  String get dayWeekdays => 'Hari kerja';

  @override
  String get dayWeekends => 'Akhir pekan';

  @override
  String get dayOnce => 'Sekali';

  @override
  String get voiceSequenceTitle => 'Urutan Suara';

  @override
  String get voiceSequenceEmptyTitle => 'Buat pesan bangun Anda';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Tambahkan rekaman atau teks yang diucapkan sesuai urutan yang ingin Anda dengar.';

  @override
  String get voiceSequenceAdd => 'Tambah Suara';

  @override
  String get voiceSequenceDelete => 'Hapus';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Hapus segmen?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Ini menghapus segmen dari urutan.';

  @override
  String get voiceSequenceReorderHint => 'Seret untuk mengurutkan ulang';

  @override
  String get voiceSegmentName => 'Nama';

  @override
  String get voiceSegmentType => 'Jenis';

  @override
  String get voiceSegmentDuration => 'Durasi';

  @override
  String voiceSegmentOrder(int number) {
    return 'Langkah $number';
  }

  @override
  String get voiceTypeRecording => 'Rekaman';

  @override
  String get voiceTypeTts => 'Teks ke Ucapan';

  @override
  String get addVoiceTitle => 'Tambah Suara';

  @override
  String get addVoiceRecord => 'Rekam Suara';

  @override
  String get addVoiceRecordSubtitle => 'Ucapkan pesan singkat ke mikrofon Anda';

  @override
  String get addVoiceTts => 'Teks ke Ucapan';

  @override
  String get addVoiceTtsSubtitle => 'Ketik pesan dan pilih suara pengucapan';

  @override
  String get ttsTitle => 'Teks ke Ucapan';

  @override
  String get ttsInputLabel => 'Pesan';

  @override
  String get ttsInputHint => 'Ketik pesan yang ingin Anda dengar…';

  @override
  String get ttsVoices => 'Suara';

  @override
  String get ttsLanguageLabel => 'Bahasa';

  @override
  String get ttsVoiceNameLabel => 'Suara';

  @override
  String get ttsVoiceQualityLabel => 'Kualitas';

  @override
  String get ttsPreview => 'Pratinjau';

  @override
  String get ttsPreviewing => 'Memutar pratinjau…';

  @override
  String get ttsSave => 'Simpan';

  @override
  String get ttsSaved => 'Segmen suara disimpan';

  @override
  String get recordTitle => 'Rekam Suara';

  @override
  String get recordStart => 'Rekam';

  @override
  String get recordStop => 'Berhenti';

  @override
  String get recordPlay => 'Putar';

  @override
  String get recordPlaying => 'Memutar…';

  @override
  String get recordSave => 'Simpan';

  @override
  String get recordHint => 'Ketuk Rekam saat Anda siap';

  @override
  String get recordRecording => 'Merekam…';

  @override
  String get recordReady => 'Siap disimpan';

  @override
  String get recordSaved => 'Rekaman disimpan';

  @override
  String get recordDefaultName => 'Rekaman suara';

  @override
  String get recordPermissionTitle => 'Akses mikrofon';

  @override
  String get recordPermissionRationale =>
      'Aplikasi memerlukan akses mikrofon untuk merekam klip audio yang Anda gunakan sebagai alarm.';

  @override
  String get recordPermissionDenied =>
      'Akses mikrofon tidak diberikan. Perekaman belum dimulai. Anda dapat mencoba lagi.';

  @override
  String get recordPermissionPermanentlyDenied =>
      'Akses mikrofon diblokir. Buka pengaturan sistem dan izinkan sebelum merekam.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsReminder => 'Pengingat';

  @override
  String get settingsReminderSubtitle =>
      'Dapatkan pengingat lembut jika tidak ada alarm yang dijadwalkan';

  @override
  String get settingsReminderTime => 'Waktu pengingat';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get settingsAboutSubtitle => 'Info aplikasi dan dukungan';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Buka alarm tanpa batas';

  @override
  String get settingsVoices => 'Suara';

  @override
  String get settingsVoicesSubtitle => 'Suara sistem untuk teks ke ucapan';

  @override
  String get settingsVersion => 'Versi';

  @override
  String get settingsLicenses => 'Lisensi Sumber Terbuka';

  @override
  String get settingsPrivacy => 'Kebijakan Privasi';

  @override
  String get settingsTerms => 'Ketentuan Penggunaan';

  @override
  String get settingsLegalPlaceholder => 'Lihat dokumen';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Buka Alarm Tanpa Batas';

  @override
  String get premiumSubtitle =>
      'Versi gratis mencakup hingga 3 alarm. Buka alarm tanpa batas dengan pembelian seumur hidup. Tanpa langganan.';

  @override
  String get premiumPlanFree => 'Gratis';

  @override
  String get premiumPlanLifetime => 'Premium Seumur Hidup';

  @override
  String get premiumPlanLifetimePrice => 'Pembelian sekali';

  @override
  String get premiumBenefitsTitle => 'Semua di Premium';

  @override
  String get premiumBenefitUnlimited => 'Alarm tanpa batas';

  @override
  String get premiumBenefitSequences => 'Urutan suara tanpa kunci fitur';

  @override
  String get premiumBenefitVoices => 'Semua suara sistem yang terpasang';

  @override
  String get premiumBenefitThemes =>
      'Tema, pengingat, dan rekaman tetap gratis';

  @override
  String get premiumBenefitSupport => 'Dukungan prioritas';

  @override
  String get premiumBenefitNoAds => 'Tanpa iklan';

  @override
  String get premiumUnlock => 'Buka Alarm Tanpa Batas';

  @override
  String get premiumRestore => 'Pulihkan Pembelian';

  @override
  String get premiumThanks => 'Terima kasih telah mendukung Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Produk harus dikonfigurasi di App Store Connect dan Google Play Console.';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonBack => 'Kembali';

  @override
  String get commonNext => 'Berikutnya';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonEnabled => 'Aktif';

  @override
  String get commonDisabled => 'Nonaktif';

  @override
  String get commonRemove => 'Hapus';

  @override
  String get commonOpen => 'Buka';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageSpanish => 'Spanyol';

  @override
  String get languagePortuguese => 'Portugis';

  @override
  String get languageFrench => 'Prancis';

  @override
  String get languageGerman => 'Jerman';

  @override
  String get languageItalian => 'Italia';

  @override
  String get languageDutch => 'Belanda';

  @override
  String get languageJapanese => 'Jepang';

  @override
  String get languageKorean => 'Korea';

  @override
  String get languageChineseSimplified => 'Tionghoa (Sederhana)';

  @override
  String get languageChineseTraditional => 'Tionghoa (Tradisional)';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageVietnamese => 'Vietnam';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali',
      one: '1 kali',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segmen',
      one: '1 segmen',
      zero: 'Tidak ada segmen',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Lonceng Lembut';

  @override
  String get ringtoneOceanBreeze => 'Angin Laut';

  @override
  String get ringtoneNightPulse => 'Denyut Malam';

  @override
  String get ringtoneForestDawn => 'Fajar Hutan';

  @override
  String get ringtoneCrystalBell => 'Lonceng Kristal';

  @override
  String get alarmStop => 'Berhenti';

  @override
  String get alarmStopAll => 'Hentikan Semua';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarm menunggu',
      one: '1 alarm menunggu',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Suara';

  @override
  String get voicesSystemVoices => 'Suara Sistem';

  @override
  String get voicesDownloadMore => 'Unduh Lebih Banyak Suara';

  @override
  String get voicesRefresh => 'Segarkan Suara';

  @override
  String get voicesOfflineHint =>
      'Lebih baik gunakan suara offline agar alarm tetap berbicara tanpa koneksi jaringan.';

  @override
  String get voicesIosGuideTitle => 'Instal suara di iPhone';

  @override
  String get voicesIosGuideBody =>
      'Buka Pengaturan → Aksesibilitas → Konten Lisan → Suara, unduh suara yang Anda butuhkan, lalu kembali ke sini dan ketuk Segarkan Suara.';

  @override
  String get voicesAndroidGuide =>
      'Membuka penginstal data TTS sistem. Smart Voice Alarm tidak mengunduh atau menghosting paket suara.';

  @override
  String get voicesWebUnavailable =>
      'Browser mengelola suaranya sendiri. Paket unduhan tidak tersedia di web.';

  @override
  String get voicesEmpty => 'Belum ada suara yang dapat digunakan';

  @override
  String get voicesEmptyCta => 'Unduh Lebih Banyak Suara';

  @override
  String get voiceQualityDefault => 'Default';

  @override
  String get voiceQualityEnhanced => 'Ditingkatkan';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Offline';

  @override
  String get voiceAvailabilityNetwork => 'Perlu jaringan';

  @override
  String get voiceAvailabilityMissing => 'Belum diinstal';

  @override
  String get ttsNoVoicesTitle => 'Tidak ada suara yang dapat digunakan';

  @override
  String get ttsNoVoicesBody => 'Unduh suara sistem, lalu segarkan daftar.';

  @override
  String get ttsOpenVoiceSettings => 'Unduh Lebih Banyak Suara';

  @override
  String get ttsVoiceFallback =>
      'Suara yang dipilih tidak tersedia. Menggunakan suara default sebagai gantinya.';

  @override
  String get reminderNotificationTitle => 'Atur alarm untuk besok';

  @override
  String get reminderNotificationBody =>
      'Luangkan waktu sebentar untuk menjadwalkan Smart Voice Alarm Anda untuk besok.';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String get aboutAppName => 'Nama Aplikasi';

  @override
  String get aboutVersion => 'Versi';

  @override
  String get aboutDeveloper => 'Pengembang';

  @override
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'Dukungan Email';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Situs Web';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'Segera hadir';

  @override
  String get voiceSystemDefault => 'Default sistem';

  @override
  String get voiceSystemDefaultHint => 'Dikelola di pengaturan perangkat';

  @override
  String get notificationChannelAlarms => 'Alarm';

  @override
  String get notificationChannelAlarmsDesc => 'Peringatan alarm suara';

  @override
  String get notificationChannelReminders => 'Pengingat';

  @override
  String get notificationChannelRemindersDesc =>
      'Pengingat harian untuk mengatur alarm besok';

  @override
  String get alarmDefaultLabel => 'Alarm';

  @override
  String get premiumBenefitLifetimeBuy => 'Beli sekali. Milik Anda selamanya.';

  @override
  String get premiumStatusLoading => 'Memeriksa toko…';

  @override
  String get premiumStatusPurchasing => 'Memulai pembelian…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime terbuka';

  @override
  String get premiumStatusRestored => 'Pembelian dipulihkan';

  @override
  String get premiumStatusCancelled => 'Pembelian dibatalkan';

  @override
  String get premiumStatusPending => 'Pembelian tertunda…';

  @override
  String get premiumStatusError => 'Pembelian gagal. Coba lagi.';

  @override
  String get premiumWebUnavailable =>
      'Pembelian dalam aplikasi tidak tersedia di demo web.';

  @override
  String get premiumStoreUnavailable => 'Toko tidak tersedia di perangkat ini.';

  @override
  String get premiumLimitExplainFree => 'Versi gratis mencakup hingga 3 alarm.';

  @override
  String get premiumLimitExplainUnlock =>
      'Buka alarm tanpa batas dengan pembelian seumur hidup.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Hingga $count alarm';
  }

  @override
  String get voicesSearchHint => 'Cari bahasa atau suara';

  @override
  String get voicesLanguages => 'Bahasa';

  @override
  String get voicesSelectVoiceHint => 'Pilih suara untuk bahasa ini';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suara',
      one: '1 suara',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Ketuk untuk memilih waktu';

  @override
  String get segmentPlay => 'Putar';

  @override
  String get voicePlaying => 'Memutar';

  @override
  String get voiceSelect => 'Pilih';

  @override
  String get voiceUnavailable => 'Suara tidak tersedia';

  @override
  String get recordingFileMissing =>
      'File rekaman hilang. Hapus segmen ini atau rekam ulang.';

  @override
  String get voiceDetails => 'Detail suara';

  @override
  String get ttsSelectedVoice => 'Suara terpilih';

  @override
  String get voicePreviewSample => 'Ini adalah pratinjau singkat suara ini.';

  @override
  String get alarmDismissTitle => 'Selesaikan untuk berhenti';

  @override
  String get alarmDismissHint => 'Jawab dengan benar untuk mematikan alarm.';

  @override
  String get alarmDismissWrong => 'Salah. Soal baru.';

  @override
  String get alarmDismissCheck => 'Periksa';

  @override
  String get alarmDismissAnswerHint => 'Jawaban Anda';

  @override
  String voicesRefreshed(int count) {
    return 'Diperbarui: $count suara ditemukan';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Suara disimpan: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Buka pengelola suara perangkat. Setelah unduh selesai, kembali ke sini.';

  @override
  String get voicesRefreshHint =>
      'Segarkan suara memuat ulang suara TTS sistem setelah memasang paket.';

  @override
  String get ringtonePreview => 'Pratinjau';

  @override
  String get ringtonePreviewHint =>
      'Ketuk putar untuk mendengar, lalu ketuk nama untuk memilih.';

  @override
  String get voicesCurrentVoice => 'Suara yang digunakan';

  @override
  String get voicesNewlyInstalled => 'Suara baru dipasang';

  @override
  String get voicesOnDevice => 'Suara di perangkat ini';

  @override
  String get voicesDownloadHint =>
      'Buka pengelola suara perangkat. Setelah unduh selesai, kembali ke sini.';

  @override
  String get voicesRescan => 'Pindai ulang suara';

  @override
  String voicesRescanResult(int count) {
    return 'Ditemukan $count suara yang dapat digunakan';
  }

  @override
  String voicesNewFound(int count) {
    return 'Ditemukan $count suara baru.';
  }

  @override
  String get voicesNoNewFound => 'Tidak ada suara baru terdeteksi.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Suara $language diperbarui dari pengaturan perangkat.';
  }

  @override
  String get voicesNoChange => 'Tidak ada perubahan suara terdeteksi.';

  @override
  String get voicesSettingsRefreshed =>
      'Pengaturan suara perangkat telah diperbarui.';

  @override
  String get voicesSystemChanges => 'Pembaruan suara perangkat';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Pengaturan suara $language di perangkat baru saja diperbarui.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Suara baru dan pembaruan perangkat akan muncul di sini.';

  @override
  String get voicesNewBadge => 'Baru';

  @override
  String get commonClear => 'Hapus';

  @override
  String voiceFriendlyName(String number) {
    return 'Suara $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Tidak dapat membuka pengelola suara. Buka pengaturan TTS sistem.';

  @override
  String get currentVoice => 'Suara yang digunakan';

  @override
  String get scanDeviceVoices => 'Pindai suara di perangkat';

  @override
  String get availableDeviceVoices => 'Suara tersedia di perangkat';

  @override
  String get scanVoicesHint =>
      'Ketuk Pindai suara di perangkat untuk melihat suara yang terpasang.';

  @override
  String get noDeviceVoicesFound =>
      'Tidak ditemukan suara yang cocok di perangkat.';

  @override
  String get scanVoicesFailed => 'Gagal memindai suara. Coba lagi.';

  @override
  String get voiceSetupGuide => 'Cara menambah suara';

  @override
  String get openVoiceSettings => 'Buka pengaturan suara';

  @override
  String get androidVoiceSetupSteps =>
      '1. Buka Pengaturan perangkat.\n2. Cari Text-to-speech.\n3. Buka mesin TTS yang digunakan.\n4. Buka bahasa atau data suara.\n5. Pasang suara baru.\n6. Kembali ke sini dan ketuk Pindai suara.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Buka Pengaturan.\n2. Buka Aksesibilitas.\n3. Buka Konten ucapan atau Suara.\n4. Pilih bahasa dan unduh suara.\n5. Kembali ke sini dan pindai lagi.\nNama menu dapat berbeda antar versi iOS.';

  @override
  String get webVoiceAvailabilityInfo =>
      'Di Web, daftar suara disediakan oleh browser dan sistem operasi.';

  @override
  String lastScanned(String time) {
    return 'Terakhir dipindai: $time';
  }

  @override
  String get voiceInUse => 'Sedang digunakan';

  @override
  String get otherLanguages => 'Bahasa lain';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suara',
      one: '1 suara',
      zero: 'Tidak ada suara',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Perluas suara bahasa';

  @override
  String get collapseLanguageVoices => 'Ciutkan suara bahasa';

  @override
  String voicePreviewNamed(String name) {
    return 'Pratinjau $name';
  }

  @override
  String get settingsSoundAndVoice => 'Suara dan suara bicara';

  @override
  String get settingsAlarmsSection => 'Alarm';

  @override
  String get supportAndFeedback => 'Dukungan';

  @override
  String get contactSupport => 'Kontak dan masukan';

  @override
  String get supportEmailSubject => 'Dukungan Smart Voice Alarm';

  @override
  String get emailCopied => 'Email dukungan disalin';

  @override
  String get linkUnavailable => 'Tautan ini belum tersedia';

  @override
  String get openSourceLicenses => 'Lisensi sumber terbuka';

  @override
  String get appInformation => 'Tentang aplikasi';

  @override
  String get appVersion => 'Versi aplikasi';

  @override
  String get permissionsAndBackground => 'Izin dan latar belakang';

  @override
  String get notificationPermission => 'Notifikasi';

  @override
  String get exactAlarmPermission => 'Alarm tepat waktu';

  @override
  String get fullScreenAlarmPermission => 'Alarm layar penuh';

  @override
  String get openSystemSettings => 'Buka pengaturan sistem';

  @override
  String get openSystemSettingsHint => 'Kelola notifikasi dan izin terkait';

  @override
  String get permissionStatusGranted => 'Diberikan';

  @override
  String get permissionStatusDenied => 'Tidak diberikan';

  @override
  String get permissionStatusUnknown => 'Tidak diketahui';

  @override
  String trialDaysRemaining(int count) {
    return '$count hari masa uji coba tersisa';
  }

  @override
  String get trialLessThanOneDay => 'Masa uji coba tersisa kurang dari 1 hari';

  @override
  String get premiumUpgrade => 'Tingkatkan ke Premium';

  @override
  String get premiumAnnualTitle => 'Premium selama satu tahun';

  @override
  String get premiumAnnualDescription =>
      'Terus gunakan semua fitur Smart Voice Alarm setelah uji coba 7 hari.';

  @override
  String get premiumAnnualPlan => 'Paket Premium tahunan';

  @override
  String get premiumAnnualAutoRenew =>
      'Diperpanjang otomatis setiap tahun hingga dibatalkan.';

  @override
  String get premiumAnnualCancelInPlay =>
      'Kelola atau batalkan melalui Google Play.';

  @override
  String get premiumAnnualAccess =>
      'Akses penuh berlanjut selama langganan aktif.';

  @override
  String get premiumSubscribeAnnual => 'Berlangganan Premium satu tahun';

  @override
  String get premiumDefer => 'Nanti saja';

  @override
  String get premiumRestoreTransactions => 'Pulihkan transaksi';

  @override
  String get premiumManageSubscription => 'Kelola langganan';

  @override
  String get premiumProductUnavailable =>
      'Langganan tahunan belum tersedia di Google Play.';

  @override
  String get premiumBillingUnavailable =>
      'Google Play Billing sedang tidak tersedia.';

  @override
  String get premiumPurchaseActive => 'Premium aktif';

  @override
  String get premiumTrialExpiredTitle => 'Masa uji coba telah berakhir';

  @override
  String get premiumTrialExpiredBody =>
      'Berlangganan untuk terus memakai fitur utama. Alarm yang ada tetap dapat berbunyi dan dapat dinonaktifkan atau dihapus.';

  @override
  String get premiumRetryVerification => 'Coba lagi';

  @override
  String get premiumViewExistingAlarms => 'Lihat alarm yang ada';

  @override
  String get premiumClientVerificationNotice =>
      'Status langganan diverifikasi di perangkat ini melalui toko aplikasi.';

  @override
  String get premiumUnableToVerify =>
      'Tidak dapat memverifikasi status langganan.';

  @override
  String get premiumRestrictedAlarmsTitle => 'Akses alarm terbatas';

  @override
  String get premiumRestrictedAlarmsBody =>
      'Anda dapat menonaktifkan atau menghapus alarm yang ada. Berlangganan untuk membuat atau mengedit alarm.';

  @override
  String get iosFullVoiceAlarmSupport => 'Dukungan penuh alarm suara';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'On iOS 26 and later, Smart Voice Alarm uses AlarmKit so voice segments and ringtones can ring with system alarm behavior.';

  @override
  String get iosLimitedSupportTitle => 'Dukungan terbatas di iOS lama';

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
  String get solveNow => 'Selesaikan sekarang';

  @override
  String get alarmSolveToStop => 'Selesaikan untuk berhenti';

  @override
  String get alarmDismissedTitle => 'Alarm dihentikan';

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
  String get savedVoicesTitle => 'Suara tersimpan';

  @override
  String get savedVoicesEmpty =>
      'Saved recordings and TTS voices will appear here after you add them.';

  @override
  String get savedVoiceAdded => 'Suara ditambahkan ke urutan';

  @override
  String get iosCapabilityLearnMore => 'How alarms work on this iPhone';

  @override
  String get alarmAudioNeedsRegeneration =>
      'Audio alarm suara perlu dibuat ulang.';

  @override
  String get iosAlarmLoudnessHint =>
      'Kenyaringan alarm juga bergantung pada Pengaturan → Suara & Haptik → Nada Dering dan Peringatan.';

  @override
  String get addSavedVoiceToSequence => 'Tambahkan ke urutan';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Acorde com a sua própria voz';

  @override
  String get homeTitle => 'Alarmes';

  @override
  String get homeEmptyTitle => 'Ainda não há alarmes';

  @override
  String get homeEmptySubtitle =>
      'Crie o seu primeiro alarme de voz e acorde com as palavras que importam.';

  @override
  String get homeCreateAlarm => 'Criar alarme';

  @override
  String get homeEdit => 'Editar';

  @override
  String get homeDuplicate => 'Duplicar';

  @override
  String get homeDelete => 'Eliminar';

  @override
  String get homeMore => 'Mais opções';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmes prontos',
      one: '1 alarme pronto',
      zero: 'Sem alarmes',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Bom dia';

  @override
  String get homeGoodAfternoon => 'Boa tarde';

  @override
  String get homeGoodEvening => 'Boa noite';

  @override
  String get alarmTypeVoice => 'Voz';

  @override
  String get alarmTypeRingtone => 'Toque';

  @override
  String get alarmTypeMixed => 'Misto';

  @override
  String get alarmTypeLabel => 'Tipo de alarme';

  @override
  String get createAlarmTitle => 'Novo alarme';

  @override
  String get editAlarmTitle => 'Editar alarme';

  @override
  String get alarmTime => 'Hora';

  @override
  String get alarmHour => 'Hora';

  @override
  String get alarmMinute => 'Minuto';

  @override
  String get alarmRepeat => 'Repetir';

  @override
  String get alarmVoiceSequence => 'Sequência de voz';

  @override
  String get alarmRingtone => 'Toque após a voz';

  @override
  String get alarmRepeatCount => 'Repetições da sequência';

  @override
  String get alarmCopyFrom => 'Copiar de outro alarme';

  @override
  String get alarmSave => 'Guardar alarme';

  @override
  String get alarmSelectSequence => 'Toque para editar a sequência';

  @override
  String get alarmSelectRingtone => 'Escolha um som';

  @override
  String get alarmNoneSelected => 'Nenhum selecionado';

  @override
  String get alarmCopied => 'Definições copiadas';

  @override
  String get alarmSaved => 'Alarme guardado';

  @override
  String get alarmDeleted => 'Alarme eliminado';

  @override
  String get alarmDuplicated => 'Alarme duplicado';

  @override
  String get dayMon => 'Seg';

  @override
  String get dayTue => 'Ter';

  @override
  String get dayWed => 'Qua';

  @override
  String get dayThu => 'Qui';

  @override
  String get dayFri => 'Sex';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get dayEveryDay => 'Todos os dias';

  @override
  String get dayWeekdays => 'Dias úteis';

  @override
  String get dayWeekends => 'Fins de semana';

  @override
  String get dayOnce => 'Uma vez';

  @override
  String get voiceSequenceTitle => 'Sequência de voz';

  @override
  String get voiceSequenceEmptyTitle => 'Crie a sua mensagem de despertar';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Adicione gravações ou texto falado na ordem em que quer ouvi-los.';

  @override
  String get voiceSequenceAdd => 'Adicionar voz';

  @override
  String get voiceSequenceDelete => 'Eliminar';

  @override
  String get voiceSequenceDeleteConfirmTitle => 'Remover segmento?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Isto remove o segmento da sequência.';

  @override
  String get voiceSequenceReorderHint => 'Arraste para reordenar';

  @override
  String get voiceSegmentName => 'Nome';

  @override
  String get voiceSegmentType => 'Tipo';

  @override
  String get voiceSegmentDuration => 'Duração';

  @override
  String voiceSegmentOrder(int number) {
    return 'Passo $number';
  }

  @override
  String get voiceTypeRecording => 'Gravação';

  @override
  String get voiceTypeTts => 'Texto para fala';

  @override
  String get addVoiceTitle => 'Adicionar voz';

  @override
  String get addVoiceRecord => 'Gravar voz';

  @override
  String get addVoiceRecordSubtitle => 'Fale uma mensagem curta no microfone';

  @override
  String get addVoiceTts => 'Texto para fala';

  @override
  String get addVoiceTtsSubtitle => 'Escreva uma mensagem e escolha uma voz';

  @override
  String get ttsTitle => 'Texto para fala';

  @override
  String get ttsInputLabel => 'Mensagem';

  @override
  String get ttsInputHint => 'Escreva a mensagem que quer ouvir…';

  @override
  String get ttsVoices => 'Vozes';

  @override
  String get ttsLanguageLabel => 'Idioma';

  @override
  String get ttsVoiceNameLabel => 'Voz';

  @override
  String get ttsVoiceQualityLabel => 'Qualidade';

  @override
  String get ttsPreview => 'Pré-visualizar';

  @override
  String get ttsPreviewing => 'A reproduzir pré-visualização…';

  @override
  String get ttsSave => 'Guardar';

  @override
  String get ttsSaved => 'Segmento de voz guardado';

  @override
  String ttsCharCounter(int used, int max) {
    return '$used/$max characters';
  }

  @override
  String get ttsCharLimitReached =>
      'Character limit reached for this language.';

  @override
  String get ttsPasteTooLongTitle => 'Paste exceeds limit';

  @override
  String ttsPasteTooLongBody(int max) {
    return 'The paste is longer than $max characters. Insert only the first $max characters?';
  }

  @override
  String get ttsPasteInsertPartial => 'Insert partial';

  @override
  String get ttsTooLongDuration =>
      'Spoken audio is longer than 20 seconds. Shorten the text and try again.';

  @override
  String get ttsDurationChecking => 'Checking spoken length…';

  @override
  String get recordTitle => 'Gravar voz';

  @override
  String recordTimerLabel(int used, int max) {
    return '$used/$max seconds';
  }

  @override
  String get recordAutoStopped => 'Recording stopped at 20 seconds.';

  @override
  String get recordLongClipWarning =>
      'This recording is longer than 20 seconds. Alarms will use only the first 20 seconds.';

  @override
  String get recordStart => 'Gravar';

  @override
  String get recordStop => 'Parar';

  @override
  String get recordPlay => 'Reproduzir';

  @override
  String get recordPlaying => 'A reproduzir…';

  @override
  String get recordSave => 'Guardar';

  @override
  String get recordHint => 'Toque em Gravar quando estiver pronto';

  @override
  String get recordRecording => 'A gravar…';

  @override
  String get recordReady => 'Pronto para guardar';

  @override
  String get recordSaved => 'Gravação guardada';

  @override
  String get recordDefaultName => 'Gravação de voz';

  @override
  String get recordPermissionTitle => 'Acesso ao microfone';

  @override
  String get recordPermissionRationale =>
      'A aplicação precisa de acesso ao microfone para gravar o áudio que utiliza como alarme.';

  @override
  String get recordPermissionDenied =>
      'O acesso ao microfone não foi concedido. A gravação não começou. Pode tentar novamente.';

  @override
  String get recordPermissionPermanentlyDenied =>
      'O acesso ao microfone está bloqueado. Abra as definições do sistema e permita-o antes de gravar.';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsReminder => 'Lembrete';

  @override
  String get settingsReminderSubtitle =>
      'Receba um aviso suave se não houver nenhum alarme agendado';

  @override
  String get settingsReminderTime => 'Hora do lembrete';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutSubtitle => 'Informações da app e suporte';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Desbloqueie alarmes ilimitados';

  @override
  String get settingsVoices => 'Vozes';

  @override
  String get settingsVoicesSubtitle => 'Vozes do sistema para texto para fala';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsLicenses => 'Licenças de código aberto';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsTerms => 'Termos de utilização';

  @override
  String get settingsLegalPlaceholder => 'Ver documento';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Desbloquear alarmes ilimitados';

  @override
  String get premiumSubtitle =>
      'A versão gratuita inclui até 3 alarmes. Desbloqueie alarmes ilimitados com uma compra vitalícia. Sem assinaturas.';

  @override
  String get premiumPlanFree => 'Grátis';

  @override
  String get premiumPlanLifetime => 'Premium vitalício';

  @override
  String get premiumPlanLifetimePrice => 'Compra única';

  @override
  String get premiumBenefitsTitle => 'Tudo no Premium';

  @override
  String get premiumBenefitUnlimited => 'Alarmes ilimitados';

  @override
  String get premiumBenefitSequences => 'Sequências de voz sem bloqueios';

  @override
  String get premiumBenefitVoices => 'Todas as vozes do sistema instaladas';

  @override
  String get premiumBenefitThemes =>
      'Temas, lembretes e gravação continuam grátis';

  @override
  String get premiumBenefitSupport => 'Suporte prioritário';

  @override
  String get premiumBenefitNoAds => 'Sem anúncios';

  @override
  String get premiumUnlock => 'Desbloquear alarmes ilimitados';

  @override
  String get premiumRestore => 'Restaurar compra';

  @override
  String get premiumThanks => 'Obrigado por apoiar o Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Os produtos devem ser configurados no App Store Connect e no Google Play Console.';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonNext => 'Seguinte';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonEnabled => 'Ligado';

  @override
  String get commonDisabled => 'Desligado';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonOpen => 'Abrir';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageDutch => 'Neerlandês';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageChineseSimplified => 'Chinês (simplificado)';

  @override
  String get languageChineseTraditional => 'Chinês (tradicional)';

  @override
  String get languageIndonesian => 'Indonésio';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes',
      one: '1 vez',
    );
    return '$_temp0';
  }

  @override
  String segmentsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segmentos',
      one: '1 segmento',
      zero: 'Sem segmentos',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Carrilhão suave';

  @override
  String get ringtoneOceanBreeze => 'Brisa oceânica';

  @override
  String get ringtoneNightPulse => 'Pulso noturno';

  @override
  String get ringtoneForestDawn => 'Amanhecer na floresta';

  @override
  String get ringtoneCrystalBell => 'Sino de cristal';

  @override
  String get alarmStop => 'Parar';

  @override
  String get alarmStopAll => 'Parar tudo';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmes à espera',
      one: '1 alarme à espera',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Vozes';

  @override
  String get voicesSystemVoices => 'Vozes do sistema';

  @override
  String get voicesDownloadMore => 'Descarregar mais vozes';

  @override
  String get voicesRefresh => 'Atualizar vozes';

  @override
  String get voicesOfflineHint =>
      'Prefira vozes offline para que os alarmes falem mesmo sem ligação à rede.';

  @override
  String get voicesIosGuideTitle => 'Instalar vozes no iPhone';

  @override
  String get voicesIosGuideBody =>
      'Abra Definições → Acessibilidade → Conteúdo falado → Vozes, descarregue as vozes de que precisa, volte aqui e toque em Atualizar vozes.';

  @override
  String get voicesAndroidGuide =>
      'Abre o instalador de dados TTS do sistema. O Smart Voice Alarm não descarrega nem aloja pacotes de voz.';

  @override
  String get voicesWebUnavailable =>
      'Os browsers gerem as suas próprias vozes. Os pacotes de descarga não estão disponíveis na web.';

  @override
  String get voicesEmpty => 'Ainda não foram encontradas vozes utilizáveis';

  @override
  String get voicesEmptyCta => 'Descarregar mais vozes';

  @override
  String get voiceQualityDefault => 'Predefinida';

  @override
  String get voiceQualityEnhanced => 'Melhorada';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Offline';

  @override
  String get voiceAvailabilityNetwork => 'Requer rede';

  @override
  String get voiceAvailabilityMissing => 'Não instalada';

  @override
  String get ttsNoVoicesTitle => 'Sem vozes utilizáveis';

  @override
  String get ttsNoVoicesBody =>
      'Descarregue vozes do sistema e depois atualize a lista.';

  @override
  String get ttsOpenVoiceSettings => 'Descarregar mais vozes';

  @override
  String get ttsVoiceFallback =>
      'A voz selecionada não está disponível. A usar uma voz predefinida.';

  @override
  String get reminderNotificationTitle => 'Defina o alarme de amanhã';

  @override
  String get reminderNotificationBody =>
      'Reserve um momento para agendar o seu Smart Voice Alarm para amanhã.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutAppName => 'Nome da app';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutDeveloper => 'Programador';

  @override
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'Suporte por e-mail';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'Em breve';

  @override
  String get voiceSystemDefault => 'Padrão do sistema';

  @override
  String get voiceSystemDefaultHint =>
      'Gerenciada nas configurações do dispositivo';

  @override
  String get notificationChannelAlarms => 'Alarmes';

  @override
  String get notificationChannelAlarmsDesc => 'Alertas de alarme de voz';

  @override
  String get notificationChannelReminders => 'Lembretes';

  @override
  String get notificationChannelRemindersDesc =>
      'Lembrete diário para definir o alarme de amanhã';

  @override
  String get alarmDefaultLabel => 'Alarme';

  @override
  String get premiumBenefitLifetimeBuy => 'Compre uma vez. Seu para sempre.';

  @override
  String get premiumStatusLoading => 'A verificar a loja…';

  @override
  String get premiumStatusPurchasing => 'A iniciar compra…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime desbloqueado';

  @override
  String get premiumStatusRestored => 'Compra restaurada';

  @override
  String get premiumStatusCancelled => 'Compra cancelada';

  @override
  String get premiumStatusPending => 'Compra pendente…';

  @override
  String get premiumStatusError => 'A compra falhou. Tente novamente.';

  @override
  String get premiumWebUnavailable =>
      'Compras não estão disponíveis na demo web.';

  @override
  String get premiumStoreUnavailable =>
      'A loja não está disponível neste dispositivo.';

  @override
  String get premiumLimitExplainFree =>
      'A versão gratuita inclui até 3 alarmes.';

  @override
  String get premiumLimitExplainUnlock =>
      'Desbloqueie alarmes ilimitados com uma compra vitalícia.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Até $count alarmes';
  }

  @override
  String get voicesSearchHint => 'Pesquisar idiomas ou vozes';

  @override
  String get voicesLanguages => 'Idiomas';

  @override
  String get voicesSelectVoiceHint => 'Escolha uma voz para este idioma';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vozes',
      one: '1 voz',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Toque para escolher a hora';

  @override
  String get segmentPlay => 'Reproduzir';

  @override
  String get voicePlaying => 'A reproduzir';

  @override
  String get voiceSelect => 'Selecionar';

  @override
  String get voiceUnavailable => 'Voz indisponível';

  @override
  String get recordingFileMissing =>
      'Ficheiro de gravação em falta. Elimine este segmento ou grave novamente.';

  @override
  String get voiceDetails => 'Detalhes da voz';

  @override
  String get ttsSelectedVoice => 'Voz selecionada';

  @override
  String get voicePreviewSample =>
      'Esta é uma pré-visualização curta desta voz.';

  @override
  String get alarmDismissTitle => 'Resolva para parar';

  @override
  String get alarmDismissHint =>
      'Responda corretamente para desligar o alarme.';

  @override
  String get alarmDismissWrong => 'Incorreto. Nova pergunta.';

  @override
  String get alarmDismissCheck => 'Verificar';

  @override
  String get alarmDismissAnswerHint => 'A sua resposta';

  @override
  String voicesRefreshed(int count) {
    return 'Atualizado: $count vozes encontradas';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Voz guardada: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Abra o gestor de vozes do dispositivo. Depois de transferir, volte aqui.';

  @override
  String get voicesRefreshHint =>
      'Atualizar vozes recarrega as vozes TTS do sistema apos instalar.';

  @override
  String get ringtonePreview => 'Pre-visualizar';

  @override
  String get ringtonePreviewHint =>
      'Toque em reproduzir para ouvir e no nome para selecionar.';

  @override
  String get voicesCurrentVoice => 'Voz atual';

  @override
  String get voicesNewlyInstalled => 'Vozes recém-instaladas';

  @override
  String get voicesOnDevice => 'Vozes neste dispositivo';

  @override
  String get voicesDownloadHint =>
      'Abra o gestor de vozes do dispositivo. Depois de transferir, volte aqui.';

  @override
  String get voicesRescan => 'Verificar vozes novamente';

  @override
  String voicesRescanResult(int count) {
    return 'Encontradas $count vozes utilizáveis';
  }

  @override
  String voicesNewFound(int count) {
    return 'Encontradas $count vozes novas.';
  }

  @override
  String get voicesNoNewFound => 'Nenhuma voz nova detetada.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Voz de $language atualizada nas definições do dispositivo.';
  }

  @override
  String get voicesNoChange => 'Nenhuma alteração de voz detetada.';

  @override
  String get voicesSettingsRefreshed =>
      'Definições de voz do dispositivo foram atualizadas.';

  @override
  String get voicesSystemChanges => 'Atualizações de voz do dispositivo';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'As definições de voz de $language no dispositivo foram atualizadas.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Novas vozes e atualizações do dispositivo aparecerão aqui.';

  @override
  String get voicesNewBadge => 'Nova';

  @override
  String get commonClear => 'Limpar';

  @override
  String voiceFriendlyName(String number) {
    return 'Voz $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'Não foi possível abrir o gestor de vozes. Abra as definições de TTS do sistema.';

  @override
  String get currentVoice => 'Voz atual';

  @override
  String get scanDeviceVoices => 'Procurar vozes no dispositivo';

  @override
  String get availableDeviceVoices => 'Vozes disponíveis no dispositivo';

  @override
  String get scanVoicesHint =>
      'Toque em Procurar vozes no dispositivo para listar as vozes instaladas.';

  @override
  String get noDeviceVoicesFound =>
      'Não foram encontradas vozes adequadas no dispositivo.';

  @override
  String get scanVoicesFailed =>
      'Não foi possível procurar vozes. Tente novamente.';

  @override
  String get voiceSetupGuide => 'Como adicionar vozes';

  @override
  String get openVoiceSettings => 'Abrir definições de voz';

  @override
  String get androidVoiceSetupSteps =>
      '1. Abra as Definições do dispositivo.\n2. Procure Texto para fala ou Text-to-speech.\n3. Abra o motor TTS em uso.\n4. Abra idiomas ou dados de voz.\n5. Instale uma nova voz.\n6. Volte aqui e toque em Procurar vozes.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Abra Definições.\n2. Abra Acessibilidade.\n3. Abra Conteúdo falado ou Vozes.\n4. Escolha um idioma e descarregue uma voz.\n5. Volte aqui e procure novamente.\nOs nomes dos menus podem variar conforme o iOS.';

  @override
  String get webVoiceAvailabilityInfo =>
      'Na Web, as vozes disponíveis vêm do navegador e do sistema operativo.';

  @override
  String lastScanned(String time) {
    return 'Última pesquisa: $time';
  }

  @override
  String get voiceInUse => 'Em uso';

  @override
  String get otherLanguages => 'Outros idiomas';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vozes',
      one: '1 voz',
      zero: 'Sem vozes',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Expandir vozes do idioma';

  @override
  String get collapseLanguageVoices => 'Recolher vozes do idioma';

  @override
  String voicePreviewNamed(String name) {
    return 'Pré-visualizar $name';
  }

  @override
  String get settingsSoundAndVoice => 'Som e voz';

  @override
  String get settingsAlarmsSection => 'Alarmes';

  @override
  String get supportAndFeedback => 'Suporte';

  @override
  String get contactSupport => 'Contacto e feedback';

  @override
  String get supportEmailSubject => 'Suporte Smart Voice Alarm';

  @override
  String get emailCopied => 'E-mail de suporte copiado';

  @override
  String get linkUnavailable => 'Esta ligação ainda não está disponível';

  @override
  String get openSourceLicenses => 'Licenças de código aberto';

  @override
  String get appInformation => 'Sobre a aplicação';

  @override
  String get appVersion => 'Versão da aplicação';

  @override
  String get permissionsAndBackground => 'Permissões e segundo plano';

  @override
  String get notificationPermission => 'Notificações';

  @override
  String get exactAlarmPermission => 'Alarmes exactos';

  @override
  String get fullScreenAlarmPermission => 'Alarmes em ecrã inteiro';

  @override
  String get openSystemSettings => 'Abrir definições do sistema';

  @override
  String get openSystemSettingsHint =>
      'Gerir notificações e permissões relacionadas';

  @override
  String get permissionStatusGranted => 'Concedida';

  @override
  String get permissionStatusDenied => 'Não concedida';

  @override
  String get permissionStatusUnknown => 'Desconhecido';

  @override
  String trialDaysRemaining(int count) {
    return '$count dias de teste restantes';
  }

  @override
  String get trialLessThanOneDay => 'Resta menos de 1 dia de teste';

  @override
  String get premiumUpgrade => 'Atualizar para Premium';

  @override
  String get premiumAnnualTitle => 'Premium por um ano';

  @override
  String get premiumAnnualDescription =>
      'Continue a usar todas as funcionalidades do Smart Voice Alarm após o teste de 7 dias.';

  @override
  String get premiumAnnualPlan => 'Plano Premium anual';

  @override
  String get premiumAnnualAutoRenew =>
      'Renova automaticamente todos os anos até ser cancelado.';

  @override
  String get premiumAnnualCancelInPlay =>
      'Faça a gestão ou cancele no Google Play.';

  @override
  String get premiumAnnualAccess =>
      'O acesso total continua enquanto a subscrição estiver ativa.';

  @override
  String get premiumSubscribeAnnual => 'Subscrever Premium por um ano';

  @override
  String get premiumDefer => 'Mais tarde';

  @override
  String get premiumRestoreTransactions => 'Restaurar transações';

  @override
  String get premiumManageSubscription => 'Gerir subscrição';

  @override
  String get premiumProductUnavailable =>
      'A subscrição anual ainda não está disponível no Google Play.';

  @override
  String get premiumBillingUnavailable =>
      'O Google Play Billing está indisponível.';

  @override
  String get premiumPurchaseActive => 'Premium está ativo';

  @override
  String get premiumTrialExpiredTitle => 'O período de teste terminou';

  @override
  String get premiumTrialExpiredBody =>
      'Subscreva para continuar a usar as funcionalidades principais. Os alarmes existentes continuam a tocar e podem ser desativados ou eliminados.';

  @override
  String get premiumRetryVerification => 'Tentar novamente';

  @override
  String get premiumViewExistingAlarms => 'Ver alarmes existentes';

  @override
  String get premiumClientVerificationNotice =>
      'O estado da subscrição é verificado neste dispositivo através da loja.';

  @override
  String get premiumUnableToVerify =>
      'Não foi possível verificar a subscrição.';

  @override
  String get premiumRestrictedAlarmsTitle => 'Acesso limitado aos alarmes';

  @override
  String get premiumRestrictedAlarmsBody =>
      'Pode desativar ou eliminar alarmes existentes. Subscreva para criar ou editar alarmes.';

  @override
  String get iosFullVoiceAlarmSupport => 'Suporte completo a alarmes de voz';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'On iOS 26 and later, Smart Voice Alarm uses AlarmKit so voice segments and ringtones can ring with system alarm behavior.';

  @override
  String get iosLimitedSupportTitle => 'Suporte limitado em iOS mais antigos';

  @override
  String get iosLimitedSupportBody =>
      'Alarmes de voz usam notificações locais (AlarmKit ainda não está ativo). Abra a notificação ou escolha Solve to stop para iniciar o desafio. Deslizar sem abrir não para segmentos posteriores.';

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
  String get solveNow => 'Resolver agora';

  @override
  String get alarmSolveToStop => 'Resolva para parar';

  @override
  String get alarmDismissedTitle => 'Alarme dispensado';

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
  String get ringtoneFallbackSystemWarning =>
      'Custom ringtone could not be prepared. The system alarm sound will be used.';

  @override
  String get iosAlarmDiagnosticsTitle => 'Run iOS alarm diagnostics';

  @override
  String get iosAlarmDiagnosticsRunning => 'Running diagnostics…';

  @override
  String get iosAlarmDiagnosticsDone =>
      'Diagnostics finished. Report copied when available.';

  @override
  String get iosAlarmDiagnosticsCopy => 'Copy report';

  @override
  String get savedVoicesTitle => 'Vozes salvas';

  @override
  String get savedVoicesEmpty =>
      'Saved recordings and TTS voices will appear here after you add them.';

  @override
  String get savedVoiceAdded => 'Voz adicionada à sequência';

  @override
  String get iosCapabilityLearnMore => 'How alarms work on this iPhone';

  @override
  String get alarmAudioNeedsRegeneration =>
      'O áudio do alarme de voz precisa ser regenerado.';

  @override
  String get iosAlarmLoudnessHint =>
      'O volume do alarme também depende de Ajustes → Sons e toques → Toque e alertas.';

  @override
  String get addSavedVoiceToSequence => 'Adicionar à sequência';

  @override
  String get savedVoiceInUseTitle => 'Voice in use';

  @override
  String savedVoiceInUseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This voice is used by $count alarms and cannot be deleted.',
      one: 'This voice is used by 1 alarm and cannot be deleted.',
    );
    return '$_temp0';
  }

  @override
  String get savedVoiceInUseBodyOne =>
      'This voice is used by 1 alarm and cannot be deleted.';

  @override
  String savedVoiceInUseBodyMany(int count) {
    return 'This voice is used by $count alarms and cannot be deleted.';
  }

  @override
  String get savedVoiceInOpenDraftBody =>
      'This voice is in the current unsaved alarm.';

  @override
  String get savedVoiceUsageTitle => 'Alarms using this voice';

  @override
  String get savedVoiceUsageEmpty => 'No alarms currently use this voice.';

  @override
  String get mixedAlarmNeedsVoiceAndRingtone =>
      'Mixed alarms need at least one voice and a ringtone.';

  @override
  String get alarmNotificationLimitExceeded =>
      'Too many notification segments. Lower repeat count or remove some voices.';

  @override
  String get savedVoiceViewAlarms => 'View alarms';

  @override
  String get savedVoiceDeleteTitle => 'Delete saved voice?';

  @override
  String get savedVoiceDeleteBody =>
      'This removes the voice from your library. Alarms are not changed.';

  @override
  String get savedVoiceDeleted => 'Saved voice deleted';

  @override
  String get savedVoiceCleanupTitle => 'Clean up unused voices';

  @override
  String get savedVoiceCleanupSubtitle =>
      'Remove library voices that are not used by any alarm.';

  @override
  String get savedVoiceCleanupEmpty => 'No unused voices to clean up.';

  @override
  String savedVoiceCleanupConfirm(int count) {
    return 'Delete $count unused voices?';
  }

  @override
  String savedVoiceCleanupBytes(String size) {
    return 'About $size of recordings can be freed.';
  }

  @override
  String get savedVoiceSelectAll => 'Select all';

  @override
  String get savedVoiceDeleteAction => 'Delete';

  @override
  String get savedVoicePreviewAction => 'Preview';

  @override
  String get iosNotificationPathHint =>
      'Notification sound volume follows Ringtone and Alerts, which can be quieter than in-app preview even for the same file.';

  @override
  String get debugPlayRenderedCaf => 'Play rendered CAF (debug)';
}

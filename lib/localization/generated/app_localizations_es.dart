// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Smart Voice Alarm';

  @override
  String get appTagline => 'Despierta con tu propia voz';

  @override
  String get homeTitle => 'Alarmas';

  @override
  String get homeEmptyTitle => 'Aún no hay alarmas';

  @override
  String get homeEmptySubtitle =>
      'Crea tu primera alarma de voz y despierta con las palabras que importan.';

  @override
  String get homeCreateAlarm => 'Crear alarma';

  @override
  String get homeEdit => 'Editar';

  @override
  String get homeDuplicate => 'Duplicar';

  @override
  String get homeDelete => 'Eliminar';

  @override
  String get homeMore => 'Más opciones';

  @override
  String homeAlarmsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmas listas',
      one: '1 alarma lista',
      zero: 'Sin alarmas',
    );
    return '$_temp0';
  }

  @override
  String get homeGoodMorning => 'Buenos días';

  @override
  String get homeGoodAfternoon => 'Buenas tardes';

  @override
  String get homeGoodEvening => 'Buenas noches';

  @override
  String get alarmTypeVoice => 'Voz';

  @override
  String get alarmTypeRingtone => 'Tono';

  @override
  String get alarmTypeMixed => 'Mixta';

  @override
  String get alarmTypeLabel => 'Tipo de alarma';

  @override
  String get createAlarmTitle => 'Nueva alarma';

  @override
  String get editAlarmTitle => 'Editar alarma';

  @override
  String get alarmTime => 'Hora';

  @override
  String get alarmHour => 'Hora';

  @override
  String get alarmMinute => 'Minuto';

  @override
  String get alarmRepeat => 'Repetir';

  @override
  String get alarmVoiceSequence => 'Secuencia de voz';

  @override
  String get alarmRingtone => 'Tono después de la voz';

  @override
  String get alarmRepeatCount => 'Repeticiones de la secuencia';

  @override
  String get alarmCopyFrom => 'Copiar de otra alarma';

  @override
  String get alarmSave => 'Guardar alarma';

  @override
  String get alarmSelectSequence => 'Toca para editar la secuencia';

  @override
  String get alarmSelectRingtone => 'Elige un sonido';

  @override
  String get alarmNoneSelected => 'Ninguno seleccionado';

  @override
  String get alarmCopied => 'Ajustes copiados';

  @override
  String get alarmSaved => 'Alarma guardada';

  @override
  String get alarmDeleted => 'Alarma eliminada';

  @override
  String get alarmDuplicated => 'Alarma duplicada';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get dayEveryDay => 'Todos los días';

  @override
  String get dayWeekdays => 'Días laborables';

  @override
  String get dayWeekends => 'Fines de semana';

  @override
  String get dayOnce => 'Una vez';

  @override
  String get voiceSequenceTitle => 'Secuencia de voz';

  @override
  String get voiceSequenceEmptyTitle => 'Crea tu mensaje para despertar';

  @override
  String get voiceSequenceEmptySubtitle =>
      'Añade grabaciones o texto hablado en el orden en que quieras oírlos.';

  @override
  String get voiceSequenceAdd => 'Añadir voz';

  @override
  String get voiceSequenceDelete => 'Eliminar';

  @override
  String get voiceSequenceDeleteConfirmTitle => '¿Eliminar segmento?';

  @override
  String get voiceSequenceDeleteConfirmBody =>
      'Esto elimina el segmento de la secuencia.';

  @override
  String get voiceSequenceReorderHint => 'Arrastra para reordenar';

  @override
  String get voiceSegmentName => 'Nombre';

  @override
  String get voiceSegmentType => 'Tipo';

  @override
  String get voiceSegmentDuration => 'Duración';

  @override
  String voiceSegmentOrder(int number) {
    return 'Paso $number';
  }

  @override
  String get voiceTypeRecording => 'Grabación';

  @override
  String get voiceTypeTts => 'Texto a voz';

  @override
  String get addVoiceTitle => 'Añadir voz';

  @override
  String get addVoiceRecord => 'Grabar voz';

  @override
  String get addVoiceRecordSubtitle => 'Di un mensaje breve al micrófono';

  @override
  String get addVoiceTts => 'Texto a voz';

  @override
  String get addVoiceTtsSubtitle => 'Escribe un mensaje y elige una voz';

  @override
  String get ttsTitle => 'Texto a voz';

  @override
  String get ttsInputLabel => 'Mensaje';

  @override
  String get ttsInputHint => 'Escribe el mensaje que quieres oír…';

  @override
  String get ttsVoices => 'Voces';

  @override
  String get ttsLanguageLabel => 'Idioma';

  @override
  String get ttsVoiceNameLabel => 'Voz';

  @override
  String get ttsVoiceQualityLabel => 'Calidad';

  @override
  String get ttsPreview => 'Vista previa';

  @override
  String get ttsPreviewing => 'Reproduciendo vista previa…';

  @override
  String get ttsSave => 'Guardar';

  @override
  String get ttsSaved => 'Segmento de voz guardado';

  @override
  String get recordTitle => 'Grabar voz';

  @override
  String get recordStart => 'Grabar';

  @override
  String get recordStop => 'Detener';

  @override
  String get recordPlay => 'Reproducir';

  @override
  String get recordPlaying => 'Reproduciendo…';

  @override
  String get recordSave => 'Guardar';

  @override
  String get recordHint => 'Toca Grabar cuando estés listo';

  @override
  String get recordRecording => 'Grabando…';

  @override
  String get recordReady => 'Listo para guardar';

  @override
  String get recordSaved => 'Grabación guardada';

  @override
  String get recordDefaultName => 'Grabación de voz';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsReminder => 'Recordatorio';

  @override
  String get settingsReminderSubtitle =>
      'Recibe un aviso suave si no hay ninguna alarma programada';

  @override
  String get settingsReminderTime => 'Hora del recordatorio';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutSubtitle => 'Información de la app y soporte';

  @override
  String get settingsAboutLegalese => '© Smart Voice Alarm';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Desbloquea alarmas ilimitadas';

  @override
  String get settingsVoices => 'Voces';

  @override
  String get settingsVoicesSubtitle => 'Voces del sistema para texto a voz';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsLicenses => 'Licencias de código abierto';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsTerms => 'Términos de uso';

  @override
  String get settingsLegalPlaceholder => 'Ver documento';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Desbloquea alarmas ilimitadas';

  @override
  String get premiumSubtitle =>
      'La versión gratuita incluye hasta 3 alarmas. Desbloquea alarmas ilimitadas con una compra de por vida. Sin suscripciones.';

  @override
  String get premiumPlanFree => 'Gratis';

  @override
  String get premiumPlanLifetime => 'Premium de por vida';

  @override
  String get premiumPlanLifetimePrice => 'Compra única';

  @override
  String get premiumBenefitsTitle => 'Todo en Premium';

  @override
  String get premiumBenefitUnlimited => 'Alarmas ilimitadas';

  @override
  String get premiumBenefitSequences => 'Secuencias de voz sin bloqueos';

  @override
  String get premiumBenefitVoices => 'Todas las voces del sistema instaladas';

  @override
  String get premiumBenefitThemes =>
      'Temas, recordatorios y grabación siguen gratis';

  @override
  String get premiumBenefitSupport => 'Soporte prioritario';

  @override
  String get premiumBenefitNoAds => 'Sin anuncios';

  @override
  String get premiumUnlock => 'Desbloquear alarmas ilimitadas';

  @override
  String get premiumRestore => 'Restaurar compra';

  @override
  String get premiumThanks => 'Gracias por apoyar Smart Voice Alarm.';

  @override
  String get premiumComingSoon =>
      'Los productos deben configurarse en App Store Connect y Google Play Console.';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonEnabled => 'Activado';

  @override
  String get commonDisabled => 'Desactivado';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonOpen => 'Abrir';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageDutch => 'Neerlandés';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageChineseSimplified => 'Chino (simplificado)';

  @override
  String get languageChineseTraditional => 'Chino (tradicional)';

  @override
  String get languageIndonesian => 'Indonesio';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String timesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
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
      zero: 'Sin segmentos',
    );
    return '$_temp0';
  }

  @override
  String get ringtoneSoftChime => 'Campanilla suave';

  @override
  String get ringtoneOceanBreeze => 'Brisa oceánica';

  @override
  String get ringtoneNightPulse => 'Pulso nocturno';

  @override
  String get ringtoneForestDawn => 'Amanecer en el bosque';

  @override
  String get ringtoneCrystalBell => 'Campana de cristal';

  @override
  String get alarmStop => 'Detener';

  @override
  String get alarmStopAll => 'Detener todo';

  @override
  String alarmQueueWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alarmas en espera',
      one: '1 alarma en espera',
    );
    return '$_temp0';
  }

  @override
  String get voicesTitle => 'Voces';

  @override
  String get voicesSystemVoices => 'Voces del sistema';

  @override
  String get voicesDownloadMore => 'Descargar más voces';

  @override
  String get voicesRefresh => 'Actualizar voces';

  @override
  String get voicesOfflineHint =>
      'Prefiere voces sin conexión para que las alarmas hablen aunque no haya red.';

  @override
  String get voicesIosGuideTitle => 'Instalar voces en iPhone';

  @override
  String get voicesIosGuideBody =>
      'Abre Ajustes → Accesibilidad → Contenido hablado → Voces, descarga las voces que necesites, vuelve aquí y toca Actualizar voces.';

  @override
  String get voicesAndroidGuide =>
      'Abre el instalador de datos TTS del sistema. Smart Voice Alarm no descarga ni aloja paquetes de voz.';

  @override
  String get voicesWebUnavailable =>
      'Los navegadores gestionan sus propias voces. Los paquetes de descarga no están disponibles en la web.';

  @override
  String get voicesEmpty => 'Aún no se encontraron voces utilizables';

  @override
  String get voicesEmptyCta => 'Descargar más voces';

  @override
  String get voiceQualityDefault => 'Predeterminada';

  @override
  String get voiceQualityEnhanced => 'Mejorada';

  @override
  String get voiceQualityPremium => 'Premium';

  @override
  String get voiceAvailabilityOffline => 'Sin conexión';

  @override
  String get voiceAvailabilityNetwork => 'Requiere red';

  @override
  String get voiceAvailabilityMissing => 'No instalada';

  @override
  String get ttsNoVoicesTitle => 'Sin voces utilizables';

  @override
  String get ttsNoVoicesBody =>
      'Descarga voces del sistema y luego actualiza la lista.';

  @override
  String get ttsOpenVoiceSettings => 'Descargar más voces';

  @override
  String get ttsVoiceFallback =>
      'La voz seleccionada no está disponible. Se usará una voz predeterminada.';

  @override
  String get reminderNotificationTitle => 'Programa la alarma de mañana';

  @override
  String get reminderNotificationBody =>
      'Tómate un momento para programar tu Smart Voice Alarm para mañana.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutAppName => 'Nombre de la app';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutDeveloper => 'Desarrollador';

  @override
  String get aboutDeveloperValue => 'Tom Satthu';

  @override
  String get aboutGithub => 'Repositorio de GitHub';

  @override
  String get aboutGithubValue => 'github.com/Tom-satthu/Smart-Voice-Alarm';

  @override
  String get aboutEmail => 'Soporte por correo';

  @override
  String get aboutEmailValue => 'support@smartvoicealarm.app';

  @override
  String get aboutWebsite => 'Sitio web';

  @override
  String get aboutWebsiteValue => 'www.smartvoicealarm.app';

  @override
  String get aboutWebsitePlaceholder => 'Próximamente';

  @override
  String get voiceSystemDefault => 'Predeterminado del sistema';

  @override
  String get notificationChannelAlarms => 'Alarmas';

  @override
  String get notificationChannelAlarmsDesc => 'Alertas de alarma de voz';

  @override
  String get notificationChannelReminders => 'Recordatorios';

  @override
  String get notificationChannelRemindersDesc =>
      'Recordatorio diario para configurar la alarma de mañana';

  @override
  String get alarmDefaultLabel => 'Alarma';

  @override
  String get premiumBenefitLifetimeBuy => 'Compra una vez. Tuyo para siempre.';

  @override
  String get premiumStatusLoading => 'Comprobando la tienda…';

  @override
  String get premiumStatusPurchasing => 'Iniciando compra…';

  @override
  String get premiumStatusPurchased => 'Premium Lifetime desbloqueado';

  @override
  String get premiumStatusRestored => 'Compra restaurada';

  @override
  String get premiumStatusCancelled => 'Compra cancelada';

  @override
  String get premiumStatusPending => 'Compra pendiente…';

  @override
  String get premiumStatusError => 'La compra falló. Inténtalo de nuevo.';

  @override
  String get premiumWebUnavailable =>
      'Las compras no están disponibles en la demo web.';

  @override
  String get premiumStoreUnavailable =>
      'La tienda no está disponible en este dispositivo.';

  @override
  String get premiumLimitExplainFree =>
      'La versión gratuita incluye hasta 3 alarmas.';

  @override
  String get premiumLimitExplainUnlock =>
      'Desbloquea alarmas ilimitadas con una compra de por vida.';

  @override
  String premiumFreeLimitLabel(int count) {
    return 'Hasta $count alarmas';
  }

  @override
  String get voicesSearchHint => 'Buscar idiomas o voces';

  @override
  String get voicesLanguages => 'Idiomas';

  @override
  String get voicesSelectVoiceHint => 'Elige una voz para este idioma';

  @override
  String voicesLanguageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voces',
      one: '1 voz',
    );
    return '$_temp0';
  }

  @override
  String get alarmSelectTime => 'Toca para elegir la hora';

  @override
  String get segmentPlay => 'Reproducir';

  @override
  String get voicePlaying => 'Reproduciendo';

  @override
  String get voiceSelect => 'Seleccionar';

  @override
  String get voiceUnavailable => 'Voz no disponible';

  @override
  String get recordingFileMissing =>
      'Falta el archivo de grabación. Elimina este segmento o vuelve a grabar.';

  @override
  String get voiceDetails => 'Detalles de la voz';

  @override
  String get ttsSelectedVoice => 'Voz seleccionada';

  @override
  String get voicePreviewSample =>
      'Esta es una vista previa breve de esta voz.';
}

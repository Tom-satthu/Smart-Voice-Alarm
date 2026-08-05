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
  String get recordPermissionTitle => 'Acceso al micrófono';

  @override
  String get recordPermissionRationale =>
      'La aplicación necesita acceso al micrófono para grabar el audio que usarás como alarma.';

  @override
  String get recordPermissionDenied =>
      'No se concedió acceso al micrófono. No se inició ninguna grabación. Puedes volver a intentarlo.';

  @override
  String get recordPermissionPermanentlyDenied =>
      'El acceso al micrófono está bloqueado. Abre los ajustes del sistema y concédelo antes de grabar.';

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
  String get aboutDeveloperValue => 'Nguyên Đức';

  @override
  String get aboutEmail => 'Soporte por correo';

  @override
  String get aboutEmailValue => 'timeforwork789@gmail.com';

  @override
  String get aboutWebsite => 'Sitio web';

  @override
  String get aboutWebsiteValue => '';

  @override
  String get aboutWebsitePlaceholder => 'Próximamente';

  @override
  String get voiceSystemDefault => 'Predeterminado del sistema';

  @override
  String get voiceSystemDefaultHint =>
      'Se gestiona en los ajustes del dispositivo';

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

  @override
  String get alarmDismissTitle => 'Resuelve para detener';

  @override
  String get alarmDismissHint =>
      'Responde correctamente para apagar la alarma.';

  @override
  String get alarmDismissWrong => 'Incorrecto. Prueba otra pregunta.';

  @override
  String get alarmDismissCheck => 'Comprobar';

  @override
  String get alarmDismissAnswerHint => 'Tu respuesta';

  @override
  String voicesRefreshed(int count) {
    return 'Actualizado: $count voces encontradas';
  }

  @override
  String voicesSelectedSaved(String name) {
    return 'Voz guardada: $name';
  }

  @override
  String get voicesDownloadThenSelect =>
      'Abre el administrador de voces del dispositivo. Tras descargar, vuelve aquí.';

  @override
  String get voicesRefreshHint =>
      'Actualizar voces recarga las voces TTS del sistema tras instalar paquetes.';

  @override
  String get ringtonePreview => 'Vista previa';

  @override
  String get ringtonePreviewHint =>
      'Toca reproducir para escuchar y el nombre para elegir.';

  @override
  String get voicesCurrentVoice => 'Voz actual';

  @override
  String get voicesNewlyInstalled => 'Voces recién instaladas';

  @override
  String get voicesOnDevice => 'Voces en este dispositivo';

  @override
  String get voicesDownloadHint =>
      'Abre el administrador de voces del dispositivo. Tras descargar, vuelve aquí.';

  @override
  String get voicesRescan => 'Volver a escanear';

  @override
  String voicesRescanResult(int count) {
    return 'Se encontraron $count voces utilizables';
  }

  @override
  String voicesNewFound(int count) {
    return 'Se encontraron $count voces nuevas.';
  }

  @override
  String get voicesNoNewFound => 'No se detectaron voces nuevas.';

  @override
  String voicesSystemUpdated(String language) {
    return 'Se actualizó la voz de $language desde los ajustes del dispositivo.';
  }

  @override
  String get voicesNoChange => 'No se detectaron cambios de voz.';

  @override
  String get voicesSettingsRefreshed =>
      'Se actualizaron los ajustes de voz del dispositivo.';

  @override
  String get voicesSystemChanges => 'Actualizaciones de voz del dispositivo';

  @override
  String voicesSystemChangeEvent(String language) {
    return 'Se actualizaron los ajustes de voz de $language en el dispositivo.';
  }

  @override
  String get voicesNewlyInstalledEmpty =>
      'Las voces nuevas y las actualizaciones del dispositivo aparecerán aquí.';

  @override
  String get voicesNewBadge => 'Nueva';

  @override
  String get commonClear => 'Borrar';

  @override
  String voiceFriendlyName(String number) {
    return 'Voz $number';
  }

  @override
  String get voicesOpenManagerFailed =>
      'No se pudo abrir el administrador de voces. Abre los ajustes de texto a voz del sistema.';

  @override
  String get currentVoice => 'Voz actual';

  @override
  String get scanDeviceVoices => 'Escanear voces del dispositivo';

  @override
  String get availableDeviceVoices => 'Voces disponibles en el dispositivo';

  @override
  String get scanVoicesHint =>
      'Toca Escanear voces del dispositivo para ver las voces instaladas.';

  @override
  String get noDeviceVoicesFound =>
      'No se encontraron voces adecuadas en el dispositivo.';

  @override
  String get scanVoicesFailed =>
      'No se pudieron escanear las voces. Inténtalo de nuevo.';

  @override
  String get voiceSetupGuide => 'Cómo añadir voces';

  @override
  String get openVoiceSettings => 'Abrir ajustes de voz';

  @override
  String get androidVoiceSetupSteps =>
      '1. Abre Ajustes del dispositivo.\n2. Busca Texto a voz o Text-to-speech.\n3. Abre el motor TTS que usas.\n4. Abre idiomas o datos de voz.\n5. Instala una voz nueva.\n6. Vuelve aquí y toca Escanear voces.';

  @override
  String get iosVoiceSetupSteps =>
      '1. Abre Ajustes.\n2. Abre Accesibilidad.\n3. Abre Contenido leído o Voces.\n4. Elige un idioma y descarga una voz.\n5. Vuelve aquí y escanea de nuevo.\nLos nombres de menú pueden variar según iOS.';

  @override
  String get webVoiceAvailabilityInfo =>
      'En la web, las voces disponibles las proporcionan el navegador y el sistema.';

  @override
  String lastScanned(String time) {
    return 'Último escaneo: $time';
  }

  @override
  String get voiceInUse => 'En uso';

  @override
  String get otherLanguages => 'Otros idiomas';

  @override
  String voicesInLanguage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voces',
      one: '1 voz',
      zero: 'Sin voces',
    );
    return '$_temp0';
  }

  @override
  String get expandLanguageVoices => 'Expandir voces del idioma';

  @override
  String get collapseLanguageVoices => 'Contraer voces del idioma';

  @override
  String voicePreviewNamed(String name) {
    return 'Vista previa de $name';
  }

  @override
  String get settingsSoundAndVoice => 'Sonido y voz';

  @override
  String get settingsAlarmsSection => 'Alarmas';

  @override
  String get supportAndFeedback => 'Soporte';

  @override
  String get contactSupport => 'Contacto y comentarios';

  @override
  String get supportEmailSubject => 'Soporte de Smart Voice Alarm';

  @override
  String get emailCopied => 'Correo de soporte copiado';

  @override
  String get linkUnavailable => 'Este enlace aún no está disponible';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get appInformation => 'Acerca de la aplicación';

  @override
  String get appVersion => 'Versión de la aplicación';

  @override
  String get permissionsAndBackground => 'Permisos y segundo plano';

  @override
  String get notificationPermission => 'Notificaciones';

  @override
  String get exactAlarmPermission => 'Alarmas exactas';

  @override
  String get fullScreenAlarmPermission => 'Alarmas a pantalla completa';

  @override
  String get openSystemSettings => 'Abrir ajustes del sistema';

  @override
  String get openSystemSettingsHint =>
      'Gestionar notificaciones y permisos relacionados';

  @override
  String get permissionStatusGranted => 'Concedido';

  @override
  String get permissionStatusDenied => 'No concedido';

  @override
  String get permissionStatusUnknown => 'Desconocido';

  @override
  String trialDaysRemaining(int count) {
    return '$count días restantes de prueba';
  }

  @override
  String get trialLessThanOneDay => 'Queda menos de 1 día de prueba';

  @override
  String get premiumUpgrade => 'Mejorar a Premium';

  @override
  String get premiumAnnualTitle => 'Premium por un año';

  @override
  String get premiumAnnualDescription =>
      'Sigue usando todas las funciones de Smart Voice Alarm después de la prueba de 7 días.';

  @override
  String get premiumAnnualPlan => 'Plan Premium anual';

  @override
  String get premiumAnnualAutoRenew =>
      'Se renueva automáticamente cada año hasta que lo canceles.';

  @override
  String get premiumAnnualCancelInPlay => 'Gestiona o cancela en Google Play.';

  @override
  String get premiumAnnualAccess =>
      'El acceso completo continúa mientras la suscripción esté activa.';

  @override
  String get premiumSubscribeAnnual => 'Suscribirse a Premium por un año';

  @override
  String get premiumDefer => 'Más tarde';

  @override
  String get premiumRestoreTransactions => 'Restaurar transacciones';

  @override
  String get premiumManageSubscription => 'Gestionar suscripción';

  @override
  String get premiumProductUnavailable =>
      'La suscripción anual aún no está disponible en Google Play.';

  @override
  String get premiumBillingUnavailable =>
      'Google Play Billing no está disponible ahora.';

  @override
  String get premiumPurchaseActive => 'Premium está activo';

  @override
  String get premiumTrialExpiredTitle => 'Tu prueba ha terminado';

  @override
  String get premiumTrialExpiredBody =>
      'Suscríbete para seguir usando las funciones principales. Las alarmas existentes aún pueden sonar y se pueden desactivar o eliminar.';

  @override
  String get premiumRetryVerification => 'Reintentar';

  @override
  String get premiumViewExistingAlarms => 'Ver alarmas existentes';

  @override
  String get premiumClientVerificationNotice =>
      'El estado de la suscripción se verifica en este dispositivo mediante la tienda.';

  @override
  String get premiumUnableToVerify => 'No se puede verificar la suscripción.';

  @override
  String get premiumRestrictedAlarmsTitle => 'Acceso limitado a alarmas';

  @override
  String get premiumRestrictedAlarmsBody =>
      'Puedes desactivar o eliminar alarmas existentes. Suscríbete para crear o editar alarmas.';

  @override
  String get iosFullVoiceAlarmSupport =>
      'Compatibilidad completa con alarmas de voz';

  @override
  String get iosFullVoiceAlarmSupportBody =>
      'On iOS 26 and later, Smart Voice Alarm uses AlarmKit so voice segments and ringtones can ring with system alarm behavior.';

  @override
  String get iosLimitedSupportTitle =>
      'Compatibilidad limitada en iOS antiguos';

  @override
  String get iosLimitedSupportBody =>
      'Las alarmas de voz usan notificaciones locales (AlarmKit aún no está activo). Abre la notificación o elige Solve to stop para iniciar el desafío. Deslizar sin abrir no detiene segmentos posteriores.';

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
  String get solveNow => 'Resolver ahora';

  @override
  String get alarmSolveToStop => 'Resuelve para detener';

  @override
  String get alarmDismissedTitle => 'Alarma descartada';

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
  String get savedVoicesTitle => 'Voces guardadas';

  @override
  String get savedVoicesEmpty =>
      'Las grabaciones y TTS guardados aparecerán aquí.';

  @override
  String get savedVoiceAdded => 'Voz añadida a la secuencia';

  @override
  String get iosCapabilityLearnMore => 'How alarms work on this iPhone';

  @override
  String get alarmAudioNeedsRegeneration =>
      'Es necesario regenerar el audio de la alarma de voz.';

  @override
  String get iosAlarmLoudnessHint =>
      'El volumen de la alarma también depende de Ajustes → Sonidos y háptica → Tono y alertas.';

  @override
  String get addSavedVoiceToSequence => 'Añadir a la secuencia';

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

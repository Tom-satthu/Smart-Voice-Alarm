import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/generated/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/providers/prototype_providers.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class SmartVoiceAlarmApp extends ConsumerStatefulWidget {
  const SmartVoiceAlarmApp({super.key, this.initialLocation});

  /// Optional override for tests (skips splash when set to home).
  final String? initialLocation;

  @override
  ConsumerState<SmartVoiceAlarmApp> createState() => _SmartVoiceAlarmAppState();
}

class _SmartVoiceAlarmAppState extends ConsumerState<SmartVoiceAlarmApp> {
  late final _router = createAppRouter(initialLocation: widget.initialLocation);
  Locale? _localizedFor;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      builder: (context, child) {
        _syncLocalizedServices(context);
        return child ?? const SizedBox.shrink();
      },
    );
  }

  void _syncLocalizedServices(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (_localizedFor == locale) return;
    final l10n = AppLocalizations.of(context);
    _localizedFor = locale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(reminderSettingsProvider.notifier).ensureScheduledLocalized(
              title: l10n.reminderNotificationTitle,
              body: l10n.reminderNotificationBody,
            ),
      );
      unawaited(
        ref.read(notificationServiceProvider).applyLocalizedCopy(
              appName: l10n.appName,
              alarmChannelName: l10n.notificationChannelAlarms,
              alarmChannelDescription: l10n.notificationChannelAlarmsDesc,
              reminderChannelName: l10n.notificationChannelReminders,
              reminderChannelDescription: l10n.notificationChannelRemindersDesc,
            ),
      );
    });
  }
}

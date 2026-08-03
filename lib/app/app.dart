import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/generated/app_localizations.dart';
import '../router/app_router.dart';
import '../shared/providers/prototype_providers.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class SmartVoiceAlarmApp extends ConsumerStatefulWidget {
  const SmartVoiceAlarmApp({super.key});

  @override
  ConsumerState<SmartVoiceAlarmApp> createState() => _SmartVoiceAlarmAppState();
}

class _SmartVoiceAlarmAppState extends ConsumerState<SmartVoiceAlarmApp> {
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Smart Voice Alarm',
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
    );
  }
}

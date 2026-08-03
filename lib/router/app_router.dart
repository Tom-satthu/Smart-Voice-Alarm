import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/alarm/presentation/screens/create_alarm_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/voice_sequence/presentation/screens/tts_record_screens.dart';
import '../features/voice_sequence/presentation/screens/voice_sequence_screen.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAlarm,
        name: 'createAlarm',
        builder: (context, state) => const CreateAlarmScreen(),
      ),
      GoRoute(
        path: AppRoutes.editAlarm,
        name: 'editAlarm',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return CreateAlarmScreen(alarmId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.voiceSequence,
        name: 'voiceSequence',
        builder: (context, state) => const VoiceSequenceScreen(),
      ),
      GoRoute(
        path: AppRoutes.addVoice,
        name: 'addVoice',
        builder: (context, state) => const AddVoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.tts,
        name: 'tts',
        builder: (context, state) => const TtsScreen(),
      ),
      GoRoute(
        path: AppRoutes.record,
        name: 'record',
        builder: (context, state) => const RecordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
  );
}

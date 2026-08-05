import 'package:go_router/go_router.dart';

import '../core/navigation/root_navigator.dart';
import '../features/alarm/presentation/screens/alarm_ringing_screen.dart';
import '../features/alarm/presentation/screens/create_alarm_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/voice_speech_settings_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/voice_sequence/presentation/screens/tts_record_screens.dart';
import '../features/voice_sequence/presentation/screens/voice_sequence_screen.dart';
import '../shared/providers/prototype_providers.dart';
import 'routes.dart';

GoRouter createAppRouter({String? initialLocation}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation ?? AppRoutes.splash,
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
        builder: (context, state) {
          final sequenceId =
              state.uri.queryParameters['id'] ?? defaultSequenceId;
          return VoiceSequenceScreen(sequenceId: sequenceId);
        },
      ),
      GoRoute(
        path: AppRoutes.addVoice,
        name: 'addVoice',
        builder: (context, state) {
          final sequenceId = state.uri.queryParameters['id'];
          return AddVoiceScreen(sequenceId: sequenceId);
        },
      ),
      GoRoute(
        path: AppRoutes.tts,
        name: 'tts',
        builder: (context, state) {
          final sequenceId =
              state.uri.queryParameters['id'] ?? defaultSequenceId;
          return TtsScreen(sequenceId: sequenceId);
        },
      ),
      GoRoute(
        path: AppRoutes.record,
        name: 'record',
        builder: (context, state) {
          final sequenceId =
              state.uri.queryParameters['id'] ?? defaultSequenceId;
          return RecordScreen(sequenceId: sequenceId);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceSpeech,
        name: 'voiceSpeech',
        builder: (context, state) => const VoiceSpeechSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        name: 'premium',
        builder: (context, state) {
          return const PremiumScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.ringing,
        name: 'ringing',
        builder: (context, state) {
          final alarmId = state.pathParameters['id'] ?? '';
          final challenge = state.uri.queryParameters['challenge'] == '1';
          final occurrenceId = state.uri.queryParameters['occurrenceId'];
          return AlarmRingingScreen(
            alarmId: alarmId,
            openDismissChallenge: challenge,
            occurrenceId: occurrenceId,
          );
        },
      ),
    ],
  );
}

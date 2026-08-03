abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String createAlarm = '/alarm/create';
  static const String editAlarm = '/alarm/edit/:id';
  static const String voiceSequence = '/voice-sequence';
  static const String addVoice = '/voice-sequence/add';
  static const String tts = '/voice-sequence/tts';
  static const String record = '/voice-sequence/record';
  static const String settings = '/settings';
  static const String premium = '/premium';

  static String editAlarmPath(String id) => '/alarm/edit/$id';
}

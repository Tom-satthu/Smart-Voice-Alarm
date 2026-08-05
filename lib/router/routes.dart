abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String createAlarm = '/alarm/create';
  static const String editAlarm = '/alarm/edit/:id';
  static const String ringing = '/alarm/ringing/:id';
  static const String voiceSequence = '/voice-sequence';
  static const String addVoice = '/voice-sequence/add';
  static const String tts = '/voice-sequence/tts';
  static const String record = '/voice-sequence/record';
  static const String settings = '/settings';
  static const String voiceSpeech = '/settings/voices';
  static const String about = '/settings/about';
  static const String premium = '/premium';
  static const String savedVoiceUsage = '/saved-voices/:id/usage';

  static String editAlarmPath(String id) => '/alarm/edit/$id';
  static String savedVoiceUsagePath(String savedVoiceId) =>
      '/saved-voices/$savedVoiceId/usage';
  static String ringingPath(
    String id, {
    bool challenge = false,
    String? occurrenceId,
  }) {
    final params = <String>[];
    if (challenge) params.add('challenge=1');
    if (occurrenceId != null && occurrenceId.isNotEmpty) {
      params.add('occurrenceId=${Uri.encodeComponent(occurrenceId)}');
    }
    if (params.isEmpty) return '/alarm/ringing/$id';
    return '/alarm/ringing/$id?${params.join('&')}';
  }

  static String voiceSequencePath(String sequenceId) =>
      '/voice-sequence?id=$sequenceId';

  static String addVoicePath(String sequenceId) =>
      '/voice-sequence/add?id=$sequenceId';

  static String ttsPath(String sequenceId) =>
      '/voice-sequence/tts?id=$sequenceId';

  static String recordPath(String sequenceId) =>
      '/voice-sequence/record?id=$sequenceId';
}

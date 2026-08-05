/// Immutable context for a single voice discovery/load pass.
class VoiceLoadContext {
  const VoiceLoadContext({
    this.preferredLocale,
    this.appLocale,
    this.systemLocale,
  });

  final String? preferredLocale;
  final String? appLocale;
  final String? systemLocale;

  String get cacheKey =>
      '${preferredLocale ?? ''}::${appLocale ?? ''}::${systemLocale ?? ''}';
}

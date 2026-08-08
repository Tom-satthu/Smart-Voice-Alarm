import 'package:flutter/foundation.dart';

/// DEBUG-only monotonic startup timing marks. No secrets / UDID / PII.
class SvaStartupTiming {
  SvaStartupTiming._();

  static final Stopwatch _sw = Stopwatch();
  static final Map<String, int> marks = {};

  static void begin() {
    if (!kDebugMode) return;
    _sw
      ..reset()
      ..start();
    mark('process_begin');
  }

  static void mark(String name) {
    if (!kDebugMode) return;
    if (!_sw.isRunning) {
      _sw.start();
    }
    marks[name] = _sw.elapsedMilliseconds;
    debugPrint('[SVA-StartupTiming] $name +${_sw.elapsedMilliseconds}ms');
  }

  static int? ms(String name) => marks[name];
}

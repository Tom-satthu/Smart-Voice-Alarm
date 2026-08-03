import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_voice_alarm/app/app.dart';

void main() {
  testWidgets('Smart Voice Alarm boots to splash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartVoiceAlarmApp(),
      ),
    );

    expect(find.text('Smart Voice Alarm'), findsOneWidget);
  });
}

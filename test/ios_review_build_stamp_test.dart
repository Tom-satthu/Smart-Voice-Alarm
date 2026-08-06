import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_voice_alarm/core/debug/sva_build_stamp.dart';
import 'package:smart_voice_alarm/features/settings/presentation/widgets/sva_review_build_stamp_section.dart';

void main() {
  group('SvaBuildStamp.reviewBuild', () {
    test('parses SVA_REVIEW_BUILD from dart define contract', () {
      // Default in unit test VM: not a review build unless injected at compile time.
      expect(SvaBuildStamp.reviewBuild, isFalse);
    });

    test('production autoProbe is false without review build', () {
      expect(SvaBuildStamp.autoProbe, isFalse);
    });
  });

  group('SvaReviewBuildStampSection', () {
    const sampleStamp =
        'SVA_BUILD=feature-ios-alarmkit-abc\n'
        'SVA_MODE=release\n'
        'SVA_ALARMKIT_STARTUP=passive\n'
        'SVA_DIAG_STAGE=R2\n'
        'SVA_BUILD_TIME=2026-08-06T08:00:00Z';

    testWidgets('visible when review release flag enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvaReviewBuildStampSection(
              visible: true,
              stampText: sampleStamp,
            ),
          ),
        ),
      );
      expect(
        find.text(SvaReviewBuildStampSection.sectionTitle),
        findsOneWidget,
      );
      expect(
        find.text(SvaReviewBuildStampSection.stampTileTitle),
        findsOneWidget,
      );
      expect(find.textContaining('SVA_BUILD='), findsOneWidget);
      expect(find.textContaining('SVA_MODE=release'), findsOneWidget);
    });

    testWidgets('hidden when review release flag disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvaReviewBuildStampSection(
              visible: false,
              stampText: sampleStamp,
            ),
          ),
        ),
      );
      expect(find.text(SvaReviewBuildStampSection.sectionTitle), findsNothing);
      expect(
        find.text(SvaReviewBuildStampSection.stampTileTitle),
        findsNothing,
      );
    });
  });
}

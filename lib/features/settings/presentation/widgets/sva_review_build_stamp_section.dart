import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Review-only build stamp card (hidden in production / App Store builds).
class SvaReviewBuildStampSection extends StatelessWidget {
  const SvaReviewBuildStampSection({
    super.key,
    required this.visible,
    required this.stampText,
  });

  @visibleForTesting
  static const sectionTitle = 'Review diagnostics';

  @visibleForTesting
  static const stampTileTitle = 'Review build stamp';

  final bool visible;
  final String stampText;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.spaceXl),
        const SectionHeader(title: sectionTitle),
        SettingTile(
          icon: Icons.fingerprint_outlined,
          title: stampTileTitle,
          subtitle: stampText,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: stampText));
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Build stamp copied')));
          },
        ),
      ],
    );
  }
}

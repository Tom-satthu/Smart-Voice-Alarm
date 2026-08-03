import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';
import '../../../../theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final benefits = [
      (Icons.all_inclusive_rounded, l10n.premiumBenefitUnlimited),
      (Icons.queue_music_rounded, l10n.premiumBenefitSequences),
      (Icons.record_voice_over_rounded, l10n.premiumBenefitVoices),
      (Icons.palette_outlined, l10n.premiumBenefitThemes),
      (Icons.support_agent_rounded, l10n.premiumBenefitSupport),
    ];

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.spaceXl,
                    ),
                    children: [
                      const SizedBox(height: AppConstants.spaceMd),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: AppColors.premiumGradient,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(27),
                            ),
                            child: const BrandMark(size: 64),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      Text(
                        l10n.premiumHeadline,
                        textAlign: TextAlign.center,
                        style: context.textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        l10n.premiumSubtitle,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      for (final benefit in benefits)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spaceMd,
                          ),
                          child: SurfacePanel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: context.colors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                  child: Icon(
                                    benefit.$1,
                                    color: context.colors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    benefit.$2,
                                    style: context.textTheme.titleSmall,
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: context.colors.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PrimaryActionButton(
                  label: l10n.premiumUnlock,
                  icon: Icons.lock_open_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.premiumThanks)));
                  },
                ),
                const SizedBox(height: AppConstants.spaceSm),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.premiumThanks)));
                  },
                  child: Text(l10n.premiumRestore),
                ),
                const SizedBox(height: AppConstants.spaceMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      (Icons.block_rounded, l10n.premiumBenefitNoAds),
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
                      const SizedBox(height: AppConstants.spaceSm),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: AppColors.premiumGradient,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: const BrandMark(size: 68),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      Text(
                        l10n.premiumTitle,
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
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
                      Row(
                        children: [
                          Expanded(
                            child: _PlanCard(
                              title: l10n.premiumPlanFree,
                              subtitle: l10n.commonEnabled,
                              selected: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PlanCard(
                              title: l10n.premiumPlanLifetime,
                              subtitle: l10n.premiumPlanLifetimePrice,
                              selected: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceXl),
                      SectionHeader(title: l10n.premiumBenefitsTitle),
                      for (final benefit in benefits)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spaceMd,
                          ),
                          child: SurfacePanel(
                            emphasized: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
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
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        l10n.premiumComingSoon,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PrimaryActionButton(
                  label: l10n.premiumUnlock,
                  icon: Icons.lock_open_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.premiumThanks)),
                    );
                  },
                ),
                const SizedBox(height: AppConstants.spaceSm),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.premiumThanks)),
                    );
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animationNormal,
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: selected ? AppColors.premiumGradient : null,
        color: selected ? null : context.colors.surface,
        border: Border.all(
          color: selected
              ? Colors.transparent
              : context.colors.outline.withValues(alpha: 0.5),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: context.colors.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              color: selected ? Colors.white : null,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: selected
                  ? Colors.white.withValues(alpha: 0.9)
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

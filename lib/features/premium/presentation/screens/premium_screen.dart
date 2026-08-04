import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/premium_purchase_service.dart';
import '../../../../core/services/trial_entitlement_service.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';
import '../../../../theme/app_colors.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({
    super.key,
    this.mandatory = false,
    this.onViewExistingAlarms,
  });

  final bool mandatory;
  final VoidCallback? onViewExistingAlarms;

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumPurchaseProvider.notifier).refreshProducts();
    });
  }

  String _statusMessage(AppLocalizations l10n, PremiumPurchaseState state) {
    return switch (state.status) {
      PurchaseFlowStatus.loading => l10n.premiumStatusLoading,
      PurchaseFlowStatus.purchasing => l10n.premiumStatusPurchasing,
      PurchaseFlowStatus.purchased ||
      PurchaseFlowStatus.restored => l10n.premiumPurchaseActive,
      PurchaseFlowStatus.cancelled => l10n.premiumStatusCancelled,
      PurchaseFlowStatus.pending => l10n.premiumStatusPending,
      PurchaseFlowStatus.error => l10n.premiumStatusError,
      PurchaseFlowStatus.unavailable => l10n.premiumBillingUnavailable,
      PurchaseFlowStatus.productUnavailable => l10n.premiumProductUnavailable,
      PurchaseFlowStatus.idle => '',
    };
  }

  Future<void> _subscribe() async {
    await ref.read(premiumPurchaseProvider.notifier).buy();
  }

  Future<void> _restore() async {
    await ref.read(premiumPurchaseProvider.notifier).restore();
  }

  Future<void> _retry() async {
    await ref.read(trialEntitlementProvider.notifier).refreshOnResume();
    await ref.read(premiumPurchaseProvider.notifier).refreshProducts();
  }

  Future<void> _manageSubscription() async {
    final uri = defaultTargetPlatform == TargetPlatform.android
        ? Uri.https('play.google.com', '/store/account/subscriptions', {
            'sku': AppConstants.premiumSubscriptionId,
            'package': AppConstants.applicationId,
          })
        : Uri.parse('https://apps.apple.com/account/subscriptions');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).premiumStatusError),
        ),
      );
    }
  }

  Future<void> _contactSupport() async {
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: AppConstants.supportEmail,
        queryParameters: {'subject': 'Smart Voice Alarm subscription support'},
      ),
    );
  }

  Future<void> _openPrivacy() async {
    if (!AppConstants.hasPrivacyPolicyUrl) return;
    await launchUrl(
      Uri.parse(AppConstants.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openTerms() async {
    if (!AppConstants.hasTermsOfUseUrl) return;
    await launchUrl(
      Uri.parse(AppConstants.termsOfUseUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final purchase = ref.watch(premiumPurchaseProvider);
    final entitlement = ref.watch(trialEntitlementProvider);
    final active = entitlement.status == EntitlementStatus.subscriptionActive;
    final busy =
        purchase.status == PurchaseFlowStatus.loading ||
        purchase.status == PurchaseFlowStatus.purchasing ||
        purchase.status == PurchaseFlowStatus.pending;
    final status = _statusMessage(l10n, purchase);

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: Column(
              children: [
                if (!widget.mandatory)
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
                      top: AppConstants.spaceMd,
                      bottom: AppConstants.spaceLg,
                    ),
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: AppColors.premiumGradient,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: const BrandMark(size: 62),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      Text(
                        active
                            ? l10n.premiumPurchaseActive
                            : widget.mandatory
                            ? l10n.premiumTrialExpiredTitle
                            : l10n.premiumAnnualTitle,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        active
                            ? l10n.premiumAnnualAccess
                            : widget.mandatory
                            ? l10n.premiumTrialExpiredBody
                            : l10n.premiumAnnualDescription,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                      SurfacePanel(
                        emphasized: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.premiumAnnualPlan,
                              style: context.textTheme.titleLarge,
                            ),
                            if (purchase.localizedPrice != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                purchase.localizedPrice!,
                                style: context.textTheme.headlineSmall
                                    ?.copyWith(color: context.colors.primary),
                              ),
                            ],
                            const SizedBox(height: AppConstants.spaceMd),
                            _DisclosureRow(text: l10n.premiumAnnualAutoRenew),
                            _DisclosureRow(
                              text: l10n.premiumAnnualCancelInPlay,
                            ),
                            _DisclosureRow(text: l10n.premiumAnnualAccess),
                          ],
                        ),
                      ),
                      if (status.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spaceMd),
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppConstants.spaceMd),
                      Text(
                        l10n.premiumClientVerificationNotice,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!active)
                  PrimaryActionButton(
                    label: l10n.premiumSubscribeAnnual,
                    icon: Icons.workspace_premium_rounded,
                    onPressed: busy || purchase.product == null
                        ? null
                        : _subscribe,
                  ),
                if (purchase.status == PurchaseFlowStatus.error ||
                    purchase.status == PurchaseFlowStatus.unavailable ||
                    purchase.status ==
                        PurchaseFlowStatus.productUnavailable) ...[
                  const SizedBox(height: AppConstants.spaceSm),
                  OutlinedButton.icon(
                    onPressed: busy ? null : _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.premiumRetryVerification),
                  ),
                ],
                const SizedBox(height: AppConstants.spaceSm),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: busy ? null : _restore,
                      child: Text(l10n.premiumRestoreTransactions),
                    ),
                    TextButton(
                      onPressed: _manageSubscription,
                      child: Text(l10n.premiumManageSubscription),
                    ),
                    if (AppConstants.hasPrivacyPolicyUrl)
                      TextButton(
                        onPressed: _openPrivacy,
                        child: Text(l10n.settingsPrivacy),
                      ),
                    if (AppConstants.hasTermsOfUseUrl)
                      TextButton(
                        onPressed: _openTerms,
                        child: Text(l10n.settingsTerms),
                      ),
                    TextButton(
                      onPressed: _contactSupport,
                      child: Text(l10n.contactSupport),
                    ),
                    TextButton(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: l10n.appName,
                      ),
                      child: Text(l10n.openSourceLicenses),
                    ),
                  ],
                ),
                if (!widget.mandatory && !active)
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.premiumDefer),
                  ),
                if (widget.mandatory && widget.onViewExistingAlarms != null)
                  TextButton(
                    onPressed: widget.onViewExistingAlarms,
                    child: Text(l10n.premiumViewExistingAlarms),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisclosureRow extends StatelessWidget {
  const _DisclosureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 20,
            color: context.colors.primary,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

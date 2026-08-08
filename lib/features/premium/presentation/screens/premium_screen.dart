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
  static bool get _isAppStorePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

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
      PurchaseFlowStatus.unavailable => _isAppStorePlatform
          ? l10n.premiumBillingUnavailableAppStore
          : l10n.premiumBillingUnavailable,
      PurchaseFlowStatus.productUnavailable => _isAppStorePlatform
          ? l10n.premiumProductUnavailableAppStore
          : l10n.premiumProductUnavailable,
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
    final showRetry =
        purchase.status == PurchaseFlowStatus.error ||
        purchase.status == PurchaseFlowStatus.unavailable ||
        purchase.status == PurchaseFlowStatus.productUnavailable;
    final title = active
        ? l10n.premiumPurchaseActive
        : widget.mandatory
        ? l10n.premiumTrialExpiredTitle
        : l10n.premiumAnnualTitle;
    final description = active
        ? l10n.premiumAnnualAccess
        : widget.mandatory
        ? l10n.premiumTrialExpiredBody
        : l10n.premiumAnnualDescription;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.spaceMd,
                    ),
                    children: [
                      if (!widget.mandatory)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: l10n.commonClose,
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        )
                      else
                        const SizedBox(height: AppConstants.spaceMd),
                      _PremiumHeader(title: title, description: description),
                      const SizedBox(height: AppConstants.spaceMd),
                      SurfacePanel(
                        emphasized: true,
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.premiumAnnualPlan,
                                    style: context.textTheme.titleMedium,
                                  ),
                                ),
                                if (purchase.localizedPrice != null) ...[
                                  const SizedBox(width: AppConstants.spaceSm),
                                  Flexible(
                                    child: Text(
                                      purchase.localizedPrice!,
                                      textAlign: TextAlign.end,
                                      style: context.textTheme.titleLarge
                                          ?.copyWith(
                                            color: context.colors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),
                            _DisclosureRow(text: l10n.premiumAnnualAutoRenew),
                            _DisclosureRow(
                              text: _isAppStorePlatform
                                  ? l10n.premiumAnnualCancelInAppStore
                                  : l10n.premiumAnnualCancelInPlay,
                            ),
                            _DisclosureRow(
                              text: l10n.premiumAnnualAccess,
                              addBottomPadding: false,
                            ),
                          ],
                        ),
                      ),
                      if (status.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spaceSm),
                        _StatusBanner(
                          message: status,
                          showRetry: showRetry,
                          busy: busy,
                          retryLabel: l10n.premiumRetryVerification,
                          onRetry: _retry,
                        ),
                      ],
                      const SizedBox(height: AppConstants.spaceSm),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: context.colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.premiumClientVerificationNotice,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      _AccountActions(
                        busy: busy,
                        restoreLabel: l10n.premiumRestoreTransactions,
                        manageLabel: l10n.premiumManageSubscription,
                        onRestore: _restore,
                        onManage: _manageSubscription,
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        children: [
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
                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text(l10n.premiumDefer),
                          ),
                        ),
                      if (widget.mandatory &&
                          widget.onViewExistingAlarms != null)
                        Center(
                          child: TextButton(
                            onPressed: widget.onViewExistingAlarms,
                            child: Text(l10n.premiumViewExistingAlarms),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!active)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.colors.outline.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    child: PrimaryActionButton(
                      label: l10n.premiumSubscribeAnnual,
                      icon: Icons.workspace_premium_rounded,
                      onPressed: busy || purchase.product == null
                          ? null
                          : _subscribe,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: AppColors.premiumGradient,
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const BrandMark(size: 40),
          ),
        ),
        const SizedBox(width: AppConstants.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.showRetry,
    required this.busy,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final bool showRetry;
  final bool busy;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          if (showRetry) ...[
            const SizedBox(width: 4),
            TextButton(
              onPressed: busy ? null : onRetry,
              child: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions({
    required this.busy,
    required this.restoreLabel,
    required this.manageLabel,
    required this.onRestore,
    required this.onManage,
  });

  final bool busy;
  final String restoreLabel;
  final String manageLabel;
  final VoidCallback onRestore;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: busy ? null : onRestore,
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: Text(
              restoreLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onManage,
            icon: const Icon(Icons.manage_accounts_outlined, size: 18),
            label: Text(
              manageLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _DisclosureRow extends StatelessWidget {
  const _DisclosureRow({required this.text, this.addBottomPadding = true});

  final String text;
  final bool addBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: addBottomPadding ? 7 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 18, color: context.colors.primary),
          const SizedBox(width: 7),
          Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

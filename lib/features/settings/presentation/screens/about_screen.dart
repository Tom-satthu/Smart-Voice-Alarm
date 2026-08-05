import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/app_version_info.dart';
import '../../../../core/services/support_contact.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchHttps(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.linkUnavailable)));
      return;
    }
    final ok =
        await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.linkUnavailable)));
    }
  }

  Future<void> _openSupport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final version = ref.read(appVersionInfoProvider).asData?.value;
    final uri = SupportContact.mailtoUri(
      subject: l10n.supportEmailSubject,
      appVersion: version?.version ?? AppConstants.appVersion,
      buildNumber: version?.buildNumber ?? AppConstants.appBuildNumber,
      platformLabel: kIsWeb ? 'Web' : defaultTargetPlatform.name,
    );
    try {
      final opened = await launchUrl(uri);
      if (opened || !context.mounted) return;
    } catch (_) {}
    if (!context.mounted) return;
    await Clipboard.setData(ClipboardData(text: AppConstants.supportEmail));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.emailCopied)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final versionAsync = ref.watch(appVersionInfoProvider);
    final versionLabel = versionAsync.maybeWhen(
      data: (info) => info.label,
      orElse: () =>
          '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
    );

    return AppScaffold(
      showBack: true,
      title: l10n.aboutTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppConstants.spaceLg,
            bottom: AppConstants.space2xl,
          ),
          children: [
            Center(
              child: Column(
                children: [
                  const BrandMark(size: 72, animated: true),
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(l10n.appName, style: context.textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    l10n.appTagline,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            _InfoTile(label: l10n.aboutAppName, value: l10n.appName),
            _InfoTile(label: l10n.aboutVersion, value: versionLabel),
            _InfoTile(
              label: l10n.aboutDeveloper,
              value: AppConstants.developerName,
            ),
            _InfoTile(
              label: l10n.contactSupport,
              value: AppConstants.supportEmail,
              onTap: () => _openSupport(context, ref),
            ),
            if (AppConstants.hasWebsiteUrl)
              _InfoTile(
                label: l10n.aboutWebsite,
                value: AppConstants.websiteUrl.replaceFirst('https://', ''),
                onTap: () => _launchHttps(context, AppConstants.websiteUrl),
              ),
            if (AppConstants.hasPrivacyPolicyUrl)
              _InfoTile(
                label: l10n.settingsPrivacy,
                value: l10n.settingsLegalPlaceholder,
                onTap: () =>
                    _launchHttps(context, AppConstants.privacyPolicyUrl),
              ),
            if (AppConstants.hasTermsOfUseUrl)
              _InfoTile(
                label: l10n.settingsTerms,
                value: l10n.settingsLegalPlaceholder,
                onTap: () => _launchHttps(context, AppConstants.termsOfUseUrl),
              ),
            _InfoTile(
              label: l10n.openSourceLicenses,
              value: l10n.settingsLegalPlaceholder,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: versionLabel,
                  applicationLegalese: l10n.settingsAboutLegalese,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: SurfacePanel(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: context.textTheme.titleSmall),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

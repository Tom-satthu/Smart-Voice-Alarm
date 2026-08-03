import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/visual_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(url);
    final ok = await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aboutWebsitePlaceholder)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            _InfoTile(
              label: l10n.aboutAppName,
              value: l10n.appName,
            ),
            _InfoTile(
              label: l10n.aboutVersion,
              value: AppConstants.appVersion,
            ),
            _InfoTile(
              label: l10n.aboutDeveloper,
              value: l10n.aboutDeveloperValue,
            ),
            _InfoTile(
              label: l10n.aboutGithub,
              value: l10n.aboutGithubValue,
              onTap: () => _launch(context, AppConstants.githubRepoUrl),
            ),
            _InfoTile(
              label: l10n.aboutEmail,
              value: AppConstants.supportEmail,
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: AppConstants.supportEmail),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppConstants.supportEmail)),
                );
              },
            ),
            _InfoTile(
              label: l10n.aboutWebsite,
              value: AppConstants.websiteUrl.replaceFirst('https://', ''),
              onTap: () => _launch(context, AppConstants.websiteUrl),
            ),
            _InfoTile(
              label: l10n.settingsPrivacy,
              value: l10n.settingsLegalPlaceholder,
              onTap: () => _launch(context, AppConstants.privacyUrl),
            ),
            _InfoTile(
              label: l10n.settingsTerms,
              value: l10n.settingsLegalPlaceholder,
              onTap: () => _launch(context, AppConstants.termsUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.onTap,
  });

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

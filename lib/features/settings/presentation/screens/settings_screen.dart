import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/app_locale_support.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/time_formatters.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final reminder = ref.watch(reminderSettingsProvider);
    final locale = ref.watch(localeProvider);

    String themeLabel() {
      return switch (themeMode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };
    }

    return AppScaffold(
      showBack: true,
      title: l10n.settingsTitle,
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppConstants.spaceMd,
            bottom: AppConstants.space2xl,
          ),
          children: [
            SettingTile(
              icon: Icons.palette_outlined,
              title: l10n.settingsTheme,
              subtitle: themeLabel(),
              onTap: () => _showThemePicker(context, ref, themeMode),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.language_rounded,
              title: l10n.settingsLanguage,
              subtitle: AppLocaleSupport.displayName(l10n, locale),
              onTap: () => _showLanguagePicker(context, ref, locale),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.record_voice_over_rounded,
              title: l10n.settingsVoices,
              subtitle: l10n.settingsVoicesSubtitle,
              onTap: () => context.push(AppRoutes.voiceSpeech),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SettingTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.settingsReminder,
              subtitle: l10n.settingsReminderSubtitle,
              trailing: Switch.adaptive(
                value: reminder.enabled,
                onChanged: (value) async {
                  await ref
                      .read(reminderSettingsProvider.notifier)
                      .setEnabled(value);
                  await ref
                      .read(reminderSettingsProvider.notifier)
                      .ensureScheduledLocalized(
                        title: l10n.reminderNotificationTitle,
                        body: l10n.reminderNotificationBody,
                      );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.schedule_rounded,
              title: l10n.settingsReminderTime,
              subtitle: TimeFormatters.formatTime(reminder.time),
              onTap: reminder.enabled
                  ? () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: reminder.time,
                      );
                      if (picked != null) {
                        await ref
                            .read(reminderSettingsProvider.notifier)
                            .setTime(picked);
                        await ref
                            .read(reminderSettingsProvider.notifier)
                            .ensureScheduledLocalized(
                              title: l10n.reminderNotificationTitle,
                              body: l10n.reminderNotificationBody,
                            );
                      }
                    }
                  : null,
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SettingTile(
              icon: Icons.workspace_premium_rounded,
              title: l10n.settingsPremium,
              subtitle: l10n.settingsPremiumSubtitle,
              onTap: () => context.push(AppRoutes.premium),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SettingTile(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAbout,
              subtitle: l10n.settingsAboutSubtitle,
              onTap: () => context.push(AppRoutes.about),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.verified_outlined,
              title: l10n.settingsVersion,
              subtitle: AppConstants.appVersion,
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.description_outlined,
              title: l10n.settingsLicenses,
              subtitle: l10n.settingsLegalPlaceholder,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationLegalese: l10n.settingsAboutLegalese,
                );
              },
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.settingsPrivacy,
              subtitle: l10n.settingsLegalPlaceholder,
              onTap: () => _openPlaceholderLink(
                context,
                l10n.settingsPrivacy,
                AppConstants.privacyUrl,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.gavel_outlined,
              title: l10n.settingsTerms,
              subtitle: l10n.settingsLegalPlaceholder,
              onTap: () => _openPlaceholderLink(
                context,
                l10n.settingsTerms,
                AppConstants.termsUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPlaceholderLink(
    BuildContext context,
    String title,
    String url,
  ) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(url);
    final opened = await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title — ${l10n.settingsLegalPlaceholder}')),
      );
    }
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsTheme, style: context.textTheme.titleLarge),
                const SizedBox(height: AppConstants.spaceMd),
                for (final mode in ThemeMode.values)
                  ListTile(
                    title: Text(switch (mode) {
                      ThemeMode.system => l10n.settingsThemeSystem,
                      ThemeMode.light => l10n.settingsThemeLight,
                      ThemeMode.dark => l10n.settingsThemeDark,
                    }),
                    trailing: current == mode
                        ? Icon(
                            Icons.check_rounded,
                            color: context.colors.primary,
                          )
                        : null,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, Locale locale) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: ListView(
                    children: [
                      for (final option in AppLocaleSupport.supported)
                        ListTile(
                          title: Text(
                            AppLocaleSupport.displayName(l10n, option),
                          ),
                          trailing: AppLocaleSupport.localeStorageCode(option) ==
                                  AppLocaleSupport.localeStorageCode(locale)
                              ? Icon(
                                  Icons.check_rounded,
                                  color: context.colors.primary,
                                )
                              : null,
                          onTap: () async {
                            await ref
                                .read(localeProvider.notifier)
                                .setLocale(option);
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

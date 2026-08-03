import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/responsive.dart';
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
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && context.isDark);
    final reminderEnabled = ref.watch(reminderEnabledProvider);
    final locale = ref.watch(localeProvider);

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
            SectionHeader(title: l10n.settingsAppearance),
            SettingTile(
              icon: Icons.dark_mode_outlined,
              title: l10n.settingsDarkMode,
              subtitle: isDark ? l10n.commonEnabled : l10n.commonDisabled,
              trailing: Switch.adaptive(
                value: isDark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleDark(value);
                },
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.language_rounded,
              title: l10n.settingsLanguage,
              subtitle: locale.languageCode == 'en'
                  ? l10n.languageEnglish
                  : locale.languageCode.toUpperCase(),
              onTap: () {
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
                            Text(
                              l10n.settingsLanguage,
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppConstants.spaceMd),
                            ListTile(
                              title: Text(l10n.languageEnglish),
                              trailing: locale.languageCode == 'en'
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: context.colors.primary,
                                    )
                                  : null,
                              onTap: () {
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.settingsReminder),
            SettingTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.settingsReminder,
              subtitle: l10n.settingsReminderSubtitle,
              trailing: Switch.adaptive(
                value: reminderEnabled,
                onChanged: (value) {
                  ref.read(reminderEnabledProvider.notifier).setEnabled(value);
                },
              ),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SettingTile(
              icon: Icons.workspace_premium_rounded,
              title: l10n.settingsPremium,
              subtitle: l10n.settingsPremiumSubtitle,
              onTap: () => context.push(AppRoutes.premium),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAbout,
              subtitle: l10n.settingsAboutSubtitle(AppConstants.appVersion),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationLegalese: '© Smart Voice Alarm',
                  children: [
                    const SizedBox(height: 12),
                    Text(l10n.appTagline),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
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
            SectionHeader(title: l10n.settingsAppearance),
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
              subtitle: locale.languageCode == 'en'
                  ? l10n.languageEnglish
                  : locale.languageCode.toUpperCase(),
              onTap: () => _showLanguagePicker(context, ref, locale),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.settingsReminder),
            SettingTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.settingsReminder,
              subtitle: l10n.settingsReminderSubtitle,
              trailing: Switch.adaptive(
                value: reminder.enabled,
                onChanged: (value) {
                  ref.read(reminderSettingsProvider.notifier).setEnabled(value);
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
                        ref
                            .read(reminderSettingsProvider.notifier)
                            .setTime(picked);
                      }
                    }
                  : null,
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.settingsVoiceSpeech),
            SettingTile(
              icon: Icons.record_voice_over_outlined,
              title: l10n.settingsVoiceSpeech,
              subtitle: l10n.settingsVoiceSpeechSubtitle,
              onTap: () => context.push(AppRoutes.voiceSpeech),
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
                  applicationLegalese: l10n.settingsAboutLegalese,
                  children: [const SizedBox(height: 12), Text(l10n.appTagline)],
                );
              },
            ),
          ],
        ),
      ),
    );
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
                      ? Icon(Icons.check_rounded, color: context.colors.primary)
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
  }
}

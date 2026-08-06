import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/release_config.dart';
import '../../../../core/debug/sva_build_stamp.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/app_locale_support.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/services/app_version_info.dart';
import '../../../../core/services/ios_alarm_diagnostics.dart';
import '../../../../core/services/support_contact.dart';
import '../../../../core/services/trial_entitlement_service.dart';
import '../../../../core/utils/time_formatters.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../widgets/sva_review_alarmkit_runtime_section.dart';
import '../widgets/sva_review_build_stamp_section.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  PermissionStatus? _notificationStatus;
  PermissionStatus? _exactAlarmStatus;
  PermissionStatus? _fullScreenIntentStatus;
  String? _reviewBuildLabel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (SvaBuildStamp.reviewBuild) {
      _reviewBuildLabel = SvaBuildStamp.formatForSettings();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPermissions();
      _loadReviewBuildStamp();
    });
  }

  Future<void> _loadReviewBuildStamp() async {
    if (!SvaBuildStamp.reviewBuild) return;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    final native = await SvaBuildStamp.fetchNativeStamp();
    if (!mounted) return;
    setState(() {
      _reviewBuildLabel = SvaBuildStamp.formatForSettings(native: native);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    if (kIsWeb) return;
    try {
      final notification = await Permission.notification.status;
      PermissionStatus? exact;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final native = ref.read(notificationServiceProvider).native;
        final allowed = await native.canScheduleExactAlarms();
        exact = allowed ? PermissionStatus.granted : PermissionStatus.denied;
        final fullScreen = await native.canUseFullScreenIntent();
        _fullScreenIntentStatus = fullScreen
            ? PermissionStatus.granted
            : PermissionStatus.denied;
      }
      if (!mounted) return;
      setState(() {
        _notificationStatus = notification;
        _exactAlarmStatus = exact;
      });
    } catch (error) {
      debugPrint('permission refresh failed: $error');
    }
  }

  Future<void> _openSupportEmail(AppLocalizations l10n) async {
    final version = ref.read(appVersionInfoProvider).asData?.value;
    final uri = SupportContact.mailtoUri(
      subject: l10n.supportEmailSubject,
      appVersion: version?.version ?? AppConstants.appVersion,
      buildNumber: version?.buildNumber ?? AppConstants.appBuildNumber,
      platformLabel: kIsWeb ? 'Web' : defaultTargetPlatform.name,
    );
    try {
      final opened = await launchUrl(uri);
      if (opened || !mounted) return;
    } catch (error) {
      debugPrint('mailto failed: $error');
    }
    if (!mounted) return;
    await Clipboard.setData(ClipboardData(text: AppConstants.supportEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.emailCopied)));
  }

  Future<void> _openExternal(String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.linkUnavailable)));
      return;
    }
    final opened =
        await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.linkUnavailable)));
    }
  }

  Future<bool> _confirmNotificationPermission(AppLocalizations l10n) async {
    final notifications = ref.read(notificationServiceProvider);
    if (await notifications.notificationPermissionGranted) return true;
    if (!mounted) return false;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationPermission),
        content: Text(l10n.openSystemSettingsHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.notificationPermission),
          ),
        ],
      ),
    );
    if (proceed != true) return false;
    final granted = await notifications.requestNotificationPermission();
    await _refreshPermissions();
    return granted;
  }

  String _permissionLabel(AppLocalizations l10n, PermissionStatus? status) {
    if (status == null) return l10n.permissionStatusUnknown;
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return l10n.permissionStatusGranted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return l10n.permissionStatusDenied;
    }
    if (status.isDenied) return l10n.permissionStatusDenied;
    return l10n.permissionStatusUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final reminder = ref.watch(reminderSettingsProvider);
    final locale = ref.watch(localeProvider);
    final versionAsync = ref.watch(appVersionInfoProvider);
    final entitlement = ref.watch(trialEntitlementProvider);
    final purchase = ref.watch(premiumPurchaseProvider);
    final versionLabel = versionAsync.maybeWhen(
      data: (info) => info.label,
      orElse: () => AppConstants.appVersion,
    );

    String themeLabel() {
      return switch (themeMode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };
    }

    String premiumLabel() {
      final base = switch (entitlement.status) {
        EntitlementStatus.trialActive =>
          entitlement.hasLessThanOneDay
              ? l10n.trialLessThanOneDay
              : l10n.trialDaysRemaining(entitlement.countdownDays),
        EntitlementStatus.subscriptionActive => l10n.premiumPurchaseActive,
        EntitlementStatus.subscriptionPending => l10n.premiumStatusPending,
        EntitlementStatus.initializing => l10n.premiumStatusLoading,
        EntitlementStatus.trialExpired => l10n.premiumTrialExpiredTitle,
        EntitlementStatus.billingUnavailable => l10n.premiumBillingUnavailable,
        EntitlementStatus.entitlementCheckFailed => l10n.premiumUnableToVerify,
      };
      final price = purchase.localizedPrice;
      return price == null ||
              entitlement.status == EntitlementStatus.subscriptionActive
          ? base
          : '$base · $price';
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
              onTap: () => _showThemePicker(context, themeMode),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.language_rounded,
              title: l10n.settingsLanguage,
              subtitle: AppLocaleSupport.displayName(l10n, locale),
              onTap: () => _showLanguagePicker(context, locale),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.settingsSoundAndVoice),
            SettingTile(
              icon: Icons.record_voice_over_rounded,
              title: l10n.settingsVoices,
              subtitle: l10n.settingsVoicesSubtitle,
              onTap: () => context.push(AppRoutes.voiceSpeech),
            ),
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.settingsAlarmsSection),
            SettingTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.settingsReminder,
              subtitle: l10n.settingsReminderSubtitle,
              trailing: Switch.adaptive(
                value: reminder.enabled,
                onChanged: (value) async {
                  if (value && !await _confirmNotificationPermission(l10n)) {
                    return;
                  }
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
            if (ReleaseConfig.showPremium) ...[
              const SizedBox(height: AppConstants.spaceXl),
              SectionHeader(title: l10n.settingsPremium),
              SettingTile(
                icon: Icons.workspace_premium_rounded,
                title: l10n.settingsPremium,
                subtitle: premiumLabel(),
                onTap: () => context.push(AppRoutes.premium),
              ),
            ],
            if (!kIsWeb) ...[
              const SizedBox(height: AppConstants.spaceXl),
              SectionHeader(title: l10n.permissionsAndBackground),
              SettingTile(
                icon: Icons.notifications_outlined,
                title: l10n.notificationPermission,
                subtitle: _permissionLabel(l10n, _notificationStatus),
                onTap: () async {
                  await openAppSettings();
                },
              ),
              if (defaultTargetPlatform == TargetPlatform.android) ...[
                const SizedBox(height: AppConstants.spaceMd),
                SettingTile(
                  icon: Icons.alarm_on_rounded,
                  title: l10n.exactAlarmPermission,
                  subtitle: _permissionLabel(l10n, _exactAlarmStatus),
                  onTap: () async {
                    await ref
                        .read(notificationServiceProvider)
                        .native
                        .openExactAlarmSettings();
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),
                SettingTile(
                  icon: Icons.fullscreen_rounded,
                  title: l10n.fullScreenAlarmPermission,
                  subtitle: _permissionLabel(l10n, _fullScreenIntentStatus),
                  onTap: () async {
                    await ref
                        .read(notificationServiceProvider)
                        .native
                        .openFullScreenIntentSettings();
                  },
                ),
              ],
              const SizedBox(height: AppConstants.spaceMd),
              SettingTile(
                icon: Icons.settings_applications_outlined,
                title: l10n.openSystemSettings,
                subtitle: l10n.openSystemSettingsHint,
                onTap: () async {
                  await openAppSettings();
                },
              ),
            ],
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.supportAndFeedback),
            SettingTile(
              icon: Icons.support_agent_rounded,
              title: l10n.contactSupport,
              subtitle: AppConstants.supportEmail,
              onTap: () => _openSupportEmail(l10n),
            ),
            if (AppConstants.hasSupportUrl) ...[
              const SizedBox(height: AppConstants.spaceMd),
              SettingTile(
                icon: Icons.help_outline_rounded,
                title: l10n.supportAndFeedback,
                subtitle: l10n.settingsLegalPlaceholder,
                onTap: () => _openExternal(AppConstants.supportUrl),
              ),
            ],
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.description_outlined,
              title: l10n.openSourceLicenses,
              subtitle: l10n.settingsLegalPlaceholder,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: versionLabel,
                  applicationLegalese: l10n.settingsAboutLegalese,
                );
              },
            ),
            if (AppConstants.hasPrivacyPolicyUrl) ...[
              const SizedBox(height: AppConstants.spaceMd),
              SettingTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacy,
                subtitle: l10n.settingsLegalPlaceholder,
                onTap: () => _openExternal(AppConstants.privacyPolicyUrl),
              ),
            ],
            if (AppConstants.hasTermsOfUseUrl) ...[
              const SizedBox(height: AppConstants.spaceMd),
              SettingTile(
                icon: Icons.gavel_outlined,
                title: l10n.settingsTerms,
                subtitle: l10n.settingsLegalPlaceholder,
                onTap: () => _openExternal(AppConstants.termsOfUseUrl),
              ),
            ],
            const SizedBox(height: AppConstants.spaceXl),
            SectionHeader(title: l10n.appInformation),
            SettingTile(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAbout,
              subtitle: l10n.settingsAboutSubtitle,
              onTap: () => context.push(AppRoutes.about),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SettingTile(
              icon: Icons.verified_outlined,
              title: l10n.appVersion,
              subtitle: versionLabel,
            ),
            SvaReviewBuildStampSection(
              visible:
                  SvaBuildStamp.reviewBuild &&
                  !kIsWeb &&
                  defaultTargetPlatform == TargetPlatform.iOS,
              stampText: _reviewBuildLabel ?? SvaBuildStamp.formatForSettings(),
            ),
            SvaReviewAlarmKitRuntimeSection(
              visible:
                  SvaBuildStamp.reviewBuild &&
                  !kIsWeb &&
                  defaultTargetPlatform == TargetPlatform.iOS,
            ),
            if (kDebugMode &&
                !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.iOS) ...[
              const SizedBox(height: AppConstants.spaceXl),
              SectionHeader(title: 'Debug'),
              SettingTile(
                icon: Icons.bug_report_outlined,
                title: l10n.iosAlarmDiagnosticsTitle,
                subtitle: 'Automated iOS alarm fixture checks',
                onTap: () => _runIosDiagnostics(context),
              ),
            ],
            if (SvaBuildStamp.reviewBuild &&
                !kDebugMode &&
                !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.iOS) ...[
              const SizedBox(height: AppConstants.spaceMd),
              SettingTile(
                icon: Icons.bug_report_outlined,
                title: l10n.iosAlarmDiagnosticsTitle,
                subtitle: 'Staged AlarmKit probe (user-initiated)',
                onTap: () => _runIosDiagnostics(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runIosDiagnostics(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.iosAlarmDiagnosticsTitle),
        content: const Text(
          'Debug diagnostics run in stages and may touch AlarmKit only if you '
          'continue past passive checks. Stop if the app becomes unstable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Run passive checks'),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.iosAlarmDiagnosticsRunning)));
    final diagnostics = IosAlarmDiagnostics(
      notifications: ref.read(notificationServiceProvider),
    );
    final report = StringBuffer(await diagnostics.runAll());
    final staged = await diagnostics.runStagedAlarmKitProbe();
    report.writeln('');
    report.writeln(staged.format());
    if (!context.mounted) return;
    await Clipboard.setData(ClipboardData(text: report.toString()));
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.iosAlarmDiagnosticsTitle),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: SelectableText(report.toString()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonClose),
          ),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report.toString()));
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.iosAlarmDiagnosticsCopy),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, ThemeMode current) {
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

  void _showLanguagePicker(BuildContext context, Locale locale) {
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
                          trailing:
                              AppLocaleSupport.localeStorageCode(option) ==
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

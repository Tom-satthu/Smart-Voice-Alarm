import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/saved_voice_usage_service.dart';
import '../../../../core/utils/time_formatters.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';

/// Lists active alarms that reference [savedVoiceId]. Pushed (not replaced)
/// so Create Alarm drafts remain on the navigation stack.
class SavedVoiceUsageScreen extends ConsumerWidget {
  const SavedVoiceUsageScreen({super.key, required this.savedVoiceId});

  final String savedVoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final drafts = ref.watch(openDraftSequenceIdsProvider);
    final service = SavedVoiceUsageService(draftSequenceIds: drafts);
    final alarms = service.alarmsUsing(savedVoiceId);

    return AppScaffold(
      showBack: true,
      title: l10n.savedVoiceUsageTitle,
      body: alarms.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceXl),
                child: Text(
                  l10n.savedVoiceUsageEmpty,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
                vertical: AppConstants.spaceMd,
              ),
              itemCount: alarms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return SurfacePanel(
                  onTap: () => context.push(AppRoutes.editAlarmPath(alarm.id)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alarm.label,
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              TimeFormatters.formatTime(alarm.time),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        alarm.isEnabled
                            ? l10n.commonEnabled
                            : l10n.commonDisabled,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: alarm.isEnabled
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

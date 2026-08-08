import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../localization/generated/app_localizations.dart';
import '../../../../router/routes.dart';
import '../../../../shared/providers/prototype_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../widgets/alarm_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    if (!ref.read(canUseMainFeaturesProvider)) {
      context.push(AppRoutes.premium);
      return;
    }
    context.push(AppRoutes.createAlarm);
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    String alarmId,
  ) async {
    if (!ref.read(canUseMainFeaturesProvider)) {
      await context.push(AppRoutes.premium);
      return;
    }
    final newId = await ref.read(alarmListProvider.notifier).duplicate(alarmId);
    if (!context.mounted) return;
    context.push(AppRoutes.editAlarmPath(newId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Loaded synchronously from the repository in AlarmListController —
    // empty means truly empty after load (no async loading flicker).
    final alarms = ref.watch(alarmListProvider);
    final canUseMainFeatures = ref.watch(canUseMainFeaturesProvider);
    final hasAlarms = alarms.isNotEmpty;

    return AppScaffold(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          tooltip: l10n.settingsTitle,
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      floatingActionButton: hasAlarms
          ? FloatingActionButton.extended(
              key: const ValueKey('home_create_alarm_fab'),
              onPressed: () => _openCreate(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.homeCreateAlarm),
            )
          : null,
      body: ResponsiveCenter(
        child: !hasAlarms
            ? EmptyStateView(
                key: const ValueKey('home_empty_create_alarm'),
                icon: Icons.alarm_add_rounded,
                title: l10n.homeEmptyTitle,
                subtitle: l10n.homeEmptySubtitle,
                actionLabel: l10n.homeCreateAlarm,
                onAction: () => _openCreate(context, ref),
              )
            : CustomScrollView(
                slivers: [
                  if (!canUseMainFeatures)
                    SliverToBoxAdapter(
                      child: SurfacePanel(
                        emphasized: true,
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded),
                            const SizedBox(width: AppConstants.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.premiumRestrictedAlarmsTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  Text(l10n.premiumRestrictedAlarmsBody),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.premium),
                              child: Text(l10n.premiumUpgrade),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppConstants.spaceSm),
                  ),
                  SliverList.separated(
                    itemCount: alarms.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppConstants.spaceMd),
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 35 * index),
                        child: AlarmListTile(
                          alarm: alarm,
                          canModify: canUseMainFeatures,
                          onToggle: () async {
                            final wasEnabled = alarm.isEnabled;
                            await ref
                                .read(alarmListProvider.notifier)
                                .toggle(alarm.id);
                            if (wasEnabled) {
                              final engine = ref.read(alarmEngineProvider);
                              await engine.dismissAlarm(alarm.id);
                              await ref
                                  .read(notificationServiceProvider)
                                  .native
                                  .stopForegroundAlarm();
                            }
                          },
                          onEdit: () =>
                              context.push(AppRoutes.editAlarmPath(alarm.id)),
                          onDuplicate: () => _duplicate(context, ref, alarm.id),
                          onDelete: () async {
                            await ref
                                .read(alarmListProvider.notifier)
                                .remove(alarm.id);
                            final engine = ref.read(alarmEngineProvider);
                            await engine.dismissAlarm(alarm.id);
                            await ref
                                .read(notificationServiceProvider)
                                .native
                                .stopForegroundAlarm();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.alarmDeleted)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
      ),
    );
  }
}

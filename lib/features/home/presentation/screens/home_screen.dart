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
    final entitlement = ref.read(premiumEntitlementProvider);
    final isPremium = ref.read(isPremiumProvider);
    final count = ref.read(alarmListProvider).length;
    if (!isPremium && !entitlement.canCreateAlarm(count)) {
      final unlocked = await context.push<bool>(
        '${AppRoutes.premium}?resumeCreate=1',
      );
      if (unlocked == true && context.mounted) {
        context.push(AppRoutes.createAlarm);
      }
      return;
    }
    context.push(AppRoutes.createAlarm);
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    String alarmId,
  ) async {
    final entitlement = ref.read(premiumEntitlementProvider);
    final isPremium = ref.read(isPremiumProvider);
    final count = ref.read(alarmListProvider).length;
    if (!isPremium && !entitlement.canDuplicateAlarm(count)) {
      await context.push('${AppRoutes.premium}?resumeCreate=1');
      return;
    }
    final newId =
        await ref.read(alarmListProvider.notifier).duplicate(alarmId);
    if (!context.mounted) return;
    context.push(AppRoutes.editAlarmPath(newId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alarms = ref.watch(alarmListProvider);

    return AppScaffold(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          tooltip: l10n.settingsTitle,
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.homeCreateAlarm),
      ),
      body: ResponsiveCenter(
        child: alarms.isEmpty
            ? EmptyStateView(
                icon: Icons.alarm_add_rounded,
                title: l10n.homeEmptyTitle,
                subtitle: l10n.homeEmptySubtitle,
                actionLabel: l10n.homeCreateAlarm,
                onAction: () => _openCreate(context, ref),
              )
            : CustomScrollView(
                slivers: [
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
                          onDuplicate: () =>
                              _duplicate(context, ref, alarm.id),
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

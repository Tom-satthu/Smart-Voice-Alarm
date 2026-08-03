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
import '../widgets/alarm_formatters.dart';
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppConstants.spaceMd,
                        bottom: AppConstants.spaceLg,
                      ),
                      child: _HomeHero(alarmCount: alarms.length),
                    ),
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
                          onToggle: () => ref
                              .read(alarmListProvider.notifier)
                              .toggle(alarm.id),
                          onEdit: () =>
                              context.push(AppRoutes.editAlarmPath(alarm.id)),
                          onDuplicate: () =>
                              _duplicate(context, ref, alarm.id),
                          onDelete: () {
                            ref
                                .read(alarmListProvider.notifier)
                                .remove(alarm.id);
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

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.alarmCount});

  final int alarmCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = TimeOfDay.now();

    return SurfacePanel(
      emphasized: true,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingForHour(l10n, now.hour),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            TimeFormatters.formatTime(now),
            style: context.textTheme.displayMedium,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            l10n.homeAlarmsReady(alarmCount),
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

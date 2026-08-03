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
import '../widgets/alarm_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
        onPressed: () => context.push(AppRoutes.createAlarm),
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
                onAction: () => context.push(AppRoutes.createAlarm),
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
                        delay: Duration(milliseconds: 40 * index),
                        child: AlarmListTile(
                          alarm: alarm,
                          onToggle: () =>
                              ref.read(alarmListProvider.notifier).toggle(alarm.id),
                          onEdit: () =>
                              context.push(AppRoutes.editAlarmPath(alarm.id)),
                          onDuplicate: () {},
                          onDelete: () => ref
                              .read(alarmListProvider.notifier)
                              .remove(alarm.id),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
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
    final now = TimeOfDay.now();

    return SurfacePanel(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TimeFormatters.formatTime(now),
                  style: context.textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  alarmCount == 1
                      ? '1 alarm ready'
                      : '$alarmCount alarms ready',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: context.colors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/settings/settings_cubit.dart';
import '../../../entities/day_key.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../shared/ui/errors.dart';
import '../../../util.dart';
import '../../event_view/ui/event_view.dart';
import 'habit_strip.dart';

class HabitCard extends StatelessWidget {
  final OrgHabit habit;
  final DayKey today;

  const HabitCard(this.habit, {required this.today, super.key});

  @override
  Widget build(BuildContext context) {
    final filesStatus = context.select(
      (OrgFilesCubit cubit) => cubit.state.status,
    );
    final tagColor = context.select(
      (SettingsCubit cubit) => cubit.state.tagColorOf(habit),
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final doneToday = habit.doneOn(today);
    final interval = habit.minDays == habit.maxDays
        ? l10n.habit_every(habit.minDays)
        : l10n.habit_every_range(habit.minDays, habit.maxDays);

    // Edits need the parsed files.
    bool canEdit() {
      switch (filesStatus) {
        case OrgFilesStatus.loading:
          showError(context, l10n.error_edit_before_loading);
          return false;
        case OrgFilesStatus.failure:
          showError(context, l10n.error_unknown);
          return false;
        case OrgFilesStatus.success:
          return true;
      }
    }

    return Card(
      elevation: 0,
      color: tagColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(
          color: colors.surfaceContainerLow,
          child: InkWell(
            onTap: () async {
              if (!canEdit()) return;
              await showDialog(
                context: context,
                builder: (_) =>
                    EventView(entry: habit, timestamp: habit.schedule),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              habit.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${l10n.habit_streak(habit.streak(today))}'
                              ' · $interval',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: doneToday
                            ? l10n.habit_done_today
                            : l10n.habit_mark_done,
                        isSelected: doneToday,
                        icon: const Icon(Icons.check_circle_outline),
                        selectedIcon: Icon(
                          Icons.check_circle,
                          color: habitStatusColor(
                            HabitStatus.due,
                            theme.brightness,
                          ),
                        ),
                        onPressed: doneToday
                            ? null
                            : () async {
                                if (!canEdit()) return;
                                await context
                                    .read<OrgFilesCubit>()
                                    .markHabitDone(habit);
                              },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HabitStrip(habit, today: today),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

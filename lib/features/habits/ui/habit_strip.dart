import 'package:flutter/material.dart';

import '../../../entities/day_key.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../util.dart';

/// The days before today in the strip.
const habitStripPastDays = 14;

/// The days after today in the strip.
const habitStripFutureDays = 6;

/// The colors of the org-habit consistency graph.
Color habitStatusColor(HabitStatus status, Brightness brightness) {
  final color = switch (status) {
    HabitStatus.early => Colors.blue,
    HabitStatus.due => Colors.green,
    HabitStatus.lastDay => Colors.amber,
    HabitStatus.overdue => Colors.red,
  };
  return brightness == Brightness.dark ? color.shade300 : color.shade600;
}

/// One square per day around today. The color shows the status of the habit
/// on that day. A solid square is a day with a completion.
class HabitStrip extends StatelessWidget {
  final OrgHabit habit;
  final DayKey today;

  const HabitStrip(this.habit, {required this.today, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 3,
      children: [
        for (
          var offset = -habitStripPastDays;
          offset <= habitStripFutureDays;
          offset++
        )
          Expanded(
            child: _DaySquare(
              habit: habit,
              day: addDays(today, offset),
              isToday: offset == 0,
              brightness: theme.brightness,
              todayBorder: theme.colorScheme.onSurface,
            ),
          ),
      ],
    );
  }
}

class _DaySquare extends StatelessWidget {
  final OrgHabit habit;
  final DayKey day;
  final bool isToday;
  final Brightness brightness;
  final Color todayBorder;

  const _DaySquare({
    required this.habit,
    required this.day,
    required this.isToday,
    required this.brightness,
    required this.todayBorder,
  });

  @override
  Widget build(BuildContext context) {
    final color = habitStatusColor(habit.statusOn(day), brightness);
    final done = habit.doneOn(day);

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: done ? color : color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(3),
          border: isToday ? Border.all(color: todayBorder, width: 1.5) : null,
        ),
      ),
    );
  }
}

/// Explains the colors of [HabitStrip].
class HabitLegend extends StatelessWidget {
  const HabitLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final labels = {
      HabitStatus.early: l10n.habit_status_early,
      HabitStatus.due: l10n.habit_status_due,
      HabitStatus.lastDay: l10n.habit_status_last_day,
      HabitStatus.overdue: l10n.habit_status_overdue,
    };

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final MapEntry(key: status, value: label) in labels.entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              SizedBox.square(
                dimension: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: habitStatusColor(status, theme.brightness),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

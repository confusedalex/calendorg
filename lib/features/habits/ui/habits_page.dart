import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/day_key.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../util.dart';
import 'habit_card.dart';
import 'habit_strip.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.select(
      (OrgFilesCubit cubit) => cubit.state.entries,
    );
    final today = dayKeyOf(DateTime.now());
    // Due habits first, then by title.
    final habits = entries.whereType<OrgHabit>().toList()
      ..sort(
        (a, b) => a.isDue(today) == b.isDue(today)
            ? a.title.compareTo(b.title)
            : (a.isDue(today) ? -1 : 1),
      );
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: context.read<OrgFilesCubit>().reload,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                context.l10n.habits,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: HabitLegend(),
            ),
          ),
          SliverList.list(
            children: [
              for (final habit in habits) HabitCard(habit, today: today),
            ],
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

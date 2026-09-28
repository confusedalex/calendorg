import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/occurrence/occurrence_getter.dart';
import '../../../util.dart';
import '../../calendar/ui/event_card.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.select(
      (OrgFilesCubit cubit) => cubit.state.entries,
    );
    final now = DateTime.now();
    const days = 3;
    final endDate = now.add(const Duration(days: days));
    final occurrences = occurrencesInRange(
      entries,
      DateTimeRange(start: now, end: endDate),
    );
    final byDay = groupBy(occurrences, (o) => dateKey(o.date));
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
                context.l10n.next_days(days),
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (occurrences.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    Text(
                      context.l10n.no_upcoming_events(days),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (final dayOccurrences in byDay.values) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Text(
                  dayLabel(context, dayOccurrences.first.date),
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverList.list(
              children:
                  (dayOccurrences..sort(
                        (a, b) => a.timestamp.startDateTime.compareTo(
                          b.timestamp.startDateTime,
                        ),
                      ))
                      .map(EventCard.new)
                      .toList(),
            ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

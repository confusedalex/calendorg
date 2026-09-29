import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/starting_day_cubit.dart';
import '../../../entities/occurrence/occurrence_getter.dart';
import '../../../util.dart';
import '../../new_section/ui/new_section_dialog.dart';
import '../model/calendar_bloc.dart';
import 'event_card.dart';
import 'event_markers.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final focusedDay = context.select(
      (CalendarBloc bloc) => bloc.state.focusedDay,
    );
    final selectedDate = context.select(
      (CalendarBloc bloc) => bloc.state.selectedDate,
    );
    final calendarFormat = context.select(
      (CalendarBloc bloc) => bloc.state.calendarFormat,
    );
    final startingDay = context.select((StartingDayCubit bloc) => bloc.state);
    final occurrencesByDate = context.select(
      (CalendarBloc bloc) => bloc.state.occurrencesByDate,
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dayEvents = [...?occurrencesByDate[dateKey(selectedDate)]]
      ..sort(
        (a, b) =>
            a.timestamp.startDateTime.compareTo(b.timestamp.startDateTime),
      );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => NewSectionDialog(
            timestamp: dateTimeToSimpleTimestamp(selectedDate, false, true),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: focusedDay,
            onPageChanged: (d) {
              context.read<CalendarBloc>().add(
                CalendarChangeFocusDateEvent(focusedDate: d),
              );
            },
            startingDayOfWeek: startingDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDate, _) =>
                context.read<CalendarBloc>().add(
                  CalendarChangeSelectedDateEvent(selectedDate: selectedDate),
                ),
            calendarFormat: calendarFormat,
            onFormatChanged: (format) => context.read<CalendarBloc>().add(
              CalendarChangeFormat(calendarFormat: format),
            ),
            eventLoader: (day) => occurrencesByDate[dateKey(day)] ?? [],
            headerStyle: HeaderStyle(
              titleTextStyle: textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              headerPadding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
              leftChevronMargin: EdgeInsets.zero,
              rightChevronMargin: const EdgeInsets.only(right: 4),
              formatButtonTextStyle: textTheme.labelLarge!,
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: colors.onSurfaceVariant,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: colors.onSurfaceVariant,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: textTheme.labelMedium!.copyWith(
                color: colors.onSurfaceVariant,
              ),
              weekendStyle: textTheme.labelMedium!.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            calendarStyle: CalendarStyle(
              cellMargin: const EdgeInsets.all(5),
              defaultTextStyle: textTheme.bodyMedium!,
              weekendTextStyle: textTheme.bodyMedium!.copyWith(
                color: colors.onSurfaceVariant,
              ),
              outsideTextStyle: textTheme.bodyMedium!.copyWith(
                color: colors.onSurface.withValues(alpha: 0.35),
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 1.5),
              ),
              todayTextStyle: textTheme.bodyMedium!.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
              selectedTextStyle: textTheme.bodyMedium!.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                return EventMarkers(
                  occurrences: occurrencesByDate[dateKey(day)] ?? [],
                );
              },
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(8, 8, 8, 8)),
          const Divider(height: 1),
          const Padding(padding: EdgeInsets.fromLTRB(8, 8, 8, 8)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: context.read<OrgFilesCubit>().reload,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (dayEvents.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          context.l10n.no_events,
                          style: textTheme.bodyMedium!.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 88),
                      sliver: SliverList.list(
                        children: dayEvents.map(EventCard.new).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

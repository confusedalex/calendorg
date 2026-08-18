import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/floating_action_button_cubit.dart';
import '../../../core/starting_day_cubit.dart';
import '../../new_section/model/new_section_cubit.dart';
import '../../new_section/ui/new_section_dialog.dart';
import '../model/calendar_bloc.dart';
import 'event_card.dart';
import 'event_markers.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  DateTimeRange visibleWindowFor(DateTime focusedDay) {
    final firstOfMonth = DateTime(focusedDay.year, focusedDay.month);
    final lastOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    return DateTimeRange(
      start: firstOfMonth.subtract(const Duration(days: 7)),
      end: lastOfMonth.add(const Duration(days: 7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime focusedDay = context.select(
      (CalendarBloc bloc) => bloc.state.focusedDay,
    );
    final DateTime selectedDate = context.select(
      (CalendarBloc bloc) => bloc.state.selectedDate,
    );
    final CalendarFormat calendarFormat = context.select(
      (CalendarBloc bloc) => bloc.state.calendarFormat,
    );
    final StartingDayOfWeek startingDay = context.select(
      (StartingDayCubit bloc) => bloc.state,
    );
    final occurrencesByDate = context
        .read<OrgFilesCubit>()
        .state
        .occurrencesByDateInRange(visibleWindowFor(focusedDay));
    String dateKey(DateTime d) => d.toIso8601String().split('T')[0];

    context.read<FloatingActionButtonCubit>().changeButton(
      FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<OrgFilesCubit>()),
              BlocProvider(create: (context) => NewSectionCubit(null, null)),
            ],
            child: NewSectionDialog(dateTime: selectedDate),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: focusedDay,
          startingDayOfWeek: startingDay,
          selectedDayPredicate: (day) {
            return isSameDay(selectedDate, day);
          },
          onDaySelected: (selectedDate, _) => context.read<CalendarBloc>().add(
            CalendarChangeSelectedDateEvent(selectedDate: selectedDate),
          ),
          calendarFormat: calendarFormat,
          onFormatChanged: (format) => context.read<CalendarBloc>().add(
            CalendarChangeFormat(calendarFormat: format),
          ),
          eventLoader: (day) => occurrencesByDate[dateKey(day)] ?? [],
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty ||
                  isSameDay(day, focusedDay) ||
                  isSameDay(day, DateTime.now())) {
                return Container();
              }
              return EventMarkers(
                occurrences: occurrencesByDate[dateKey(day)] ?? [],
              );
            },
          ),
        ),
        Expanded(
          child: ListView(
            children:
                (occurrencesByDate[dateKey(focusedDay)] ?? [])
                    .map(EventCard.new)
                    .toList()
                  ..sort(
                    (a, b) => a.occurrence.timestamp.startDateTime.compareTo(
                      b.occurrence.timestamp.startDateTime,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

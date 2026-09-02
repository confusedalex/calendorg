import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/starting_day_cubit.dart';
import '../../new_section/model/new_section_cubit.dart';
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
    String dateKey(DateTime d) => d.toIso8601String().split('T')[0];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
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
      ),
    );
  }
}

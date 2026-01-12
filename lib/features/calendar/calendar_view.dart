import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';
import 'package:calendorg/features/calendar/event_markers.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/features/new_section/cubit/new_section_cubit.dart';
import 'package:calendorg/features/new_section/new_section_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

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
    final eventsByDate = context.read<OrgFilesBloc>().state.eventsByDate;

    context.read<FloatingActionButtonCubit>().changeButton(
      FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<OrgFilesBloc>()),
              BlocProvider(create: (context) => NewSectionCubit(null, null)),
            ],
            child: NewSectionDialog(dateTime: selectedDate),
          ),
        ),
        child: Icon(Icons.add),
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
          eventLoader: eventsByDate,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty ||
                  isSameDay(day, focusedDay) ||
                  isSameDay(day, DateTime.now())) {
                return Container();
              }
              return EventMarkers(eventList: eventsByDate(day));
            },
          ),
        ),
        Expanded(
          child: ListView(
            children:
                context
                    .read<OrgFilesBloc>()
                    .state
                    .eventsByDateWithTimestamps(focusedDay)
                    .entries
                    .fold(
                      [],
                      (acc, entry) => [
                        ...acc,
                        ...entry.value.map(
                          (timestamp) => EventCard(entry.key, timestamp),
                        ),
                      ],
                    )
                  ..sort(
                    (a, b) => (a as EventCard).timestamp.startDateTime
                        .compareTo((b as EventCard).timestamp.startDateTime),
                  ),
          ),
        ),
      ],
    );
  }
}

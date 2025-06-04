import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';
import 'package:calendorg/features/calendar/event_markers.dart';
import 'package:calendorg/pages/calendar/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    context.select((CalendarBloc bloc) => bloc.state.eventList);
    final DateTime focusedDay =
        context.select((CalendarBloc bloc) => bloc.state.focusedDay);
    final DateTime selectedDate =
        context.select((CalendarBloc bloc) => bloc.state.selectedDate);
    final CalendarFormat calendarFormat =
        context.select((CalendarBloc bloc) => bloc.state.calendarFormat);

    return Column(children: [
      TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(selectedDate, day);
        },
        onDaySelected: (selectedDate, _) => context
            .read<CalendarBloc>()
            .add(CalendarChangeSelectedDateEvent(selectedDate: selectedDate)),
        calendarFormat: calendarFormat,
        onFormatChanged: (format) => context
            .read<CalendarBloc>()
            .add(CalendarChangeFormat(calendarFormat: format)),
        eventLoader: (day) => context.read<CalendarBloc>().eventsByDate(day),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty ||
                isSameDay(day, focusedDay) ||
                isSameDay(day, DateTime.now())) {
              return Container();
            }
            return EventMarkers(
                eventList: context.read<CalendarBloc>().eventsByDate(day));
          },
        ),
      ),
      Expanded(
        child: ListView(
          children: context
              .read<CalendarBloc>()
              .eventsByDateWithTimestamps(focusedDay)
              .entries
              .fold(
                  [],
                  (acc, entry) => [
                        ...acc,
                        ...entry.value
                            .map((timestamp) => EventCard(entry.key, timestamp))
                      ]),
        ),
      ),
    ]);
  }
}

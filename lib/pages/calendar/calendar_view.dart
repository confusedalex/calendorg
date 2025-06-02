import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/calendar/event_card.dart';
import 'package:calendorg/tag_color.dart';
import 'package:calendorg/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final List<Event> eventlist;
  final DateTime initialFocusedDay;

  const CalendarView(this.eventlist, this.initialFocusedDay, {super.key});

  @override
  State<CalendarView> createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  late DateTime focusedDay;
  DateTime? selectedDay;
  CalendarFormat calendarFormat = CalendarFormat.month;
  Map<Event, List<OrgTimestamp>> timestampsByEvent = {};

  @override
  void initState() {
    super.initState();
    focusedDay = widget.initialFocusedDay;
  }

  List<Event> eventsByDate(DateTime date) =>
      widget.eventlist.fold([], (acc, cur) {
        var timestampsByDate = cur.timestampsByDateTime(date);
        timestampsByEvent.addAll({cur: timestampsByDate});

        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
            },
            calendarFormat: calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                calendarFormat = format;
              });
            },
            eventLoader: (day) => eventsByDate(day),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty ||
                    isSameDay(day, focusedDay) ||
                    isSameDay(day, DateTime.now())) {
                  return Container();
                }
                return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 1,
                        children: events
                            .map<Widget>((event) =>
                                BlocBuilder<TagColorsCubit, List<TagColor>>(
                                  builder: (context, state) => CircleAvatar(
                                    radius: 7,
                                    backgroundColor: context
                                        .read<TagColorsCubit>()
                                        .getTagColor(event as Event),
                                  ),
                                ))
                            .toList()));
              },
            ),
          ),
          Expanded(
            child: ListView(
                children: eventsByDate(focusedDay).fold(
                    [],
                    (acc, cur) => [
                          ...acc,
                          ...timestampsByEvent[cur]?.map(
                                  (timestamp) => EventCard(cur, timestamp)) ??
                              []
                        ])),
          ),
        ],
      );
}

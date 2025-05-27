import 'package:calendorg/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final List<Event> eventlist;

  const CalendarPage(this.eventlist, {super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  List<Event> eventsByDate(DateTime date) =>
      widget.eventlist.where((e) => isSameDay(date, e.start)).toList();

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
            if (events.isEmpty || isSameDay(day, focusedDay)) {
              return Container();
            }
            return Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
      Expanded(
        child: ListView(
          children:
              eventsByDate(focusedDay).map((e) {
                return Card(child: ListTile(title: Text(e.title)));
              }).toList(),
        ),
      ),
    ],
  );
}

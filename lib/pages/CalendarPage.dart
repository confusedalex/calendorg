import 'package:calendorg/TagColor.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/models/TagModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Color getTagColor(Event event) => Provider.of<TagsModel>(context)
      .tagColorsFromPrefs
      .firstWhere((tagColor) => (event).tags.contains(tagColor.tag),
          orElse: () => TagColor("", Colors.blue))
      .color;

  List<Event> eventsByDate(DateTime date) =>
      widget.eventlist.fold([], (acc, cur) {
        var timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  Widget eventCard(Event event) => Card(
          child: ListTile(
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: getTagColor(event),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(event.title),
      ));

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
                return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 1,
                    children: events
                        .map<Widget>((event) => Consumer<TagsModel>(
                            builder: (context, tags, child) => Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: getTagColor(event as Event),
                                    shape: BoxShape.circle,
                                  ),
                                )))
                        .toList());
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: eventsByDate(focusedDay)
                  .map((event) => eventCard(event))
                  .toList(),
            ),
          ),
        ],
      );
}

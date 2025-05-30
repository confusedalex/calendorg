import 'package:calendorg/tag_color.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
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
  Map<Event, List<OrgGenericTimestamp>> timestampsByEvent = {};

  Color getTagColor(Event event) => Provider.of<TagColorsModel>(context)
      .tagColorsFromPrefs
      .firstWhere((tagColor) => (event).tags.contains(tagColor.tag),
          orElse: () => TagColor("", Colors.blue))
      .color;

  List<Event> eventsByDate(DateTime date) =>
      widget.eventlist.fold([], (acc, cur) {
        var timestampsByDate = cur.timestampsByDateTime(date);
        timestampsByEvent.addAll({cur: timestampsByDate});

        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  Widget eventCard(Event event, OrgGenericTimestamp timestamp) => Card(
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
          subtitle: Row(
            children: [
              Expanded(
                  child: Text(
                timestamp.toMarkup(),
                textAlign: TextAlign.left,
              )),
              if (event.tags.isNotEmpty)
                Expanded(
                    child: Text(
                  ":${event.tags.join(":")}:",
                  textAlign: TextAlign.right,
                )),
            ],
          )));

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
                            .map<Widget>((event) => Consumer<TagColorsModel>(
                                  builder: (context, tags, child) =>
                                      CircleAvatar(
                                    radius: 7,
                                    backgroundColor:
                                        getTagColor(event as Event),
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
                                  (timestamp) => eventCard(cur, timestamp)) ??
                              []
                        ])),
          ),
        ],
      );
}

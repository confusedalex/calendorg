import 'package:calendorg/event.dart';
import 'package:calendorg/pages/calendar/calendar_view.dart';
import 'package:flutter/widgets.dart';

class CalendarPage extends StatelessWidget {
  final List<Event> eventlist;
  final DateTime initialSelectedDay;
  const CalendarPage(this.eventlist, this.initialSelectedDay, {super.key});

  @override
  Widget build(BuildContext context) =>
      CalendarView(eventlist, initialSelectedDay);
}

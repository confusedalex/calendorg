import 'package:calendorg/event.dart';
import 'package:calendorg/pages/calendar/calendar_view.dart';
import 'package:flutter/widgets.dart';

class CalendarPage extends StatelessWidget {
  final List<Event> eventlist;
  const CalendarPage(this.eventlist, {super.key});

  @override
  Widget build(BuildContext context) => CalendarView(eventlist);
}

part of 'calendar_bloc.dart';

final class CalendarState {
  final List<Event> eventList;
  final DateTime focusedDay;
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final Map<Event, List<OrgTimestamp>> timestampsByEvent;

  CalendarState(
      {required this.eventList,
      required this.focusedDay,
      required this.selectedDate,
      this.calendarFormat = CalendarFormat.month,
      this.timestampsByEvent = const {}});

  CalendarState copyWith(
      {List<Event>? eventList,
      DateTime? focusedDay,
      DateTime? selectedDate,
      CalendarFormat? calendarFormat,
      Map<Event, List<OrgTimestamp>>? timestampsByEvent}) {
    return CalendarState(
        eventList: eventList ?? this.eventList,
        focusedDay: focusedDay ?? this.focusedDay,
        selectedDate: selectedDate ?? this.selectedDate,
        calendarFormat: calendarFormat ?? this.calendarFormat,
        timestampsByEvent: timestampsByEvent ?? this.timestampsByEvent);
  }
}

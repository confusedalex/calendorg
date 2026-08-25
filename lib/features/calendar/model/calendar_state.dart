part of 'calendar_bloc.dart';

final class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final Map<OrgEntry, List<OrgTimestamp>> timestampsByEvent;
  final Map<String, List<Occurrence>> occurrencesByDate;

  CalendarState({
    required this.focusedDay,
    required this.selectedDate,
    this.calendarFormat = CalendarFormat.month,
    this.timestampsByEvent = const {},
    required this.occurrencesByDate,
  });

  factory CalendarState.initial(DateTime today) {
    return CalendarState(
      selectedDate: today,
      focusedDay: today,
      occurrencesByDate: {},
    );
  }

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDate,
    CalendarFormat? calendarFormat,
    Map<OrgEntry, List<OrgTimestamp>>? timestampsByEvent,
    Map<String, List<Occurrence>>? occurrencesByDate,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDate: selectedDate ?? this.selectedDate,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      timestampsByEvent: timestampsByEvent ?? this.timestampsByEvent,
      occurrencesByDate: occurrencesByDate ?? this.occurrencesByDate,
    );
  }
}

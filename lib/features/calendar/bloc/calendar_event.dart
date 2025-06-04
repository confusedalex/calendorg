part of 'calendar_bloc.dart';

@immutable
sealed class CalendarEvent {}

final class CalendarChangeSelectedDateEvent extends CalendarEvent {
  CalendarChangeSelectedDateEvent({required this.selectedDate});
  final DateTime selectedDate;
}

final class CalendarChangeFormat extends CalendarEvent {
  CalendarChangeFormat({required this.calendarFormat});
  final CalendarFormat calendarFormat;
}

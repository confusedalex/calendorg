import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc(List<Event> eventList, DateTime today)
      : super(CalendarState(
            eventList: eventList, selectedDate: today, focusedDay: today)) {
    on<CalendarEvent>((event, emit) {});
    on<CalendarChangeFormat>((event, emit) {
      print(
          '[BLoC_LOG] Event received. Current format: ${state.calendarFormat}');
      print('[BLoC_LOG] Event received. new format: ${event.calendarFormat}');
      emit(state.copyWith(calendarFormat: event.calendarFormat));
    });
    on<CalendarChangeSelectedDateEvent>(
      (event, emit) => emit(state.copyWith(
          selectedDate: event.selectedDate, focusedDay: event.selectedDate)),
    );
  }

  List<Event> eventsByDate(DateTime date) =>
      state.eventList.fold([], (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);
        return timestampsByDate.isEmpty ? acc : [...acc, cur];
      });

  Map<Event, List<OrgTimestamp>> eventsByDateWithTimestamps(DateTime date) =>
      state.eventList.fold({}, (acc, cur) {
        final timestampsByDate = cur.timestampsByDateTime(date);

        return timestampsByDate.isEmpty ? acc : {...acc, cur: timestampsByDate};
      });
}

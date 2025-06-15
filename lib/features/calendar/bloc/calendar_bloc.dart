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
      emit(state.copyWith(calendarFormat: event.calendarFormat));
    });
    on<CalendarChangeSelectedDateEvent>(
      (event, emit) => emit(state.copyWith(
          selectedDate: event.selectedDate, focusedDay: event.selectedDate)),
    );
  }


}

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:org_parser/org_parser.dart';

part 'date_picker_event.dart';
part 'date_picker_state.dart';

class DatePickerBloc extends Bloc<DatePickerEvent, DatePickerState> {
  DatePickerBloc(OrgTimestamp timestamp)
      : super(DatePickerState.initial(timestamp)) {
    on<DatePickerEvent>((event, emit) {
      switch (event) {
        case DatePickerStartDateChanged():
          emit(state.copyWith(startDate: event.startDate));
        case DatePickerStartTimeActiveChanged():
          emit(state.copyWith(startTimeActive: event.startTimeActive));
        case DatePickerStartDurationChanged():
          emit(state.copyWith(startTimeDuration: event.startTimeDuration));
        case DatePickerEndTimeActiveChanged():
          emit(state.copyWith(endTimeActive: event.endTimeActive));
        case DatePickerEndDateActiveChanged():
          emit(state.copyWith(endDateActive: event.endDateActive));
        case DatePickerEndDateChanged():
          emit(state.copyWith(endDate: event.endDate));
        case DatePickerEndDurationChanged():
          emit(state.copyWith(endTimeDuration: event.endTimeDuration));
      }
    });
  }
}

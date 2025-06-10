import 'package:bloc/bloc.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
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
        case DatePickerEndTimeActiveChanged():
          emit(state.copyWith(endTimeActive: event.endTimeActive));
        case DatePickerEndDateActiveChanged():
          emit(state.copyWith(endDateActive: event.endDateActive));
        case DatePickerEndDateChanged():
          emit(state.copyWith(endDate: event.endDate));
        case DatePickerTimeChanged():
          event.type == "end"
              ? emit(state.copyWith(endTimeDuration: event.timeDuration))
              : emit(state.copyWith(startTimeDuration: event.timeDuration));
      }
    });
  }

  void datePickerDatePressed(context, String type) async {
    if (type == "start") {
      final DateTime? pickerDate = await showDatePicker(
          context: context,
          firstDate: DateTime(0),
          lastDate: state.endDate ?? DateTime(3000));

      if (pickerDate != null) {
        add(DatePickerStartDateChanged(pickerDate));
      }
      return;
    }
    if (type == "end") {
      final DateTime? pickerDate = await showDatePicker(
          context: context,
          firstDate: state.startDate,
          lastDate: DateTime(3000));

      if (pickerDate != null) {
        add(DatePickerEndDateChanged(pickerDate));
      }
      return;
    }
  }

  void datePickerTimePressed(context, String type) async {
    final TimeOfDay? time = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 12, minute: 00));

    if (time == null) return;
    add(DatePickerTimeChanged(time, type));
  }

  OrgTimestamp generateTimestamp() {
    final DateTime startDate = state.startTimeActive
        ? DateTime(
            state.startDate.year,
            state.startDate.month,
            state.startDate.day,
            state.startTimeDuration.hour,
            state.startTimeDuration.minute)
        : state.startDate;
    final DateTime? endDate = state.endTimeActive
        ? DateTime(
            state.endDate!.year,
            state.endDate!.month,
            state.endDate!.day,
            state.endTimeDuration.hour,
            state.endTimeDuration.minute)
        : state.endDate;

    if (state.endDateActive && state.endDate != null) {
      return dateTimeToTimeRangeTimestamp(startDate, endDate!, true,
          state.startTimeActive, state.endTimeActive);
    } else if (state.startTimeActive && state.endTimeActive) {
      return dateTimeToTimeRangeTimestamp(
          startDate,
          startDate.copyWith(
              hour: state.endTimeDuration.hour,
              minute: state.endTimeDuration.minute),
          true,
          true,
          true);
    } else {
      return dateTimeToSimpleTimestamp(startDate, state.startTimeActive, true);
    }
  }
}

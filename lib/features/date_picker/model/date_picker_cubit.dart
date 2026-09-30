import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';

import '../../../util.dart';

part 'date_picker_state.dart';

class DatePickerCubit extends Cubit<DatePickerState> {
  DatePickerCubit(super.initialState);

  void changeStartDate(DateTime startDate) =>
      emit(state.copyWith(startDate: startDate));

  void changeStartTimeActive(bool startTimeActive) => emit(
    state.copyWith(
      startTimeActive: startTimeActive,
      endTimeActive:
          state.endTimeActive && (startTimeActive || state.endDateActive),
    ),
  );

  void changeEndTimeActive(bool endTimeActive) =>
      emit(state.copyWith(endTimeActive: endTimeActive));

  void changeEndDateActive(bool endDateActive) => emit(
    state.copyWith(
      endDateActive: endDateActive,
      endTimeActive:
          state.endTimeActive && (endDateActive || state.startTimeActive),
    ),
  );

  void changeEndDate(DateTime endDate) =>
      emit(state.copyWith(endDate: () => endDate));

  void changeTime(TimeOfDay time, DatePickerType type) => emit(
    type == DatePickerType.end
        ? state.copyWith(endTime: time)
        : state.copyWith(startTime: time),
  );
}

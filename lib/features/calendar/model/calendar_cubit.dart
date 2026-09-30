import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/occurrence/occurrence.dart';
import '../../../entities/occurrence/occurrence_getter.dart';
import '../../../entities/org_entry/org_entry.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(DateTime today, OrgFilesCubit orgFilesCubit)
    : _orgFilesCubit = orgFilesCubit,
      super(CalendarState.initial(today)) {
    _orgFilesSub = _orgFilesCubit.stream
        .map((state) => state.entries)
        .distinct(identical)
        .listen((_) => _reloadOccurrencesByDate());
    _reloadOccurrencesByDate();
  }
  final OrgFilesCubit _orgFilesCubit;
  late final StreamSubscription<List<OrgEntry>> _orgFilesSub;

  void changeFormat(CalendarFormat calendarFormat) =>
      emit(state.copyWith(calendarFormat: calendarFormat));

  void selectDate(DateTime selectedDate) => emit(
    state.copyWith(selectedDate: selectedDate, focusedDay: selectedDate),
  );

  void focusDate(DateTime focusedDate) {
    emit(state.copyWith(focusedDay: focusedDate));
    _reloadOccurrencesByDate();
  }

  DateTimeRange _visibleWindowFor(DateTime focusedDay) {
    final firstOfMonthBefore = DateTime(focusedDay.year, focusedDay.month - 1);
    final lastOfMonthAfter = DateTime(focusedDay.year, focusedDay.month + 2, 0);
    return DateTimeRange(
      start: firstOfMonthBefore.subtract(const Duration(days: 7)),
      end: lastOfMonthAfter.add(const Duration(days: 7)),
    );
  }

  void _reloadOccurrencesByDate() {
    final range = _visibleWindowFor(state.focusedDay);
    final selectedDateInRange =
        state.selectedDate.compareTo(range.start) >= 0 &&
        state.selectedDate.compareTo(range.end) <= 0;

    final occurrences = occurrencesByDateInRange(_orgFilesCubit.state.entries, [
      range,
      if (!selectedDateInRange)
        DateTimeRange(start: state.selectedDate, end: state.selectedDate),
    ]);

    emit(state.copyWith(occurrencesByDate: occurrences));
  }

  @override
  Future<void> close() async {
    await _orgFilesSub.cancel();
    return super.close();
  }
}

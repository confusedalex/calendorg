import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/occurrence/occurrence.dart';
import '../../../entities/org_entry/org_entry.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc(DateTime today, OrgFilesCubit orgFilesCubit)
    : _orgFilesCubit = orgFilesCubit,
      super(CalendarState.initial(today)) {
    on<CalendarChangeFormat>(_onFormatChanged);
    on<CalendarChangeSelectedDateEvent>(_onSelectedDateChanged);
    on<CalendarChangeFocusDateEvent>(
      _onFocusDateChanged,
      transformer: restartable(),
    );
    on<_OrgFilesChanged>(_onOrgFilesChanged, transformer: restartable());

    _orgFilesSub = _orgFilesCubit.stream.listen((_) => add(_OrgFilesChanged()));
    add(_OrgFilesChanged());
  }
  final OrgFilesCubit _orgFilesCubit;
  late final StreamSubscription _orgFilesSub;

  DateTimeRange _visibleWindowFor(DateTime focusedDay) {
    final firstOfMonthBefore = DateTime(focusedDay.year, focusedDay.month - 1);
    final lastOfMonthAfter = DateTime(focusedDay.year, focusedDay.month + 2, 0);
    return DateTimeRange(
      start: firstOfMonthBefore.subtract(const Duration(days: 7)),
      end: lastOfMonthAfter.add(const Duration(days: 7)),
    );
  }

  Future<void> _onOrgFilesChanged(
    _OrgFilesChanged event,
    Emitter<CalendarState> emit,
  ) async {
    final occurrences = await _orgFilesCubit.state.occurrencesByDateInRange(
      _visibleWindowFor(state.focusedDay),
    );
    emit(state.copyWith(occurrencesByDate: occurrences));
  }

  Future<void> _onFocusDateChanged(
    CalendarChangeFocusDateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(focusedDay: event.focusedDate));
    final occurrences = await _orgFilesCubit.state.occurrencesByDateInRange(
      _visibleWindowFor(event.focusedDate),
    );
    emit(state.copyWith(occurrencesByDate: occurrences));
  }

  void _onSelectedDateChanged(
    CalendarChangeSelectedDateEvent event,
    Emitter<CalendarState> emit,
  ) => emit(
    state.copyWith(
      selectedDate: event.selectedDate,
      focusedDay: event.selectedDate,
    ),
  );

  void _onFormatChanged(
    CalendarChangeFormat event,
    Emitter<CalendarState> emit,
  ) => emit(state.copyWith(calendarFormat: event.calendarFormat));

  @override
  Future<void> close() async {
    await _orgFilesSub.cancel();
    return super.close();
  }
}

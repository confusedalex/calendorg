import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../shared/config/preferences_service.dart';

class StartingDayCubit extends Cubit<StartingDayOfWeek> {
  StartingDayCubit(this._prefs) : super(StartingDayOfWeek.monday);

  final PreferencesService _prefs;

  Future<void> changeStartingDayOfWeek(StartingDayOfWeek day) async {
    await _prefs.setInt(PrefKeys.startingDay, getWeekdayNumber(day) - 1);
    emit(day);
  }

  Future<void> setInititalStartingDay() async {
    try {
      final dayValue = (await _prefs.getInt(PrefKeys.startingDay)) ?? 0;
      if (dayValue >= 0 && dayValue < StartingDayOfWeek.values.length) {
        emit(StartingDayOfWeek.values[dayValue]);
      } else {
        emit(StartingDayOfWeek.monday);
      }
    } on Exception {
      emit(StartingDayOfWeek.monday);
    }
  }
}

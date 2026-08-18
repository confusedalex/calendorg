import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class StartingDayCubit extends Cubit<StartingDayOfWeek> {
  StartingDayCubit() : super(StartingDayOfWeek.monday);

  Future<void> changeStartingDayOfWeek(StartingDayOfWeek day) async {
    await SharedPreferencesAsync().setInt(
      'startingDay',
      getWeekdayNumber(day) - 1,
    );
    emit(day);
  }

  Future<void> setInititalStartingDay() async {
    try {
      final dayValue =
          (await SharedPreferencesAsync().getInt('startingDay')) ?? 0;
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

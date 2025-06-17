import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class StartingDayCubit extends Cubit<StartingDayOfWeek> {
  late final SharedPreferences prefs;

  StartingDayCubit() : super(StartingDayOfWeek.monday);

  void changeStartingDayOfWeek(StartingDayOfWeek day) {
    prefs.setInt("startingDay", getWeekdayNumber(day) - 1);
    emit(day);
  }

  Future<StartingDayOfWeek> loadStartingDay() async {
    prefs = await SharedPreferences.getInstance();
    return StartingDayOfWeek.values[(prefs.getInt("startingDay") ?? 0)];
  }

  Future<void> setInititalStartingDay() async {
    emit(await loadStartingDay());
  }
}

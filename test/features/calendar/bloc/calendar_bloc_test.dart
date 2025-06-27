import 'package:bloc_test/bloc_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test/test.dart';
import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';

void main() {
  group(
    "CalendarBloc tests",
    () {
      late CalendarBloc bloc;

      setUp(() {
        bloc = CalendarBloc([], DateTime(2025, 05, 15));
      });

      test("Initial format is month", () {
        expect(bloc.state.calendarFormat, equals(CalendarFormat.month));
      });

      blocTest(
        "Changing CalendarFormat works",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(CalendarChangeFormat(calendarFormat: CalendarFormat.week)),
        expect: () => [
          TypeMatcher<CalendarState>().having((state) => state.calendarFormat,
              "Calendar Format", equals(CalendarFormat.week))
        ],
      );

      blocTest(
        "Changing selected Day works",
        build: () => bloc,
        act: (bloc) => bloc.add(CalendarChangeSelectedDateEvent(
            selectedDate: DateTime(2025, 05, 16))),
        expect: () => [
          TypeMatcher<CalendarState>().having((state) => state.selectedDate,
              "selected Date", equals(DateTime(2025, 05, 16)))
        ],
      );
    },
  );
}

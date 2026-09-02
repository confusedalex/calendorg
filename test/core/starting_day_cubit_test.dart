import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test/test.dart';

import '../helpers/preferences.dart';

void main() {
  group('Starting Day Cubit Tests', () {
    test('Initial Starting Day is monday', () {
      final cubit = StartingDayCubit(inMemoryPreferences());
      expect(cubit.state, equals(StartingDayOfWeek.monday));
    });

    blocTest(
      'Switchting Starting Day works',
      build: () => StartingDayCubit(inMemoryPreferences()),
      act: (bloc) => bloc.changeStartingDayOfWeek(StartingDayOfWeek.sunday),
      expect: () => [StartingDayOfWeek.sunday],
    );

    blocTest(
      'Loading Starting Day from Shared Preferences works',
      build: () =>
          StartingDayCubit(inMemoryPreferences({'startingDay': 4}))
            ..setInititalStartingDay(),
      expect: () => [StartingDayOfWeek.friday],
    );
  });
}

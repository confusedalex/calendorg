import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Starting Day Cubit Tests', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('Initial Starting Day is monday', () {
      final cubit = StartingDayCubit();
      expect(cubit.state, equals(StartingDayOfWeek.monday));
    });

    blocTest(
      'Switchting Starting Day works',
      build: StartingDayCubit.new,
      act: (bloc) => bloc.changeStartingDayOfWeek(StartingDayOfWeek.sunday),
      expect: () => [StartingDayOfWeek.sunday],
    );

    blocTest(
      'Loading Starting Day from Shared Preferences works',
      setUp: () => SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'startingDay': 4}),
      build: () => StartingDayCubit()..setInititalStartingDay(),
      expect: () => [StartingDayOfWeek.friday],
    );
  });
}

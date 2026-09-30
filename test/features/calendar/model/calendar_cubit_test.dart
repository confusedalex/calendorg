import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/calendar/model/calendar_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test/test.dart';

class MockOrgFilesCubit extends Mock implements OrgFilesCubit {
  @override
  Stream<OrgFilesState> get stream => const Stream.empty();
  @override
  OrgFilesState get state => OrgFilesState.initial();
}

void main() {
  group('CalendarCubit tests', () {
    late CalendarCubit cubit;

    setUp(() {
      cubit = CalendarCubit(DateTime(2025, 05, 15), MockOrgFilesCubit());
    });

    test('Initial format is month', () {
      expect(cubit.state.calendarFormat, equals(CalendarFormat.month));
    });

    blocTest(
      'Changing CalendarFormat works',
      build: () => cubit,
      act: (cubit) => cubit.changeFormat(CalendarFormat.week),
      expect: () => [
        const TypeMatcher<CalendarState>().having(
          (state) => state.calendarFormat,
          'Calendar Format',
          equals(CalendarFormat.week),
        ),
      ],
    );

    blocTest(
      'Changing selected Day works',
      build: () => cubit,
      act: (cubit) => cubit.selectDate(DateTime(2025, 05, 16)),
      expect: () => [
        const TypeMatcher<CalendarState>().having(
          (state) => state.selectedDate,
          'selected Date',
          equals(DateTime(2025, 05, 16)),
        ),
      ],
    );

    blocTest(
      'Changing focused Day works',
      build: () => cubit,
      act: (cubit) => cubit.focusDate(DateTime(2025, 07)),
      verify: (cubit) =>
          expect(cubit.state.focusedDay, equals(DateTime(2025, 07))),
    );
  });
}

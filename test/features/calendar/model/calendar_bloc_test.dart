import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/calendar/model/calendar_bloc.dart';
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
  group('CalendarBloc tests', () {
    late CalendarBloc bloc;

    setUp(() {
      bloc = CalendarBloc(DateTime(2025, 05, 15), MockOrgFilesCubit());
    });

    test('Initial format is month', () {
      expect(bloc.state.calendarFormat, equals(CalendarFormat.month));
    });

    blocTest(
      'Changing CalendarFormat works',
      build: () => bloc,
      skip: 1,
      act: (bloc) =>
          bloc.add(CalendarChangeFormat(calendarFormat: CalendarFormat.week)),
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
      build: () => bloc,
      skip: 1,
      act: (bloc) => bloc.add(
        CalendarChangeSelectedDateEvent(selectedDate: DateTime(2025, 05, 16)),
      ),
      expect: () => [
        const TypeMatcher<CalendarState>().having(
          (state) => state.selectedDate,
          'selected Date',
          equals(DateTime(2025, 05, 16)),
        ),
      ],
    );
  });
}

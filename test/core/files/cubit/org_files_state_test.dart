import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

void main() {
  group("OrgFilesState", () {
    test('', () async {});
    group('initial', () {
      test('initial state should be loading', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.status, OrgFilesStatus.loading);
      });
      test('initial state should have empty errors', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.errors, isEmpty);
      });
      test('initial state should have empty filePaths', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.filePaths, isEmpty);
      });
      test('initial state should have empty documentsMap', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.documentsMap, isEmpty);
      });
      test('initial state should have empty allEvents', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.entries, isEmpty);
      });
      test('initial state should have null directory', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.directory, isNull);
      });
      test('initial state should have default todoStates', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        expect(cubit.state.todoStates.todo, ["TODO"]);
        expect(cubit.state.todoStates.done, ["DONE"]);
        expect(cubit.state.todoStates.ignored, []);
      });
    });
    group('eventsByDate()', () {
      test('should return empty list for date with no events', () {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        final events = cubit.state.eventsByDate(DateTime.now());

        expect(events, isEmpty);
      });
    });
  });
}

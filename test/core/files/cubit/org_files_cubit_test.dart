import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:calendorg/core/files/cubit/org_files_cubit.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeDirectoryInfo extends Fake implements DirectoryInfo {}

void main() {
  group("OrgFilesCubit", () {
    setUpAll(() {
      registerFallbackValue(FakeDirectoryInfo());
    });
    group('setOrgDirectory()', () {
      test('should save directory in repository', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        when(() => repository.saveDirectory(any())).thenAnswer((_) async {});

        await cubit.setOrgDirectory(FakeDirectoryInfo());

        verify(() => repository.saveDirectory(any())).called(1);
      });
      test('should emit new state with updated directory', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        when(() => repository.saveDirectory(any())).thenAnswer((_) async {});

        final newDirectory = FakeDirectoryInfo();
        await cubit.setOrgDirectory(newDirectory);

        expect(cubit.state.directory, newDirectory);
        expect(cubit.state.directory, isNotNull);
      });
    });
  });
}

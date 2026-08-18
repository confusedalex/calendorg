import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';
import 'package:test/test.dart';
import 'package:calendorg/core/files/cubit/org_files_cubit.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeDirectoryInfo extends Fake implements DirectoryInfo {}

class FakeFileInfo extends Fake implements FileInfo {}

class FakeOrgDocument extends Fake implements OrgDocument {}

void main() {
  group('OrgFilesCubit', () {
    setUpAll(() {
      registerFallbackValue(FakeDirectoryInfo());
      registerFallbackValue(FakeFileInfo());
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
    group('addFilePath()', () {
      test('should save file list in repository', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        when(
          () => repository.loadDocument(any()),
        ).thenAnswer((_) async => FakeOrgDocument());
        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseAllEntries(any(), any()),
        ).thenAnswer((_) async => []);

        await cubit.addFilePath(FakeFileInfo());

        verify(() => repository.saveFileList(any())).called(1);
      });
      test(
        'should emit new state with updated file paths and documents map',
        () async {
          final repository = MockOrgFilesRepository();
          final cubit = OrgFilesCubit(repository);

          final fakeFileInfo = FakeFileInfo();
          when(
            () => repository.loadDocument(fakeFileInfo),
          ).thenAnswer((_) async => FakeOrgDocument());
          when(() => repository.saveFileList(any())).thenAnswer((_) async {});
          when(
            () => repository.parseAllEntries(any(), any()),
          ).thenAnswer((_) async => []);

          await cubit.addFilePath(fakeFileInfo);

          expect(cubit.state.filePaths.contains(fakeFileInfo), isTrue);
          expect(cubit.state.documentsMap.containsKey(fakeFileInfo), isTrue);
        },
      );
    });
    group('removeFilePath()', () {
      test('should save file list in repository', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        when(() => repository.saveFileList(any())).thenAnswer((_) async {});

        final fakeFileInfo = FakeFileInfo();
        await cubit.removeFilePath(fakeFileInfo);

        verify(() => repository.saveFileList(any())).called(1);
      });
      test(
        'should emit new state with updated file paths and documents map',
        () async {
          final repository = MockOrgFilesRepository();
          final cubit = OrgFilesCubit(repository);

          final fakeFileInfo = FakeFileInfo();
          when(() => repository.saveFileList(any())).thenAnswer((_) async {});

          await cubit.removeFilePath(fakeFileInfo);

          expect(cubit.state.filePaths.contains(fakeFileInfo), isFalse);
          expect(cubit.state.documentsMap.containsKey(fakeFileInfo), isFalse);
        },
      );
    });
  });
}

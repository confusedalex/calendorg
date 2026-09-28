import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/entities/org_entry/entry_edit.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';
import 'package:test/test.dart';

import '../../../helpers/entries.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeDirectoryInfo extends Fake implements DirectoryInfo {}

class FakeFileInfo extends Fake implements FileInfo {}

void main() {
  group('OrgFilesCubit', () {
    setUpAll(() {
      registerFallbackValue(FakeDirectoryInfo());
      registerFallbackValue(FakeFileInfo());
      registerFallbackValue(
        OrgTodoStatesWithIgnored(todo: [], done: [], ignored: []),
      );
      registerFallbackValue(const EntryEdit());
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

        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});

        await cubit.addFilePath(FakeFileInfo());

        verify(() => repository.saveFileList(any())).called(1);
      });
      test('should emit new state with updated file paths', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        final fakeFileInfo = FakeFileInfo();
        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});

        await cubit.addFilePath(fakeFileInfo);

        expect(cubit.state.filePaths.contains(fakeFileInfo), isTrue);
      });
    });
    group('removeFilePath()', () {
      test('should save file list in repository', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});

        final fakeFileInfo = FakeFileInfo();
        await cubit.removeFilePath(fakeFileInfo);

        verify(() => repository.saveFileList(any())).called(1);
      });
      test('should emit new state with updated file paths', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        final fakeFileInfo = FakeFileInfo();
        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});

        await cubit.removeFilePath(fakeFileInfo);

        expect(cubit.state.filePaths.contains(fakeFileInfo), isFalse);
      });
    });
    group('applyEdit()', () {
      final entry = parseEntries(
        OrgDocument.parse('* Exam\n<2026-05-01>\n'),
      ).single;
      final fileInfo = FileInfo(
        identifier: 'test-identifier',
        persistable: false,
        uri: 'file:///test.org',
        fileName: entry.filePath,
      );

      setUpAll(() => registerFallbackValue(entry));

      Future<OrgFilesCubit> cubitWithFile(
        MockOrgFilesRepository repository,
      ) async {
        when(() => repository.saveDirectory(any())).thenAnswer((_) async {});
        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => [entry]);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});
        final cubit = OrgFilesCubit(repository);
        await cubit.setOrgDirectory(FakeDirectoryInfo());
        await cubit.addFilePath(fileInfo);
        return cubit;
      }

      test('should end in success when the repository saves nothing', () async {
        final repository = MockOrgFilesRepository();
        final cubit = await cubitWithFile(repository);
        when(
          () => repository.applyEdit(any(), any(), any(), any(), any()),
        ).thenAnswer((_) async => null);

        await cubit.applyEdit(entry, const EntryEdit(newTitle: 'New'));

        expect(cubit.state.status, OrgFilesStatus.success);
        expect(cubit.state.entries, [entry]);
      });

      test('should end in success when the repository throws', () async {
        final repository = MockOrgFilesRepository();
        final cubit = await cubitWithFile(repository);
        when(
          () => repository.applyEdit(any(), any(), any(), any(), any()),
        ).thenThrow(Exception('disk full'));

        await cubit.applyEdit(entry, const EntryEdit(newTitle: 'New'));

        expect(cubit.state.status, OrgFilesStatus.success);
      });
    });
  });
}

import 'dart:async';

import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/entities/org_entry/entry_edit.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/entries.dart';
import '../services/org_file_persistence_service_test.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeDirectoryInfo extends Fake implements DirectoryInfo {}

class FakeFileInfo extends Fake implements FileInfo {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

        await cubit.addFilePath(fakeFileInfo('work'));

        verify(() => repository.saveFileList(any())).called(1);
      });
      test('should emit new state with updated file paths', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        final file = fakeFileInfo('work');
        when(() => repository.saveFileList(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});

        await cubit.addFilePath(file);

        expect(cubit.state.filePaths.contains(file), isTrue);
      });
      test('should not allow adding of inboxFile', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        final inboxFile = fakeFileInfo('inbox');
        when(() => repository.saveInboxFile(any())).thenAnswer((_) async {});
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});

        await cubit.changeInboxFile(inboxFile);
        await cubit.addFilePath(inboxFile);

        expect(cubit.state.filePaths, isEmpty);
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
    group('reload()', () {
      final oldEntry = parseEntries(
        OrgDocument.parse('* Exam\n<2026-05-01>\n'),
      ).single;
      final newEntry = parseEntries(
        OrgDocument.parse('* Exam\n<2026-05-02>\n'),
        fileHash: 'new-hash',
      ).single;
      final todoStates = OrgTodoStatesWithIgnored(
        todo: ['TODO'],
        done: ['DONE'],
        ignored: [],
      );

      Future<OrgFilesCubit> loadedCubit(
        MockOrgFilesRepository repository,
      ) async {
        when(
          () => repository.loadCachedEntries(any()),
        ).thenAnswer((_) async => null);
        when(() => repository.loadInitialState(any(), any())).thenAnswer(
          (_) async => InitialState(
            dirInfo: FakeDirectoryInfo(),
            fileInfos: {},
            inboxFile: null,
            todoStates: todoStates,
            entries: [oldEntry],
          ),
        );
        when(
          () => repository.cacheOrgEntries(any(), any()),
        ).thenAnswer((_) async {});
        final cubit = OrgFilesCubit(repository);
        await cubit.init(todoStates);
        return cubit;
      }

      test('should emit the entries of changed files', () async {
        final repository = MockOrgFilesRepository();
        final cubit = await loadedCubit(repository);
        when(
          () => repository.parseEntriesForFiles(any(), any(), any(), any()),
        ).thenAnswer((_) async => [newEntry]);

        await cubit.reload();

        expect(cubit.state.entries, [newEntry]);
        verify(
          () =>
              repository.parseEntriesForFiles(any(), any(), any(), [oldEntry]),
        ).called(1);
        verify(() => repository.cacheOrgEntries([newEntry], any())).called(1);
      });

      test('should not emit when no file changed', () async {
        final repository = MockOrgFilesRepository();
        final cubit = await loadedCubit(repository);
        final before = cubit.state.entries;
        when(
          () => repository.parseEntriesForFiles(any(), any(), any(), any()),
        ).thenAnswer((_) async => [oldEntry]);

        await cubit.reload();

        expect(cubit.state.entries, same(before));
      });

      test('should do nothing before the files are loaded', () async {
        final repository = MockOrgFilesRepository();
        final cubit = OrgFilesCubit(repository);

        await cubit.reload();

        verifyNever(
          () => repository.parseEntriesForFiles(any(), any(), any(), any()),
        );
      });

      test('should run only once when called twice', () async {
        final repository = MockOrgFilesRepository();
        final cubit = await loadedCubit(repository);
        final result = Completer<List<OrgEntry>>();
        when(
          () => repository.parseEntriesForFiles(any(), any(), any(), any()),
        ).thenAnswer((_) => result.future);

        final first = cubit.reload();
        final second = cubit.reload();
        result.complete([newEntry]);
        await Future.wait([first, second]);

        verify(
          () => repository.parseEntriesForFiles(any(), any(), any(), any()),
        ).called(1);
      });

      test('should drop the result when entries changed meanwhile', () async {
        final repository = MockOrgFilesRepository();
        final cubit = await loadedCubit(repository);
        final result = Completer<List<OrgEntry>>();
        when(
          () => repository.parseEntriesForFiles(any(), any(), any(), any()),
        ).thenAnswer((_) => result.future);
        when(
          () => repository.parseEntriesForFiles(any(), any(), any()),
        ).thenAnswer((_) async => []);

        final reload = cubit.reload();
        await cubit.changeTodoStates(todoStates);
        result.complete([newEntry]);
        await reload;

        expect(cubit.state.entries, isEmpty);
      });
    });
  });
}

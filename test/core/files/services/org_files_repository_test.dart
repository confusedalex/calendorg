import 'dart:io';

import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/files/services/org_parser_service.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:calendorg/shared/org_text_hash.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/entries.dart';

class MockFilePickerWritable extends Mock implements FilePickerWritable {}

class MockOrgFilePersistenceService extends Mock
    implements OrgFilePersistenceService {}

class MockOrgParserService extends Mock implements OrgParserService {}

void main() {
  const markup = '* Exam\n<2026-05-01>\n';
  final fileInfo = FileInfo(
    identifier: 'test-identifier',
    persistable: false,
    uri: 'file:///test.org',
    fileName: 'test.org',
  );
  final dirInfo = DirectoryInfo(
    identifier: 'dir-identifier',
    persistable: false,
    uri: 'file:///',
  );

  late MockFilePickerWritable filePicker;
  late MockOrgParserService parserService;
  late OrgFilesRepository repository;

  setUpAll(() {
    registerFallbackValue((FileInfo _, File _) => Future.value(''));
  });

  setUp(() {
    filePicker = MockFilePickerWritable();
    parserService = MockOrgParserService();
    repository = OrgFilesRepository(
      filePicker: filePicker,
      persistence: MockOrgFilePersistenceService(),
      parserService: parserService,
    );

    when(
      () => filePicker.resolveRelativePath(
        directoryIdentifier: dirInfo.identifier,
        relativePath: fileInfo.fileName!,
      ),
    ).thenAnswer((_) async => fileInfo);
    when(
      () => filePicker.readFile<String>(
        identifier: fileInfo.identifier,
        reader: any(named: 'reader'),
      ),
    ).thenAnswer((_) async => markup);
    when(
      () => parserService.parseContentInBackground(markup),
    ).thenAnswer((_) async => OrgDocument.parse(markup));
    when(
      () => parserService.todoStates,
    ).thenReturn(OrgTodoStatesWithIgnored.defaults);
  });

  group('parseEntriesForFiles', () {
    test('reuses the cached entries when the file hash matches', () async {
      final cached = parseEntries(
        OrgDocument.parse(markup),
        fileHash: orgTextHash(markup),
      );

      final entries = await repository.parseEntriesForFiles(
        dirInfo,
        [fileInfo],
        [],
        cached,
      );

      expect(identical(entries.first, cached.first), isTrue);
      verifyNever(() => parserService.parseContentInBackground(any()));
    });

    test('parses the file when the cached hash is stale', () async {
      final cached = parseEntries(OrgDocument.parse(markup), fileHash: 'stale');

      final entries = await repository.parseEntriesForFiles(
        dirInfo,
        [fileInfo],
        [],
        cached,
      );

      expect(identical(entries.first, cached.first), isFalse);
      expect(entries.first.fileHash, orgTextHash(markup));
      verify(() => parserService.parseContentInBackground(markup)).called(1);
    });

    test('parses the file when nothing is cached', () async {
      final entries = await repository.parseEntriesForFiles(dirInfo, [
        fileInfo,
      ], []);

      expect(entries.single.title, 'Exam');
      verify(() => parserService.parseContentInBackground(markup)).called(1);
    });

    test('returns nothing when the directory is unknown', () async {
      final entries = await repository.parseEntriesForFiles(null, [
        fileInfo,
      ], []);

      expect(entries, isEmpty);
    });
  });
}

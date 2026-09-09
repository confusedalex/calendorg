import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:calendorg/core/files/services/org_file_service.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/files/services/org_parser_service.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/shared/org_text_hash.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/entries.dart';

class MockOrgFileService extends Mock implements OrgFileService {}

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

  late MockOrgFileService fileService;
  late OrgFilesRepository repository;

  setUp(() {
    fileService = MockOrgFileService();
    repository = OrgFilesRepository(
      fileService: fileService,
      persistence: MockOrgFilePersistenceService(),
      parserService: MockOrgParserService(),
      eventParserService: EventParserService(),
    );

    when(
      () => fileService.readText(fileInfo.identifier),
    ).thenAnswer((_) async => markup);
    when(() => fileService.parseText(markup)).thenAnswer(
      (_) async => ParsedFile(
        document: OrgDocument.parse(markup),
        hash: orgTextHash(markup),
      ),
    );
  });

  group('parseEntriesForFiles', () {
    test('reuses the cached entries when the file hash matches', () async {
      final cached = parseEntries(
        OrgDocument.parse(markup),
        fileHash: orgTextHash(markup),
      );

      final entries = await repository.parseEntriesForFiles(
        [fileInfo],
        [],
        cached,
      );

      expect(identical(entries.first, cached.first), isTrue);
      verifyNever(() => fileService.parseText(any()));
    });

    test('parses the file when the cached hash is stale', () async {
      final cached = parseEntries(
        OrgDocument.parse(markup),
        fileHash: 'stale',
      );

      final entries = await repository.parseEntriesForFiles(
        [fileInfo],
        [],
        cached,
      );

      expect(identical(entries.first, cached.first), isFalse);
      expect(entries.first.fileHash, orgTextHash(markup));
      verify(() => fileService.parseText(markup)).called(1);
    });

    test('parses the file when nothing is cached', () async {
      final entries = await repository.parseEntriesForFiles([fileInfo], []);

      expect(entries.single.title, 'Exam');
      verify(() => fileService.parseText(markup)).called(1);
    });
  });
}

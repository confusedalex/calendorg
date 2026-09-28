import 'dart:io';

import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/files/services/org_parser_service.dart';
import 'package:calendorg/entities/org_entry/entry_edit.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/features/date_picker/model/date_picker_bloc.dart';
import 'package:calendorg/shared/org_text_hash.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import 'helpers/entries.dart';

class MockFilePickerWritable extends Mock implements FilePickerWritable {}

class MockOrgFilePersistenceService extends Mock
    implements OrgFilePersistenceService {}

class MockOrgParserService extends Mock implements OrgParserService {}

const markup = '''
#+TITLE: Round trip
#+TODO: TODO | DONE

Text before the first heading.

* TODO Exam                                                  :school:
SCHEDULED: <2026-05-01 Fri 10:00>
:PROPERTIES:
:ID:       abc-123
:END:
:LOGBOOK:
- State "DONE"       from "TODO"       [2026-04-01 Wed 09:00]
:END:
Notes with *bold*, =code= and a [[https://example.org][link]].

** Sub item\t
<2026-05-02 Sat +1w>
  - list item
    continued


* Birthday 🎂
<2026-06-10 Wed>
#+BEGIN_SRC elisp
(message "hi")
#+END_SRC

* Rent
<2026-09-01 Tue ++1m -3d>

* Workshop
<2026-07-01 Wed>--<2026-07-03 Fri>

* Meeting
<2026-08-04 Tue 09:00-10:30>

* Lunch <2026-10-01 Thu 12:00> with Sam                           :social:
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  late OrgFilesRepository repository;
  late Directory tempDir;
  String? written;
  var source = markup;

  setUpAll(() {
    registerFallbackValue((FileInfo _, File _) => Future.value(''));
  });

  setUp(() {
    written = null;
    source = markup;
    tempDir = Directory.systemTemp.createTempSync('calendorg_round_trip');
    filePicker = MockFilePickerWritable();
    final parserService = MockOrgParserService();
    repository = OrgFilesRepository(
      filePicker: filePicker,
      persistence: MockOrgFilePersistenceService(),
      parserService: parserService,
      eventParserService: EventParserService(),
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
    ).thenAnswer((_) async => source);
    when(
      () => parserService.parseContentInBackground(any()),
    ).thenAnswer((i) async => OrgDocument.parse(i.positionalArguments.first));
    when(
      () => filePicker.writeFile(
        identifier: fileInfo.identifier,
        writer: any(named: 'writer'),
      ),
    ).thenAnswer((i) async {
      final writer =
          i.namedArguments[#writer] as Future<void> Function(File file);
      final file = File('${tempDir.path}/out.org');
      await writer(file);
      written = file.readAsStringSync();
      return fileInfo;
    });
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('parsing and printing a file without edits keeps every byte', () {
    expect(OrgDocument.parse(markup).toMarkup(), markup);
  });

  Future<String?> applyEdit(
    String title,
    EntryEdit Function(OrgEntry entry) buildEdit, {
    String from = markup,
  }) async {
    source = from;
    final entry = parseEntries(
      OrgDocument.parse(from),
      fileHash: orgTextHash(from),
    ).firstWhere((e) => e.title == title);

    await repository.applyEdit(dirInfo, fileInfo, entry, buildEdit(entry), []);
    return written;
  }

  test('a title edit changes only the title in the written file', () async {
    final result = await applyEdit(
      'Exam',
      (_) => const EntryEdit(newTitle: 'Final exam'),
    );

    expect(result, markup.replaceFirst('TODO Exam', 'TODO Final exam'));
  });

  test('a scheduled edit changes only the scheduled timestamp', () async {
    final result = await applyEdit(
      'Exam',
      (entry) => EntryEdit(
        oldTimestamp: entry.scheduled!.value as OrgTimestamp,
        newTimestamp: dateTimeToSimpleTimestamp(
          DateTime(2026, 5, 8, 14, 30),
          true,
          true,
        ),
      ),
    );

    expect(
      result,
      markup.replaceFirst(
        'SCHEDULED: <2026-05-01 Fri 10:00>',
        'SCHEDULED: <2026-05-08 Fri 14:30>',
      ),
    );
  });

  test('a body timestamp edit changes only that timestamp', () async {
    final result = await applyEdit(
      'Birthday 🎂',
      (entry) => EntryEdit(
        oldTimestamp: entry.timestamps.single,
        newTimestamp: dateTimeToSimpleTimestamp(
          DateTime(2026, 6, 11),
          false,
          true,
        ),
      ),
    );

    expect(result, markup.replaceFirst('<2026-06-10 Wed>', '<2026-06-11 Thu>'));
  });

  OrgTimestamp picked(
    OrgTimestamp old,
    DatePickerState Function(DatePickerState state) change,
  ) => DatePickerBloc(change(DatePickerState.initial(old))).generateTimestamp();

  group('modifiers', () {
    test('a date edit keeps the repeater', () async {
      final result = await applyEdit(
        'Sub item',
        (entry) => EntryEdit(
          oldTimestamp: entry.timestamps.single,
          newTimestamp: picked(
            entry.timestamps.single,
            (s) => s.copyWith(startDate: DateTime(2026, 5, 9)),
          ),
        ),
      );

      expect(
        result,
        markup.replaceFirst('<2026-05-02 Sat +1w>', '<2026-05-09 Sat +1w>'),
      );
    });

    test('a date edit keeps the repeater and the warning delay', () async {
      final result = await applyEdit(
        'Rent',
        (entry) => EntryEdit(
          oldTimestamp: entry.timestamps.single,
          newTimestamp: picked(
            entry.timestamps.single,
            (s) => s.copyWith(startDate: DateTime(2026, 9, 2)),
          ),
        ),
      );

      expect(
        result,
        markup.replaceFirst(
          '<2026-09-01 Tue ++1m -3d>',
          '<2026-09-02 Wed ++1m -3d>',
        ),
      );
    });
  });

  test('a date range edit changes only the date range', () async {
    final result = await applyEdit(
      'Workshop',
      (entry) => EntryEdit(
        oldTimestamp: entry.timestamps.single,
        newTimestamp: picked(
          entry.timestamps.single,
          (s) => s.copyWith(
            startDate: DateTime(2026, 7, 2),
            endDate: () => DateTime(2026, 7, 5),
          ),
        ),
      ),
    );

    expect(
      result,
      markup.replaceFirst(
        '<2026-07-01 Wed>--<2026-07-03 Fri>',
        '<2026-07-02 Thu>--<2026-07-05 Sun>',
      ),
    );
  });

  test('a time range edit changes only the time range', () async {
    final result = await applyEdit(
      'Meeting',
      (entry) => EntryEdit(
        oldTimestamp: entry.timestamps.single,
        newTimestamp: picked(
          entry.timestamps.single,
          (s) =>
              s.copyWith(endTimeDuration: const TimeOfDay(hour: 11, minute: 0)),
        ),
      ),
    );

    expect(
      result,
      markup.replaceFirst(
        '<2026-08-04 Tue 09:00-10:30>',
        '<2026-08-04 Tue 09:00-11:00>',
      ),
    );
  });

  group('timestamp in the headline', () {
    test('a date edit changes only that timestamp', () async {
      final result = await applyEdit(
        'Lunch with Sam',
        (entry) => EntryEdit(
          oldTimestamp: entry.timestamps.single,
          newTimestamp: picked(
            entry.timestamps.single,
            (s) => s.copyWith(startDate: DateTime(2026, 10, 2)),
          ),
        ),
      );

      expect(
        result,
        markup.replaceFirst(
          '<2026-10-01 Thu 12:00> with Sam',
          '<2026-10-02 Fri 12:00> with Sam',
        ),
      );
    });

    test('a title edit keeps the timestamp and the tags', () async {
      final result = await applyEdit(
        'Lunch with Sam',
        (entry) => EntryEdit(
          newTitle: 'Lunch with Kim',
          oldTimestamp: entry.timestamps.single,
        ),
      );

      expect(
        result,
        markup.replaceFirst(
          'Lunch <2026-10-01 Thu 12:00> with Sam',
          'Lunch with Kim <2026-10-01 Thu 12:00>',
        ),
      );
    });
  });

  group('line endings', () {
    test('an edit keeps CRLF line endings', () async {
      const crlf = '* Exam :school:\r\n<2026-05-01 Fri>\r\nNotes\r\n';

      final result = await applyEdit(
        'Exam',
        (entry) => EntryEdit(
          newTitle: 'Final exam',
          oldTimestamp: entry.timestamps.single,
          newTimestamp: dateTimeToSimpleTimestamp(
            DateTime(2026, 5, 8),
            false,
            true,
          ),
        ),
        from: crlf,
      );

      expect(result, '* Final exam :school:\r\n<2026-05-08 Fri>\r\nNotes\r\n');
    });

    test('an edit adds no newline at the end of the file', () async {
      final result = await applyEdit(
        'Exam',
        (_) => const EntryEdit(newTitle: 'Final exam'),
        from: '* Exam\n<2026-05-01 Fri>',
      );

      expect(result, '* Final exam\n<2026-05-01 Fri>');
    });
  });
}

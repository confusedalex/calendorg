import 'dart:convert';

import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/shared/config/preferences_service.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/preferences.dart';

import '../../../helpers/entries.dart';

class MockFilePickerWritable extends Mock implements FilePickerWritable {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OrgFilePersistenceService service;
  late PreferencesService prefs;

  setUp(() {
    prefs = inMemoryPreferences();
    service = OrgFilePersistenceService(prefs, FilePickerWritable());
  });

  group('OrgFilePersistenceService', () {
    group('saveFileList()', () {
      test('should write fileInfos to agendaFiles preference', () async {
        final Set<FileInfo> fileInfos = {
          fakeFileInfo('notes'),
          fakeFileInfo('work'),
        };

        await service.saveFileList(fileInfos);

        expect(
          await prefs.getStringList(PrefKeys.agendaFiles),
          equals(fileInfos.map((e) => e.fileName).toList()),
        );
      });
    });
    group('saveDirectory()', () {
      test('should save directory to sharedPreferences', () async {
        final directoryInfo = fakeDirectoryInfo('orgFiles');

        await service.saveDirectory(directoryInfo);

        expect(
          await prefs.getString(PrefKeys.agendaDirectory),
          jsonEncode(directoryInfo),
        );
      });
    });
    group('saveInboxFile()', () {
      test('should save name of inbox file to sharedPreferences', () async {
        final inboxFile = fakeFileInfo('inbox');

        await service.saveInboxFile(inboxFile);

        expect(await prefs.getString(PrefKeys.inboxFile), 'inbox.org');
      });
    });
    group('saveEntriesCache()', () {
      test('should save entries to sharedPreferences', () async {
        const raw = '''
* TODO Install Emacs
* Org-Mode Meetup @org
<2026-05-01>''';
        final document = OrgDocument.parse(raw);
        final entries = parseEntries(document, ignored: {'OTHER'});

        await service.saveEntriesCache(entries, 'TODO|DONE|');

        expect(
          await prefs.getStringList(PrefKeys.entriesCache),
          entries.map((entry) => entry.toJson()).toList(),
        );
        expect(
          await prefs.getString(PrefKeys.entriesCacheKey),
          'v2|TODO|DONE|',
        );
      });
    });
    group('loadCachedOrgEntries()', () {
      test('should return the entries when the cache key matches', () async {
        final entries = parseEntries(OrgDocument.parse('* Exam\n<2026-05-01>'));
        await service.saveEntriesCache(entries, 'TODO|DONE|');

        final cached = await service.loadCachedOrgEntries('TODO|DONE|');

        expect(
          cached?.map((entry) => entry.toJson()).toList(),
          entries.map((entry) => entry.toJson()).toList(),
        );
      });
      test('should return null when the cache key differs', () async {
        final entries = parseEntries(OrgDocument.parse('* Exam\n<2026-05-01>'));
        await service.saveEntriesCache(entries, 'TODO|DONE|');

        expect(await service.loadCachedOrgEntries('TODO|DONE|LATER'), isNull);
      });
      test('should return null for a cache from an older version', () async {
        final entries = parseEntries(OrgDocument.parse('* Exam\n<2026-05-01>'));
        await service.saveEntriesCache(entries, 'TODO|DONE|');
        await prefs.setString(PrefKeys.entriesCacheKey, 'TODO|DONE|');

        expect(await service.loadCachedOrgEntries('TODO|DONE|'), isNull);
      });
      test('should keep habits as habits', () async {
        final entries = parseEntries(
          OrgDocument.parse('''
* TODO Run
SCHEDULED: <2026-05-02 Sat .+1d/3d>
:PROPERTIES:
:STYLE: habit
:END:
- State "DONE"       from "TODO"       [2026-05-01 Fri 08:00]
'''),
        );
        await service.saveEntriesCache(entries, 'TODO|DONE|');

        final cached = await service.loadCachedOrgEntries('TODO|DONE|');

        final habit = cached!.single as OrgHabit;
        expect(habit.completions, [20260501]);
        expect(habit.maxDays, 3);
      });
    });
    group('loadFilePreferences()', () {
      late MockFilePickerWritable filePicker;
      final dirInfo = fakeDirectoryInfo('orgFiles');

      void resolvesTo(String name, Future<EntityInfo> Function() result) =>
          when(
            () => filePicker.resolveRelativePath(
              directoryIdentifier: dirInfo.identifier,
              relativePath: name,
            ),
          ).thenAnswer((_) => result());

      setUp(() async {
        filePicker = MockFilePickerWritable();
        service = OrgFilePersistenceService(prefs, filePicker);
        await service.saveDirectory(dirInfo);
        await service.saveFileList({
          fakeFileInfo('work'),
          fakeFileInfo('old'),
          fakeFileInfo('folder'),
        });
        await service.saveInboxFile(fakeFileInfo('inbox'));
      });

      test('should skip missing files and keep the rest', () async {
        resolvesTo('work.org', () async => fakeFileInfo('work'));
        resolvesTo('old.org', () => Future.error(Exception('not found')));
        resolvesTo('folder.org', () async => fakeDirectoryInfo('folder'));
        resolvesTo('inbox.org', () async => fakeFileInfo('inbox'));

        final (:files, :inbox, :directory, :missing) = await service
            .loadFilePreferences();

        expect(files.map((f) => f.fileName), ['work.org']);
        expect(inbox?.fileName, 'inbox.org');
        expect(directory?.identifier, dirInfo.identifier);
        expect(missing, unorderedEquals(['old.org', 'folder.org']));
      });

      test('should keep the files when the inbox file is missing', () async {
        resolvesTo('work.org', () async => fakeFileInfo('work'));
        resolvesTo('old.org', () async => fakeFileInfo('old'));
        resolvesTo('folder.org', () async => fakeFileInfo('folder'));
        resolvesTo('inbox.org', () => Future.error(Exception('not found')));

        final (:files, :inbox, :directory, :missing) = await service
            .loadFilePreferences();

        expect(files, hasLength(3));
        expect(inbox, isNull);
        expect(directory, isNotNull);
        expect(missing, ['inbox.org']);
      });
    });
  });
}

FileInfo fakeFileInfo(String name) => FileInfo(
  identifier: '$name-identifier',
  persistable: true,
  uri: '$name-uri',
  fileName: '$name.org',
);

DirectoryInfo fakeDirectoryInfo(String name) => DirectoryInfo(
  identifier: '$name-identifier',
  persistable: true,
  uri: '$name-uri',
);

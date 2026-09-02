import 'dart:convert';

import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendorg/shared/config/preferences_service.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/preferences.dart';

void main() {
  late OrgFilePersistenceService service;
  late PreferencesService prefs;

  setUp(() {
    prefs = inMemoryPreferences();
    service = OrgFilePersistenceService(prefs);
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
        final entries = EventParserService().parseEntriesFromDocument(
          fakeFileInfo('notes'),
          document,
          {'OTHER'},
        );

        await service.saveEntriesCache(entries);

        expect(
          await prefs.getStringList(PrefKeys.entriesCache),
          entries.map((e) => OrgEntryCached.fromLoaded(e).toJson()).toList(),
        );
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

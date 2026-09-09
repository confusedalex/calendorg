import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/event_parser_service.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../entities/org_entry/org_entry_locator.dart';
import '../../../entities/todo_states/todo_states_ignored.dart';
import 'org_file_persistence_service.dart';
import 'org_file_service.dart';
import 'org_parser_service.dart';

class OrgFilesRepository {
  final OrgFileService _fileService;
  final OrgFilePersistenceService _persistence;
  final OrgParserService _parserService;
  final EventParserService _eventParserService;

  OrgFilesRepository({
    required OrgFileService fileService,
    required OrgFilePersistenceService persistence,
    required OrgParserService parserService,
    required EventParserService eventParserService,
  }) : _eventParserService = eventParserService,
       _fileService = fileService,
       _persistence = persistence,
       _parserService = parserService;

  Future<List<OrgEntry>?> loadCachedEntries() async {
    return await _persistence.loadCachedOrgEntries();
  }

  Future<InitialState> loadInitialState(
    OrgTodoStatesWithIgnored todoStates,
  ) async {
    final (fileInfos, inboxFile, dirInfo) = await _persistence
        .loadFilePreferences();

    return InitialState(
      dirInfo: dirInfo,
      fileInfos: fileInfos,
      inboxFile: inboxFile,
      todoStates: todoStates,
      entries: await parseEntriesForFiles([
        ...fileInfos,
        ?inboxFile,
      ], todoStates.ignored),
    );
  }

  Future<List<OrgEntry>> parseEntriesForFiles(
    Iterable<FileInfo> fileInfos,
    List<String> ignoredTodoStates,
  ) async {
    final ignored = ignoredTodoStates.toSet();
    final perFile = await Future.wait(
      fileInfos.map((fileInfo) async {
        final fileName = fileInfo.fileName;
        if (fileName == null) return const <OrgEntry>[];

        try {
          final parsed = await _fileService.documentByIdentifier(
            fileInfo.identifier,
          );
          return _eventParserService.parseEntriesFromDocument(
            fileName,
            parsed.hash,
            parsed.document,
            ignored,
          );
        } on Exception catch (e) {
          debugPrint('Error loading file $fileName: $e');
          return const <OrgEntry>[];
        }
      }),
    );

    return perFile.expand((entries) => entries).toList();
  }

  Future<void> saveDirectory(DirectoryInfo dirInfo) {
    return _persistence.saveDirectory(dirInfo);
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) {
    return _persistence.saveFileList(fileInfos);
  }

  Future<void> saveInboxFile(FileInfo fileInfo) {
    return _persistence.saveInboxFile(fileInfo);
  }

  Future<void> cacheOrgEntries(List<OrgEntry> entries) {
    return _persistence.saveEntriesCache(entries);
  }

  void updateTodoStates(OrgTodoStatesWithIgnored states) {
    _parserService.invalidateCache(states);
  }

  Future<void> applyEdit(
    FileInfo fileInfo,
    OrgEntry entry,
    EntryEdit edit,
  ) async {
    final parsed = await _fileService.documentByIdentifier(fileInfo.identifier);
    final section = locateSection(parsed.document, entry.locator);
    if (section == null) throw EntryNotFoundException(entry.title);

    final replacements = _eventParserService.replacementsFor(
      section,
      entry,
      edit,
    );
    if (replacements.isEmpty) return;

    await _fileService.replaceNodesAndSave(
      fileInfo.identifier,
      parsed.document,
      replacements,
    );
  }
}

class EntryNotFoundException implements Exception {
  final String title;

  EntryNotFoundException(this.title);

  @override
  String toString() => 'The entry "$title" is no longer in the file.';
}

class InitialState {
  final DirectoryInfo? dirInfo;
  final Set<FileInfo> fileInfos;
  final FileInfo? inboxFile;
  final OrgTodoStatesWithIgnored todoStates;
  final List<OrgEntry> entries;

  InitialState({
    required this.dirInfo,
    required this.fileInfos,
    required this.inboxFile,
    required this.todoStates,
    required this.entries,
  });
}

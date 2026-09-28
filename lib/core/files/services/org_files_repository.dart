import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/event_parser_service.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../entities/org_entry/org_entry_locator.dart';
import '../../../entities/todo_states/todo_states_ignored.dart';
import '../../../shared/org_text_hash.dart';
import '../../../util.dart';
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

  Future<List<OrgEntry>?> loadCachedEntries(
    OrgTodoStatesWithIgnored todoStates,
  ) async {
    return await _persistence.loadCachedOrgEntries(todoStates.cacheKey);
  }

  Future<InitialState> loadInitialState(
    OrgTodoStatesWithIgnored todoStates,
    Iterable<OrgEntry> cachedEntries,
  ) async {
    final (fileInfos, inboxFile, dirInfo) = await _persistence
        .loadFilePreferences();

    return InitialState(
      dirInfo: dirInfo,
      fileInfos: fileInfos,
      inboxFile: inboxFile,
      todoStates: todoStates,
      entries: await parseEntriesForFiles(
        dirInfo,
        [...fileInfos, ?inboxFile],
        todoStates.ignored,
        cachedEntries,
      ),
    );
  }

  Future<List<OrgEntry>> parseEntriesForFiles(
    DirectoryInfo? dirInfo,
    Iterable<FileInfo> fileInfos,
    List<String> ignoredTodoStates, [
    Iterable<OrgEntry> cachedEntries = const [],
  ]) async {
    final ignored = ignoredTodoStates.toSet();
    final cached = <String, List<OrgEntry>>{};
    for (final entry in cachedEntries) {
      cached.putIfAbsent(entry.filePath, () => []).add(entry);
    }

    final perFile = await Future.wait(
      fileInfos.map((fileInfo) async {
        final fileName = fileInfo.fileName;
        if (fileName == null || dirInfo == null) return const <OrgEntry>[];

        try {
          final resolved = await _fileService.resolveFileInfo(
            dirInfo,
            fileName,
          );
          final text = await _fileService.readText(resolved.identifier);
          final reusable = cached[fileName];
          if (reusable != null &&
              reusable.first.fileHash == orgTextHash(text)) {
            return reusable;
          }

          final parsed = await _fileService.parseText(text);
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

  Future<void> cacheOrgEntries(
    List<OrgEntry> entries,
    OrgTodoStatesWithIgnored todoStates,
  ) {
    return _persistence.saveEntriesCache(entries, todoStates.cacheKey);
  }

  void updateTodoStates(OrgTodoStatesWithIgnored states) {
    _parserService.invalidateCache(states);
  }

  Future<List<OrgEntry>?> appendToInboxFile(
    DirectoryInfo dirInfo,
    FileInfo inboxFile,
    String markup,
    List<String> ignoredTodoStates,
  ) async {
    final fileName = inboxFile.fileName;
    if (fileName == null) return null;

    try {
      final parsed = await _fileService.appendToFile(inboxFile, markup);
      if (parsed == null) return null;

      return _eventParserService.parseEntriesFromDocument(
        fileName,
        parsed.hash,
        parsed.document,
        ignoredTodoStates.toSet(),
      );
    } on Exception catch (e) {
      sendError(globalL10n.error_saving_section(e));
      return null;
    }
  }

  Future<List<OrgEntry>?> applyEdit(
    DirectoryInfo dirInfo,
    FileInfo fileInfo,
    OrgEntry entry,
    EntryEdit edit,
    List<String> ignoredTodoStates,
  ) async {
    final fileName = fileInfo.fileName;
    if (fileName == null) return null;

    final resolved = await _fileService.resolveFileInfo(dirInfo, fileName);
    final parsed = await _fileService.documentByIdentifier(resolved.identifier);
    final section = locateSection(parsed.document, entry.locator);
    if (section == null) {
      sendError(globalL10n.error_entry_not_found(entry));
      return null;
    }

    final replacements = _eventParserService.replacementsFor(
      section,
      entry,
      edit,
    );
    if (replacements.isEmpty) return null;

    if (entry.fileHash != parsed.hash) {
      debugPrint('File changed on disk!');
      sendError(globalL10n.error_file_changed_on_disk);
      return null;
    }

    final newDocument = await _fileService.replaceNodesAndSave(
      resolved.identifier,
      parsed.document,
      replacements,
    );

    return _eventParserService.parseEntriesFromDocument(
      entry.filePath,
      orgTextHash(newDocument.toMarkup()),
      newDocument,
      ignoredTodoStates.toSet(),
    );
  }
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

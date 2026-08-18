import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:org_parser/org_parser.dart';

import '../../../entities/org_entry/event_parser_service.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../todo_states_cubit.dart';
import 'org_file_persistence_service.dart';
import 'org_file_service.dart';
import 'org_parser_service.dart';

class OrgFilesRepository {
  final OrgFileService _fileService;
  final OrgFilePersistenceService _persistence;
  final OrgParserService _parserService;

  OrgFilesRepository({
    required OrgFileService fileService,
    required EventParserService eventParser,
    required OrgFilePersistenceService persistence,
    required OrgParserService parserService,
  }) : _fileService = fileService,
       _persistence = persistence,
       _parserService = parserService;

  Future<InitialState> loadInitialState(
    OrgTodoStatesWithIgnored todoStates,
  ) async {
    final (fileInfos, inboxFile, dirInfo) = await _persistence
        .loadFilePreferences();
    final fileInfosToLoad = [...fileInfos, ?inboxFile];
    final loadedDocuments = await Future.wait(
      fileInfosToLoad.map((fileInfo) async {
        try {
          final document = await _fileService.documentByIdentifier(
            fileInfo.identifier,
          );
          return document;
        } catch (e) {
          debugPrint('Error loading file: $e');
          return null;
        }
      }),
    );
    final documentsMap = Map<FileInfo, OrgDocument>.fromIterables(
      fileInfosToLoad,
      loadedDocuments.whereType<OrgDocument>(),
    );

    return InitialState(
      dirInfo: dirInfo,
      fileInfos: fileInfos,
      inboxFile: inboxFile,
      documentsMap: documentsMap,
      todoStates: todoStates,
    );
  }

  Future<List<OrgEntry>> parseAllEntries(
    Map<FileInfo, OrgDocument> documentsMap,
    List<String> ignoredTodoStates,
  ) async {
    final perFileEvents = await Future.wait(
      documentsMap.entries.map((entry) async {
        final parsedEvents = EventParserService().parseEntriesFromDocument(
          entry.key,
          entry.value,
          ignoredTodoStates.toSet(),
        );

        return parsedEvents;
      }),
    );
    return perFileEvents.expand((e) => e).toList();
  }

  Future<void> saveDirectory(DirectoryInfo dirInfo) async {
    return _persistence.saveDirectory(dirInfo);
  }

  Future<OrgDocument> loadDocument(FileInfo fileInfo) async {
    return _fileService.documentByIdentifier(fileInfo.identifier);
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) async {
    return _persistence.saveFileList(fileInfos);
  }

  Future<void> saveInboxFile(FileInfo fileInfo) async {
    return _persistence.saveInboxFile(fileInfo);
  }

  void updateTodoStates(OrgTodoStatesWithIgnored states) {
    _parserService.invalidateCache(states);
  }

  Future<OrgDocument> replaceNodesAndSave(
    FileInfo fileInfo,
    OrgDocument oldDocument,
    List<(OrgNode, OrgNode)> replacements,
  ) async {
    return await _fileService.replaceNodesAndSave(
      fileInfo.identifier,
      oldDocument,
      replacements,
    );
  }
}

class InitialState {
  final DirectoryInfo? dirInfo;
  final Set<FileInfo> fileInfos;
  final FileInfo? inboxFile;
  final Map<FileInfo, OrgDocument> documentsMap;
  final OrgTodoStatesWithIgnored todoStates;

  InitialState({
    required this.dirInfo,
    required this.fileInfos,
    required this.inboxFile,
    required this.documentsMap,
    required this.todoStates,
  });
}

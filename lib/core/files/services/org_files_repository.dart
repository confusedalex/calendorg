import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:logging/logging.dart';
import 'package:org_parser/org_parser.dart';

import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/event_parser_service.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../entities/org_entry/org_entry_locator.dart';
import '../../../entities/todo_states/todo_states_ignored.dart';
import '../../../shared/org_text_hash.dart';
import '../../../util.dart';
import 'org_file_persistence_service.dart';
import 'org_parser_service.dart';

final _log = Logger('OrgFilesRepository');

typedef _ParsedFile = ({OrgDocument document, String hash});

class OrgFilesRepository {
  final FilePickerWritable _filePicker;
  final OrgFilePersistenceService _persistence;
  final OrgParserService _parserService;
  final EventParserService _eventParserService;

  OrgFilesRepository({
    required FilePickerWritable filePicker,
    required OrgFilePersistenceService persistence,
    required OrgParserService parserService,
    required EventParserService eventParserService,
  }) : _eventParserService = eventParserService,
       _filePicker = filePicker,
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
          final resolved = await _resolveFileInfo(dirInfo, fileName);
          final text = await readText(resolved.identifier);
          final reusable = cached[fileName];
          if (reusable != null &&
              reusable.first.fileHash == orgTextHash(text)) {
            return reusable;
          }

          final parsed = await _parseText(text);
          return _eventParserService.parseEntriesFromDocument(
            fileName,
            parsed.hash,
            parsed.document,
            ignored,
          );
        } on Exception catch (e, stack) {
          _log.warning('Error loading file $fileName', e, stack);
          return const <OrgEntry>[];
        }
      }),
    );

    return perFile.expand((entries) => entries).toList();
  }

  Future<DirectoryInfo?> pickDirectory() => _filePicker.openDirectory();

  Future<FileInfo?> pickFile() =>
      _filePicker.openFile((fileInfo, _) async => fileInfo);

  Future<String?> pickFileText() =>
      _filePicker.openFile((_, file) => file.readAsString());

  Future<FileInfo?> createEmptyFile(String fileName) =>
      _filePicker.openFileForCreate(
        writer: (file) => file.writeAsString('', mode: FileMode.writeOnly),
        fileName: fileName,
      );

  Future<String> readText(String identifier) => _filePicker.readFile(
    identifier: identifier,
    reader: (_, file) => file.readAsString(),
  );

  Future<bool> validateFileDirectory(
    FileInfo? fileInfo,
    DirectoryInfo? dirInfo,
  ) async {
    if (fileInfo == null || dirInfo == null) return false;
    final fileName = fileInfo.fileName;
    if (fileName == null) return false;

    void sendErr() => sendError(globalL10n.error_file_not_in_org_folder);

    try {
      late final EntityInfo relative;

      try {
        relative = await _filePicker.resolveRelativePath(
          directoryIdentifier: dirInfo.identifier,
          relativePath: fileName,
        );
      } on Exception {
        sendErr();
        return false;
      }

      final relativeHash = orgTextHash(await readText(relative.identifier));
      final pickedHash = orgTextHash(await readText(fileInfo.identifier));

      final isSameFile = relativeHash == pickedHash;

      if (!isSameFile) {
        sendErr();
      }

      return isSameFile;
    } on Exception {
      sendError(globalL10n.error_reading_file);
      return false;
    }
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
      final oldText = await readText(inboxFile.identifier);
      final newText = '$oldText\n$markup';
      await _writeText(inboxFile.identifier, newText);
      final parsed = await _parseText(newText);

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

    final resolved = await _resolveFileInfo(dirInfo, fileName);
    final parsed = await _parseText(await readText(resolved.identifier));
    final ignored = ignoredTodoStates.toSet();

    if (entry.fileHash != parsed.hash) {
      _log.info('File changed on disk, reloading $fileName');
      sendError(globalL10n.error_file_changed_on_disk);
      return _eventParserService.parseEntriesFromDocument(
        fileName,
        parsed.hash,
        parsed.document,
        ignored,
      );
    }

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

    final newDocument =
        replacements
                .fold<OrgZipper>(
                  parsed.document.edit(),
                  (builder, nodes) => builder.find(nodes.$1)!.replace(nodes.$2),
                )
                .commit()
            as OrgDocument;
    await _writeText(resolved.identifier, newDocument.toMarkup());

    return _eventParserService.parseEntriesFromDocument(
      entry.filePath,
      orgTextHash(newDocument.toMarkup()),
      newDocument,
      ignored,
    );
  }

  Future<FileInfo> _resolveFileInfo(
    DirectoryInfo dirInfo,
    String fileName,
  ) async {
    final entity = await _filePicker.resolveRelativePath(
      directoryIdentifier: dirInfo.identifier,
      relativePath: fileName,
    );
    return entity as FileInfo;
  }

  Future<_ParsedFile> _parseText(String content) async => (
    document: await _parserService.parseContentInBackground(content),
    hash: orgTextHash(content),
  );

  Future<void> _writeText(String identifier, String text) =>
      _filePicker.writeFile(
        identifier: identifier,
        writer: (file) => file.writeAsString(text, mode: FileMode.writeOnly),
      );
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

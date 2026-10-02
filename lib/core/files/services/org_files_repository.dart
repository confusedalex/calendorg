import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:logging/logging.dart';
import 'package:org_parser/org_parser.dart';

import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/habit_completion.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../entities/org_entry/org_entry_locator.dart';
import '../../../entities/org_entry/org_entry_parser.dart';
import '../../../entities/todo_states/todo_states_ignored.dart';
import '../../../shared/org_text_hash.dart';
import '../org_files_problem.dart';
import 'org_file_persistence_service.dart';
import 'org_parser_service.dart';

final _log = Logger('OrgFilesRepository');

typedef _ParsedFile = ({OrgDocument document, String hash});

class OrgFilesRepository {
  final FilePickerWritable _filePicker;
  final OrgFilePersistenceService _persistence;
  final OrgParserService _parserService;

  OrgFilesRepository({
    required FilePickerWritable filePicker,
    required OrgFilePersistenceService persistence,
    required OrgParserService parserService,
  }) : _filePicker = filePicker,
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
    final (:files, :inbox, :directory, :missing) = await _persistence
        .loadFilePreferences();

    return InitialState(
      dirInfo: directory,
      fileInfos: files,
      inboxFile: inbox,
      todoStates: todoStates,
      entries: await parseEntriesForFiles(
        directory,
        [...files, ?inbox],
        todoStates.ignored,
        cachedEntries,
      ),
      missingFiles: missing,
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
          return parseEntriesFromDocument(
            fileName,
            parsed.hash,
            parsed.document,
            ignored,
            _doneStates,
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

  Future<void> ensureInDirectory(
    FileInfo fileInfo,
    DirectoryInfo dirInfo,
  ) async {
    final fileName = fileInfo.fileName;
    if (fileName == null) throw const FileNotInOrgFolder();

    final EntityInfo relative;
    try {
      relative = await _filePicker.resolveRelativePath(
        directoryIdentifier: dirInfo.identifier,
        relativePath: fileName,
      );
    } on Exception {
      throw const FileNotInOrgFolder();
    }

    final String relativeText;
    final String pickedText;
    try {
      relativeText = await readText(relative.identifier);
      pickedText = await readText(fileInfo.identifier);
    } on Exception {
      throw const FileReadFailed();
    }

    if (relativeText != pickedText) throw const FileNotInOrgFolder();
  }

  Future<void> saveDirectory(DirectoryInfo dirInfo) {
    return _persistence.saveDirectory(dirInfo);
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) {
    return _persistence.saveFileList(fileInfos);
  }

  Future<void> saveInboxFile(FileInfo? fileInfo) {
    return _persistence.saveInboxFile(fileInfo);
  }

  Future<void> cacheOrgEntries(
    List<OrgEntry> entries,
    OrgTodoStatesWithIgnored todoStates,
  ) {
    return _persistence.saveEntriesCache(entries, todoStates.cacheKey);
  }

  OrgTodoStatesWithIgnored get todoStates => _parserService.todoStates;

  Set<String> get _doneStates => todoStates.done.toSet();

  set todoStates(OrgTodoStatesWithIgnored states) =>
      _parserService.todoStates = states;

  Future<List<OrgEntry>?> appendToInboxFile(
    DirectoryInfo dirInfo,
    FileInfo inboxFile,
    String markup,
    List<String> ignoredTodoStates,
  ) async {
    final fileName = inboxFile.fileName;
    if (fileName == null) return null;

    final oldText = await readText(inboxFile.identifier);
    final newText = '$oldText\n$markup';
    await _writeText(inboxFile.identifier, newText);
    final parsed = await _parseText(newText);

    return parseEntriesFromDocument(
      fileName,
      parsed.hash,
      parsed.document,
      ignoredTodoStates.toSet(),
      _doneStates,
    );
  }

  Future<List<OrgEntry>?> applyEdit(
    DirectoryInfo dirInfo,
    FileInfo fileInfo,
    OrgEntry entry,
    EntryEdit edit,
    List<String> ignoredTodoStates,
  ) => _editSection(dirInfo, fileInfo, entry, ignoredTodoStates, (
    document,
    section,
  ) {
    final replacements = replacementsFor(section, entry, edit);
    if (replacements.isEmpty) return null;

    return replacements
            .fold<OrgZipper>(
              document.edit(),
              (builder, nodes) => builder.find(nodes.$1)!.replace(nodes.$2),
            )
            .commit()
        as OrgDocument;
  });

  Future<List<OrgEntry>?> markHabitDone(
    DirectoryInfo dirInfo,
    FileInfo fileInfo,
    OrgHabit habit,
    DateTime now,
    List<String> ignoredTodoStates,
  ) => _editSection(
    dirInfo,
    fileInfo,
    habit,
    ignoredTodoStates,
    (document, section) =>
        document
                .editNode(section)!
                .replace(
                  completeHabit(
                    section,
                    doneKeyword: todoStates.done.firstOrNull ?? 'DONE',
                    now: now,
                  ),
                )
                .commit()
            as OrgDocument,
  );

  /// Reads the file of [entry], applies [edit] to its section, and writes the
  /// result. If [edit] returns null, nothing changes.
  Future<List<OrgEntry>?> _editSection(
    DirectoryInfo dirInfo,
    FileInfo fileInfo,
    OrgEntry entry,
    List<String> ignoredTodoStates,
    OrgDocument? Function(OrgDocument document, OrgSection section) edit,
  ) async {
    final fileName = fileInfo.fileName;
    if (fileName == null) return null;

    final resolved = await _resolveFileInfo(dirInfo, fileName);
    final parsed = await _parseText(await readText(resolved.identifier));
    final ignored = ignoredTodoStates.toSet();

    if (entry.fileHash != parsed.hash) {
      _log.info('File changed on disk, reloading $fileName');
      throw FileChangedOnDisk(
        parseEntriesFromDocument(
          fileName,
          parsed.hash,
          parsed.document,
          ignored,
          _doneStates,
        ),
      );
    }

    final section = locateSection(parsed.document, entry.locator);
    if (section == null) throw EntryNotFound(entry.title);

    final newDocument = edit(parsed.document, section);
    if (newDocument == null) return null;

    final newText = newDocument.toMarkup();
    await _writeText(resolved.identifier, newText);

    final written = await _parseText(newText);
    return parseEntriesFromDocument(
      entry.filePath,
      written.hash,
      written.document,
      ignored,
      _doneStates,
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
    if (entity is! FileInfo) throw FileSystemException('Not a file', fileName);
    return entity;
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

  final List<String> missingFiles;

  InitialState({
    required this.dirInfo,
    required this.fileInfos,
    required this.inboxFile,
    required this.todoStates,
    required this.entries,
    this.missingFiles = const [],
  });
}

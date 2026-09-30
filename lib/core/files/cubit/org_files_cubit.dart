import 'package:bloc/bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../entities/todo_states/todo_states_ignored.dart';
import '../org_files_problem.dart';
import '../services/org_files_repository.dart';

part 'org_files_state.dart';

final _log = Logger('OrgFilesCubit');

class OrgFilesCubit extends Cubit<OrgFilesState> {
  final OrgFilesRepository _repository;
  Future<void>? _reloading;

  OrgFilesCubit(this._repository) : super(OrgFilesState.initial());

  Future<void> earlyInit(OrgTodoStatesWithIgnored todoStates) async {
    final entries = await _repository.loadCachedEntries(todoStates);
    emit(state.copyWith(entries: entries?.toList() ?? []));
  }

  Future<void> init(OrgTodoStatesWithIgnored todoStates) async {
    try {
      await earlyInit(todoStates);
      final cachedEntries = state.entries;

      final result = await _repository.loadInitialState(
        todoStates,
        cachedEntries,
      );
      emit(
        OrgFilesState(
          directory: result.dirInfo,
          status: OrgFilesStatus.success,
          filePaths: result.fileInfos,
          inboxFile: result.inboxFile,
          todoStates: result.todoStates,
          entries: result.entries,
          problem: result.missingFiles.isEmpty
              ? null
              : FilesNotFound(result.missingFiles),
        ),
      );
      if (!_sameEntries(result.entries, cachedEntries)) {
        await _repository.cacheOrgEntries(result.entries, todoStates);
      }
    } on Exception catch (e, stack) {
      _log.severe('Error initializing org files', e, stack);
      emit(state.copyWith(status: OrgFilesStatus.failure));
    }
  }

  Future<void> reload() =>
      _reloading ??= _reload().whenComplete(() => _reloading = null);

  Future<void> _reload() async {
    if (state.status != OrgFilesStatus.success) return;

    final before = state.entries;
    try {
      final entries = await _repository.parseEntriesForFiles(
        state.directory,
        [...state.filePaths, ?state.inboxFile],
        state.todoStates.ignored,
        before,
      );
      if (!identical(state.entries, before)) return;
      if (_sameEntries(entries, before)) return;

      emit(state.copyWith(entries: entries));
      await _repository.cacheOrgEntries(entries, state.todoStates);
    } on Exception catch (e, stack) {
      _log.warning('Error reloading files', e, stack);
    }
  }

  Future<void> setOrgDirectory(DirectoryInfo dirInfo) async {
    await _repository.saveDirectory(dirInfo);

    emit(state.copyWith(directory: () => dirInfo));
  }

  Future<void> addFilePath(FileInfo? fileInfo) async {
    if (fileInfo == null) return;
    if (fileInfo.fileName == state.inboxFile?.fileName) {
      emit(state.copyWith(problem: const InboxFileInAgendaFiles()));
      return;
    }

    try {
      final filePaths = {...state.filePaths, fileInfo};
      await _repository.saveFileList(filePaths);

      emit(state.copyWith(filePaths: filePaths));
      await _reloadEntries();
    } on Exception catch (e, stack) {
      _log.warning('Error adding file', e, stack);
    }
  }

  Future<void> removeFilePath(FileInfo fileInfo) async {
    try {
      final filePaths = {...state.filePaths}..remove(fileInfo);
      await _repository.saveFileList(filePaths);

      emit(state.copyWith(filePaths: filePaths));
      await _reloadEntries();
    } on Exception catch (e, stack) {
      _log.warning('Error removing file', e, stack);
    }
  }

  Future<void> changeInboxFile(FileInfo fileInfo) async {
    if (state.filePaths.any((f) => f.fileName == fileInfo.fileName)) {
      emit(state.copyWith(problem: const AlreadyInAgendaFiles()));
      return;
    }

    try {
      await _repository.saveInboxFile(fileInfo);

      emit(state.copyWith(inboxFile: () => fileInfo));
      await _reloadEntries();
    } on Exception catch (e, stack) {
      _log.warning('Error changing inbox file', e, stack);
    }
  }

  Future<void> changeTodoStates(OrgTodoStatesWithIgnored todoStates) async {
    try {
      _repository.todoStates = todoStates;

      emit(state.copyWith(todoStates: todoStates));
      await _reloadEntries();
    } on Exception catch (e, stack) {
      _log.warning('Error changing todo states', e, stack);
    }
  }

  Future<void> appendToInboxFile(String markup) async {
    final dirInfo = state.directory;
    final inboxFile = state.inboxFile;
    if (dirInfo == null || inboxFile == null) return;

    try {
      final newEntries = await _repository.appendToInboxFile(
        dirInfo,
        inboxFile,
        markup,
        state.todoStates.ignored,
      );
      if (newEntries == null) return;

      final entries = [
        ...state.entries.where((e) => e.filePath != inboxFile.fileName),
        ...newEntries,
      ];
      emit(state.copyWith(entries: entries));
      await _repository.cacheOrgEntries(entries, state.todoStates);
    } on Exception catch (e, stack) {
      _log.warning('Error appending to inbox file', e, stack);
      emit(state.copyWith(problem: SaveFailed(e)));
    }
  }

  Future<void> applyEdit(OrgEntry entry, EntryEdit edit) async {
    final dirInfo = state.directory;
    final fileInfo = _fileInfoOf(entry.filePath);
    if (dirInfo == null || fileInfo == null) return;

    emit(state.copyWith(status: OrgFilesStatus.loading));
    try {
      final newEntries = await _repository.applyEdit(
        dirInfo,
        fileInfo,
        entry,
        edit,
        state.todoStates.ignored,
      );
      if (newEntries == null) return;

      final entries = [
        ...state.entries.where((e) => e.filePath != fileInfo.fileName),
        ...newEntries,
      ];
      emit(state.copyWith(entries: entries));
      await _repository.cacheOrgEntries(entries, state.todoStates);
    } on FileChangedOnDisk catch (problem) {
      final entries = [
        ...state.entries.where((e) => e.filePath != fileInfo.fileName),
        ...problem.entries,
      ];
      emit(state.copyWith(entries: entries, problem: problem));
      await _repository.cacheOrgEntries(entries, state.todoStates);
    } on OrgFilesProblem catch (problem) {
      emit(state.copyWith(problem: problem));
    } on Exception catch (e, stack) {
      _log.warning('Error applying edit', e, stack);
      emit(state.copyWith(problem: SaveFailed(e)));
    } finally {
      emit(state.copyWith(status: OrgFilesStatus.success));
    }
  }

  FileInfo? _fileInfoOf(String filePath) {
    for (final fileInfo in [...state.filePaths, ?state.inboxFile]) {
      if (fileInfo.fileName == filePath) return fileInfo;
    }
    return null;
  }

  bool _sameEntries(List<OrgEntry> entries, List<OrgEntry> other) =>
      entries.length == other.length &&
      entries.indexed.every((entry) => identical(entry.$2, other[entry.$1]));

  Future<void> _reloadEntries() =>
      _emitEntries([...state.filePaths, ?state.inboxFile], const []);

  Future<void> _emitEntries(
    Iterable<FileInfo> fileInfos,
    Iterable<OrgEntry> keep,
  ) async {
    final entries = [
      ...keep,
      ...await _repository.parseEntriesForFiles(
        state.directory,
        fileInfos,
        state.todoStates.ignored,
      ),
    ];

    emit(state.copyWith(entries: entries));
    await _repository.cacheOrgEntries(entries, state.todoStates);
  }
}

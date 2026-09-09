import 'package:bloc/bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';

import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../entities/todo_states/todo_states_ignored.dart';
import '../services/org_files_repository.dart';

part 'org_files_state.dart';

class OrgFilesCubit extends Cubit<OrgFilesState> {
  final OrgFilesRepository _repository;

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
        ),
      );
      if (!_sameEntries(result.entries, cachedEntries)) {
        await _repository.cacheOrgEntries(result.entries, todoStates);
      }
    } on Exception catch (e) {
      debugPrint('Error initializing org files: $e');
      emit(OrgFilesState.initial());
    }
  }

  Future<void> setOrgDirectory(DirectoryInfo dirInfo) async {
    await _repository.saveDirectory(dirInfo);

    emit(state.copyWith(directory: () => dirInfo));
  }

  Future<void> addFilePath(FileInfo? fileInfo) async {
    if (fileInfo == null) return;

    try {
      final filePaths = {...state.filePaths, fileInfo};
      await _repository.saveFileList(filePaths);

      emit(state.copyWith(filePaths: filePaths));
      await _reloadEntries();
    } on Exception catch (e) {
      debugPrint('Error adding file: $e');
    }
  }

  Future<void> removeFilePath(FileInfo fileInfo) async {
    try {
      final filePaths = {...state.filePaths}..remove(fileInfo);
      await _repository.saveFileList(filePaths);

      emit(state.copyWith(filePaths: filePaths));
      await _reloadEntries();
    } on Exception catch (e) {
      debugPrint('Error removing file: $e');
    }
  }

  Future<void> changeInboxFile(FileInfo fileInfo) async {
    try {
      await _repository.saveInboxFile(fileInfo);

      emit(state.copyWith(inboxFile: () => fileInfo));
      await _reloadEntries();
    } on Exception catch (e) {
      debugPrint('Error changing inbox file: $e');
    }
  }

  Future<void> changeTodoStates(OrgTodoStatesWithIgnored todoStates) async {
    try {
      _repository.updateTodoStates(todoStates);

      emit(state.copyWith(todoStates: todoStates));
      await _reloadEntries();
    } on Exception catch (e) {
      debugPrint('Error changing todo states: $e');
    }
  }

  Future<void> applyEdit(OrgEntry entry, EntryEdit edit) async {
    final fileInfo = _fileInfoOf(entry.filePath);
    if (fileInfo == null) return;

    try {
      await _repository.applyEdit(fileInfo, entry, edit);
      await _reloadFile(fileInfo);
    } on Exception catch (e) {
      debugPrint('Error applying edit: $e');
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

  Future<void> _reloadFile(FileInfo fileInfo) => _emitEntries([
    fileInfo,
  ], state.entries.where((entry) => entry.filePath != fileInfo.fileName));

  Future<void> _emitEntries(
    Iterable<FileInfo> fileInfos,
    Iterable<OrgEntry> keep,
  ) async {
    final entries = [
      ...keep,
      ...await _repository.parseEntriesForFiles(
        fileInfos,
        state.todoStates.ignored,
      ),
    ];

    emit(state.copyWith(entries: entries));
    await _repository.cacheOrgEntries(entries, state.todoStates);
  }
}

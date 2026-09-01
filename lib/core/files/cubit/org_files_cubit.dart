import 'package:bloc/bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';

import '../../../entities/org_entry/org_entry.dart';
import '../../todo_states_cubit.dart';
import '../services/org_files_repository.dart';

part 'org_files_state.dart';

class OrgFilesCubit extends Cubit<OrgFilesState> {
  final OrgFilesRepository _repository;

  OrgFilesCubit(this._repository) : super(OrgFilesState.initial());

  Future<void> earlyInit() async {
    final entries = await _repository.loadCachedEntries();
    emit(state.copyWith(entries: entries?.toList() ?? []));
  }

  Future<void> init(OrgTodoStatesWithIgnored todoStates) async {
    try {
      await earlyInit();

      final result = await _repository.loadInitialState(todoStates);
      emit(
        OrgFilesState(
          directory: result.dirInfo,
          status: OrgFilesStatus.success,
          filePaths: result.fileInfos,
          documentsMap: result.documentsMap,
          inboxFile: result.inboxFile,
          todoStates: result.todoStates,
          entries: state.entries,
        ),
      );
    } on Exception catch (e) {
      debugPrint('Error initializing org files: $e');
      emit(OrgFilesState.initial());
    }
    await parseFiles();
  }

  Future<void> parseFiles() async {
    final entries = await _repository.parseAllEntries(
      state.documentsMap,
      state.todoStates.ignored,
    );
    emit(state.copyWith(entries: entries));

    await _repository.cacheOrgEntries(state.entries as List<OrgEntryLoaded>);
  }

  Future<void> setOrgDirectory(DirectoryInfo dirInfo) async {
    await _repository.saveDirectory(dirInfo);

    emit(state.copyWith(directory: () => dirInfo));
  }

  Future<void> addFilePath(FileInfo? fileInfo) async {
    if (fileInfo == null) return;

    try {
      final document = await _repository.loadDocument(fileInfo);
      final filePaths = {...state.filePaths, fileInfo};

      await _repository.saveFileList(filePaths);

      emit(
        state.copyWith(
          filePaths: filePaths,
          documentsMap: {...state.documentsMap, fileInfo: document},
        ),
      );

      emit(
        state.copyWith(
          entries: await _repository.parseAllEntries(
            state.documentsMap,
            state.todoStates.ignored,
          ),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Error adding file: $e');
    }
  }

  Future<void> removeFilePath(FileInfo fileInfo) async {
    try {
      final filePaths = {...state.filePaths}..remove(fileInfo);
      final documentsMap = {...state.documentsMap}..remove(fileInfo);

      await _repository.saveFileList(filePaths);

      emit(state.copyWith(filePaths: filePaths, documentsMap: documentsMap));
    } on Exception catch (e) {
      debugPrint('Error removing file: $e');
    }
  }

  Future<void> changeInboxFile(FileInfo fileInfo) async {
    try {
      await _repository.saveInboxFile(fileInfo);

      final documentsMap = {...state.documentsMap}..remove(state.inboxFile);

      final document = await _repository.loadDocument(fileInfo);
      documentsMap[fileInfo] = document;

      emit(
        state.copyWith(inboxFile: () => fileInfo, documentsMap: documentsMap),
      );
    } on Exception catch (e) {
      debugPrint('Error changing inbox file: $e');
    }
  }

  Future<void> changeTodoStates(OrgTodoStatesWithIgnored todoStates) async {
    try {
      _repository.updateTodoStates(todoStates);

      final newDocuments = await Future.wait(
        state.filePaths.map(_repository.loadDocument),
      );

      final documentsMap = Map<FileInfo, OrgDocument>.fromIterables(
        state.filePaths,
        newDocuments,
      );

      final entries = await _repository.parseAllEntries(
        documentsMap,
        todoStates.ignored,
      );

      emit(
        state.copyWith(
          todoStates: todoStates,
          documentsMap: documentsMap,
          entries: entries,
        ),
      );

      if (state.status == OrgFilesStatus.success) {
        await _repository.cacheOrgEntries(
          state.entries as List<OrgEntryLoaded>,
        );
      }
    } on Exception catch (e) {
      debugPrint('Error changing todo states: $e');
    }
  }

  Future<void> replaceNodes(
    FileInfo fileInfo,
    List<(OrgNode, OrgNode)> replacements,
  ) async {
    try {
      final oldDocument = state.documentsMap[fileInfo];
      if (oldDocument == null) return;

      final newDocument = await _repository.replaceNodesAndSave(
        fileInfo,
        oldDocument,
        replacements,
      );

      emit(
        state.copyWith(
          documentsMap: {...state.documentsMap, fileInfo: newDocument},
        ),
      );
    } on Exception catch (e) {
      debugPrint('Error replacing nodes: $e');
    }
  }
}

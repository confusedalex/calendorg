import 'package:bloc/bloc.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/event.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:org_parser/org_parser.dart';

part 'org_files_state.dart';

class OrgFilesCubit extends Cubit<OrgFilesState> {
  final OrgFilesRepository _repository;

  OrgFilesCubit(this._repository) : super(OrgFilesState.initial());

  Future<void> init(OrgTodoStatesWithIgnored todoStates) async {
    try {
      final result = await _repository.loadInitialState(todoStates);
      final allEvents = _repository.parseAllEvents(
        result.documentsMap,
        todoStates.ignored,
      );
      emit(
        OrgFilesState(
          directory: result.dirInfo,
          filePaths: result.fileInfos,
          documentsMap: result.documentsMap,
          inboxFile: result.inboxFile,
          todoStates: result.todoStates,
          allEvents: allEvents,
        ),
      );
    } catch (e) {
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
          allEvents: _repository.parseAllEvents(
            state.documentsMap,
            state.todoStates.ignored,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error adding file: $e');
    }
  }

  Future<void> removeFilePath(FileInfo fileInfo) async {
    try {
      final filePaths = {...state.filePaths}..remove(fileInfo);
      final documentsMap = {...state.documentsMap}..remove(fileInfo);

      await _repository.saveFileList(filePaths);

      emit(state.copyWith(filePaths: filePaths, documentsMap: documentsMap));
    } catch (e) {
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
    } catch (e) {
      debugPrint('Error changing inbox file: $e');
    }
  }

  Future<void> changeTodoStates(OrgTodoStatesWithIgnored todoStates) async {
    try {
      _repository.updateTodoStates(todoStates);

      final newDocuments = await Future.wait(
        state.filePaths.map((fileInfo) => _repository.loadDocument(fileInfo)),
      );

      final documentsMap = Map<FileInfo, OrgDocument>.fromIterables(
        state.filePaths,
        newDocuments,
      );

      final allEvents = _repository.parseAllEvents(
        documentsMap,
        todoStates.ignored,
      );

      emit(
        state.copyWith(
          todoStates: todoStates,
          documentsMap: documentsMap,
          allEvents: allEvents,
        ),
      );
    } catch (e) {
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
    } catch (e) {
      debugPrint('Error replacing nodes: $e');
    }
  }
}

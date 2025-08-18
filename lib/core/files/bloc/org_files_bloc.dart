import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petitparser/petitparser.dart';

part 'org_files_event.dart';
part 'org_files_state.dart';

class OrgFilesBloc extends Bloc<OrgFilesEvent, OrgFilesState> {
  Parser get parser =>
      OrgParserDefinition(todoStates: [state.todoStates]).build();

  OrgFilesBloc() : super(OrgFilesState.initial()) {
    on<OrgFilesEvent>((event, emit) async {
      switch (event) {
        case OrgFilesInit():
          emit(await _initOrgFilesState());
        case OrgFilesAddFilePath():
          if (event.fileInfo == null) return;
          final fileInfo = event.fileInfo!;

          final filePaths = state.filePaths..add(fileInfo);
          final documentsMap = state.documentsMap
            ..addAll({
              fileInfo: await documentByIdentifier(fileInfo.identifier),
            });

          emit(
            state.copyWith(filePaths: filePaths, documentsMap: documentsMap),
          );
        case OrgFilesRemoveFilePath():
          final filePaths = state.filePaths..remove(event.fileInfo);
          final documentsMap = state.documentsMap..remove(event.fileInfo);

          emit(
            state.copyWith(filePaths: filePaths, documentsMap: documentsMap),
          );

        case OrgFilesReplaceNode():
          final oldDocument = state.documentsMap[event.fileInfo];
          if (oldDocument == null) return;

          final newDoc = oldDocument
              .edit()
              .find(event.oldNode)!
              .replace(event.newNode)
              .commit();

          emit(
            state.copyWith(
              documentsMap: state.documentsMap
                ..update(
                  event.fileInfo,
                  (doc) => parser.parse(newDoc.toMarkup()).value,
                ),
            ),
          );
        case OrgFilesChangeInboxFileEvent():
          emit(state.copyWith(inboxFile: () => event.fileInfo));
        case OrgFilesChangeTodoStatesEvent():
          emit(state.copyWith(todoStates: event.todoStates));
          emit(
            state.copyWith(
              documentsMap: {
                for (var fileInfo in state.filePaths)
                  fileInfo: await documentByIdentifier(fileInfo.identifier),
              },
            ),
          );
      }

      _updateSharedPreferences();
    });
  }

  _updateSharedPreferences() async {
    final prefs = SharedPreferencesAsync();
    // We need to convert the Set to a List, because Dart somehow
    // only know how to encode an List, not a Set
    await prefs.setString("agendaFiles", jsonEncode(state.filePaths.toList()));
    await prefs.setString("inboxFile", jsonEncode(state.inboxFile));
  }

  Future<OrgFilesState> _initOrgFilesState() async {
    final prefs = SharedPreferencesAsync();
    final files = await prefs.getString("agendaFiles");
    final inboxFileString = await prefs.getString("inboxFile");
    final inboxFile = (inboxFileString == null || inboxFileString == "null")
        ? null
        : FileInfo.fromJson((jsonDecode(inboxFileString)));

    if (files == null && inboxFile == null) {
      return OrgFilesState.initial();
    } else if (files == null) {
      return OrgFilesState(
        inboxFile: inboxFile,
        todoStates: state.todoStates,
        filePaths: {},
        documentsMap: {},
      );
    } else {
      final jsonObject = jsonDecode(files) as List<dynamic>;
      final fileInfos =
          jsonObject.map((info) => FileInfo.fromJson(info)).toSet();

      return OrgFilesState(
        filePaths: fileInfos,
        documentsMap: {
          for (var fileInfo in fileInfos)
            fileInfo: await documentByIdentifier(fileInfo.identifier),
        },
        inboxFile: inboxFile,
        todoStates: state.todoStates,
      );
    }
  }

  Future<OrgDocument> documentByIdentifier(String identifier) async => parser
      .parse(
        await FilePickerWritable().readFile(
          identifier: identifier,
          reader: (fileInfo, file) => file.readAsString(),
        ),
      )
      .value;
}

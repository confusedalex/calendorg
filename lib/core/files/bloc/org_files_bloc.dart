import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
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
        case OrgFilesReplaceNodes():
          final oldDocument = state.documentsMap[event.fileInfo];
          if (oldDocument == null) return;

          // Generates the new document.
          // The replacments (oldNode, newNode) are reduced
          // to a Zipper which then get's comitted
          final newDoc = event.replacements
              .fold<OrgZipper>(
                oldDocument.edit(),
                (builder, nodes) =>
                    builder.find(nodes.$1)?.replace(nodes.$2) as OrgZipper,
              )
              .commit();

          await FilePickerWritable().writeFile(
            identifier: event.fileInfo.identifier,
            writer: (file) async =>
                file.writeAsString(newDoc.toMarkup(), mode: FileMode.writeOnly),
          );

          final parseResult = parser.parse(newDoc.toMarkup());
          emit(
            state.copyWith(
              documentsMap: state.documentsMap
                ..update(
                  event.fileInfo,
                  (doc) => parseResult.value,
                ),
            ),
          );
        case OrgFilesChangeInboxFileEvent():
          final documentsMap = {...state.documentsMap}..remove(state.inboxFile);

          if (event.fileInfo case final fileInfo?) {
            documentsMap[fileInfo] = await documentByIdentifier(
              fileInfo.identifier,
            );
          }

          emit(
            state.copyWith(
              inboxFile: () => event.fileInfo,
              documentsMap: documentsMap,
            ),
          );
        case OrgFilesChangeTodoStatesEvent():
          emit(
            state.copyWith(
              todoStates: event.todoStates,
              documentsMap: {
                for (var fileInfo in state.filePaths)
                  fileInfo: await documentByIdentifier(fileInfo.identifier),
              },
            ),
          );
      }

      _updateSharedPreferences().then((_) {}).catchError((e) {
        debugPrint('Error updating preferences after event: $e');
      });
    });
  }

  Future<void> _updateSharedPreferences() async {
    try {
      final prefs = SharedPreferencesAsync();
      // We need to convert the Set to a List, because Dart somehow
      // only know how to encode an List, not a Set
      await prefs.setString("agendaFiles", jsonEncode(state.filePaths.toList()));
      await prefs.setString("inboxFile", jsonEncode(state.inboxFile));
    } catch (e) {
      debugPrint('Error updating shared preferences: $e');
    }
  }

  Future<OrgFilesState> _initOrgFilesState() async {
    try {
      final prefs = SharedPreferencesAsync();
      final files = await prefs.getString("agendaFiles");
      final inboxFileString = await prefs.getString("inboxFile");
      final inboxFile = (inboxFileString == null || inboxFileString == "null")
          ? null
          : FileInfo.fromJson((jsonDecode(inboxFileString)));

      if (files == null && inboxFile == null) {
        return OrgFilesState.initial();
      } else if (files == null) {
        final documentsMap = <FileInfo, OrgDocument>{};
        if (inboxFile != null) {
          try {
            documentsMap[inboxFile] = await documentByIdentifier(
              inboxFile.identifier,
            );
          } catch (e) {
            debugPrint('Error loading inbox file: $e');
          }
        }
        return OrgFilesState(
          inboxFile: inboxFile,
          todoStates: state.todoStates,
          filePaths: {},
          documentsMap: documentsMap,
        );
      } else {
        final jsonObject = jsonDecode(files) as List<dynamic>;
        final fileInfos = jsonObject
            .map((info) => FileInfo.fromJson(info))
            .toSet();
        final documentsMap = <FileInfo, OrgDocument>{};
        
        for (var fileInfo in fileInfos) {
          try {
            documentsMap[fileInfo] = await documentByIdentifier(fileInfo.identifier);
          } catch (e) {
            debugPrint('Error loading file $fileInfo: $e');
          }
        }

        if (inboxFile != null && !fileInfos.contains(inboxFile)) {
          try {
            documentsMap[inboxFile] = await documentByIdentifier(
              inboxFile.identifier,
            );
          } catch (e) {
            debugPrint('Error loading inbox file: $e');
          }
        }

        return OrgFilesState(
          filePaths: fileInfos,
          documentsMap: documentsMap,
          inboxFile: inboxFile,
          todoStates: state.todoStates,
        );
      }
    } catch (e) {
      debugPrint('Error initializing org files state: $e');
      return OrgFilesState.initial();
    }
  }

  Future<OrgDocument> documentByIdentifier(String identifier) async {
    try {
      final content = await FilePickerWritable().readFile(
        identifier: identifier,
        reader: (fileInfo, file) => file.readAsString(),
      );
      final parseResult = parser.parse(content);
      return parseResult.value;
    } catch (e) {
      debugPrint('Error parsing document with identifier $identifier: $e');
      rethrow;
    }
  }
}

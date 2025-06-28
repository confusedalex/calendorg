import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'org_files_event.dart';
part 'org_files_state.dart';

class OrgFilesBloc extends Bloc<OrgFilesEvent, OrgFilesState> {
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
            ..addAll(
                {fileInfo: await documentByIdentifier(fileInfo.identifier)});

          emit(state.copyWith(
              filePaths: filePaths,
              documentsMap: documentsMap,
              fileToCaptureTo: () => filePaths.length == 1
                  ? filePaths.first
                  : state.fileToCaptureTo));
        case OrgFilesRemoveFilePath():
          final filePaths = state.filePaths..remove(event.fileInfo);
          final documentsMap = state.documentsMap..remove(event.fileInfo);

          emit(state.copyWith(
              filePaths: filePaths,
              documentsMap: documentsMap,
              fileToCaptureTo: () =>
                  filePaths.isEmpty ? null : state.fileToCaptureTo));

        case OrgFilesReplaceNode():
          final oldDocument = state.documentsMap[event.fileInfo];
          if (oldDocument == null) return;

          final newDoc = oldDocument
              .edit()
              .find(event.oldNode)!
              .replace(event.newNode)
              .commit();

          emit(state.copyWith(
              documentsMap: state.documentsMap
                ..update(event.fileInfo,
                    (doc) => OrgDocument.parse(newDoc.toMarkup()))));
        case OrgFilesChangeCaptureFileEvent():
          emit(state.copyWith(fileToCaptureTo: () => event.fileInfo));
      }

      _updateSharedPreferences();
    });
  }

  _updateSharedPreferences() async {
    final prefs = SharedPreferencesAsync();
    // We need to convert the Set to a List, because Dart somehow
    // only know how to encode an List, not a Set
    await prefs.setString("agendaFiles", jsonEncode(state.filePaths.toList()));
    await prefs.setString("captureFile", jsonEncode(state.fileToCaptureTo));
  }

  Future<OrgFilesState> _initOrgFilesState() async {
    final prefs = SharedPreferencesAsync();
    final files = await prefs.getString("agendaFiles");
    final captureFileString = await prefs.getString("agendaFiles");
    final captureFile = captureFileString == null
        ? null
        : FileInfo.fromJsonString(captureFileString);
    if (files == null) {
      return OrgFilesState(filePaths: {}, documentsMap: {});
    }
    final jsonObject = jsonDecode(files) as List<dynamic>;
    final fileInfos = jsonObject.map((info) => FileInfo.fromJson(info)).toSet();

    return OrgFilesState(
        filePaths: fileInfos,
        documentsMap: {
          for (var fileInfo in fileInfos)
            fileInfo: await documentByIdentifier(fileInfo.identifier)
        },
        fileToCaptureTo: captureFile);
  }

  Future<OrgDocument> documentByIdentifier(String identifier) async =>
      OrgDocument.parse(await FilePickerWritable().readFile(
        identifier: identifier,
        reader: (fileInfo, file) => file.readAsString(),
      ));
}

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';

part 'org_files_event.dart';
part 'org_files_state.dart';

class OrgFilesBloc extends Bloc<OrgFilesEvent, OrgFilesState> {
  OrgFilesBloc() : super(OrgFilesState.initial()) {
    on<OrgFilesEvent>((event, emit) async {
      switch (event) {
        case OrgFilesAddFilePath():
          final document =
              OrgDocument.parse(await File(event.file).readAsString());

          emit(state.copyWith(
              filePaths: state.filePaths..add(event.file),
              documentsMap: state.documentsMap
                ..addAll({event.file: document})));
        case OrgFilesRemoveFilePath():
          emit(state.copyWith(
              filePaths: state.filePaths..remove(event.file),
              documentsMap: state.documentsMap..remove(event.file)));
        case OrgFilesReplaceNode():
          final oldDocument = state.documentsMap[event.filePath];
          if (oldDocument == null) return;
          if (!oldDocument.children.contains(event.oldNode)) return;

          final newDoc = oldDocument
              .edit()
              .find(event.oldNode)!
              .replace(event.newNode)
              .commit();
          emit(state.copyWith(
              documentsMap: state.documentsMap
                ..update(event.filePath,
                    (doc) => OrgDocument.parse(newDoc.toMarkup()))));
      }
    });
  }
}

import 'dart:io';

import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaFilesDialog extends StatelessWidget {
  List<TextButton> buttons(OrgFilesState state, BuildContext context) {
    bool validateFile(FileInfo? fileInfo) {
      if (fileInfo == null || fileInfo.fileName == null) {
        sendError(context, "File could not be opened!");
        return false;
      }
      return true;
    }

    bool validateFileName(String? fileName) {
      if (fileName == null ||
          state.filePaths.any((it) => it.fileName == fileName)) {
        sendError(context, "File does already exist!");
        return false;
      }
      return true;
    }

    Future<FileInfo?> selectGetFileInfo() async =>
        await FilePickerWritable().openFile((fileInfo, file) async {
          return fileInfo;
        });

    Future<FileInfo?> createGetFileInfo() async =>
        await FilePickerWritable().openFileForCreate(
          writer: (file) => file.writeAsString('', mode: FileMode.writeOnly),
          fileName: "agenda.org",
        );

    void onPressed(FileInfo? fileInfo) {
      if (!validateFile(fileInfo)) return;
      if (!validateFileName(fileInfo?.fileName)) return;
      context.read<OrgFilesBloc>().add(OrgFilesAddFilePath(fileInfo));
    }

    return [
      TextButton(
        onPressed: () async => onPressed(await selectGetFileInfo()),
        child: Text("select file"),
      ),
      TextButton(
        onPressed: () async => onPressed(await createGetFileInfo()),
        child: Text("create file"),
      ),
    ];
  }

  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrgFilesBloc, OrgFilesState>(
      builder: (_, state) => AlertDialog(
        title: Row(children: [Text("Agenda Files"), Spacer(), CloseButton()]),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.filePaths.length,
            itemBuilder: (context, index) {
              final fileInfo = state.filePaths.elementAt(index);
              return ListTile(
                title: Text(
                  fileInfo.fileName ?? "File name could't not be loaded",
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => context.read<OrgFilesBloc>().add(
                    OrgFilesRemoveFilePath(fileInfo),
                  ),
                ),
              );
            },
          ),
        ),
        actions: buttons(state, context),
      ),
    );
  }
}

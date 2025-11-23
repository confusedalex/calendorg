import 'package:calendorg/l10n/calendorg_localizations.dart';
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
        sendError(
          context,
          CalendorgLocalizations.of(context)!.file_could_not_open,
        );
        return false;
      }
      return true;
    }

    bool validateFileName(String? fileName) {
      if (fileName == null ||
          state.filePaths.any((it) => it.fileName == fileName)) {
        sendError(
          context,
          CalendorgLocalizations.of(context)!.file_already_exists,
        );
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
        child: Text(CalendorgLocalizations.of(context)!.select_file),
      ),
      TextButton(
        onPressed: () async => onPressed(await createGetFileInfo()),
        child: Text(CalendorgLocalizations.of(context)!.create_file),
      ),
    ];
  }

  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrgFilesBloc, OrgFilesState>(
      builder: (_, state) => AlertDialog(
        title: Row(
          children: [
            Text(CalendorgLocalizations.of(context)!.agenda_files),
            Spacer(),
            CloseButton(),
          ],
        ), // Agenda Files
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.filePaths.length,
            itemBuilder: (context, index) {
              final fileInfo = state.filePaths.elementAt(index);
              return ListTile(
                title: Text(
                  fileInfo.fileName ??
                      CalendorgLocalizations.of(
                        context,
                      )!.file_name_couldnt_load,
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

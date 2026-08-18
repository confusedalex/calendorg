import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../l10n/calendorg_localizations.dart';
import 'dart:io';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaFilesDialog extends StatelessWidget {
  List<TextButton> buttons(OrgFilesState state, BuildContext context) {
    bool validateFile(FileInfo? fileInfo) {
      if (fileInfo == null || fileInfo.fileName == null) {
        sendError(
          context,
          CalendorgLocalizations.of(context).file_could_not_open,
        );
        return false;
      }
      return true;
    }

    Future<bool> validateFileDirectory(
      FileInfo? fileInfo,
      DirectoryInfo? dirInfo,
    ) async {
      if (fileInfo == null || dirInfo == null) return false;
      if (fileInfo.fileName == null) return false;

      sendErr() => sendError(
        context,
        'File is not in org folder!\nPlease select a file that lies in your in org folder or change your org folder.',
      );

      try {
        final filePicker = FilePickerWritable();
        late final EntityInfo relative;

        try {
          relative = await filePicker.resolveRelativePath(
            directoryIdentifier: dirInfo.identifier,
            relativePath: fileInfo.fileName as String,
          );
        } catch (e) {
          sendErr();
          return false;
        }

        final relativeSize = await filePicker.readFile(
          identifier: relative.identifier,
          reader: (_, file) async => file.length(),
        );
        final pickedSize = await filePicker.readFile(
          identifier: fileInfo.identifier,
          reader: (_, file) async => file.length(),
        );

        final isSameFile = relativeSize == pickedSize;

        if (!isSameFile) {
          sendErr();
        }

        return isSameFile;
      } catch (e) {
        return false;
      }
    }

    bool validateFileName(String? fileName) {
      if (fileName == null ||
          state.filePaths.any((it) => it.fileName == fileName)) {
        sendError(
          context,
          CalendorgLocalizations.of(context).file_already_exists,
        );
        return false;
      }
      return true;
    }

    Future<FileInfo?> selectGetFileInfo() async {
      try {
        return await FilePickerWritable().openFile((fileInfo, file) async {
          return fileInfo;
        });
      } catch (e) {
        if (context.mounted) {
          sendError(context, 'Error selecting file: $e');
        }
        return null;
      }
    }

    Future<FileInfo?> createGetFileInfo() async {
      try {
        return await FilePickerWritable().openFileForCreate(
          writer: (file) => file.writeAsString('', mode: FileMode.writeOnly),
          fileName: 'agenda.org',
        );
      } catch (e) {
        if (context.mounted) {
          sendError(context, 'Error creating file: $e');
        }
        return null;
      }
    }

    void onPressed(FileInfo? fileInfo) async {
      if (!validateFile(fileInfo)) return;
      if (!(await validateFileDirectory(
        fileInfo,
        context.read<OrgFilesCubit>().state.directory,
      ))) {
        return;
      }
      if (!validateFileName(fileInfo?.fileName)) return;
      context.read<OrgFilesCubit>().addFilePath(fileInfo);
    }

    return [
      TextButton(
        onPressed: () async => onPressed(await selectGetFileInfo()),
        child: Text(CalendorgLocalizations.of(context).select_file),
      ),
      TextButton(
        onPressed: () async => onPressed(await createGetFileInfo()),
        child: Text(CalendorgLocalizations.of(context).create_file),
      ),
    ];
  }

  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogShell(
      title: CalendorgLocalizations.of(context).agenda_files,
      titleIcon: Icons.file_copy,
      showClose: true,
      content: BlocBuilder<OrgFilesCubit, OrgFilesState>(
        builder: (_, state) => SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.filePaths.length,
            itemBuilder: (context, index) {
              final fileInfo = state.filePaths.elementAt(index);
              return ListTile(
                title: Text(
                  fileInfo.fileName ??
                      CalendorgLocalizations.of(context).file_name_couldnt_load,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      context.read<OrgFilesCubit>().removeFilePath(fileInfo),
                ),
              );
            },
          ),
        ),
      ),
      actions: buttons(context.read<OrgFilesCubit>().state, context),
    );
  }
}

import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/files/services/org_file_service.dart';
import '../../../../l10n/calendorg_localizations.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class AgendaFilesDialog extends StatelessWidget {
  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final filePaths = context.select(
      (OrgFilesCubit cubit) => cubit.state.filePaths,
    );
    final validateFileDirectory = context.select(
      (OrgFileService service) => service.validateFileDirectory,
    );
    final filePicker = context.select(
      (OrgFileService service) => service.filePicker,
    );
    final orgFilesCubit = context.read<OrgFilesCubit>();

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

    bool validateFileName(String? fileName) {
      if (fileName == null || filePaths.any((it) => it.fileName == fileName)) {
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
        return await filePicker.openFile((fileInfo, file) async {
          return fileInfo;
        });
      } on Exception catch (e) {
        if (context.mounted) {
          sendError(context, 'Error selecting file: $e');
        }
        return null;
      }
    }

    Future<FileInfo?> createGetFileInfo() async {
      try {
        return await filePicker.openFileForCreate(
          writer: (file) => file.writeAsString('', mode: FileMode.writeOnly),
          fileName: 'agenda.org',
        );
      } on Exception catch (e) {
        if (context.mounted) {
          sendError(context, 'Error creating file: $e');
        }
        return null;
      }
    }

    Future<void> onPressed(
      OrgFilesCubit orgFilesCubit,
      FileInfo? fileInfo,
    ) async {
      if (!validateFile(fileInfo)) return;
      if (!(await validateFileDirectory(
        context,
        fileInfo,
        orgFilesCubit.state.directory,
      ))) {
        return;
      }
      if (!validateFileName(fileInfo?.fileName)) return;
      await orgFilesCubit.addFilePath(fileInfo);
    }

    final buttons = [
      TextButton(
        onPressed: () async =>
            onPressed(orgFilesCubit, await selectGetFileInfo()),
        child: Text(CalendorgLocalizations.of(context).select_file),
      ),
      TextButton(
        onPressed: () async =>
            onPressed(orgFilesCubit, await createGetFileInfo()),
        child: Text(CalendorgLocalizations.of(context).create_file),
      ),
    ];

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
                  onPressed: () => orgFilesCubit.removeFilePath(fileInfo),
                ),
              );
            },
          ),
        ),
      ),
      actions: buttons,
    );
  }
}

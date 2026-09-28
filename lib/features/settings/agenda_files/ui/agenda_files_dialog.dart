import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/files/services/org_files_repository.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class AgendaFilesDialog extends StatelessWidget {
  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final filePaths = context.select(
      (OrgFilesCubit cubit) => cubit.state.filePaths,
    );
    final repository = context.read<OrgFilesRepository>();
    final orgFilesCubit = context.read<OrgFilesCubit>();

    bool validateFile(FileInfo? fileInfo) {
      if (fileInfo == null || fileInfo.fileName == null) {
        sendError(context.l10n.file_could_not_open);
        return false;
      }
      return true;
    }

    bool validateFileName(String? fileName) {
      if (fileName == null || filePaths.any((it) => it.fileName == fileName)) {
        sendError(context.l10n.file_already_exists);
        return false;
      }
      return true;
    }

    Future<FileInfo?> selectGetFileInfo() async {
      try {
        return await repository.pickFile();
      } on Exception catch (e) {
        if (context.mounted) {
          sendError(context.l10n.error_selecting_file(e));
        }
        return null;
      }
    }

    Future<FileInfo?> createGetFileInfo() async {
      try {
        return await repository.createEmptyFile('agenda.org');
      } on Exception catch (e) {
        if (context.mounted) {
          sendError(context.l10n.error_creating_file(e));
        }
        return null;
      }
    }

    Future<void> onPressed(
      OrgFilesCubit orgFilesCubit,
      FileInfo? fileInfo,
    ) async {
      if (!validateFile(fileInfo)) return;
      if (!(await repository.validateFileDirectory(
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
        child: Text(context.l10n.select_file),
      ),
      TextButton(
        onPressed: () async =>
            onPressed(orgFilesCubit, await createGetFileInfo()),
        child: Text(context.l10n.create_file),
      ),
    ];

    return DialogShell(
      title: context.l10n.agenda_files,
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
                  fileInfo.fileName ?? context.l10n.file_name_couldnt_load,
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

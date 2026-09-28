import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/files/services/org_file_service.dart';
import '../../../../util.dart';
import 'agenda_files_dialog.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orgFileService = context.read<OrgFileService>();

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<OrgFilesCubit, OrgFilesState>(
        builder: (context, state) => Column(
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(context.l10n.pick_org_directory),
              trailing: Text(
                state.directory?.fileName ?? context.l10n.not_set,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () async {
                try {
                  final dirInfo = await orgFileService.filePicker
                      .openDirectory();

                  if (dirInfo == null) throw Error();
                  if (context.mounted) {
                    await context.read<OrgFilesCubit>().setOrgDirectory(
                      dirInfo,
                    );
                  }
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.error_selecting_file(e)),
                      ),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              enabled: state.directory != null,
              leading: const Icon(Icons.inbox),
              title: Text(context.l10n.inbox_file),
              trailing: Text(
                state.inboxFile?.fileName ?? context.l10n.not_set,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () async {
                try {
                  final fileInfo = await orgFileService.filePicker.openFile((
                    fileInfo,
                    file,
                  ) async {
                    return fileInfo;
                  });

                  final valid = await orgFileService.validateFileDirectory(
                    fileInfo,
                    state.directory,
                  );

                  if (valid && context.mounted) {
                    await context.read<OrgFilesCubit>().changeInboxFile(
                      fileInfo!,
                    );
                  }
                } on Exception catch (e) {
                  sendError(globalL10n.error_loading_file(e));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_copy),
              title: Text(context.l10n.agenda_files),
              enabled: state.directory != null,
              onTap: () => showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<OrgFilesCubit>(context),
                  child: const AgendaFilesDialog(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

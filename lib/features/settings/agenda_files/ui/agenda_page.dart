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
    final filePicker = context.select(
      (OrgFileService service) => service.filePicker,
    );
    final validateFileDirectory = context.select(
      (OrgFileService service) => service.validateFileDirectory,
    );

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<OrgFilesCubit, OrgFilesState>(
        builder: (context, state) => Column(
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Pick org directory'),
              trailing: Text(
                state.directory?.fileName ?? 'Not set',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () async {
                try {
                  final dirInfo = await filePicker.openDirectory();

                  if (dirInfo == null) throw Error();
                  if (context.mounted) {
                    context.read<OrgFilesCubit>().setOrgDirectory(dirInfo);
                  }
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error selecting file: $e')),
                    );
                  }
                }
              },
            ),
            const Divider(),
            ListTile(
              enabled: state.directory != null,
              leading: const Icon(Icons.inbox),
              title: const Text('Inbox File'),
              trailing: Text(
                state.inboxFile?.fileName ?? 'Not set',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () async {
                try {
                  final fileInfo = await filePicker.openFile((
                    fileInfo,
                    file,
                  ) async {
                    return fileInfo;
                  });

                  final valid = await validateFileDirectory(
                    context,
                    fileInfo,
                    state.directory,
                  );

                  if (valid && context.mounted) {
                    await context.read<OrgFilesCubit>().changeInboxFile(
                      fileInfo!,
                    );
                  }
                } on Exception catch (e) {
                  sendError(context, 'Error loading file: {$e}');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_copy),
              title: const Text('Agenda Files'),
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

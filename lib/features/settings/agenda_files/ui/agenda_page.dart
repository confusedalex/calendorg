import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../util.dart';
import 'agenda_files_dialog.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  final dirInfo = await FilePickerWritable().openDirectory();

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
                  final fileInfo = await FilePickerWritable().openFile((
                    fileInfo,
                    file,
                  ) async {
                    return fileInfo;
                  });

                  if (fileInfo == null) return;
                  if (state.directory == null) return;
                  if (fileInfo.fileName == null &&
                      fileInfo.fileName is String) {
                    return;
                  }
                  final relative = await FilePickerWritable()
                      .resolveRelativePath(
                        directoryIdentifier: state.directory!.identifier,
                        relativePath: fileInfo.fileName!,
                      );
                  final isSameFile = relative.uri == fileInfo.uri;
                  if (!isSameFile) {
                    sendError(
                      context,
                      'File is not in org folder!\nPlease select a file that lies in your in org folder or change your org folder.',
                    );
                  }
                  if (context.mounted) {
                    context.read<OrgFilesCubit>().changeInboxFile(fileInfo);
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

import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/settings/agenda_files/agenda_files_dialog.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              leading: Icon(Icons.inbox),
              title: Text("Pick org directory"),
              trailing: Text(
                state.directory?.fileName ?? "Not set",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () async {
                try {
                  final dirInfo = await FilePickerWritable().openDirectory();

                  if (dirInfo == null) throw Error();
                  if (context.mounted) {
                    context.read<OrgFilesCubit>().setOrgDirectory(dirInfo);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error selecting file: $e')),
                    );
                  }
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("Agenda Files"),
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

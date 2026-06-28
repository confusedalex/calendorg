import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          BlocBuilder<OrgFilesCubit, OrgFilesState>(
            builder: (context, state) => ListTile(
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

                  context.read<OrgFilesCubit>().setOrgDirectory(dirInfo);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error selecting file: $e')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

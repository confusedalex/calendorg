import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaFilesDialog extends StatelessWidget {
  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Row(
          children: [Text("Agenda Files"), Spacer(), CloseButton()],
        ),
        content: SizedBox(
            width: double.maxFinite,
            child: BlocBuilder<OrgFilesBloc, OrgFilesState>(
                builder: (context, state) => Column(
                      children: state.filePaths
                          .map((fileInfo) => ListTile(
                                title: Text(fileInfo.fileName ??
                                    "File name could't not be loaded"),
                                trailing: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => context
                                      .read<OrgFilesBloc>()
                                      .add(OrgFilesRemoveFilePath(fileInfo)),
                                ),
                              ))
                          .toList(),
                    ))),
        actions: [
          TextButton(
              onPressed: () async => context.read<OrgFilesBloc>().add(
                      OrgFilesAddFilePath(await FilePickerWritable()
                          .openFile((fileInfo, file) async {
                    return fileInfo;
                  }))),
              child: Text("add"))
        ],
      );
}

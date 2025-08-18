import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaFilesDialog extends StatelessWidget {
  const AgendaFilesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [Text("Agenda Files"), Spacer(), CloseButton()],
      ),
      content: BlocBuilder<OrgFilesBloc, OrgFilesState>(
          builder: (context, state) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.filePaths.length,
                    itemBuilder: (context, index) {
                      final fileInfo = state.filePaths.elementAt(index);
                      return ListTile(
                        title: Text(fileInfo.fileName ??
                            "File name could't not be loaded"),
                        leading: Radio(
                            value: fileInfo.identifier,
                            groupValue: state.inboxFile?.identifier,
                            onChanged: (value) => context
                                .read<OrgFilesBloc>()
                                .add(OrgFilesChangeInboxFileEvent(fileInfo))),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => context
                              .read<OrgFilesBloc>()
                              .add(OrgFilesRemoveFilePath(fileInfo)),
                        ),
                      );
                    }),
              )),
      actions: [
        TextButton(
            onPressed: () async => context
                .read<OrgFilesBloc>()
                .add(OrgFilesAddFilePath(
                    await FilePickerWritable().openFile((fileInfo, file) async {
                  return fileInfo;
                }))),
            child: Text("add"))
      ],
    );
  }
}

import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/features/diff_view/cubit/diff_view_cubit.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

class DiffViewPage extends StatelessWidget {
  const DiffViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final oldText = context.select(
      (DiffViewCubit cubit) => cubit.state.oldText,
    );
    final newText = context.select(
      (OrgFilesBloc bloc) =>
          bloc.state.documentsMap.entries.firstOrNull?.value.toMarkup(),
    );

    if (oldText == null) {
      return Center(
        child: OutlinedButton(
          onPressed: () async {
            context.read<DiffViewCubit>().changeOldText(
              (await FilePickerWritable().openFile((fileInfo, file) {
                    return file.readAsString();
                  }) ??
                  ""),
            );
          },
          child: Text("select"),
        ),
      );
    }

    return SingleChildScrollView(
      child: PrettyDiffText(oldText: oldText, newText: newText ?? "Loading..."),
    );
  }
}

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../model/diff_view_cubit.dart';

class DiffViewPage extends StatelessWidget {
  const DiffViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final oldText = context.select(
      (DiffViewCubit cubit) => cubit.state.oldText,
    );
    final newText = context.select(
      (OrgFilesCubit bloc) =>
          bloc.state.documentsMap.entries.firstOrNull?.value.toMarkup(),
    );

    if (oldText == null) {
      return Center(
        child: OutlinedButton(
          onPressed: () async {
            try {
              final content = await FilePickerWritable().openFile((
                fileInfo,
                file,
              ) {
                return file.readAsString();
              });
              if (content != null && context.mounted) {
                context.read<DiffViewCubit>().changeOldText(content);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error reading file: $e')),
                );
              }
            }
          },
          child: const Text('select'),
        ),
      );
    }

    return SingleChildScrollView(
      child: PrettyDiffText(oldText: oldText, newText: newText ?? 'Loading...'),
    );
  }
}

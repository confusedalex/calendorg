import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/files/services/org_file_service.dart';
import '../model/diff_view_cubit.dart';

class DiffViewPage extends StatelessWidget {
  const DiffViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filePicker = context.select(
      (OrgFileService service) => service.filePicker,
    );
    final oldText = context.select(
      (DiffViewCubit cubit) => cubit.state.oldText,
    );
    final fileInfo = context.select(
      (OrgFilesCubit bloc) => bloc.state.filePaths.firstOrNull,
    );

    if (oldText == null) {
      return Center(
        child: OutlinedButton(
          onPressed: () async {
            try {
              final content = await filePicker.openFile((fileInfo, file) {
                return file.readAsString();
              });
              if (content != null && context.mounted) {
                context.read<DiffViewCubit>().changeOldText(content);
              }
            } on Exception catch (e) {
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

    return FutureBuilder<String>(
      future: fileInfo == null
          ? null
          : context.read<OrgFileService>().readText(fileInfo.identifier),
      builder: (context, snapshot) => SingleChildScrollView(
        child: PrettyDiffText(
          oldText: oldText,
          newText: snapshot.data ?? 'Loading...',
        ),
      ),
    );
  }
}

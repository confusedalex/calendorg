import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/files/org_files_problem.dart';
import '../../../../core/files/services/org_files_repository.dart';
import '../../../../shared/ui/errors.dart';
import '../../../../util.dart';
import 'agenda_files_dialog.dart';

final _log = Logger('AgendaPage');

Future<void> pickOrgDirectory(BuildContext context) async {
  try {
    final dirInfo = await context.read<OrgFilesRepository>().pickDirectory();

    if (dirInfo == null || !context.mounted) return;
    await context.read<OrgFilesCubit>().setOrgDirectory(dirInfo);
  } on Exception catch (e, stack) {
    _log.warning('Error picking directory', e, stack);
    if (context.mounted) {
      showError(context, context.l10n.error_selecting_file);
    }
  }
}

Future<void> pickInboxFile(BuildContext context) async {
  final repository = context.read<OrgFilesRepository>();
  final cubit = context.read<OrgFilesCubit>();
  final dirInfo = cubit.state.directory;
  try {
    final fileInfo = await repository.pickFile();
    if (fileInfo == null || dirInfo == null) return;

    await repository.ensureInDirectory(fileInfo, dirInfo);
    await cubit.changeInboxFile(fileInfo);
  } on OrgFilesProblem catch (problem) {
    if (context.mounted) showProblem(context, problem);
  } on Exception catch (e, stack) {
    _log.warning('Error picking inbox file', e, stack);
    if (context.mounted) {
      showError(context, context.l10n.error_loading_file);
    }
  }
}

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.agenda_files)),
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
              onTap: () => pickOrgDirectory(context),
            ),
            ListTile(
              enabled: state.directory != null,
              leading: const Icon(Icons.inbox),
              title: Text(context.l10n.inbox_file),
              trailing: Text(
                state.inboxFile?.fileName ?? context.l10n.not_set,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => pickInboxFile(context),
            ),
            ListTile(
              leading: const Icon(Icons.folder_copy),
              title: Text(context.l10n.agenda_files),
              enabled: state.directory != null,
              onTap: () => showDialog(
                context: context,
                builder: (_) => const AgendaFilesDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

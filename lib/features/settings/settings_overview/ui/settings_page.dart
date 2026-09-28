import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/starting_day_cubit.dart';
import '../../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../../core/todo_states_cubit.dart';
import '../../../../util.dart';
import '../../agenda_files/ui/agenda_page.dart';
import '../../debug/ui/debug_page.dart';
import '../../starting_day/ui/starting_day_dialog.dart';
import '../../tags/ui/tags_page.dart';
import '../../theme/model/theme_bloc.dart';
import '../../theme/ui/theme_dialog.dart';
import '../../todo_state/ui/todo_states_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.palette),
          title: Text(context.l10n.tag_colors),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<TagColorsCubit>(context),
                child: const TagsPage(),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(context.l10n.starting_day_of_week),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<StartingDayCubit>(context),
              child: const StartingDateDialog(),
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.check_circle),
          title: Text(context.l10n.todo_states),
          onTap: () => showDialog(
            context: context,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<TodoStatesCubit>()),
                BlocProvider.value(value: context.read<OrgFilesCubit>()),
              ],
              child: const TodoStatesDialog(),
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.brightness_4),
          title: Text(context.l10n.theme),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<ThemeBloc>(context),
              child: const ThemeDialog(),
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: Text(context.l10n.debug),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<OrgFilesCubit>(context),
                child: const DebugPage(),
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.folder),
          title: Text(context.l10n.agenda_files),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<OrgFilesCubit>(context),
                child: const AgendaPage(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

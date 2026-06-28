import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/agenda_files/agenda_page.dart';
import 'package:calendorg/features/settings/debug_page.dart';
import 'package:calendorg/features/settings/starting_day_dialog.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/features/settings/tags/tags_page.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:calendorg/features/settings/theme/theme_dialog.dart';
import 'package:calendorg/features/settings/todo_state/todo_states_dialog.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FloatingActionButtonCubit>().changeButton(null);
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.palette),
          title: Text("Tag Colors"),
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
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text("Starting Day of Week"),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<StartingDayCubit>(context),
              child: const StartingDateDialog(),
            ),
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.check_circle),
          title: Text("TODO States"),
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
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.brightness_4),
          title: Text("Theme"),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<ThemeBloc>(context),
              child: const ThemeDialog(),
            ),
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.bug_report),
          title: Text("Debug"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<OrgFilesCubit>(context),
                child: DebugPage(),
              ),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.folder),
          title: Text("Agenda Files"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<OrgFilesCubit>(context),
                child: AgendaPage(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

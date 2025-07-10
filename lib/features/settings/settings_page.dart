import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/agenda_files_dialog.dart';
import 'package:calendorg/features/settings/starting_day_dialog.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/features/settings/tags/tags_page.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:calendorg/features/settings/theme/theme_dialog.dart';
import 'package:calendorg/features/settings/todo_state/todo_states_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FloatingActionButtonCubit>().changeButton(null);
    return Column(children: [
      ListTile(
          title: Text("Tag Colors"),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<TagColorsCubit>(context),
                      child: const TagsPage())))),
      Divider(),
      ListTile(
          title: Text("Starting Day of week"),
          onTap: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<StartingDayCubit>(context),
                  child: const StartingDateDialog()))),
      Divider(),
      ListTile(
          title: Text("TODO states"),
          onTap: () => showDialog(
              context: context,
              builder: (_) => MultiBlocProvider(providers: [
                    BlocProvider.value(value: context.read<TodoStatesCubit>()),
                    BlocProvider.value(value: context.read<OrgFilesBloc>())
                  ], child: const TodoStatesDialog()))),
      Divider(),
      ListTile(
          title: Text("Agenda Files"),
          onTap: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<OrgFilesBloc>(context),
                  child: const AgendaFilesDialog()))),
      Divider(),
      ListTile(
          title: Text("Theme"),
          onTap: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<ThemeBloc>(context),
                  child: const ThemeDialog()))),
    ]);
  }
}

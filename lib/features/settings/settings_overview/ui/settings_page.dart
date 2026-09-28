import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/logging.dart';
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
    final themeMode = context.watch<ThemeBloc>().state;
    final directory = context.select(
      (OrgFilesCubit cubit) => cubit.state.directory?.fileName,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _SectionHeader(context.l10n.settings_section_files),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(context.l10n.agenda_files),
          subtitle: Text(directory ?? context.l10n.not_set),
          trailing: const Icon(Icons.chevron_right),
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
        _SectionHeader(context.l10n.settings_section_calendar),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(context.l10n.tag_colors),
          trailing: const Icon(Icons.chevron_right),
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
        ListTile(
          leading: const Icon(Icons.calendar_view_week_outlined),
          title: Text(context.l10n.starting_day_of_week),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<StartingDayCubit>(context),
              child: const StartingDateDialog(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline),
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
        _SectionHeader(context.l10n.settings_section_appearance),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: Text(context.l10n.theme),
          subtitle: Text(switch (themeMode) {
            ThemeMode.dark => context.l10n.theme_dark,
            ThemeMode.light => context.l10n.theme_light,
            ThemeMode.system => context.l10n.theme_automatic,
          }),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<ThemeBloc>(context),
              child: const ThemeDialog(),
            ),
          ),
        ),
        _SectionHeader(context.l10n.settings_section_diagnostics),
        ListTile(
          leading: const Icon(Icons.content_copy_outlined),
          title: Text(context.l10n.copy_log),
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final message = context.l10n.log_copied;
            await Clipboard.setData(ClipboardData(text: logText));
            messenger.showSnackBar(SnackBar(content: Text(message)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: Text(context.l10n.debug),
          trailing: const Icon(Icons.chevron_right),
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
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

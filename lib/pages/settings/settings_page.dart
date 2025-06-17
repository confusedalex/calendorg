import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/pages/settings/starting_day_dialog.dart';
import 'package:calendorg/pages/settings/starting_day_cubit.dart';
import 'package:calendorg/pages/settings/tags/tags_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
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
      ]);
}

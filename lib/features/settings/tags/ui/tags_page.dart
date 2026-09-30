import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/tag_colors/tag_color.dart';
import '../../../../util.dart';
import 'edit_tag_color_dialog.dart';
import 'new_tag_color_dialog.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.tag_colors)),
    body: BlocSelector<SettingsCubit, AppSettings, List<TagColor>>(
      selector: (settings) => settings.tagColors,
      builder: (_, state) => ReorderableListView(
        buildDefaultDragHandles: false,
        children: state
            .mapIndexed(
              (i, tagColor) => ListTile(
                key: Key(tagColor.tag),
                title: Text(tagColor.tag),
                trailing: ReorderableDragStartListener(
                  index: i,
                  child: const Icon(Icons.drag_handle),
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: tagColor.color,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => EditTagColorDialog(tagColor),
                  );
                },
              ),
            )
            .toList(),
        onReorderItem: (oldIndex, newIndex) =>
            context.read<SettingsCubit>().reorderTagColors(oldIndex, newIndex),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (_) => const NewTagColorDialog(),
        );
      },
      icon: const Icon(Icons.add),
      label: Text(context.l10n.add),
    ),
  );
}

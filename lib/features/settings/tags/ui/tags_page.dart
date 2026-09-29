import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tag_colors/tag_color.dart';
import '../../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../../util.dart';
import '../model/new_tag_color_cubit.dart';
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
    body: BlocBuilder<TagColorsCubit, List<TagColor>>(
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
            context.read<TagColorsCubit>().reorder(oldIndex, newIndex),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (_) => BlocProvider(
            create: (context) => NewTagColorCubit(),
            child: const NewTagColorDialog(),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: Text(context.l10n.add),
    ),
  );
}

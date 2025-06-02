import 'package:calendorg/pages/settings/tags/edit_tag_color_dialog.dart';
import 'package:calendorg/pages/settings/tags/new_tag_color_dialog.dart';
import 'package:calendorg/tag_color.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<TagColorsCubit, List<TagColor>>(
          builder: (_, state) => ReorderableListView(
              buildDefaultDragHandles: false,
              children: state
                  .mapIndexed((i, tagColor) => ListTile(
                        key: Key(tagColor.tag),
                        title: Text(tagColor.tag),
                        trailing: ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle),
                        ),
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: tagColor.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                  value:
                                      BlocProvider.of<TagColorsCubit>(context),
                                  child: EditTagColorDialog(tagColor)));
                        },
                      ))
                  .toList(),
              onReorder: (oldIndex, newIndex) =>
                  context.read<TagColorsCubit>().reorder(oldIndex, newIndex))),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<TagColorsCubit>(context),
                    child: NewTagColorDialog()));
          },
          label: Text("Add")));
}

import 'package:calendorg/tag_color.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  String tagName = "";
  Color selectedColor = Color(0x00000000);
  TagColor? selectedTag;

  Widget tagColorEdit(TagColor? tag) => AlertDialog(
        title: Text("Add new Tag"),
        content: Column(
          children: [
            TextField(
                controller: TextEditingController()..text = tag?.tag ?? '',
                onChanged: (value) => setState(() {
                      tagName = value;
                    })),
            Divider(),
            ColorPicker(
              color: tag?.color ?? Colors.blue,
              onColorChanged: (Color color) => setState(() {
                selectedColor = color;
              }),
              pickersEnabled: <ColorPickerType, bool>{
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.wheel: true
              },
            )
          ],
        ),
        actions: [
          if (tag != null)
            TextButton(
                onPressed: () {
                  context.read<TagColorsCubit>().removeTagColor(tag.tag);
                  Navigator.of(context).pop();
                },
                child: Text("delete")),
          TextButton(
              onPressed: () {
                context
                    .read<TagColorsCubit>()
                    .addTagColor(TagColor(tagName, selectedColor));
                Navigator.of(context).pop();
              },
              child: Text("save"))
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Tags"),
        ),
        body: BlocBuilder<TagColorsCubit, List<TagColor>>(
            builder: (context, state) => ListView(
                children: state
                    .map((tagColor) => ListTile(
                          key: Key(tagColor.tag),
                          title: Text(tagColor.tag),
                          trailing: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: tagColor.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          onTap: () {
                            tagName = tagColor.tag;
                            showDialog(
                                context: context,
                                builder: (context) => tagColorEdit(tagColor));
                          },
                        ))
                    .toList())),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              tagName = '';
              showDialog(
                  context: context, builder: (context) => tagColorEdit(null));
            },
            label: Text("Add")),
      );
}

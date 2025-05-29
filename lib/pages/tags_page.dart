import 'package:calendorg/tag_color.dart';
import 'package:calendorg/models/tag_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  String tagName = "";
  Color selectedColor = Color(0x00000000);
  TagColor? selectedTag;

  @override
  void initState() {
    super.initState();
  }

  void saveTag() async {
    Provider.of<TagColorsModel>(context, listen: false)
        .addTagColor(TagColor(tagName, selectedColor));
  }

  void deleteTag(String tagName) {
    Provider.of<TagColorsModel>(context, listen: false).removeTagColor(tagName);
  }

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
                  deleteTag(tag.tag);
                  Navigator.of(context).pop();
                },
                child: Text("delete")),
          TextButton(
              onPressed: () {
                saveTag();
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
        body: Consumer<TagColorsModel>(
            builder: (context, tags, child) => ListView(
                children: tags.tagColorsFromPrefs
                    .map((tagColor) => ListTile(
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

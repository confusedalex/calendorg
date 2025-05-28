import 'dart:convert';

import 'package:calendorg/TagColor.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  List<TagColor> tagColors = [];
  String tagName = "";
  Color selectedColor = Color(0x00000000);
  TagColor? selectedTag;

  @override
  void initState() {
    super.initState();
    loadTags();
  }

  void loadTags() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      tagColors = (jsonDecode(prefs.getString("tagColors") ?? "[]") as List)
          .map((tagColor) => TagColor.fromJson(tagColor))
          .toList();
    });
  }

  void saveTag() async {
    setState(() {
      tagColors.removeWhere((tag) => tag.tag == tagName);
      tagColors.add(TagColor(tagName, selectedColor));
    });
    saveTagsToPrefs();
  }

  void deleteTag(String tagName) {
    setState(() {
      tagColors.removeWhere((tag) => tag.tag == tagName);
    });
    saveTagsToPrefs();
  }

  void saveTagsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("tagColors", jsonEncode(tagColors));
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
        body: ListView(
            children: tagColors
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
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => tagColorEdit(tagColor)),
                    ))
                .toList()),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showDialog(
                context: context, builder: (context) => tagColorEdit(null)),
            label: Text("Add")),
      );
}

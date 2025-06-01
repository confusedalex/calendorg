import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/tag_color.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewTagColorDialog extends StatefulWidget {
  const NewTagColorDialog({super.key});

  @override
  State<NewTagColorDialog> createState() => _NewTagColorDialogState();
}

class _NewTagColorDialogState extends State<NewTagColorDialog> {
  String name = "";
  Color selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text("Add new Tag"),
        content: Column(
          children: [
            TextField(
                onChanged: (value) => setState(() {
                      name = value;
                    })),
            Divider(),
            ColorPicker(
              color: selectedColor,
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
          TextButton(
              onPressed: () {
                context
                    .read<TagColorsCubit>()
                    .addTagColor(TagColor(name, selectedColor));
                Navigator.of(context).pop();
              },
              child: Text("save"))
        ],
      );
}

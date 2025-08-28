import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/features/settings/tags/cubit/new_tag_color_cubit.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewTagColorDialog extends StatelessWidget {
  const NewTagColorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<NewTagColorCubit>();

    return AlertDialog(
      title: Text("Add new Tag"),
      content: SizedBox(
        height: 400,
        width: 400,
        child: ListView(
          children: [
            TextField(onChanged: (value) => state.updateText(value)),
            Divider(),
            ColorPicker(
              color: state.state.color,
              onColorChanged: (Color color) => state.updateColor(color),
              pickersEnabled: <ColorPickerType, bool>{
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.wheel: true
              },
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            key: Key("newtag_savebutton"),
            onPressed: () {
              context
                  .read<TagColorsCubit>()
                  .addTagColor(TagColor(state.state.text, state.state.color));
              Navigator.of(context).pop();
            },
            child: Text("save"))
      ],
    );
  }
}

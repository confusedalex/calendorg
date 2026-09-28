import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tag_colors/tag_color.dart';
import '../../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../../util.dart';

class EditTagColorDialog extends StatefulWidget {
  final TagColor tagColor;
  const EditTagColorDialog(this.tagColor, {super.key});

  @override
  State<EditTagColorDialog> createState() => _EditTagColorDialogState();
}

class _EditTagColorDialogState extends State<EditTagColorDialog> {
  var selectedColor = const Color(0x00000000);

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.edit_tag(widget.tagColor.tag)),
    content: SingleChildScrollView(
      child: ColorPicker(
        color: widget.tagColor.color,
        onColorChanged: (Color color) => setState(() {
          selectedColor = color;
        }),
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.primary: false,
          ColorPickerType.accent: false,
          ColorPickerType.wheel: true,
        },
      ),
    ),
    actions: [
      TextButton(
        key: const Key('edittag_deletebutton'),
        onPressed: () async {
          await context.read<TagColorsCubit>().removeTagColor(
            widget.tagColor.tag,
          );
          Navigator.of(context).pop();
        },
        child: Text(context.l10n.delete),
      ),
      TextButton(
        key: const Key('edittag_savebutton'),
        onPressed: () async {
          await context.read<TagColorsCubit>().addTagColor(
            TagColor(widget.tagColor.tag, selectedColor),
          );
          Navigator.of(context).pop();
        },
        child: Text(context.l10n.save),
      ),
    ],
  );
}

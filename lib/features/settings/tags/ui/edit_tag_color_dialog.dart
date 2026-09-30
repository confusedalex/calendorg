import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/tag_colors/tag_color.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class EditTagColorDialog extends StatefulWidget {
  final TagColor tagColor;
  const EditTagColorDialog(this.tagColor, {super.key});

  @override
  State<EditTagColorDialog> createState() => _EditTagColorDialogState();
}

class _EditTagColorDialogState extends State<EditTagColorDialog> {
  late var selectedColor = widget.tagColor.color;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return DialogShell(
      title: context.l10n.edit_tag(widget.tagColor.tag),
      titleIcon: Icons.palette_outlined,
      content: SingleChildScrollView(
        child: ColorPicker(
          color: selectedColor,
          padding: EdgeInsets.zero,
          onColorChanged: (color) => setState(() => selectedColor = color),
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
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await cubit.removeTagColor(widget.tagColor.tag);
            navigator.pop();
          },
          child: Text(context.l10n.delete),
        ),
        FilledButton(
          key: const Key('edittag_savebutton'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await cubit.addTagColor(
              TagColor(widget.tagColor.tag, selectedColor),
            );
            navigator.pop();
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

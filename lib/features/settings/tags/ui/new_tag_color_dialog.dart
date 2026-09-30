import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tag_colors/tag_color.dart';
import '../../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class NewTagColorDialog extends StatefulWidget {
  const NewTagColorDialog({super.key});

  @override
  State<NewTagColorDialog> createState() => _NewTagColorDialogState();
}

class _NewTagColorDialogState extends State<NewTagColorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  Color _color = Colors.blue;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagColorsCubit = context.read<TagColorsCubit>();

    return DialogShell(
      title: context.l10n.add_new_tag,
      titleIcon: Icons.sell_outlined,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.tag_name,
                  filled: true,
                ),
                validator: (value) => validate(
                  context.l10n,
                  value,
                  context.l10n.tag_name,
                  notIn: tagColorsCubit.state.map((e) => e.tag),
                ),
              ),
              ColorPicker(
                color: _color,
                padding: EdgeInsets.zero,
                onColorChanged: (color) => setState(() => _color = color),
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.wheel: true,
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          key: const Key('newtag_savebutton'),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final navigator = Navigator.of(context);
            await tagColorsCubit.addTagColor(TagColor(_name.text, _color));
            navigator.pop();
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tag_colors/tag_color.dart';
import '../../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../../util.dart';
import '../model/new_tag_color_cubit.dart';

class NewTagColorDialog extends StatelessWidget {
  const NewTagColorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<NewTagColorCubit>();
    final tagColorsCubit = context.read<TagColorsCubit>();
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: AlertDialog(
        title: Text(context.l10n.add_new_tag),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                onChanged: state.updateText,
                validator: (value) => validate(
                  context.l10n,
                  value,
                  context.l10n.tag_color,
                  notIn: tagColorsCubit.state.map((e) => e.tag),
                ),
              ),
              ColorPicker(
                color: state.state.color,
                onColorChanged: state.updateColor,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.wheel: true,
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('newtag_savebutton'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await tagColorsCubit.addTagColor(
                  TagColor(state.state.text, state.state.color),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }
}

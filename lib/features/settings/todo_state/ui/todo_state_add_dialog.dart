import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/settings_cubit.dart';
import '../../../../entities/todo_states/todo_states.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class TodoStateAddDialog extends StatefulWidget {
  final TodoStatus status;
  const TodoStateAddDialog({super.key, required this.status});

  @override
  State<TodoStateAddDialog> createState() => _TodoStateAddDialogState();
}

class _TodoStateAddDialogState extends State<TodoStateAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<SettingsCubit>().addTodoState(widget.status, _name.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final states = context.read<SettingsCubit>().state.todoStates;

    return DialogShell(
      title: context.l10n.todo_state,
      titleIcon: Icons.add_task,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: context.l10n.todo_state_name,
            filled: true,
          ),
          onFieldSubmitted: (_) => _save(),
          validator: (value) => validate(
            context.l10n,
            value,
            context.l10n.todo_state,
            notIn: [
              ...states.todoStates.todo,
              ...states.todoStates.done,
              ...states.ignored,
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(context.l10n.save)),
      ],
    );
  }
}

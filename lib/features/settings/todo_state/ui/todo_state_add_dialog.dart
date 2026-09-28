import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/todo_states_cubit.dart';
import '../../../../entities/todo_states/todo_states.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';
import '../model/todo_state_add_dialog_cubit.dart';

class TodoStateAddDialog extends StatelessWidget {
  final TodoStatus status;
  const TodoStateAddDialog({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final states = context.read<TodoStatesCubit>().state;
    final formKey = GlobalKey<FormState>();

    Future<void> save(String state) async {
      if (!formKey.currentState!.validate()) return;
      await context.read<TodoStatesCubit>().addTodo(status, state);
      if (context.mounted) Navigator.pop(context);
    }

    return BlocBuilder<TodoStateAddDialogCubit, String>(
      builder: (context, state) {
        return DialogShell(
          title: context.l10n.todo_state,
          titleIcon: Icons.add_task,
          content: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: context.l10n.todo_state_name,
                filled: true,
              ),
              onChanged: context.read<TodoStateAddDialogCubit>().updateText,
              onFieldSubmitted: (_) => save(state),
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
            FilledButton(
              onPressed: () => save(state),
              child: Text(context.l10n.save),
            ),
          ],
        );
      },
    );
  }
}

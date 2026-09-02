import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/todo_states_cubit.dart';
import '../../../../entities/todo_states/todo_states.dart';
import '../../../../util.dart';
import '../model/todo_state_add_dialog_cubit.dart';

class TodoStateAddDialog extends StatelessWidget {
  final TodoStatus status;
  const TodoStateAddDialog({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final states = context.read<TodoStatesCubit>().state;
    final formKey = GlobalKey<FormState>();

    return BlocBuilder<TodoStateAddDialogCubit, String>(
      builder: (context, state) {
        return Form(
          key: formKey,
          child: AlertDialog(
            title: const Text('TODO State Name'),
            content: TextFormField(
              onChanged: context.read<TodoStateAddDialogCubit>().updateText,
              validator: (value) => validate(
                value,
                'TODO State',
                notIn: [
                  ...states.todoStates.todo,
                  ...states.todoStates.done,
                  ...states.ignored,
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await context.read<TodoStatesCubit>().addTodo(
                      status,
                      state,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

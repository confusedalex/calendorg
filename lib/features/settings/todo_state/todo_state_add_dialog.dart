import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/todo_state/todo_state_add_dialog_cubit.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoStateAddDialog extends StatelessWidget {
  final String status;
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
              title: Text("TODO State Name"),
              content: TextFormField(
                  onChanged: context.read<TodoStateAddDialogCubit>().updateText,
                  validator: (value) => validate(value, "TODO State",
                      notIn: [...states.todo, ...states.done])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("cancel")),
                TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<TodoStatesCubit>().addTodo("todo", state);
                        Navigator.pop(context);
                      }
                    },
                    child: Text("save"))
              ],
            ));
      },
    );
  }
}

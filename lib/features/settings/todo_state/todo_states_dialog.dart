import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/todo_state/todo_state_add_dialog.dart';
import 'package:calendorg/features/settings/todo_state/todo_state_add_dialog_cubit.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoStatesDialog extends StatelessWidget {
  const TodoStatesDialog({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TodoStatesCubit, OrgTodoStatesWithIgnored>(
        listener: (_, state) => context.read<OrgFilesBloc>().add(
          OrgFilesChangeTodoStatesEvent(state),
        ),
        builder: (context, state) {
          return AlertDialog(
            title: Text("TODO states"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...["todo", "done", "ignored"].mapIndexed(
                    (index, status) => Column(
                      children: [
                        Text(status.toUpperCase(), textAlign: TextAlign.start),
                        Divider(),
                        Wrap(
                          children: [
                            ...(index == 2
                                    ? state.ignored
                                    : index == 1
                                    ? state.todoStates.done
                                    : state.todoStates.todo)
                                .map(
                                  (todo) => Chip(
                                    label: Text(todo),
                                    deleteIcon: Icon(Icons.close),
                                    onDeleted: () => context
                                        .read<TodoStatesCubit>()
                                        .removeTodo(status, todo),
                                  ),
                                ),
                            TextButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context.read<TodoStatesCubit>(),
                                    ),
                                    BlocProvider(
                                      create: (context) =>
                                          TodoStateAddDialogCubit(),
                                    ),
                                  ],
                                  child: TodoStateAddDialog(status: status),
                                ),
                              ),
                              child: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

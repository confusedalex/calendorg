import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/files/cubit/org_files_cubit.dart';
import '../../../../core/todo_states_cubit.dart';
import '../../../../entities/todo_states/todo_states.dart';
import '../../../../entities/todo_states/todo_states_ignored.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../model/todo_state_add_dialog_cubit.dart';
import 'todo_state_add_dialog.dart';

class TodoStatesDialog extends StatelessWidget {
  const TodoStatesDialog({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TodoStatesCubit, OrgTodoStatesWithIgnored>(
        listener: (_, state) =>
            context.read<OrgFilesCubit>().changeTodoStates(state),
        builder: (context, state) {
          return DialogShell(
            title: 'TODO states',
            titleIcon: Icons.check,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...[
                    TodoStatus.todo,
                    TodoStatus.done,
                    TodoStatus.ignored,
                  ].mapIndexed(
                    (index, status) => Column(
                      children: [
                        Text(status.name, textAlign: TextAlign.start),
                        const Divider(),
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
                                    deleteIcon: const Icon(Icons.close),
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
                              child: const Icon(Icons.add),
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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../entities/todo_states/todo_states_ignored.dart';
import 'files/cubit/org_files_cubit.dart';
import 'todo_states_cubit.dart';

class TodoStatesListener
    extends BlocListener<TodoStatesCubit, OrgTodoStatesWithIgnored> {
  TodoStatesListener({super.key, super.child})
    : super(
        listener: (context, states) =>
            unawaited(context.read<OrgFilesCubit>().changeTodoStates(states)),
      );
}

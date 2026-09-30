import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/todo_states_cubit.dart';
import '../../../../entities/todo_states/todo_states.dart';
import '../../../../entities/todo_states/todo_states_ignored.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';
import 'todo_state_add_dialog.dart';

class TodoStatesDialog extends StatelessWidget {
  const TodoStatesDialog({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TodoStatesCubit, OrgTodoStatesWithIgnored>(
        builder: (context, state) {
          final colors = Theme.of(context).colorScheme;
          return DialogShell(
            title: context.l10n.todo_states,
            titleIcon: Icons.checklist,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusSection(
                    status: TodoStatus.todo,
                    label: context.l10n.todo_status_todo,
                    color: colors.error,
                    states: state.todo,
                  ),
                  _StatusSection(
                    status: TodoStatus.done,
                    label: context.l10n.todo_status_done,
                    color: Colors.green.shade600,
                    states: state.done,
                  ),
                  _StatusSection(
                    status: TodoStatus.ignored,
                    label: context.l10n.todo_status_ignored,
                    color: colors.onSurfaceVariant,
                    states: state.ignored,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
              ),
            ],
          );
        },
      );
}

class _StatusSection extends StatelessWidget {
  final TodoStatus status;
  final String label;
  final Color color;
  final List<String> states;

  const _StatusSection({
    required this.status,
    required this.label,
    required this.color,
    required this.states,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            DialogSectionLabel(label.toUpperCase()),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...states.map(
              (todo) => Chip(
                label: Text(todo),
                labelStyle: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(color: color.withValues(alpha: 0.4)),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () =>
                    context.read<TodoStatesCubit>().removeTodo(status, todo),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(context.l10n.add),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => TodoStateAddDialog(status: status),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

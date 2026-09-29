import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../core/todo_states_cubit.dart';
import '../../../entities/occurrence/occurrence.dart';
import '../../../util.dart';
import '../../event_view/ui/event_view.dart';

class EventCard extends StatelessWidget {
  final Occurrence occurrence;
  const EventCard(this.occurrence, {super.key});

  @override
  Widget build(BuildContext context) {
    final filesStatus = context.select(
      (OrgFilesCubit cubit) => cubit.state.status,
    );
    final keyword = occurrence.entry.todoKeyword;
    final eventIsDone = context.select(
      (TodoStatesCubit cubit) => cubit.state.done.contains(keyword),
    );
    final tagColor = context.select(
      (TagColorsCubit cubit) => cubit.getTagColor(occurrence.entry),
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final scheduled = occurrence.entry.scheduled?.value as OrgTimestamp?;
    final deadline = occurrence.entry.deadline?.value as OrgTimestamp?;

    return Card(
      key: const Key('EventCardAccent'),
      elevation: 0,
      color: tagColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(
          color: colors.surfaceContainerLow,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: textTheme.titleMedium?.copyWith(
                              color: eventIsDone
                                  ? colors.onSurfaceVariant
                                  : null,
                            ),
                            children: [
                              if (keyword != null)
                                TextSpan(
                                  text: '$keyword ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: eventIsDone
                                        ? Colors.green.shade600
                                        : colors.error,
                                  ),
                                ),
                              TextSpan(
                                text: occurrence.entry.title,
                                style: eventIsDone
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        _InfoLine(
                          icon: Icons.schedule,
                          text: occurrence.timestamp.toMarkup(),
                          color: colors.onSurfaceVariant,
                        ),
                        if (scheduled != null)
                          _InfoLine(
                            icon: Icons.event_available,
                            text: 'SCHEDULED: ${scheduled.toMarkup()}',
                            color: colors.tertiary,
                          ),
                        if (deadline != null)
                          _InfoLine(
                            icon: Icons.flag_outlined,
                            text: 'DEADLINE: ${deadline.toMarkup()}',
                            color: colors.error,
                          ),
                        if (occurrence.entry.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: occurrence.entry.tags
                                  .map(_TagPill.new)
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              switch (filesStatus) {
                case OrgFilesStatus.loading:
                  sendError(context.l10n.error_edit_before_loading);
                case OrgFilesStatus.success:
                  await showDialog(
                    context: context,
                    builder: (_) => EventView(
                      entry: occurrence.entry,
                      timestamp: occurrence.timestamp,
                    ),
                  );
                case OrgFilesStatus.failure:
                  sendError(context.l10n.error_unknown);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    spacing: 6,
    children: [
      Icon(icon, size: 14, color: color),
      Flexible(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ),
    ],
  );
}

class _TagPill extends StatelessWidget {
  final String tag;
  const _TagPill(this.tag);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surfaceContainerHighest,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          tag,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

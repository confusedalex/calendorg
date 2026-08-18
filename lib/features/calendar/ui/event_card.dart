import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../core/tag_colors/tag_colors_cubit.dart';
import '../../../core/todo_states_cubit.dart';
import '../../../entities/occurrence/occurrence.dart';
import '../../event_view/model/event_view_bloc.dart';
import '../../event_view/ui/event_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class EventCard extends StatelessWidget {
  final Occurrence occurrence;
  const EventCard(this.occurrence, {super.key});

  @override
  Widget build(BuildContext context) {
    final keyword = occurrence.entry.section.headline.keyword;
    final todoStates = context.read<TodoStatesCubit>().state;
    final eventIsDone = todoStates.done.contains(keyword?.value);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 12,
                  color: context.read<TagColorsCubit>().getTagColor(
                    occurrence.entry,
                  ),
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: keyword == null ? '' : '${keyword.value} ',
                        style: keyword == null
                            ? const TextStyle()
                            : TextStyle(
                                color: eventIsDone ? Colors.green : Colors.red,
                              ),
                      ),
                      TextSpan(text: occurrence.entry.title),
                    ],
                  ),
                ),
                Text(
                  occurrence.timestamp.toMarkup(),
                  textAlign: TextAlign.left,
                  textScaler: const TextScaler.linear(0.9),
                ),
                if (occurrence.entry.scheduled != null)
                  Text(
                    'SCHEDULED: ${(occurrence.entry.scheduled?.value as OrgTimestamp).toMarkup()}',
                    textAlign: TextAlign.left,
                    textScaler: const TextScaler.linear(0.85),
                    style: const TextStyle(color: Colors.amber),
                  ),
                if (occurrence.entry.deadline != null)
                  Text(
                    'DEADLINE: ${(occurrence.entry.deadline?.value as OrgTimestamp).toMarkup()}',
                    textAlign: TextAlign.left,
                    textScaler: const TextScaler.linear(0.85),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                if (occurrence.entry.tags.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        ":${occurrence.entry.tags.join(":")}:",
                        textAlign: TextAlign.right,
                        textScaler: const TextScaler.linear(0.9),
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onTap: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<OrgFilesCubit>(),
              child: BlocProvider(
                create: (context) => EventViewBloc(
                  context.read<OrgFilesCubit>(),
                  occurrence.entry,
                  occurrence.timestamp,
                ),
                child: const EventView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/features/event_view/event_view.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final OrgTimestamp timestamp;
  const EventCard(this.event, this.timestamp, {super.key});

  @override
  Widget build(BuildContext context) {
    final keyword = event.section.headline.keyword;
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
                  color: context.read<TagColorsCubit>().getTagColor(event),
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
                        text: keyword == null ? "" : "${keyword.value} ",
                        style: keyword == null
                            ? const TextStyle()
                            : TextStyle(
                                color: eventIsDone ? Colors.green : Colors.red,
                              ),
                      ),
                      TextSpan(text: event.title),
                    ],
                  ),
                ),
                Text(
                  timestamp.toMarkup(),
                  textAlign: TextAlign.left,
                  textScaler: const TextScaler.linear(0.9),
                ),
                if (event.scheduled != null)
                  Text(
                    'SCHEDULED: ${(event.scheduled?.value as OrgTimestamp).toMarkup()}',
                    textAlign: TextAlign.left,
                    textScaler: const TextScaler.linear(0.85),
                    style: const TextStyle(color: Colors.amber),
                  ),
                if (event.deadline != null)
                  Text(
                    'DEADLINE: ${(event.deadline?.value as OrgTimestamp).toMarkup()}',
                    textAlign: TextAlign.left,
                    textScaler: const TextScaler.linear(0.85),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                if (event.tags.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        ":${event.tags.join(":")}:",
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
                  event,
                  timestamp,
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

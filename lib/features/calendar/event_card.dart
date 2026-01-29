import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
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
    final brightness = MediaQuery.of(context).platformBrightness;

    return Card(
      child: ListTile(
        minTileHeight: 83,
        leading: BlocBuilder<TagColorsCubit, List<TagColor>>(
          builder: (context, state) => Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: context.read<TagColorsCubit>().getTagColor(event),
              shape: BoxShape.circle,
            ),
          ),
        ),
        title: BlocBuilder<TodoStatesCubit, OrgTodoStates>(
          builder: (context, state) => RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: keyword == null ? "" : "${keyword.value} ",
                  style: keyword == null
                      ? TextStyle()
                      : TextStyle(
                          color: eventIsDone ? Colors.green : Colors.red,
                        ),
                ),
                TextSpan(
                  text: event.title,
                  style: TextStyle(
                    color: _colorByEvent(event, eventIsDone, brightness),
                  ),
                ),
              ],
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              timestamp.toMarkup(),
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(0.9),
            ),
            Text(
              event.tags.isNotEmpty ? ":${event.tags.join(":")}:" : '',
              textAlign: TextAlign.right,
              textScaler: TextScaler.linear(0.9),
            ),
          ],
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<OrgFilesBloc>(),
            child: BlocProvider(
              create: (context) =>
                  EventViewBloc(context.read<OrgFilesBloc>(), event, timestamp),
              child: EventView(),
            ),
          ),
        ),
      ),
    );
  }

  Color? _colorByEvent(Event event, bool eventIsDone, Brightness brightness) {
    if (eventIsDone) return Colors.green;
    if (event.deadline != null &&
        (event.deadline?.value as OrgTimestamp).startDateTime ==
            timestamp.startDateTime) {
      return Colors.red;
    }
    if (event.scheduled != null &&
        (event.scheduled?.value as OrgTimestamp).startDateTime ==
            timestamp.startDateTime) {
      return Colors.amber;
    }
    return switch (brightness) {
      Brightness.dark => Colors.white,
      Brightness.light => Colors.black,
    };
  }
}

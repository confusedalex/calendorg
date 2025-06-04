import 'package:calendorg/core/tag_colors/tag_model.dart';
import 'package:calendorg/event.dart';
import 'package:calendorg/models/document_model.dart';
import 'package:calendorg/pages/calendar/event_view.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final OrgTimestamp timestamp;
  const EventCard(this.event, this.timestamp, {super.key});

  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
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
          title: Text(event.title),
          subtitle: Row(
            children: [
              Expanded(
                  child: Text(
                timestamp.toMarkup(),
                textAlign: TextAlign.left,
              )),
              if (event.tags.isNotEmpty)
                Expanded(
                    child: Text(
                  ":${event.tags.join(":")}:",
                  textAlign: TextAlign.right,
                )),
            ],
          ),
          onTap: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                  value: context.read<OrgDocumentCubit>(),
                  child: EventView(event, timestamp)))));
}

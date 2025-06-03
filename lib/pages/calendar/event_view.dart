import 'package:calendorg/event.dart';
import 'package:calendorg/models/document_model.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class EventView extends StatefulWidget {
  final Event event;
  final OrgTimestamp timestamp;
  const EventView(this.event, this.timestamp, {super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  String newTitle = "";

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Row(
          children: [Text("Edit Event"), Spacer(), CloseButton()],
        ),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              initialValue: widget.event.title,
              onChanged: (value) => newTitle = value,
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                var oldNode = widget.event.section;
                context.read<OrgDocumentCubit>().replaceNode(
                    oldNode, changeSectionTitle(oldNode, newTitle));
              },
              child: Text("save"))
        ],
      );
}

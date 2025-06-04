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
  final _formKey = GlobalKey<FormState>();
  String newTitle = "";
  bool isSavable() => _formKey.currentState?.validate() ?? true;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrgDocumentCubit, OrgDocument>(builder: (context, state) {
        return AlertDialog(
            title: Row(
              children: [Text("Edit Event"), Spacer(), CloseButton()],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: Key("TitleField"),
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    initialValue: widget.event.title,
                    autovalidateMode: AutovalidateMode.always,
                    onChanged: (value) => (newTitle = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "The Event name can't be empty";
                      }
                      return null;
                    },
                  ),
                  switch (widget.timestamp) {
                    OrgSimpleTimestamp() => TextButton(
                        onPressed: () => showDatePicker(
                            context: context,
                            firstDate: DateTime(0),
                            lastDate: DateTime(3000),
                            currentDate:
                                (widget.timestamp as OrgSimpleTimestamp)
                                    .dateTime),
                        child: Text(widget.timestamp.toMarkup())),
                    OrgDateRangeTimestamp() => TextButton(
                        onPressed: () => showDateRangePicker(
                            context: context,
                            firstDate: DateTime(0),
                            lastDate: DateTime(3000)),
                        child: Text(widget.timestamp.toMarkup())),
                    OrgTimeRangeTimestamp() => throw UnimplementedError(),
                  },
                  TextButton(
                      key: Key("SaveButton"),
                      onPressed: isSavable()
                          ? () {
                              final oldNode = widget.event.section;
                              final newNode =
                                  changeSectionTitle(oldNode, newTitle);
                              context
                                  .read<OrgDocumentCubit>()
                                  .replaceNode(oldNode, newNode);
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text("save"))
                ],
              ),
            ));
      });
}

import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  // final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final title = context.select((EventViewBloc bloc) => bloc.state.title);
    final timestamp =
        context.select((EventViewBloc bloc) => bloc.state.timestamp);
    final allDay = context.select((EventViewBloc bloc) => bloc.state.allDay);
    final start = context.select((EventViewBloc bloc) => bloc.state.start);
    final end = context.select((EventViewBloc bloc) => bloc.state.end);

    return AlertDialog(
        title: Row(
          children: [Text("Edit Event"), Spacer(), CloseButton()],
        ),
        content: SingleChildScrollView(
          child: Column(children: [
            TextFormField(
              key: Key("TitleField"),
              decoration: InputDecoration(border: OutlineInputBorder()),
              initialValue: title,
              autovalidateMode: AutovalidateMode.always,
              onChanged: (value) => context
                  .read<EventViewBloc>()
                  .add(EventViewTitleChangeEvent(value)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "The Event name can't be empty";
                }
                return null;
              },
            ),
            BlocBuilder<EventViewBloc, EventViewState>(
              builder: (context, state) {
                return CheckboxListTile(
                    value: state.allDay,
                    title: Text("ALl day?"),
                    onChanged: (value) => context
                        .read<EventViewBloc>()
                        .add(EventViewTitleChangeAllDay(value!)));
              },
            ),
            BlocBuilder<EventViewBloc, EventViewState>(
              builder: (context, state) {
                if (state.allDay) {
                  return TextButton(
                      onPressed: () => showDatePicker(
                          context: context,
                          firstDate: DateTime(0),
                          lastDate: DateTime(3000)),
                      child: Text(timestamp.toMarkup()));
                } else {
                  return Row(
                    children: [
                      Expanded(
                          child: TextButton(
                              onPressed: () => {}, child: Text("start"))),
                      Expanded(
                          child: TextButton(
                              onPressed: () => {}, child: Text("end")))
                    ],
                  );
                }
              },
            )
            // TextButton(
            // key: Key("SaveButton"),
            // onPressed: isSavable()
            //     ? () {
            //         final oldNode = widget.event.section;
            //         final newNode =
            //             changeSectionTitle(oldNode, newTitle);
            //         context
            //             .read<OrgDocumentCubit>()
            //             .replaceNode(oldNode, newNode);
            //         Navigator.pop(context);
            //       }
            //     : null,
            // child: Text("save"))
            // ],
          ]),
        ));
  }
}

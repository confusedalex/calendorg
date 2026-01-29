import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/date_picker.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.select(
      (EventViewBloc bloc) => bloc.state.newEvent.title,
    );
    final timestamp = context.select(
      (EventViewBloc bloc) => bloc.state.newTimestamp,
    );

    void handleDatePickerSet(OrgTimestamp timestamp) =>
        context.read<EventViewBloc>().add(EventViewChangeTimestamp(timestamp));

    return AlertDialog(
      title: Row(children: [Text("Edit Event")]),
      content: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            TextFormField(
              key: Key("TitleField"),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                helperText: "Event Title",
              ),
              initialValue: title,
              autovalidateMode: AutovalidateMode.always,
              onChanged: (value) => context.read<EventViewBloc>().add(
                EventViewTitleChangeEvent(value),
              ),
              validator: (value) => validate(value, "Event Name"),
            ),
            BlocBuilder<EventViewBloc, EventViewState>(
              builder: (context, state) {
                return TextButton(
                  key: Key("datePickerButton"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) => DatePickerBloc(
                                DatePickerState.initial(timestamp),
                              ),
                            ),
                            BlocProvider.value(
                              value: context.read<EventViewBloc>(),
                            ),
                          ],
                          child: DatePicker(handleDatePickerSet),
                        );
                      },
                    );
                  },
                  child: Text(timestamp.toMarkup()),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              key: Key("CancelButton"),
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              key: Key("SaveButton"),
              onPressed: () {
                context.read<EventViewBloc>().add(EventViewSaveEvent());
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        ),
      ],
    );
  }
}

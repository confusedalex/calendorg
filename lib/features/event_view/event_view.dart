import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/date_picker.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    final fileInfo =
        context.select((EventViewBloc bloc) => bloc.state.event.fileInfo);
    final title = context.select((EventViewBloc bloc) => bloc.state.title);
    final timestamp =
        context.select((EventViewBloc bloc) => bloc.state.timestamp);
    final oldSection = context.select((EventViewBloc bloc) => bloc.oldSection);
    final newSection =
        context.select((EventViewBloc bloc) => bloc.state.event.section);

    return AlertDialog(
        title: Row(
          children: [Text("Edit Event"), Spacer(), CloseButton()],
        ),
        content: SingleChildScrollView(
          child: Column(spacing: 20, children: [
            TextFormField(
                key: Key("TitleField"),
                decoration: InputDecoration(
                    border: OutlineInputBorder(), helperText: "Event Title"),
                initialValue: title,
                autovalidateMode: AutovalidateMode.always,
                onChanged: (value) => context
                    .read<EventViewBloc>()
                    .add(EventViewTitleChangeEvent(value)),
                validator: (value) => validate(value, "Event Name")),
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
                                create: (_) => DatePickerBloc(timestamp)),
                            BlocProvider.value(
                                value: context.read<EventViewBloc>())
                          ],
                          child: DatePicker(),
                        );
                      });
                },
                child: Text(timestamp.toMarkup()),
              );
            }),
            TextButton(
                key: Key("SaveButton"),
                onPressed: () {
                  context.read<OrgFilesBloc>().add(
                      OrgFilesReplaceNode(fileInfo, oldSection, newSection));
                  Navigator.pop(context);
                },
                child: Text("save"))
          ]),
        ));
  }
}

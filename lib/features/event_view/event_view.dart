import 'package:calendorg/core/document/document_cubit.dart';
import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/date_picker.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext widgetContext) {
    final title =
        widgetContext.select((EventViewBloc bloc) => bloc.state.title);
    final timestamp =
        widgetContext.select((EventViewBloc bloc) => bloc.state.timestamp);
    final isSavable =
        widgetContext.select((EventViewBloc bloc) => bloc.isSavable);
    final section =
        widgetContext.select((EventViewBloc bloc) => bloc.state.event.section);
    final newSection =
        widgetContext.select((EventViewBloc bloc) => bloc.generateNewSection());

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
              onChanged: (value) => widgetContext
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
              return TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                                create: (context) => DatePickerBloc(timestamp)),
                            BlocProvider.value(
                                value: BlocProvider.of<OrgDocumentCubit>(
                                    widgetContext)),
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
                onPressed: isSavable
                    ? () {
                        widgetContext
                            .read<OrgDocumentCubit>()
                            .replaceNode(section, newSection);
                        Navigator.pop(widgetContext);
                      }
                    : null,
                child: Text("save"))
          ]),
        ));
  }
}

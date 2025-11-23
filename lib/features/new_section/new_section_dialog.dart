import 'dart:io';

import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/date_picker.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/features/new_section/cubit/new_section_cubit.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class NewSectionDialog extends StatelessWidget {
  final DateTime dateTime;
  const NewSectionDialog({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final title = context.select((NewSectionCubit bloc) => bloc.state.title);
    final inboxFile = context.select(
      (OrgFilesBloc bloc) => bloc.state.inboxFile,
    );
    final timestamp = context.select(
      (NewSectionCubit bloc) => bloc.state.timestamp,
    );
    void handleSave(OrgTimestamp timestamp) =>
        context.read<EventViewBloc>().add(EventViewChangeTimestamp(timestamp));

    return AlertDialog(
      title: Row(children: [Text("Add Heading"), Spacer(), CloseButton()]),
      content: inboxFile == null
          ? Text("You need to set an inbox file")
          : SingleChildScrollView(
              child: Column(
                spacing: 20,
                children: [
                  TextFormField(
                    key: Key("titleField"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      helperText: "Title",
                    ),
                    initialValue: "",
                    autovalidateMode: AutovalidateMode.always,
                    onChanged: (value) =>
                        context.read<NewSectionCubit>().changeTitle(value),
                    validator: (value) => validate(value, "Title"),
                  ),
                  TextButton(
                    key: Key("datePickerButton"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (_) => DatePickerBloc(
                                  DatePickerState.parseDateTimeWithoutTime(
                                    dateTime,
                                  ),
                                ),
                              ),
                              BlocProvider.value(
                                value: context.read<EventViewBloc>(),
                              ),
                            ],
                            child: DatePicker(handleSave),
                          );
                        },
                      );
                    },
                    child: Text(timestamp?.toMarkup() ?? "No date selected"),
                  ),
                  TextButton(
                    key: Key("SaveButton"),
                    onPressed: () {
                      final oldFile = FilePickerWritable().readFile(
                        identifier: inboxFile.identifier,
                        reader: (FileInfo fileInfo, File file) =>
                            file.readAsString(),
                      );

                      FilePickerWritable().writeFile(
                        identifier: inboxFile.identifier,
                        writer: (file) async => file.writeAsString(
                          "${await oldFile} \n $title",
                          mode: FileMode.writeOnly,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text("save"),
                  ),
                ],
              ),
            ),
    );
  }
}

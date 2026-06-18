import 'dart:io';

import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/date_picker/date_picker.dart';
import 'package:calendorg/features/new_section/cubit/new_section_cubit.dart';
import 'package:calendorg/features/shared/editor_dialog_shell.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewSectionDialog extends StatelessWidget {
  final DateTime dateTime;

  const NewSectionDialog({super.key, required this.dateTime});

  void _openDatePicker(BuildContext context, DateTime initialDateTime) {
    showDialog(
      context: context,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => DatePickerBloc(
                DatePickerState.parseDateTimeWithoutTime(initialDateTime),
              ),
            ),
          ],
          child: DatePicker((timestamp) {
            context.read<NewSectionCubit>().changeTimestamp(timestamp);
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = context.select((NewSectionCubit bloc) => bloc.state.title);
    final inboxFile = context.select(
      (OrgFilesCubit bloc) => bloc.state.inboxFile,
    );
    final timestamp = context.select(
      (NewSectionCubit bloc) => bloc.state.timestamp,
    );
    final bloc = context.read<NewSectionCubit>();

    return DialogShell(
      title: "Add Event",
      titleIcon: Icons.title,
      content: inboxFile == null
          ? Text("You need to set an inbox file")
          : Form(
              key: bloc.formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    SizedBox(height: 0),
                    TextFormField(
                      key: Key("titleField"),
                      decoration: InputDecoration(
                        labelText: "Heading title",
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      initialValue: title ?? "",
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (value) => bloc.changeTitle(value),
                      validator: (value) => validate(value, "Title"),
                    ),
                    Text("When", style: Theme.of(context).textTheme.labelLarge),
                    Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        key: Key("datePickerButton"),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openDatePicker(
                          context,
                          timestamp?.startDateTime ?? dateTime,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.schedule),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timestamp == null
                                          ? "Choose date and time"
                                          : "Change date and time",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      timestamp?.toMarkup() ??
                                          "No date selected",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          key: Key("CancelButton"),
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        FilledButton.icon(
          key: Key("SaveButton"),
          onPressed: inboxFile != null && timestamp != null
              ? () async {
                  if (!(bloc.formKey.currentState?.validate() ?? false)) return;

                  try {
                    final oldFile = await FilePickerWritable().readFile(
                      identifier: inboxFile.identifier,
                      reader: (FileInfo fileInfo, File file) =>
                          file.readAsString(),
                    );

                    await FilePickerWritable().writeFile(
                      identifier: inboxFile.identifier,
                      writer: (file) async => file.writeAsString(
                        "$oldFile \n* $title\n${timestamp.toMarkup()}",
                        mode: FileMode.writeOnly,
                      ),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving section: $e')),
                    );
                  }
                }
              : null,
          icon: Icon(Icons.save),
          label: Text("Save"),
        ),
      ],
    );
  }
}

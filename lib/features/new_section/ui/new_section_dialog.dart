import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../../date_picker/model/date_picker_bloc.dart';
import '../../date_picker/ui/open_date_picker.dart';
import '../model/new_section_cubit.dart';

class NewSectionDialog extends StatelessWidget {
  final DateTime dateTime;

  const NewSectionDialog({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final title = context.select((NewSectionCubit bloc) => bloc.state.title);
    final inboxFile = context.select(
      (OrgFilesCubit bloc) => bloc.state.inboxFile,
    );
    final timestamp = context.select(
      (NewSectionCubit bloc) => bloc.state.timestamp,
    );
    final appendTextToInboxFile = context
        .read<OrgFilesCubit>()
        .appendToInboxFile;

    final bloc = context.read<NewSectionCubit>();

    return DialogShell(
      title: context.l10n.add_event,
      titleIcon: Icons.title,
      content: inboxFile == null
          ? Text(context.l10n.need_inbox_file)
          : Form(
              key: bloc.formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    const SizedBox(height: 0),
                    TextFormField(
                      key: const Key('titleField'),
                      decoration: InputDecoration(
                        labelText: context.l10n.heading_title,
                        prefixIcon: const Icon(Icons.title),
                        border: const OutlineInputBorder(),
                        filled: true,
                      ),
                      initialValue: title ?? '',
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: bloc.changeTitle,
                      validator: (value) =>
                          validate(context.l10n, value, context.l10n.title),
                    ),
                    Text(
                      context.l10n.when,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Material(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        key: const Key('datePickerButton'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => openDatePicker(
                          context,
                          DatePickerState.parseDateTimeWithoutTime(
                            timestamp?.startDateTime ?? dateTime,
                          ),
                          bloc.changeTimestamp,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timestamp == null
                                          ? context.l10n.choose_date_and_time
                                          : context.l10n.change_date_and_time,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timestamp?.toMarkup() ??
                                          context.l10n.no_date_selected,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
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
          key: const Key('CancelButton'),
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          key: const Key('SaveButton'),
          onPressed: inboxFile != null && timestamp != null
              ? () async {
                  if (!(bloc.formKey.currentState?.validate() ?? false)) return;

                  await appendTextToInboxFile(
                    '* $title \n ${timestamp.toMarkup()}',
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              : null,
          icon: const Icon(Icons.save),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../shared/ui/date_tile.dart';
import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../../date_picker/model/date_picker_bloc.dart';
import '../../date_picker/ui/open_date_picker.dart';
import '../model/new_section_cubit.dart';

class NewSectionDialog extends StatelessWidget {
  const NewSectionDialog({super.key});

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
    final isLoading = context.select(
      (OrgFilesCubit cubit) => cubit.state.status == OrgFilesStatus.loading,
    );

    final bloc = context.read<NewSectionCubit>();
    final colors = Theme.of(context).colorScheme;

    return DialogShell(
      title: context.l10n.add_event,
      titleIcon: Icons.add,
      content: inboxFile == null
          ? Row(
              spacing: 12,
              children: [
                Icon(Icons.inbox_outlined, color: colors.error),
                Expanded(child: Text(context.l10n.need_inbox_file)),
              ],
            )
          : Form(
              key: bloc.formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    TextFormField(
                      key: const Key('titleField'),
                      decoration: InputDecoration(
                        labelText: context.l10n.heading_title,
                        filled: true,
                      ),
                      initialValue: title ?? '',
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: bloc.changeTitle,
                      validator: (value) =>
                          validate(context.l10n, value, context.l10n.title),
                    ),
                    const SizedBox(height: 8),
                    DialogSectionLabel(context.l10n.when),
                    DateTile(
                      key: const Key('datePickerButton'),
                      title: dayLabel(context, timestamp.startDateTime),
                      subtitle: timestamp.toMarkup(),
                      onTap: () => openDatePicker(
                        context,
                        DatePickerState.parseDateTimeWithoutTime(
                          timestamp.startDateTime,
                        ),
                        bloc.changeTimestamp,
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
        FilledButton(
          key: const Key('SaveButton'),
          onPressed: inboxFile != null && !isLoading
              ? () async {
                  if (!(bloc.formKey.currentState?.validate() ?? false)) return;

                  await appendTextToInboxFile(
                    '* $title \n ${timestamp.toMarkup()}',
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              : null,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

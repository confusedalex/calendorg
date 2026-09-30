import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../shared/ui/date_tile.dart';
import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../../date_picker/model/date_picker_cubit.dart';
import '../../date_picker/ui/open_date_picker.dart';

class NewSectionDialog extends StatefulWidget {
  final OrgTimestamp timestamp;
  const NewSectionDialog({super.key, required this.timestamp});

  @override
  State<StatefulWidget> createState() => _NewSectionDialogState();
}

class _NewSectionDialogState extends State<NewSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController();
  late var _timestamp = widget.timestamp;

  @override
  Widget build(BuildContext context) {
    final inboxFile = context.select(
      (OrgFilesCubit bloc) => bloc.state.inboxFile,
    );
    final appendTextToInboxFile = context
        .read<OrgFilesCubit>()
        .appendToInboxFile;
    final isLoading = context.select(
      (OrgFilesCubit cubit) => cubit.state.status == OrgFilesStatus.loading,
    );
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
              key: _formKey,
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
                      controller: _title,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          validate(context.l10n, value, context.l10n.title),
                    ),
                    const SizedBox(height: 8),
                    DialogSectionLabel(context.l10n.when),
                    DateTile(
                      key: const Key('datePickerButton'),
                      title: _timestamp.toMarkup(),
                      onTap: () => openDatePicker(
                        context,
                        DatePickerState.initial(_timestamp),
                        (newTimestamp) =>
                            setState(() => _timestamp = newTimestamp),
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
                  if (!(_formKey.currentState?.validate() ?? false)) return;

                  await appendTextToInboxFile(
                    '* ${_title.text.trim()} \n ${_timestamp.toMarkup()}',
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

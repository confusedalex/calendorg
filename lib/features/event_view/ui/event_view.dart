import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../../../entities/org_entry/entry_edit.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../shared/ui/date_tile.dart';
import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../../date_picker/model/date_picker_bloc.dart';
import '../../date_picker/ui/open_date_picker.dart';

class EventView extends StatefulWidget {
  final OrgEntry entry;
  final OrgTimestamp timestamp;

  const EventView({super.key, required this.entry, required this.timestamp});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.entry.title);
  late var _timestamp = widget.timestamp;
  var _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final edit = EntryEdit(
      newTitle: _title.text == widget.entry.title ? null : _title.text,
      oldTimestamp: widget.timestamp,
      newTimestamp: _timestamp == widget.timestamp ? null : _timestamp,
    );
    if (!edit.isEmpty) {
      setState(() => _saving = true);
      await context.read<OrgFilesCubit>().applyEdit(widget.entry, edit);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DialogShell(
      title: context.l10n.edit_event,
      titleIcon: Icons.edit_calendar,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              TextFormField(
                key: const Key('TitleField'),
                controller: _title,
                decoration: InputDecoration(
                  labelText: context.l10n.event_title,
                  filled: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    validate(context.l10n, value, context.l10n.event_title),
              ),
              const SizedBox(height: 8),
              DialogSectionLabel(context.l10n.when),
              DateTile(
                key: const Key('datePickerButton'),
                title: dayLabel(context, _timestamp.startDateTime),
                subtitle: _timestamp.toMarkup(),
                onTap: () => openDatePicker(
                  context,
                  DatePickerState.initial(_timestamp),
                  (newTimestamp) => setState(() => _timestamp = newTimestamp),
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
          onPressed: _saving ? null : _save,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

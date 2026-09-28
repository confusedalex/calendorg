import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui/date_tile.dart';
import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../../date_picker/model/date_picker_bloc.dart';
import '../../date_picker/ui/open_date_picker.dart';
import '../model/event_view_bloc.dart';

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
    final bloc = context.read<EventViewBloc>();

    return DialogShell(
      title: context.l10n.edit_event,
      titleIcon: Icons.edit_calendar,
      content: Form(
        key: bloc.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              TextFormField(
                key: const Key('TitleField'),
                decoration: InputDecoration(
                  labelText: context.l10n.event_title,
                  filled: true,
                ),
                initialValue: title,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => context.read<EventViewBloc>().add(
                  EventViewTitleChangeEvent(value),
                ),
                validator: (value) =>
                    validate(context.l10n, value, context.l10n.event_title),
              ),
              const SizedBox(height: 8),
              DialogSectionLabel(context.l10n.when),
              DateTile(
                key: const Key('datePickerButton'),
                title: dayLabel(context, timestamp.startDateTime),
                subtitle: timestamp.toMarkup(),
                onTap: () => openDatePicker(
                  context,
                  DatePickerState.initial(timestamp),
                  (newTimestamp) => context.read<EventViewBloc>().add(
                    EventViewChangeTimestamp(newTimestamp),
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
        FilledButton(
          key: const Key('SaveButton'),
          onPressed: () {
            if (!(bloc.formKey.currentState?.validate() ?? false)) return;
            context.read<EventViewBloc>().add(EventViewSaveEvent());
            Navigator.pop(context);
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      titleIcon: Icons.event_available,
      content: Form(
        key: bloc.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              const SizedBox(height: 0),
              TextFormField(
                key: const Key('TitleField'),
                decoration: InputDecoration(
                  labelText: context.l10n.event_title,
                  prefixIcon: const Icon(Icons.title),
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                initialValue: title,
                autovalidateMode: AutovalidateMode.always,
                onChanged: (value) => context.read<EventViewBloc>().add(
                  EventViewTitleChangeEvent(value),
                ),
                validator: (value) =>
                    validate(context.l10n, value, context.l10n.event_title),
              ),
              Text(
                context.l10n.when,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Material(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  key: const Key('datePickerButton'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openDatePicker(
                    context,
                    DatePickerState.initial(timestamp),
                    (newTimestamp) => context.read<EventViewBloc>().add(
                      EventViewChangeTimestamp(newTimestamp),
                    ),
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
                                context.l10n.change_date_and_time,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timestamp.toMarkup(),
                                style: Theme.of(context).textTheme.bodyMedium,
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
          onPressed: () {
            if (!(bloc.formKey.currentState?.validate() ?? false)) return;
            context.read<EventViewBloc>().add(EventViewSaveEvent());
            Navigator.pop(context);
          },
          icon: const Icon(Icons.save),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

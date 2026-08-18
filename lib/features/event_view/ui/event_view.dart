import '../lib/openDatePicker.dart';
import '../model/event_view_bloc.dart';
import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      title: 'Edit Event',
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
                decoration: const InputDecoration(
                  labelText: 'Event title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                initialValue: title,
                autovalidateMode: AutovalidateMode.always,
                onChanged: (value) => context.read<EventViewBloc>().add(
                  EventViewTitleChangeEvent(value),
                ),
                validator: (value) => validate(value, 'Event title'),
              ),
              Text('When', style: Theme.of(context).textTheme.labelLarge),
              Material(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  key: const Key('datePickerButton'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openDatePicker(context, timestamp),
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
                                'Change date and time',
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
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('SaveButton'),
          onPressed: () {
            if (!(bloc.formKey.currentState?.validate() ?? false)) return;
            context.read<EventViewBloc>().add(EventViewSaveEvent());
            Navigator.pop(context);
          },
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:org_parser/org_parser.dart';

import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../model/date_picker_bloc.dart';

class DatePicker extends StatelessWidget {
  final void Function(OrgTimestamp timestamp) handleSave;

  const DatePicker(this.handleSave, {super.key});

  @override
  Widget build(BuildContext context) {
    final timestamp = context.select(
      (DatePickerBloc bloc) => bloc.generateTimestamp(),
    );
    final bloc = context.read<DatePickerBloc>();
    final dateFormat = DateFormat.yMMMEd();

    return DialogShell(
      title: context.l10n.select_date,
      titleIcon: Icons.date_range,
      content: BlocBuilder<DatePickerBloc, DatePickerState>(
        builder: (context, state) {
          final endTimeAllowed = state.endDateActive || state.startTimeActive;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _Preview(timestamp.toMarkup()),
                const SizedBox(height: 8),
                _PickerRow(
                  label: context.l10n.start_date,
                  button: _PickerButton(
                    key: const Key('datepicker_startdatebutton'),
                    icon: Icons.calendar_today_outlined,
                    text: dateFormat.format(state.startDate),
                    onPressed: () => bloc.datePickerDatePressed(
                      context,
                      DatePickerType.start,
                      initialDate: state.startDate,
                    ),
                  ),
                ),
                _PickerRow(
                  label: context.l10n.start_time,
                  button: _PickerButton(
                    key: const Key('datepicker_starttimebutton'),
                    icon: Icons.schedule,
                    text: state.startTimeDuration.format(context),
                    onPressed: state.startTimeActive
                        ? () => bloc.datePickerTimePressed(
                            context,
                            DatePickerType.start,
                          )
                        : null,
                  ),
                  toggle: Switch(
                    key: const Key('datepicker_starttimecheckbox'),
                    value: state.startTimeActive,
                    onChanged: (value) =>
                        bloc.add(DatePickerStartTimeActiveChanged(value)),
                  ),
                ),
                const Divider(height: 24),
                _PickerRow(
                  label: context.l10n.end_date,
                  button: _PickerButton(
                    key: const Key('datepicker_enddatebutton'),
                    icon: Icons.event_outlined,
                    text: state.endDate != null
                        ? dateFormat.format(state.endDate!)
                        : context.l10n.select_end_date,
                    onPressed: state.endDateActive
                        ? () => bloc.datePickerDatePressed(
                            context,
                            DatePickerType.end,
                            initialDate: state.endDate,
                          )
                        : null,
                  ),
                  toggle: Switch(
                    key: const Key('datepicker_enddatecheckbox'),
                    value: state.endDateActive,
                    onChanged: (value) =>
                        bloc.add(DatePickerEndDateActiveChanged(value)),
                  ),
                ),
                _PickerRow(
                  label: context.l10n.end_time,
                  button: _PickerButton(
                    key: const Key('datepicker_endtimebutton'),
                    icon: Icons.schedule,
                    text: state.endTimeDuration.format(context),
                    onPressed: state.endTimeActive && endTimeAllowed
                        ? () => bloc.datePickerTimePressed(
                            context,
                            DatePickerType.end,
                          )
                        : null,
                  ),
                  toggle: Switch(
                    key: const Key('datepicker_endtimecheckbox'),
                    value: state.endTimeActive,
                    onChanged: endTimeAllowed
                        ? (value) =>
                              bloc.add(DatePickerEndTimeActiveChanged(value))
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          key: const Key('CancelButton'),
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          key: const Key('SetButton'),
          onPressed: () {
            handleSave(timestamp);
            Navigator.pop(context);
          },
          child: Text(context.l10n.set),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  final String markup;
  const _Preview(this.markup);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          markup,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final Widget button;
  final Widget? toggle;

  const _PickerRow({required this.label, required this.button, this.toggle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        DialogSectionLabel(label),
        Row(
          spacing: 8,
          children: [
            Expanded(child: button),
            ?toggle,
          ],
        ),
      ],
    ),
  );
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  const _PickerButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(text),
    style: OutlinedButton.styleFrom(
      alignment: Alignment.centerLeft,
      minimumSize: const Size.fromHeight(44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

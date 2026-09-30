import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:org_parser/org_parser.dart';

import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../model/date_picker_cubit.dart';

class DatePicker extends StatelessWidget {
  final void Function(OrgTimestamp timestamp) handleSave;

  const DatePicker(this.handleSave, {super.key});

  @override
  Widget build(BuildContext context) {
    final timestamp = context.select(
      (DatePickerCubit cubit) => cubit.state.timestamp,
    );
    final cubit = context.read<DatePickerCubit>();
    final dateFormat = DateFormat.yMMMEd();

    return DialogShell(
      title: context.l10n.select_date,
      titleIcon: Icons.date_range,
      content: BlocBuilder<DatePickerCubit, DatePickerState>(
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
                    onPressed: () => _pickDate(context, DatePickerType.start),
                  ),
                ),
                _PickerRow(
                  label: context.l10n.start_time,
                  button: _PickerButton(
                    key: const Key('datepicker_starttimebutton'),
                    icon: Icons.schedule,
                    text: state.startTime.format(context),
                    onPressed: state.startTimeActive
                        ? () => _pickTime(context, DatePickerType.start)
                        : null,
                  ),
                  toggle: Switch(
                    key: const Key('datepicker_starttimecheckbox'),
                    value: state.startTimeActive,
                    onChanged: cubit.changeStartTimeActive,
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
                        ? () => _pickDate(context, DatePickerType.end)
                        : null,
                  ),
                  toggle: Switch(
                    key: const Key('datepicker_enddatecheckbox'),
                    value: state.endDateActive,
                    onChanged: cubit.changeEndDateActive,
                  ),
                ),
                _PickerRow(
                  label: context.l10n.end_time,
                  button: _PickerButton(
                    key: const Key('datepicker_endtimebutton'),
                    icon: Icons.schedule,
                    error: state.endTimeBeforeStart,
                    text: state.endTime.format(context),
                    onPressed: state.endTimeActive && endTimeAllowed
                        ? () => _pickTime(context, DatePickerType.end)
                        : null,
                  ),
                  toggle: Switch(
                    key: const Key('datepicker_endtimecheckbox'),
                    value: state.endTimeActive,
                    onChanged: endTimeAllowed
                        ? cubit.changeEndTimeActive
                        : null,
                  ),
                ),
                if (state.endTimeBeforeStart)
                  Text(
                    context.l10n.error_end_time_before_start,
                    key: const Key('datepicker_endtimeerror'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
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
        BlocSelector<DatePickerCubit, DatePickerState, bool>(
          selector: (state) => state.endTimeBeforeStart,
          builder: (context, endTimeBeforeStart) => FilledButton(
            key: const Key('SetButton'),
            onPressed: endTimeBeforeStart
                ? null
                : () {
                    handleSave(timestamp);
                    Navigator.pop(context);
                  },
            child: Text(context.l10n.set),
          ),
        ),
      ],
    );
  }
}

Future<void> _pickDate(BuildContext context, DatePickerType type) async {
  final cubit = context.read<DatePickerCubit>();
  final state = cubit.state;
  final endDate = state.endDate;
  final date = await showDatePicker(
    context: context,
    firstDate: type == DatePickerType.start ? DateTime(0) : state.startDate,
    lastDate: type == DatePickerType.start
        ? endDate ?? DateTime(3000)
        : DateTime(3000),
    initialDate: type == DatePickerType.start
        ? state.startDate
        : endDate == null || endDate.isBefore(state.startDate)
        ? state.startDate
        : endDate,
  );
  if (date == null || !context.mounted) return;

  type == DatePickerType.start
      ? cubit.changeStartDate(date)
      : cubit.changeEndDate(date);
}

Future<void> _pickTime(BuildContext context, DatePickerType type) async {
  final cubit = context.read<DatePickerCubit>();
  final time = await showTimePicker(
    context: context,
    initialTime: type == DatePickerType.start
        ? cubit.state.startTime
        : cubit.state.endTime,
  );
  if (time == null || !context.mounted) return;

  cubit.changeTime(time, type);
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
  final bool error;

  const _PickerButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: error ? errorColor : null,
        side: error ? BorderSide(color: errorColor) : null,
      ),
    );
  }
}

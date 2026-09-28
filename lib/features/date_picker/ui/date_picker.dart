import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

import '../../../shared/ui/editor_dialog_shell.dart';
import '../../../util.dart';
import '../model/date_picker_bloc.dart';

class DatePicker extends StatelessWidget {
  final void Function(OrgTimestamp timestamp) handleSave;

  const DatePicker(this.handleSave, {super.key});

  @override
  Widget build(BuildContext context) {
    final startDate = context.select(
      (DatePickerBloc bloc) => bloc.state.startDate,
    );
    final endDate = context.select((DatePickerBloc bloc) => bloc.state.endDate);
    final timestamp = context.select(
      (DatePickerBloc bloc) => bloc.generateTimestamp(),
    );

    TableRow titleRow(String title) => TableRow(
      children: [
        Text(title, textAlign: TextAlign.center),
        const SizedBox(),
      ],
    );
    return DialogShell(
      title: context.l10n.select_date,
      titleIcon: Icons.date_range,
      content: BlocBuilder<DatePickerBloc, DatePickerState>(
        builder: (context, state) => Table(
          columnWidths: const {1: FractionColumnWidth(0.25)},
          children: [
            titleRow(context.l10n.start_date),
            TableRow(
              children: [
                OutlinedButton(
                  key: const Key('datepicker_startdatebutton'),
                  onPressed: () =>
                      context.read<DatePickerBloc>().datePickerDatePressed(
                        context,
                        DatePickerType.start,
                        initialDate: startDate,
                      ),
                  child: Text(
                    dateTimeToSimpleTimestamp(
                      startDate,
                      false,
                      true,
                    ).toMarkup(),
                  ),
                ),
                const SizedBox(),
              ],
            ),
            titleRow(context.l10n.start_time),
            TableRow(
              children: [
                OutlinedButton(
                  key: const Key('datepicker_starttimebutton'),
                  onPressed: state.startTimeActive
                      ? () => context
                            .read<DatePickerBloc>()
                            .datePickerTimePressed(
                              context,
                              DatePickerType.start,
                            )
                      : null,
                  child: Text(state.startTimeDuration.format(context)),
                ),
                Switch(
                  key: const Key('datepicker_starttimecheckbox'),
                  value: state.startTimeActive,
                  onChanged: (value) => context.read<DatePickerBloc>().add(
                    DatePickerStartTimeActiveChanged(value),
                  ),
                ),
              ],
            ),
            titleRow(context.l10n.end_date),
            TableRow(
              children: [
                OutlinedButton(
                  key: const Key('datepicker_enddatebutton'),
                  onPressed: state.endDateActive
                      ? () => context
                            .read<DatePickerBloc>()
                            .datePickerDatePressed(
                              context,
                              DatePickerType.end,
                              initialDate: endDate,
                            )
                      : null,
                  child: Text(
                    endDate != null
                        ? dateTimeToSimpleTimestamp(
                            endDate,
                            false,
                            true,
                          ).toMarkup()
                        : context.l10n.select_end_date,
                  ),
                ),
                Switch(
                  key: const Key('datepicker_enddatecheckbox'),
                  value: state.endDateActive,
                  onChanged: (value) => context.read<DatePickerBloc>().add(
                    DatePickerEndDateActiveChanged(value),
                  ),
                ),
              ],
            ),
            titleRow(context.l10n.end_time),
            TableRow(
              children: [
                OutlinedButton(
                  key: const Key('datepicker_endtimebutton'),
                  onPressed:
                      state.endTimeActive &&
                          (state.endDateActive || state.startTimeActive)
                      ? () => context
                            .read<DatePickerBloc>()
                            .datePickerTimePressed(context, DatePickerType.end)
                      : null,
                  child: Text(state.endTimeDuration.format(context)),
                ),

                Switch(
                  key: const Key('datepicker_endtimecheckbox'),
                  value: state.endTimeActive,
                  onChanged: state.endDateActive || state.startTimeActive
                      ? (value) => context.read<DatePickerBloc>().add(
                          DatePickerEndTimeActiveChanged(value),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('CancelButton'),
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          key: const Key('SetButton'),
          onPressed: () {
            handleSave(timestamp);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check),
          label: Text(context.l10n.set),
        ),
      ],
    );
  }
}

import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/shared/editor_dialog_shell.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

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
        SizedBox(),
      ],
    );
    return DialogShell(
      title: "Select Date",
      titleIcon: Icons.date_range,
      content: BlocBuilder<DatePickerBloc, DatePickerState>(
        builder: (context, state) => Table(
          columnWidths: {1: FractionColumnWidth(0.25)},
          children: [
            titleRow("Start Date"),
            TableRow(
              children: [
                OutlinedButton(
                  key: Key("datepicker_startdatebutton"),
                  onPressed: () =>
                      context.read<DatePickerBloc>().datePickerDatePressed(
                        context,
                        "start",
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
                SizedBox(),
              ],
            ),
            titleRow("Start Time"),
            TableRow(
              children: [
                OutlinedButton(
                  key: Key("datepicker_starttimebutton"),
                  onPressed: state.startTimeActive
                      ? () => context
                            .read<DatePickerBloc>()
                            .datePickerTimePressed(context, "start")
                      : null,
                  child: Text(state.startTimeDuration.format(context)),
                ),
                Switch(
                  key: Key("datepicker_starttimecheckbox"),
                  value: state.startTimeActive,
                  onChanged: (value) => context.read<DatePickerBloc>().add(
                    DatePickerStartTimeActiveChanged(value!),
                  ),
                ),
              ],
            ),
            titleRow("End Date"),
            TableRow(
              children: [
                OutlinedButton(
                  key: Key("datepicker_enddatebutton"),
                  onPressed: state.endDateActive
                      ? () => context
                            .read<DatePickerBloc>()
                            .datePickerDatePressed(
                              context,
                              "end",
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
                        : "select end date",
                  ),
                ),
                Switch(
                  key: Key("datepicker_enddatecheckbox"),
                  // semanticLabel: state.endDateActive.toString(),
                  value: state.endDateActive,
                  onChanged: (value) => context.read<DatePickerBloc>().add(
                    DatePickerEndDateActiveChanged(value!),
                  ),
                ),
              ],
            ),
            titleRow("End Time"),
            TableRow(
              children: [
                OutlinedButton(
                  key: Key("datepicker_endtimebutton"),
                  onPressed:
                      state.endTimeActive == true &&
                          (state.endDateActive || state.startTimeActive)
                      ? () => context
                            .read<DatePickerBloc>()
                            .datePickerTimePressed(context, "end")
                      : null,
                  child: Text(state.endTimeDuration.format(context)),
                ),

                Switch(
                  key: Key("datepicker_endtimecheckbox"),
                  // semanticLabel: state.endTimeActive.toString(),
                  value: state.endTimeActive,
                  onChanged: state.endDateActive || state.startTimeActive
                      ? (value) => context.read<DatePickerBloc>().add(
                          DatePickerEndTimeActiveChanged(value!),
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
          key: Key("CancelButton"),
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        FilledButton.icon(
          key: Key("SetButton"),
          onPressed: () {
            handleSave(timestamp);
            Navigator.pop(context);
          },
          icon: Icon(Icons.check),
          label: Text("Set"),
        ),
      ],
    );
  }
}

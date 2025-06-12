import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final startDate =
        context.select((DatePickerBloc bloc) => bloc.state.startDate);
    final end = context.select((DatePickerBloc bloc) => bloc.state.endDate);
    final timestamp =
        context.select((DatePickerBloc bloc) => bloc.generateTimestamp());
    return AlertDialog(
        title: Row(children: [Text("DatePicker"), Spacer(), CloseButton()]),
        content: BlocBuilder<DatePickerBloc, DatePickerState>(
            builder: (context, state) {
          return SizedBox(
              width: double.maxFinite,
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  // Start Date Column
                  Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                              key: Key("datepicker_startdatebutton"),
                              onPressed: () => context
                                  .read<DatePickerBloc>()
                                  .datePickerDatePressed(context, "start"),
                              child: Text(dateTimeToSimpleTimestamp(
                                      startDate, false, true)
                                  .toMarkup())),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                              key: Key("datepicker_starttimebutton"),
                              onPressed: state.startTimeActive
                                  ? () => context
                                      .read<DatePickerBloc>()
                                      .datePickerTimePressed(context, "start")
                                  : null,
                              child: Text(state.startTimeDuration.toString())),
                          Checkbox(
                            key: Key("datepicker_starttimecheckbox"),
                            value: state.startTimeActive,
                            onChanged: (value) => context
                                .read<DatePickerBloc>()
                                .add(DatePickerStartTimeActiveChanged(value!)),
                          )
                        ],
                      )
                    ],
                  ),
                  // End Date Row
                  Column(
                    children: [
                      Row(
                        children: [
                          // End Date Button
                          TextButton(
                              key: Key("datepicker_enddatebutton"),
                              onPressed: state.endDateActive
                                  ? () => context
                                      .read<DatePickerBloc>()
                                      .datePickerDatePressed(context, "end")
                                  : null,
                              child: Text(end != null
                                  ? dateTimeToSimpleTimestamp(end, false, true)
                                      .toMarkup()
                                  : "select end date")),
                          // End Date enabled checkbox
                          Checkbox(
                              key: Key("datepicker_enddatecheckbox"),
                              semanticLabel: state.endDateActive.toString(),
                              value: state.endDateActive,
                              onChanged: (value) => context
                                  .read<DatePickerBloc>()
                                  .add(DatePickerEndDateActiveChanged(value!)))
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                              key: Key("datepicker_endtimebutton"),
                              onPressed: state.endTimeActive
                                  ? () => context
                                      .read<DatePickerBloc>()
                                      .datePickerTimePressed(context, "end")
                                  : null,
                              child: Text(state.endTimeDuration.toString())),
                          Checkbox(
                            key: Key("datepicker_endtimecheckbox"),
                            semanticLabel: state.endTimeActive.toString(),
                            value: state.endTimeActive,
                            onChanged: (value) => context
                                .read<DatePickerBloc>()
                                .add(DatePickerEndTimeActiveChanged(value!)),
                          )
                        ],
                      )
                    ],
                  ),
                  Text(timestamp.toMarkup())
                ],
              ));
        }));
  }
}

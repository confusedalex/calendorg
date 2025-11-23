import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final startDate = context.select(
      (DatePickerBloc bloc) => bloc.state.startDate,
    );
    final endDate = context.select((DatePickerBloc bloc) => bloc.state.endDate);
    final timestamp = context.select(
      (DatePickerBloc bloc) => bloc.generateTimestamp(),
    );

    return AlertDialog(
      title: Row(children: [Text("DatePicker"), Spacer(), CloseButton()]),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<DatePickerBloc, DatePickerState>(
          builder: (context, state) => Column(
            children: [
              Column(
                children: [
                  Text("Start Date"),
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
                ],
              ),
              Column(
                children: [
                  Text("Start Time"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      Checkbox(
                        key: Key("datepicker_starttimecheckbox"),
                        value: state.startTimeActive,
                        onChanged: (value) => context
                            .read<DatePickerBloc>()
                            .add(DatePickerStartTimeActiveChanged(value!)),
                      ),
                    ],
                  ),
                ],
              ),
              Text("End Date"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  // End Date enabled checkbox
                  Checkbox(
                    key: Key("datepicker_enddatecheckbox"),
                    semanticLabel: state.endDateActive.toString(),
                    value: state.endDateActive,
                    onChanged: (value) => context.read<DatePickerBloc>().add(
                      DatePickerEndDateActiveChanged(value!),
                    ),
                  ),
                ],
              ),
              Text("End Time"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    key: Key("datepicker_endtimebutton"),
                    onPressed: state.endTimeActive
                        ? () => context
                              .read<DatePickerBloc>()
                              .datePickerTimePressed(context, "end")
                        : null,
                    child: Text(state.endTimeDuration.format(context)),
                  ),
                  Checkbox(
                    key: Key("datepicker_endtimecheckbox"),
                    semanticLabel: state.endTimeActive.toString(),
                    value: state.endTimeActive,
                    onChanged: state.endDateActive || state.startTimeActive
                        ? (value) => context.read<DatePickerBloc>().add(
                            DatePickerEndTimeActiveChanged(value!),
                          )
                        : null,
                  ),
                ],
              ),
              Spacer(),
              Text(timestamp.toMarkup()),
              Spacer(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: Key("SaveButton"),
          onPressed: () {
            context.read<EventViewBloc>().add(
              EventViewChangeTimestamp(timestamp),
            );
            Navigator.pop(context);
          },
          child: Text("save"),
        ),
      ],
    );
  }
}

import 'package:calendorg/features/date_picker/bloc/date_picker_bloc.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final start = context.select((DatePickerBloc bloc) => bloc.state.startDate);
    final end = context.select((DatePickerBloc bloc) => bloc.state.endDate);
    return AlertDialog(
        title: Row(children: [Text("DatePicker"), Spacer(), CloseButton()]),
        content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 2,
              children: <Widget>[
                Row(
                  children: [
                    TextButton(
                        onPressed: () => {},
                        child: Text(start.toIso8601String())),
                  ],
                ),
                Row(
                  children: [
                    BlocBuilder<DatePickerBloc, DatePickerState>(
                      builder: (context, state) {
                        return TextButton(
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              side: BorderSide(width: 5),
                            )),
                            onPressed: state.endDateActive ? () {} : null,
                            child: Text(
                                end?.toIso8601String() ?? "select end date"));
                      },
                    ),
                    BlocBuilder<DatePickerBloc, DatePickerState>(
                      builder: (context, state) {
                        return Checkbox(
                          value: state.endDateActive,
                          onChanged: (value) {
                            context
                                .read<DatePickerBloc>()
                                .add(DatePickerEndDateActiveChanged(value!));
                          },
                        );
                      },
                    )
                  ],
                ),
              ],
            )));
  }
}

import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class StartingDateDialog extends StatelessWidget {
  const StartingDateDialog({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StartingDayCubit, StartingDayOfWeek>(
        builder: (context, state) {
          return AlertDialog(
            title: Text("Starting Day"),
            content: Flex(
              direction: Axis.vertical,
              children: [
                ListTile(
                    title: Text("Montag"),
                    leading: Radio<StartingDayOfWeek>(
                        value: StartingDayOfWeek.monday,
                        groupValue: state,
                        onChanged: (day) => context
                            .read<StartingDayCubit>()
                            .changeStartingDayOfWeek(day!))),
                ListTile(
                    title: Text("Sunday"),
                    leading: Radio<StartingDayOfWeek>(
                        value: StartingDayOfWeek.sunday,
                        groupValue: state,
                        onChanged: (day) => context
                            .read<StartingDayCubit>()
                            .changeStartingDayOfWeek(day!)))
              ],
            ),
          );
        },
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/starting_day_cubit.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class StartingDateDialog extends StatelessWidget {
  const StartingDateDialog({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StartingDayCubit, StartingDayOfWeek>(
        builder: (context, state) {
          return DialogShell(
            title: context.l10n.starting_day,
            titleIcon: Icons.calendar_month,
            showClose: true,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ListView(
                shrinkWrap: true,
                children: [
                  RadioGroup(
                    groupValue: state,
                    onChanged: (day) => context
                        .read<StartingDayCubit>()
                        .changeStartingDayOfWeek(day!),
                    child: Column(
                      children: [
                        RadioListTile(
                          title: Text(context.l10n.monday),
                          value: StartingDayOfWeek.monday,
                        ),
                        RadioListTile(
                          title: Text(context.l10n.sunday),
                          value: StartingDayOfWeek.sunday,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../shared/ui/editor_dialog_shell.dart';
import '../../../../util.dart';

class StartingDateDialog extends StatelessWidget {
  const StartingDateDialog({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, AppSettings, StartingDayOfWeek>(
        selector: (settings) => settings.startingDay,
        builder: (context, state) {
          return DialogShell(
            title: context.l10n.starting_day,
            titleIcon: Icons.calendar_view_week_outlined,
            showClose: true,
            content: RadioGroup(
              groupValue: state,
              onChanged: (day) =>
                  context.read<SettingsCubit>().setStartingDay(day!),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.monday),
                    value: StartingDayOfWeek.monday,
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.sunday),
                    value: StartingDayOfWeek.sunday,
                  ),
                ],
              ),
            ),
          );
        },
      );
}

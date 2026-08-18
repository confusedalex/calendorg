import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/cubit/org_files_cubit.dart';
import '../model/calendar_bloc.dart';
import 'calendar_view.dart';

class CalendarPage extends StatelessWidget {
  final DateTime initialSelectedDay;
  const CalendarPage(this.initialSelectedDay, {super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrgFilesCubit, OrgFilesState>(
        builder: (context, state) => BlocProvider(
          create: (context) => CalendarBloc(initialSelectedDay),
          child: const CalendarView(),
        ),
      );
}

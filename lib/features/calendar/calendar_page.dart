import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';
import 'package:calendorg/features/calendar/calendar_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarPage extends StatelessWidget {
  final DateTime initialSelectedDay;
  const CalendarPage(this.initialSelectedDay, {super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrgFilesCubit, OrgFilesState>(
        builder: (context, state) => BlocProvider(
          create: (context) => CalendarBloc(initialSelectedDay),
          child: CalendarView(),
        ),
      );
}

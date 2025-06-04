import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';
import 'package:calendorg/core/document/document_cubit.dart';
import 'package:calendorg/features/calendar/calendar_view.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:org_parser/org_parser.dart';

class CalendarPage extends StatelessWidget {
  final DateTime initialSelectedDay;
  const CalendarPage(this.initialSelectedDay, {super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrgDocumentCubit, OrgDocument>(
          builder: (context, state) => BlocProvider(
              create: (context) =>
                  CalendarBloc(parseEvents(state), initialSelectedDay),
              child: CalendarView()));
}

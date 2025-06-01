import 'package:calendorg/models/document_model.dart';
import 'package:calendorg/pages/calendar/calendar_view.dart';
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
          builder: (context, state) =>
              CalendarView(parseEvents(state), initialSelectedDay));
}

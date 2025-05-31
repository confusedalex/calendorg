import 'package:calendorg/models/tag_model.dart';
import 'package:calendorg/pages/calendar/calendar_page.dart';
import 'package:calendorg/tag_color.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  final markup = """
* Heading 1
** orgmode meetup
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
""";
  final document = OrgDocument.parse(markup);
  final events = parseEvents(document);

  Future<void> pumpWidgetToTester(dynamic tester) async {
    await tester.pumpWidget(MaterialApp(
        home: BlocProvider(
      create: (context) =>
          TagColorsCubit.withInitialValue([TagColor("school", Colors.orange)]),
      child: Scaffold(body: CalendarPage(events)),
    )));
  }

  testWidgets('Calendar should show marker for every event occurance',
      (tester) async {
    await pumpWidgetToTester(tester);

    expect(find.byType(CircleAvatar), findsNWidgets(9));
  });

  testWidgets('Calendar respects tag colors from model', (tester) async {
    await pumpWidgetToTester(tester);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is CircleAvatar && widget.backgroundColor == Colors.orange),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is CircleAvatar && widget.backgroundColor == Colors.blue),
        findsNWidgets(8));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is CircleAvatar && widget.backgroundColor == Colors.green),
        findsNothing);
  });
}

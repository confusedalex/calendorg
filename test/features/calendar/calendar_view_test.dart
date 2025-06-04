import 'package:calendorg/core/tag_colors/tag_model.dart';
import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';
import 'package:calendorg/models/document_model.dart';
import 'package:calendorg/features/calendar/calendar_page.dart';
import 'package:calendorg/features/calendar/calendar_view.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/src/widgets/format_button.dart';

void main() {
  group(
    'CalendarWidget',
    () {
      final markup = """
* Heading 1
** orgmode meetup
<2025-05-05>
<2025-05-05>
<2025-05-06 11:00>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
<2025-05-27>
<2025-05-05>
<2025-05-08 11:00-13:00>
* Home :@home:
<2025-05-08 11:00-13:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
""";
      final document = OrgDocument.parse(markup);
      final schoolTagColor = TagColor("school", Colors.orange);
      final homeTagColor = TagColor("@home", Colors.lightGreen);
      final workTagColor = TagColor("@work", Colors.yellow);
      late CalendarBloc calendarBloc;

      setUp(() {
        calendarBloc =
            CalendarBloc(parseEvents(document), DateTime(2025, 05, 17));
      });

      Future<void> pumpWidgetToTester(dynamic tester) async {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: MultiBlocProvider(
                    // child: CalendarPage(DateTime(2025, 05, 17)))))));
                    providers: [
              BlocProvider(create: (context) => OrgDocumentCubit(document)),
              BlocProvider<CalendarBloc>(create: (context) => calendarBloc),
              BlocProvider(
                  create: (context) => TagColorsCubit.withInitialValue(
                      [schoolTagColor, homeTagColor, workTagColor])),
            ],
                    child: CalendarView()))));
      }

      testWidgets('Calendar should show marker for every tag occurance at day',
          (tester) async {
        await pumpWidgetToTester(tester);

        expect(find.byType(CircleAvatar), findsNWidgets(11));
      });

      testWidgets('Calendar respects tag colors from model', (tester) async {
        await pumpWidgetToTester(tester);

        expect(
            find.byWidgetPredicate((widget) =>
                widget is CircleAvatar &&
                widget.backgroundColor == Colors.orange),
            findsNWidgets(3));
        expect(
            find.byWidgetPredicate((widget) =>
                widget is CircleAvatar &&
                widget.backgroundColor == Colors.blue),
            findsNWidgets(5));
        expect(
            find.byWidgetPredicate((widget) =>
                widget is CircleAvatar &&
                widget.backgroundColor == Colors.lightGreen),
            findsNWidgets(3));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is CircleAvatar &&
                widget.backgroundColor == Colors.green),
            findsNothing);
      });

      testWidgets("Date will change", (tester) async {
        await pumpWidgetToTester(tester);

        await tester.pumpAndSettle();

        expect(isSameDay(calendarBloc.state.focusedDay, DateTime(2025, 05, 17)),
            isTrue);
        await tester.tap(find.byKey(Key("CellContent-2025-5-16")));
        expect(isSameDay(calendarBloc.state.focusedDay, DateTime(2025, 05, 16)),
            isTrue);
      });
    },
  );
}

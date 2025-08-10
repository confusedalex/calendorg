import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/calendar/bloc/calendar_bloc.dart';
import 'package:calendorg/features/calendar/calendar_view.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
      late OrgFilesBloc orgFilesBloc;
      late CalendarBloc calendarBloc;

      orgFilesBloc = MockOrgFilesBloc(document);

      setUp(() {
        calendarBloc = CalendarBloc(DateTime(2025, 05, 17));
      });

      Future<void> pumpWidgetToTester(dynamic tester) async {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: MultiBlocProvider(providers: [
          BlocProvider.value(value: orgFilesBloc),
          BlocProvider.value(value: calendarBloc),
          BlocProvider(create: (context) => StartingDayCubit()),
          BlocProvider(create: (context) => TodoStatesCubit()),
          BlocProvider(create: (context) => FloatingActionButtonCubit()),
          BlocProvider(
              create: (context) => TagColorsCubit.withInitialValue(
                  [schoolTagColor, homeTagColor, workTagColor])),
        ], child: CalendarView()))));
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
      testWidgets("Changing calendar format works", (tester) async {
        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FormatButton));

        expect(
            calendarBloc.state.calendarFormat, equals(CalendarFormat.twoWeeks));
      });
      testWidgets(
          "CalendarView shows eventCards for every event, when events are there",
          (tester) async {
        calendarBloc = CalendarBloc(DateTime(2025, 05, 05));

        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        expect(find.byType(EventCard), findsNWidgets(3));
      });
      testWidgets("CalendarView shows no eventCards, when no events are there",
          (tester) async {
        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        expect(find.byType(EventCard), findsNothing);
      });
    },
  );
}

class MockOrgFilesBloc extends Mock implements OrgFilesBloc {
  final fileInfo = MockFileInfo();
  final OrgDocument document;

  MockOrgFilesBloc(this.document);

  @override
  OrgFilesState get state => OrgFilesState(
      filePaths: {fileInfo},
      documentsMap: {fileInfo: document},
      todoStates: OrgTodoStates());

  @override
  Stream<OrgFilesState> get stream => Stream.value(state);
}

class MockFileInfo extends Mock implements FileInfo {}

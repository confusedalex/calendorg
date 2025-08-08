import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:calendorg/features/event_view/event_view.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  final markup = """
* Heading 1
** orgmode meetup :meetups:
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
""";
  final document = OrgDocument.parse(markup);
  final event = parseEvents(MockFileInfo(), document).entries.first.value.first;
  final meetupTagColor = TagColor("meetups", Colors.pink);

  Future<void> initWidget(dynamic tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  TagColorsCubit.withInitialValue([meetupTagColor])),
          BlocProvider(create: (context) => TodoStatesCubit())
        ],
        child: EventCard(event, event.timestamps.first),
      ),
    )));

    await tester.pumpAndSettle();
  }

  group('EventCard', () {
    group(
      'EventCard displays correct information',
      () {
        testWidgets(
          'EventCard displays correct TagColor',
          (tester) async {
            await initWidget(tester);

            final container = tester.widget<Container>(find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration != null &&
                    widget.decoration is BoxDecoration));

            expect((container.decoration as BoxDecoration).color,
                isSameColorAs(meetupTagColor.color));
          },
        );
        testWidgets("EventCard display correct title", (tester) async {
          await initWidget(tester);

          expect(find.text(event.title), findsOneWidget);
        });

        testWidgets("EventCard display correct time", (tester) async {
          await initWidget(tester);

          expect(find.text(event.timestamps.first.toMarkup()), findsOneWidget);
        });

        testWidgets("EventCard Title is orange for scheduled entry",
            (tester) async {
          final markup = """
** TODO uninstall vim
SCHEDULED: <2025-05-16>
""";
          final document = OrgDocument.parse(markup);
          final event =
              parseEvents(MockFileInfo(), document).entries.first.value.first;

          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
            body: BlocProvider<TagColorsCubit>(
              create: (context) =>
                  TagColorsCubit.withInitialValue([meetupTagColor]),
              child: EventCard(event, event.timestamps.first),
            ),
          )));

          expect(
              find.byWidgetPredicate((widget) =>
                  widget is Text &&
                  widget.style == TextStyle(color: Colors.amber)),
              findsOne);
        });

        testWidgets("EventCard Title is red for deadlined entry",
            (tester) async {
          final markup = """
** TODO install emacs
DEADLINE: <2025-05-17>
""";
          final document = OrgDocument.parse(markup);
          final event =
              parseEvents(MockFileInfo(), document).entries.first.value.first;

          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
            body: BlocProvider<TagColorsCubit>(
              create: (context) => TagColorsCubit.withInitialValue([]),
              child: EventCard(event, event.timestamps.first),
            ),
          )));

          expect(
              find.byWidgetPredicate((widget) =>
                  widget is Text &&
                  widget.style == TextStyle(color: Colors.red)),
              findsOne);
        });
        testWidgets("EventCard Title is green for done entry", (tester) async {
          final markup = """
** DONE install emacs
<2025-05-05>
""";
          final document = OrgDocument.parse(markup);
          final event =
              parseEvents(MockFileInfo(), document).entries.first.value.first;

          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (create) => TagColorsCubit.withInitialValue([])),
                BlocProvider(create: (create) => TodoStatesCubit())
              ],
              child: EventCard(event, event.timestamps.first),
            ),
          )));

          // We expect to find 2 widgets, because of the keyword and the heading
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is Text &&
                  widget.style == TextStyle(color: Colors.green)),
              findsNWidgets(2));
        });
      },
    );
    testWidgets("EventCard tap will open EventView", (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => TagColorsCubit.withInitialValue(
                      [meetupTagColor],
                    )),
            BlocProvider(create: (context) => MockOrgFilesBloc(document))
          ],
          child: EventCard(event, event.timestamps.first),
        ),
      )));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(EventCard));

      await tester.pumpAndSettle();

      expect(find.byType(EventView), findsOneWidget);
    }, skip: true);
  });
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

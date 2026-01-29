import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/calendar/event_card.dart';
import 'package:calendorg/features/event_view/bloc/event_view_bloc.dart';
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
  final OrgFilesBloc orgFilesBloc = OrgFilesBloc();

  Future<void> initWidget(dynamic tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    TagColorsCubit.withInitialValue([meetupTagColor]),
              ),
              BlocProvider(create: (context) => TodoStatesCubit()),
              BlocProvider(create: (context) => orgFilesBloc),
            ],
            child: EventCard(event, event.timestamps.first),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('EventCard', () {
    group('EventCard displays correct information', () {
      testWidgets("EventCard display correct title", (tester) async {
        await initWidget(tester);

        expect(find.text(event.title, findRichText: true), findsOneWidget);
      });
      testWidgets('EventCard displays correct TagColor', (tester) async {
        await initWidget(tester);

        final container = tester.widget<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration != null &&
                widget.decoration is BoxDecoration,
          ),
        );

        expect(
          (container.decoration as BoxDecoration).color,
          isSameColorAs(meetupTagColor.color),
        );
      });
      testWidgets("EventCard display correct time", (tester) async {
        await initWidget(tester);

        expect(find.text(event.timestamps.first.toMarkup()), findsOneWidget);
      });
    });
    testWidgets("EventCard tap will open EventView", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => EventViewBloc(
                    orgFilesBloc,
                    event,
                    event.timestamps.first,
                  ),
                ),
                BlocProvider(create: (context) => TodoStatesCubit()),
                BlocProvider(
                  create: (context) =>
                      TagColorsCubit.withInitialValue([meetupTagColor]),
                ),
                BlocProvider(create: (context) => OrgFilesBloc()),
              ],
              child: EventCard(event, event.timestamps.first),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(EventCard));

      await tester.pumpAndSettle();

      expect(find.byType(EventView), findsOneWidget);
    });
  });
}

class MockFileInfo extends Mock implements FileInfo {}

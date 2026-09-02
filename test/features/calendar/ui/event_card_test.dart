import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/entities/occurrence/occurrence_generator.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:calendorg/features/calendar/ui/event_card.dart';
import 'package:calendorg/features/event_view/ui/event_view.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/preferences.dart';

void main() {
  const markup = '''
* Heading 1
** orgmode meetup :meetups:
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** School :school:
<2025-05-27>
''';
  final document = OrgDocument.parse(markup);
  final entry = EventParserService()
      .parseEntriesFromDocument(MockFileInfo(), document, {})
      .first;
  final occurrence = occurrencesFor(
    entry,
    DateTimeRange(start: DateTime(2025, 5), end: DateTime(2025, 5, 30)),
  ).first;
  final meetupTagColor = TagColor('meetups', Colors.pink);

  Future<void> initWidget(
    dynamic tester, {
    List<BlocProvider<dynamic>>? extraProviders,
    OrgFilesCubit? customOrgFilesCubit,
  }) async {
    final tagColorsCubit = TagColorsCubit.withInitialValue(
      inMemoryPreferences(),
      [meetupTagColor],
    );
    final todoStatesCubit = TodoStatesCubit(inMemoryPreferences());
    final orgFilesCubit = customOrgFilesCubit ?? FakeOrgFilesCubit();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: tagColorsCubit),
              BlocProvider.value(value: todoStatesCubit),
              BlocProvider.value(value: orgFilesCubit),
              ...?extraProviders,
            ],
            child: EventCard(occurrence),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('EventCard', () {
    group('EventCard displays correct information', () {
      testWidgets('EventCard display correct title', (tester) async {
        await initWidget(tester);

        expect(find.text(entry.title, findRichText: true), findsOneWidget);
      });
      testWidgets('EventCard displays correct TagColor', (tester) async {
        await initWidget(tester);

        final containerFinder = find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        );

        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration! as BoxDecoration;
        final border = decoration.border as Border?;

        expect(border, isNotNull);
        expect(border!.left.color, isSameColorAs(meetupTagColor.color));
      });
      testWidgets('EventCard display correct time', (tester) async {
        await initWidget(tester);

        expect(find.text(occurrence.timestamp.toMarkup()), findsOneWidget);
      });
    });
    testWidgets('EventCard tap will open EventView', (tester) async {
      await initWidget(tester);

      await tester.tap(find.byType(EventCard));
      await tester.pumpAndSettle();

      expect(find.byType(EventView), findsOneWidget);
    });
  });
}

class MockFileInfo extends Mock implements FileInfo {}

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeOrgFilesCubit extends OrgFilesCubit {
  FakeOrgFilesCubit() : super(MockOrgFilesRepository()) {
    emit(
      OrgFilesState(
        directory: null,
        status: OrgFilesStatus.success,
        filePaths: {},
        documentsMap: {},
        todoStates: OrgTodoStatesWithIgnored(
          todo: ['TODO'],
          done: ['DONE'],
          ignored: [],
        ),
        entries: [],
      ),
    );
  }
}

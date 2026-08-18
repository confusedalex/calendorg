import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/features/date_picker/ui/date_picker.dart';
import 'package:calendorg/features/event_view/model/event_view_bloc.dart';
import 'package:calendorg/features/event_view/ui/event_view.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:org_parser/org_parser.dart';

import '../../settings/settings_overview/ui/settings_page_test.dart';

void main() {
  const markup = '''
* orgmode meetup :meetups:
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-01>--<2025-05-03>
''';
  final document = OrgDocument.parse(markup);
  final entry = EventParserService()
      .parseEntriesFromDocument(MockFileInfo(), document, {})
      .first;
  final meetupTagColor = TagColor('meetups', Colors.pink);
  final orgFilesCubit = OrgFilesCubit(MockOrgFilesRepository());

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
              BlocProvider(
                create: (context) =>
                    EventViewBloc(orgFilesCubit, entry, entry.timestamps.first),
              ),
            ],
            child: const EventView(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('Event View', () {
    testWidgets('EventView shows event title', (tester) async {
      await initWidget(tester);

      expect(find.byKey(const Key('TitleField')), findsOneWidget);
      expect(find.text(entry.title), findsOneWidget);
    });
    group('date picker', () {
      testWidgets('EventView shows date picker Button', (tester) async {
        await initWidget(tester);

        expect(find.byKey(const Key('datePickerButton')), findsOneWidget);
      });
      testWidgets('Date Picker button shows timestamp', (tester) async {
        await initWidget(tester);

        expect(find.text(entry.timestamps.first.toMarkup()), findsOneWidget);
      });
      testWidgets('Date Picker button open datePickerDialog', (tester) async {
        await initWidget(tester);

        await tester.tap(find.byKey(const Key('datePickerButton')));

        await tester.pumpAndSettle();

        expect(find.byType(DatePicker), findsOneWidget);
      });
    });
  });
}

class MockFileInfo extends Mock implements FileInfo {}

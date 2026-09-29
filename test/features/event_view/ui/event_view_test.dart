import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/entities/org_entry/entry_edit.dart';
import 'package:calendorg/features/date_picker/ui/date_picker.dart';
import 'package:calendorg/features/event_view/ui/event_view.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/entries.dart';

class MockOrgFilesCubit extends Mock implements OrgFilesCubit {}

void main() {
  const markup = '''
* orgmode meetup :meetups:
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-01>--<2025-05-03>
''';
  final document = OrgDocument.parse(markup);
  final entry = parseEntries(document).first;
  late MockOrgFilesCubit orgFilesCubit;

  setUpAll(() {
    registerFallbackValue(entry);
    registerFallbackValue(const EntryEdit());
  });

  setUp(() {
    orgFilesCubit = MockOrgFilesCubit();
    when(() => orgFilesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => orgFilesCubit.applyEdit(any(), any())).thenAnswer((_) async {});
  });

  Future<void> openEventView(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<OrgFilesCubit>.value(
        value: orgFilesCubit,
        child: MaterialApp(
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    EventView(entry: entry, timestamp: entry.timestamps.first),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('Event View', () {
    testWidgets('EventView shows event title', (tester) async {
      await openEventView(tester);

      expect(find.byKey(const Key('TitleField')), findsOneWidget);
      expect(find.text(entry.title), findsOneWidget);
    });

    group('date picker', () {
      testWidgets('EventView shows date picker Button', (tester) async {
        await openEventView(tester);

        expect(find.byKey(const Key('datePickerButton')), findsOneWidget);
      });
      testWidgets('Date Picker button shows timestamp', (tester) async {
        await openEventView(tester);

        expect(find.text(entry.timestamps.first.toMarkup()), findsOneWidget);
      });
      testWidgets('Date Picker button open datePickerDialog', (tester) async {
        await openEventView(tester);

        await tester.tap(find.byKey(const Key('datePickerButton')));
        await tester.pumpAndSettle();

        expect(find.byType(DatePicker), findsOneWidget);
      });
    });

    group('save', () {
      testWidgets('saves a changed title and closes', (tester) async {
        await openEventView(tester);

        await tester.enterText(
          find.byKey(const Key('TitleField')),
          'History exam',
        );
        await tester.tap(find.byKey(const Key('SaveButton')));
        await tester.pumpAndSettle();

        final edit =
            verify(
                  () => orgFilesCubit.applyEdit(entry, captureAny()),
                ).captured.single
                as EntryEdit;
        expect(edit.newTitle, 'History exam');
        expect(edit.newTimestamp, isNull);
        expect(find.byType(EventView), findsNothing);
      });

      testWidgets('does not save without changes', (tester) async {
        await openEventView(tester);

        await tester.tap(find.byKey(const Key('SaveButton')));
        await tester.pumpAndSettle();

        verifyNever(() => orgFilesCubit.applyEdit(any(), any()));
        expect(find.byType(EventView), findsNothing);
      });

      testWidgets('does not save an empty title', (tester) async {
        await openEventView(tester);

        await tester.enterText(find.byKey(const Key('TitleField')), ' ');
        await tester.tap(find.byKey(const Key('SaveButton')));
        await tester.pumpAndSettle();

        verifyNever(() => orgFilesCubit.applyEdit(any(), any()));
        expect(find.byType(EventView), findsOneWidget);
      });
    });
  });
}

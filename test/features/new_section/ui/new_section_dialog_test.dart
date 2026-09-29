import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:calendorg/features/date_picker/ui/date_picker.dart';
import 'package:calendorg/features/new_section/model/new_section_cubit.dart';
import 'package:calendorg/features/new_section/ui/new_section_dialog.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('NewSectionDialog', () {
    late OrgFilesCubit orgFilesCubit;

    setUp(() {
      orgFilesCubit = TestOrgFilesCubit.withInboxFile(MockFileInfo());
    });

    Future<void> pumpWidget(WidgetTester tester) async {
      final date = DateTime(2025, 5, 17);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: orgFilesCubit),
                BlocProvider(
                  create: (_) => NewSectionCubit(
                    null,
                    dateTimeToSimpleTimestamp(date, false, true),
                  ),
                ),
              ],
              child: const NewSectionDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('uses the event-style dialog chrome', (tester) async {
      await pumpWidget(tester);

      expect(find.text('Add Event'), findsOneWidget);
      expect(find.byKey(const Key('titleField')), findsOneWidget);
      expect(find.byKey(const Key('datePickerButton')), findsOneWidget);
      expect(find.byKey(const Key('CancelButton')), findsOneWidget);
      expect(find.byKey(const Key('SaveButton')), findsOneWidget);

      final saveButton = tester.widget<FilledButton>(
        find.byKey(const Key('SaveButton')),
      );
      expect(saveButton.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('datePickerButton')));
      await tester.pumpAndSettle();

      expect(find.byType(DatePicker), findsOneWidget);
    });
  });
}

class TestOrgFilesCubit extends OrgFilesCubit {
  TestOrgFilesCubit._(OrgFilesState state) : super(MockOrgFilesRepository()) {
    emit(state);
  }

  factory TestOrgFilesCubit.withInboxFile(FileInfo inboxFile) {
    return TestOrgFilesCubit._(
      OrgFilesState(
        directory: null,
        status: OrgFilesStatus.success,
        filePaths: {inboxFile},
        todoStates: OrgTodoStatesWithIgnored(
          todo: ['TODO'],
          done: ['DONE'],
          ignored: [],
        ),
        entries: [],
        inboxFile: inboxFile,
      ),
    );
  }
}

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class MockFileInfo extends Mock implements FileInfo {}

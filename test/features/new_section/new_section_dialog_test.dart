import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/date_picker/date_picker.dart';
import 'package:calendorg/features/new_section/cubit/new_section_cubit.dart';
import 'package:calendorg/features/new_section/new_section_dialog.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  group('NewSectionDialog', () {
    late OrgFilesCubit orgFilesCubit;

    setUp(() {
      orgFilesCubit = TestOrgFilesCubit.withInboxFile(MockFileInfo());
    });

    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: orgFilesCubit),
                BlocProvider(create: (_) => NewSectionCubit(null, null)),
              ],
              child: NewSectionDialog(dateTime: DateTime(2025, 5, 17)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('uses the event-style dialog chrome', (tester) async {
      await pumpWidget(tester);

      expect(find.text('Add Event'), findsOneWidget);
      expect(find.byKey(Key('titleField')), findsOneWidget);
      expect(find.byKey(Key('datePickerButton')), findsOneWidget);
      expect(find.byKey(Key('CancelButton')), findsOneWidget);
      expect(find.byKey(Key('SaveButton')), findsOneWidget);
      expect(find.text('No date selected'), findsOneWidget);

      final saveButton = tester.widget<FilledButton>(
        find.byKey(Key('SaveButton')),
      );
      expect(saveButton.onPressed, isNull);

      await tester.tap(find.byKey(Key('datePickerButton')));
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
        filePaths: {inboxFile},
        documentsMap: {inboxFile: OrgDocument.parse('')},
        todoStates: OrgTodoStatesWithIgnored(
          todo: ['TODO'],
          done: ['DONE'],
          ignored: [],
        ),
        allEvents: {},
        inboxFile: inboxFile,
      ),
    );
  }
}

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class MockFileInfo extends Mock implements FileInfo {}

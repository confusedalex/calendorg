import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:calendorg/features/settings/agenda_files/ui/agenda_page.dart';
import 'package:calendorg/features/today_page/ui/today_page.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeOrgFilesCubit extends OrgFilesCubit {
  FakeOrgFilesCubit(OrgFilesState state) : super(MockOrgFilesRepository()) {
    emit(state);
  }
}

OrgFilesState filesState({
  OrgFilesStatus status = OrgFilesStatus.success,
  DirectoryInfo? directory,
  Set<FileInfo> filePaths = const {},
}) => OrgFilesState(
  directory: directory,
  status: status,
  filePaths: filePaths,
  todoStates: OrgTodoStatesWithIgnored.defaults,
  entries: [],
);

void main() {
  Future<void> pumpTodayPage(WidgetTester tester, OrgFilesState state) =>
      tester.pumpWidget(
        RepositoryProvider<OrgFilesRepository>(
          create: (_) => MockOrgFilesRepository(),
          child: BlocProvider<OrgFilesCubit>(
            create: (_) => FakeOrgFilesCubit(state),
            child: const MaterialApp(
              localizationsDelegates:
                  CalendorgLocalizations.localizationsDelegates,
              supportedLocales: CalendorgLocalizations.supportedLocales,
              home: Scaffold(body: TodayPage()),
            ),
          ),
        ),
      );

  testWidgets('shows the setup hint without an org folder', (tester) async {
    await pumpTodayPage(tester, filesState());

    expect(find.text('Choose files'), findsOne);
  });

  testWidgets('the setup hint opens the file settings', (tester) async {
    await pumpTodayPage(tester, filesState());

    await tester.tap(find.text('Choose files'));
    await tester.pumpAndSettle();

    expect(find.byType(AgendaPage), findsOne);
  });

  testWidgets('shows no setup hint while loading', (tester) async {
    await pumpTodayPage(tester, filesState(status: OrgFilesStatus.loading));

    expect(find.text('Choose files'), findsNothing);
  });

  testWidgets('shows no setup hint when files are set', (tester) async {
    await pumpTodayPage(
      tester,
      filesState(
        directory: DirectoryInfo(
          identifier: 'org',
          persistable: true,
          uri: 'org-uri',
        ),
        filePaths: {
          FileInfo(
            identifier: 'work',
            persistable: true,
            uri: 'work-uri',
            fileName: 'work.org',
          ),
        },
      ),
    );

    expect(find.text('Choose files'), findsNothing);
    expect(find.text('Nothing planned for the next 3 days'), findsOne);
  });
}

import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/settings/app_settings.dart';
import 'package:calendorg/core/settings/settings_cubit.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:calendorg/features/habits/ui/habits_page.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:org_parser/org_parser.dart';

import '../../../helpers/entries.dart';
import '../../../helpers/preferences.dart';

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {}

class FakeOrgFilesCubit extends OrgFilesCubit {
  FakeOrgFilesCubit(List<OrgEntry> entries) : super(MockOrgFilesRepository()) {
    emit(
      OrgFilesState(
        directory: null,
        status: OrgFilesStatus.success,
        filePaths: {},
        todoStates: OrgTodoStatesWithIgnored.defaults,
        entries: entries,
      ),
    );
  }

  final done = <OrgHabit>[];

  @override
  Future<void> markHabitDone(OrgHabit habit) async => done.add(habit);
}

String _orgDay(DateTime day) =>
    '${day.toIso8601String().substring(0, 10)} '
    '${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1]}';

void main() {
  final today = DateTime.now();
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  final markup =
      '''
* TODO Run
SCHEDULED: <${_orgDay(today)} .+1d/3d>
:PROPERTIES:
:STYLE: habit
:END:
- State "DONE"       from "TODO"       [${_orgDay(yesterday)} 08:00]
* TODO Read
SCHEDULED: <${_orgDay(today)} .+1d>
:PROPERTIES:
:STYLE: habit
:END:
- State "DONE"       from "TODO"       [${_orgDay(today)} 08:00]
* Not a habit
<${_orgDay(today)}>
''';

  Future<FakeOrgFilesCubit> pumpPage(WidgetTester tester) async {
    final cubit = FakeOrgFilesCubit(parseEntries(OrgDocument.parse(markup)));
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<OrgFilesCubit>.value(value: cubit),
          BlocProvider(
            create: (_) =>
                SettingsCubit(inMemoryPreferences(), const AppSettings()),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: Scaffold(body: HabitsPage()),
        ),
      ),
    );
    return cubit;
  }

  testWidgets('shows only habits, due habits first', (tester) async {
    await pumpPage(tester);

    expect(find.text('Not a habit'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Run')).dy,
      lessThan(tester.getTopLeft(find.text('Read')).dy),
    );
  });

  testWidgets('shows the streak and the interval', (tester) async {
    await pumpPage(tester);

    expect(find.text('1 in a row · Every 1 to 3 days'), findsOne);
    expect(find.text('1 in a row · Every day'), findsOne);
  });

  testWidgets('the check button marks the habit as done', (tester) async {
    final cubit = await pumpPage(tester);

    await tester.tap(find.byTooltip('Mark as done today'));

    expect(cubit.done.single.title, 'Run');
  });

  testWidgets('a habit done today has no active check button', (tester) async {
    await pumpPage(tester);

    final button = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.check_circle),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}

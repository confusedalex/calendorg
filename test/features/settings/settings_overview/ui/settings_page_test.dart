import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/logging.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/agenda_files/ui/agenda_page.dart';
import 'package:calendorg/features/settings/settings_overview/ui/settings_page.dart';
import 'package:calendorg/features/settings/starting_day/ui/starting_day_dialog.dart';
import 'package:calendorg/features/settings/tags/ui/tags_page.dart';
import 'package:calendorg/features/settings/theme/model/theme_bloc.dart';
import 'package:calendorg/features/settings/theme/ui/theme_dialog.dart';
import 'package:calendorg/features/settings/todo_state/ui/todo_states_dialog.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/preferences.dart';

void main() {
  group('Settings Page Test', () {
    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider<OrgFilesRepository>(
          create: (context) => MockOrgFilesRepository(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => OrgFilesCubit(MockOrgFilesRepository()),
              ),
              BlocProvider(create: (context) => ThemeBloc()),
              BlocProvider(
                create: (context) => TagColorsCubit(inMemoryPreferences()),
              ),
              BlocProvider(
                create: (context) => TodoStatesCubit(inMemoryPreferences()),
              ),
              BlocProvider(
                create: (context) => StartingDayCubit(inMemoryPreferences()),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates:
                  CalendorgLocalizations.localizationsDelegates,
              supportedLocales: CalendorgLocalizations.supportedLocales,
              home: const Scaffold(body: SettingsPage()),
            ),
          ),
        ),
      );
    }

    group('Tag Colors', () {
      testWidgets('Find Tag Colors Button', (tester) async {
        await pumpWidget(tester);

        await tester.pumpAndSettle();

        expect(find.text('Tag Colors'), findsOneWidget);
      });

      testWidgets('Tapping Button open Dialog', (tester) async {
        await pumpWidget(tester);

        await tester.pumpAndSettle();
        await tester.tap(find.text('Tag Colors'));

        await tester.pumpAndSettle();

        expect(find.byType(TagsPage), findsOneWidget);
      });
    });
    testWidgets('Theme Dialog will open', (tester) async {
      await pumpWidget(tester);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));

      await tester.pumpAndSettle();

      expect(find.byType(ThemeDialog), findsOneWidget);
    });
    testWidgets('Agenda Files Page will open', (tester) async {
      await pumpWidget(tester);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Agenda Files'));

      await tester.pumpAndSettle();

      expect(find.byType(AgendaPage), findsOneWidget);
    });
    testWidgets('TODO States Dialog will open', (tester) async {
      await pumpWidget(tester);

      await tester.pumpAndSettle();
      await tester.tap(find.text('TODO States'));

      await tester.pumpAndSettle();

      expect(find.byType(TodoStatesDialog), findsOneWidget);
    });
    testWidgets('Starting Day Dialog will open', (tester) async {
      await pumpWidget(tester);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Starting Day of Week'));

      await tester.pumpAndSettle();

      expect(find.byType(StartingDateDialog), findsOneWidget);
    });
    testWidgets('Copy Log copies the log to the clipboard', (tester) async {
      setUpLogging();
      Logger('SettingsPageTest').warning('Error saving file list');
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );

      await pumpWidget(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy log'));
      await tester.pumpAndSettle();

      expect(copied, contains('SettingsPageTest: Error saving file list'));
      expect(find.text('Log copied to the clipboard'), findsOneWidget);
    });
  });
}

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {
  OrgFilesState get state =>
      OrgFilesState.initial().copyWith(status: OrgFilesStatus.success);
}

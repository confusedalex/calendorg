import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/files/services/org_files_repository.dart';
import 'package:calendorg/core/floating_action_button_cubit.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Settings Page Test', () {
    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => OrgFilesCubit(MockOrgFilesRepository()),
                ),
                BlocProvider(create: (context) => ThemeBloc()),
                BlocProvider(create: (context) => TagColorsCubit()),
                BlocProvider(create: (context) => TodoStatesCubit()),
                BlocProvider(create: (context) => StartingDayCubit()),
                BlocProvider(create: (context) => FloatingActionButtonCubit()),
              ],
              child: const SettingsPage(),
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
  });
}

class MockOrgFilesRepository extends Mock implements OrgFilesRepository {
  @override
  OrgFilesState get state =>
      OrgFilesState.initial().copyWith(status: OrgFilesStatus.success);

  @override
  Stream<OrgFilesState> get stream => Stream.value(state);
}

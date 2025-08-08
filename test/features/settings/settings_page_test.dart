import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/floating_action_button_cubit.dart';
import 'package:calendorg/core/starting_day_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_colors_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/agenda_files_dialog.dart';
import 'package:calendorg/features/settings/settings_page.dart';
import 'package:calendorg/features/settings/starting_day_dialog.dart';
import 'package:calendorg/features/settings/tags/tags_page.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:calendorg/features/settings/theme/theme_dialog.dart';
import 'package:calendorg/features/settings/todo_state/todo_states_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Settings Page Test',
    () {
      group('Tag Colors', () {
        testWidgets("Find Tag Colors Button", (tester) async {
          await tester.pumpWidget(BlocProvider(
            create: (context) => FloatingActionButtonCubit(),
            child: MaterialApp(home: Scaffold(body: SettingsPage())),
          ));

          await tester.pumpAndSettle();

          expect(find.text("Tag Colors"), findsOneWidget);
        });

        testWidgets("Tapping Button open Dialog", (tester) async {
          await tester.pumpWidget(MaterialApp(
              home: Scaffold(
                  body: MultiBlocProvider(providers: [
            BlocProvider(
              create: (context) => TagColorsCubit(),
            ),
            BlocProvider(create: (context) => FloatingActionButtonCubit())
          ], child: SettingsPage()))));

          await tester.pumpAndSettle();
          await tester.tap(find.text("Tag Colors"));

          await tester.pumpAndSettle();

          expect(find.byType(TagsPage), findsOneWidget);
        });
      });
      testWidgets("Theme Dialog will open", (tester) async {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(create: (context) => FloatingActionButtonCubit())
        ], child: SettingsPage()))));

        await tester.pumpAndSettle();
        await tester.tap(find.text("Theme"));

        await tester.pumpAndSettle();

        expect(find.byType(ThemeDialog), findsOneWidget);
      });
      testWidgets("Agenda Files Dialog will open", (tester) async {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => OrgFilesBloc(),
          ),
          BlocProvider(create: (context) => FloatingActionButtonCubit())
        ], child: SettingsPage()))));

        await tester.pumpAndSettle();
        await tester.tap(find.text("Agenda Files"));

        await tester.pumpAndSettle();

        expect(find.byType(AgendaFilesDialog), findsOneWidget);
      });
      testWidgets("TODO States Dialog will open", (tester) async {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => OrgFilesBloc(),
          ),
          BlocProvider(
            create: (context) => TodoStatesCubit(),
          ),
          BlocProvider(create: (context) => FloatingActionButtonCubit())
        ], child: SettingsPage()))));

        await tester.pumpAndSettle();
        await tester.tap(find.text("TODO states"));

        await tester.pumpAndSettle();

        expect(find.byType(TodoStatesDialog), findsOneWidget);
      });
      testWidgets("Starting Day Dialog will open", (tester) async {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => StartingDayCubit(),
          ),
          BlocProvider(create: (context) => FloatingActionButtonCubit())
        ], child: SettingsPage()))));

        await tester.pumpAndSettle();
        await tester.tap(find.text("Starting Day of week"));

        await tester.pumpAndSettle();

        expect(find.byType(StartingDateDialog), findsOneWidget);
      });
    },
  );
}

import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/features/settings/theme/bloc/theme_bloc.dart';
import 'package:calendorg/features/settings/theme/theme_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group(
    "Theme Dialog",
    () {
      late ThemeBloc bloc;

      setUpAll(() {
        registerFallbackValue(ThemeSwitchEvent(ThemeData.light()));
      });

      setUp(() {
        bloc = MockThemeBloc();

        whenListen(
          bloc,
          Stream<ThemeData>.value(ThemeData.dark()),
          initialState: ThemeData.dark(),
        );
      });

      Future<void> pumpWidgetToTester(dynamic tester) async {
        await tester.pumpWidget(MaterialApp(
            home: BlocProvider.value(
                value: bloc, child: Scaffold(body: ThemeDialog()))));
      }

      group("find themes", () {
        testWidgets('Find light theme', (tester) async {
          await pumpWidgetToTester(tester);
          expect(
              find.widgetWithText(RadioListTile<ThemeData>, "light"), findsOne);
        });

        testWidgets('Find dark theme', (tester) async {
          await pumpWidgetToTester(tester);
          expect(find.widgetWithText(RadioListTile<ThemeData>, "dark"), findsOne);
        });

        testWidgets('Find green theme', (tester) async {
          await pumpWidgetToTester(tester);
          expect(find.widgetWithText(RadioListTile<ThemeData>, "green"), findsOne);
        });
      });

      group("theme switching calls correct event", () {
        testWidgets('Switching to light theme works', (tester) async {
          await pumpWidgetToTester(tester);

          await tester.tap(find.byKey(Key("ThemeRadioLightTheme")));

          await tester.pumpAndSettle();

          verify(() => bloc.add(any())).called(1);
        });
      });
    },
  );
}

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeData>
    implements ThemeBloc {}

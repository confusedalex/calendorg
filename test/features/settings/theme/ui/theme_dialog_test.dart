import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/features/settings/theme/model/theme_bloc.dart';
import 'package:calendorg/features/settings/theme/ui/theme_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Theme Dialog', () {
    late ThemeBloc bloc;

    setUpAll(() {
      registerFallbackValue(ThemeSwitchEvent(ThemeMode.light));
    });

    setUp(() {
      bloc = MockThemeBloc();

      whenListen(
        bloc,
        Stream<ThemeMode>.value(ThemeMode.dark),
        initialState: ThemeMode.dark,
      );
    });

    Future<void> pumpWidgetToTester(dynamic tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(body: ThemeDialog()),
          ),
        ),
      );
    }

    group('find themes', () {
      testWidgets('Find light theme', (tester) async {
        await pumpWidgetToTester(tester);
        expect(
          find.widgetWithText(RadioListTile<ThemeMode>, 'light'),
          findsOne,
        );
      });

      testWidgets('Find dark theme', (tester) async {
        await pumpWidgetToTester(tester);
        expect(find.widgetWithText(RadioListTile<ThemeMode>, 'dark'), findsOne);
      });

      testWidgets('Find automatic theme', (tester) async {
        await pumpWidgetToTester(tester);
        expect(
          find.widgetWithText(RadioListTile<ThemeMode>, 'automatic'),
          findsOne,
        );
      });
    });

    group('theme switching calls correct event', () {
      testWidgets('Switching to light theme works', (tester) async {
        await pumpWidgetToTester(tester);

        await tester.tap(find.byKey(Key('ThemeRadioLightTheme')));

        await tester.pumpAndSettle();

        verify(() => bloc.add(any())).called(1);
      });
    });
  });
}

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeMode>
    implements ThemeBloc {}

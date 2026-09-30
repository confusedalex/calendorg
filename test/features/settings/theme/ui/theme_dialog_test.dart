import 'package:calendorg/core/settings/app_settings.dart';
import 'package:calendorg/core/settings/settings_cubit.dart';
import 'package:calendorg/features/settings/theme/ui/theme_dialog.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/preferences.dart';

void main() {
  group('Theme Dialog', () {
    late SettingsCubit cubit;

    setUp(() {
      cubit = SettingsCubit(
        inMemoryPreferences(),
        const AppSettings(themeMode: ThemeMode.dark),
      );
    });

    Future<void> pumpWidgetToTester(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: ThemeDialog()),
          ),
        ),
      );
    }

    group('find themes', () {
      testWidgets('Find light theme', (tester) async {
        await pumpWidgetToTester(tester);
        expect(
          find.widgetWithText(RadioListTile<ThemeMode>, 'Light'),
          findsOne,
        );
      });

      testWidgets('Find dark theme', (tester) async {
        await pumpWidgetToTester(tester);
        expect(find.widgetWithText(RadioListTile<ThemeMode>, 'Dark'), findsOne);
      });

      testWidgets('Find automatic theme', (tester) async {
        await pumpWidgetToTester(tester);
        expect(
          find.widgetWithText(RadioListTile<ThemeMode>, 'Automatic'),
          findsOne,
        );
      });
    });

    testWidgets('Switching to light theme works', (tester) async {
      await pumpWidgetToTester(tester);

      await tester.tap(find.byKey(const Key('ThemeRadioLightTheme')));
      await tester.pumpAndSettle();

      expect(cubit.state.themeMode, ThemeMode.light);
    });
  });
}

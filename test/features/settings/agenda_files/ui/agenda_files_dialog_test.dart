import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/features/settings/agenda_files/ui/agenda_files_dialog.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../settings_overview/ui/settings_page_test.dart';

void main() {
  group('Agenda Files Dialog', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    Future<void> pumpWidgetToTester(dynamic tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
          supportedLocales: CalendorgLocalizations.supportedLocales,

          home: Scaffold(
            body: BlocProvider(
              create: (context) => OrgFilesCubit(MockOrgFilesRepository()),
              child: AgendaFilesDialog(),
            ),
          ),
        ),
      );
    }

    testWidgets('should find "select file" button', (tester) async {
      await pumpWidgetToTester(tester);

      expect(find.text('select file'), findsOneWidget);
    });

    testWidgets('should find "create file" button', (tester) async {
      await pumpWidgetToTester(tester);

      expect(find.text('create file'), findsOneWidget);
    });
  });
}

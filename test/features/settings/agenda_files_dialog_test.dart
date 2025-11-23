import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/features/settings/agenda_files_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group("Agenda Files Dialog", () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    Future<void> pumpWidgetToTester(dynamic tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (context) => OrgFilesBloc(),
              child: AgendaFilesDialog(),
            ),
          ),
        ),
      );
    }

    testWidgets('should find add button', (tester) async {
      await pumpWidgetToTester(tester);

      expect(find.text("add"), findsOneWidget);
    });
  });
}

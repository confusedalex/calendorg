import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/entities/todo_states/todo_states.dart';
import 'package:calendorg/features/settings/todo_state/model/todo_state_add_dialog_cubit.dart';
import 'package:calendorg/features/settings/todo_state/ui/todo_state_add_dialog.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/preferences.dart';

void main() {
  Future<void> pumpWidgetToTester(dynamic tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
        supportedLocales: CalendorgLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => TodoStatesCubit(inMemoryPreferences()),
              ),
              BlocProvider(create: (context) => TodoStateAddDialogCubit()),
            ],
            child: const TodoStateAddDialog(status: TodoStatus.todo),
          ),
        ),
      ),
    );
  }

  group('todo_state_add_dialog_test', () {
    testWidgets('cancel button closes dialog', (tester) async {
      await pumpWidgetToTester(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(TodoStateAddDialog), findsNothing);
    });
  });
}

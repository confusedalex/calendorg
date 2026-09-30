import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/entities/todo_states/todo_states.dart';
import 'package:calendorg/features/settings/todo_state/ui/todo_state_add_dialog.dart';
import 'package:calendorg/l10n/calendorg_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/preferences.dart';

void main() {
  late TodoStatesCubit cubit;

  Future<void> pumpWidgetToTester(WidgetTester tester) async {
    cubit = TodoStatesCubit(inMemoryPreferences());
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: CalendorgLocalizations.localizationsDelegates,
        supportedLocales: CalendorgLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
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

    testWidgets('save adds the state', (tester) async {
      await pumpWidgetToTester(tester);

      await tester.enterText(find.byType(TextFormField), 'WAIT');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(cubit.state.todo, contains('WAIT'));
      expect(find.byType(TodoStateAddDialog), findsNothing);
    });

    testWidgets('save rejects a state that exists', (tester) async {
      await pumpWidgetToTester(tester);

      await tester.enterText(find.byType(TextFormField), 'TODO');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(cubit.state.todo, ['TODO']);
      expect(find.byType(TodoStateAddDialog), findsOne);
    });
  });
}

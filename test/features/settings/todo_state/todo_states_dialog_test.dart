import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/features/settings/todo_state/todo_state_add_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calendorg/features/settings/todo_state/todo_states_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pumpWidgetToTester(dynamic tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => TodoStatesCubit()),
              BlocProvider(create: (context) => OrgFilesBloc()),
            ],
            child: TodoStatesDialog(),
          ),
        ),
      ),
    );
  }

  group("todo_states_dialog_test", () {
    group("finding chips", () {
      testWidgets('should find one todo chip', (tester) async {
        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        final todoChip = find.byWidgetPredicate(
          (widget) => widget is Chip && (widget.label as Text).data == "TODO",
        );

        expect(todoChip, findsOne);
      });
      testWidgets('should find one done chip', (tester) async {
        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        final doneChip = find.byWidgetPredicate(
          (widget) => widget is Chip && (widget.label as Text).data == "DONE",
        );

        expect(doneChip, findsOne);
      });
    });
    testWidgets(
      'tapping on close button at done chip should make it disappear',
      (tester) async {
        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        // We just press the last close button, because when using the
        // default todo values, there should only be two, and because of hard
        // coded ordering, the done will be the second
        await tester.tap(find.byIcon(Icons.close).last);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Chip && (widget.label as Text).data == "DONE",
          ),
          findsNothing,
        );
      },
    );
    testWidgets(
      'tapping on close button at todo chip should make it disappear',
      (tester) async {
        await pumpWidgetToTester(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Chip && (widget.label as Text).data == "TODO",
          ),
          findsNothing,
        );
      },
    );
    testWidgets('tapping on first plus button will open dialog', (
      tester,
    ) async {
      await pumpWidgetToTester(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.byType(TodoStateAddDialog), findsOne);
    });
    testWidgets('tapping on second plus button will open dialog', (
      tester,
    ) async {
      await pumpWidgetToTester(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pumpAndSettle();

      expect(find.byType(TodoStateAddDialog), findsOne);
    });
  });
}

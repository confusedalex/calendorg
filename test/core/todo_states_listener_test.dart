import 'package:calendorg/core/files/cubit/org_files_cubit.dart';
import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/core/todo_states_listener.dart';
import 'package:calendorg/entities/todo_states/todo_states.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/preferences.dart';

class MockOrgFilesCubit extends Mock implements OrgFilesCubit {}

void main() {
  setUpAll(() => registerFallbackValue(OrgTodoStatesWithIgnored.defaults));

  testWidgets('sends changed states to OrgFilesCubit', (tester) async {
    final todoStatesCubit = TodoStatesCubit(inMemoryPreferences());
    final orgFilesCubit = MockOrgFilesCubit();
    when(() => orgFilesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => orgFilesCubit.changeTodoStates(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: todoStatesCubit),
          BlocProvider<OrgFilesCubit>.value(value: orgFilesCubit),
        ],
        child: TodoStatesListener(child: const SizedBox()),
      ),
    );

    await tester.runAsync(
      () => todoStatesCubit.addTodo(TodoStatus.ignored, 'LATER'),
    );
    await tester.pump();

    verify(
      () => orgFilesCubit.changeTodoStates(
        const OrgTodoStatesWithIgnored(
          todo: ['TODO'],
          done: ['DONE'],
          ignored: ['LATER'],
        ),
      ),
    ).called(1);
  });
}

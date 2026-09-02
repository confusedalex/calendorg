import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:calendorg/entities/todo_states/todo_states.dart';
import 'package:test/test.dart';

import '../helpers/preferences.dart';

void main() {
  group('todo_states_cubit_test', () {
    group('adding states', () {
      test('adding TODO state works', () async {
        final cubit = TodoStatesCubit(inMemoryPreferences());

        await cubit.addTodo(TodoStatus.todo, 'TOCALL');

        expect(cubit.state.todo, contains('TOCALL'));
      });

      test('adding DONE state works', () async {
        final cubit = TodoStatesCubit(inMemoryPreferences());

        await Future<void>.delayed(const Duration(milliseconds: 10));

        await cubit.addTodo(TodoStatus.done, 'KILL');

        expect(cubit.state.done, contains('KILL'));
      });
    });
    group('removing states', () {
      test('removing TODO state works', () async {
        final cubit = TodoStatesCubit(inMemoryPreferences());

        await cubit.addTodo(TodoStatus.todo, 'TOCALL');
        await cubit.removeTodo(TodoStatus.todo, 'TOCALL');

        expect(cubit.state.todo, isNot(contains('TOCALL')));
      });

      test('removing DONE state works', () async {
        final cubit = TodoStatesCubit(inMemoryPreferences());

        await cubit.addTodo(TodoStatus.done, 'KILL');
        await cubit.removeTodo(TodoStatus.done, 'KILL');

        expect(cubit.state.done, isNot(contains('KILL')));
      });
    });
    group('loading from sharedPreferences', () {
      Future<TodoStatesCubit> getCubit() async {
        final cubit = TodoStatesCubit(
          inMemoryPreferences({
            'todoStates': '["TOREAD"]',
            'doneStates': '["COMPLETED"]',
          }),
        );
        await cubit.loadFromPrefs();
        return cubit;
      }

      test('loading TODO state from sharedPreferences works', () async {
        final cubit = await getCubit();

        expect(cubit.state.todo, contains('TOREAD'));
      });
      test('loading DONE state from sharedPreferences works', () async {
        final cubit = await getCubit();

        expect(cubit.state.done, contains('COMPLETED'));
      });
    });
  });
}

import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  group('todo_states_cubit_test', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('adding states', () {
      test('adding TODO state works', () async {
        final cubit = TodoStatesCubit();

        await cubit.addTodo('todo', 'TOCALL');

        expect(cubit.state.todo, contains('TOCALL'));
      });

      test('adding DONE state works', () async {
        final cubit = TodoStatesCubit();

        await Future<void>.delayed(const Duration(milliseconds: 10));

        await cubit.addTodo('done', 'KILL');

        expect(cubit.state.done, contains('KILL'));
      });
    });
    group('removing states', () {
      test('removing TODO state works', () async {
        final cubit = TodoStatesCubit();

        await cubit.addTodo('todo', 'TOCALL');
        await cubit.removeTodo('todo', 'TOCALL');

        expect(cubit.state.todo, isNot(contains('TOCALL')));
      });

      test('removing DONE state works', () async {
        final cubit = TodoStatesCubit();

        await cubit.addTodo('done', 'KILL');
        await cubit.removeTodo('done', 'KILL');

        expect(cubit.state.done, isNot(contains('KILL')));
      });
    });
    group('loading from sharedPreferences', () {
      Future<TodoStatesCubit> getCubit() async {
        SharedPreferences.setMockInitialValues({
          'todoStates': '["TOREAD"]',
          'doneStates': '["COMPLETED"]',
        });

        final cubit = TodoStatesCubit()..loadFromPrefs();

        await Future.delayed(const Duration(milliseconds: 10));
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

import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('states with the same keywords are equal', () {
    // A second instance, so that the test checks ==, not identity.
    // ignore: use_named_constants
    const states = OrgTodoStatesWithIgnored(
      todo: ['TODO'],
      done: ['DONE'],
      ignored: [],
    );

    expect(states, OrgTodoStatesWithIgnored.defaults);
    expect(states.hashCode, OrgTodoStatesWithIgnored.defaults.hashCode);
  });

  test('states with other keywords are not equal', () {
    const states = OrgTodoStatesWithIgnored(
      todo: ['TODO'],
      done: ['DONE'],
      ignored: ['LATER'],
    );

    expect(states, isNot(OrgTodoStatesWithIgnored.defaults));
  });
}

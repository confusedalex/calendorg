import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:org_parser/org_parser.dart';

import 'todo_states.dart';

@immutable
class OrgTodoStatesWithIgnored {
  final List<String> todo;
  final List<String> done;
  final List<String> ignored;
  OrgTodoStates get todoStates =>
      OrgTodoStates(todo: [...todo, ...ignored], done: done);

  String get cacheKey =>
      [todo, done, ignored].map((states) => states.join(',')).join('|');

  const OrgTodoStatesWithIgnored({
    required this.todo,
    required this.done,
    required this.ignored,
  });

  static const defaults = OrgTodoStatesWithIgnored(
    todo: ['TODO'],
    done: ['DONE'],
    ignored: [],
  );

  List<String> statesOf(TodoStatus status) => switch (status) {
    TodoStatus.todo => todo,
    TodoStatus.done => done,
    TodoStatus.ignored => ignored,
  };

  OrgTodoStatesWithIgnored withStates(TodoStatus status, List<String> states) =>
      switch (status) {
        TodoStatus.todo => OrgTodoStatesWithIgnored(
          todo: states,
          done: done,
          ignored: ignored,
        ),
        TodoStatus.done => OrgTodoStatesWithIgnored(
          todo: todo,
          done: states,
          ignored: ignored,
        ),
        TodoStatus.ignored => OrgTodoStatesWithIgnored(
          todo: todo,
          done: done,
          ignored: states,
        ),
      };

  static const _lists = ListEquality<String>();

  @override
  bool operator ==(Object other) =>
      other is OrgTodoStatesWithIgnored &&
      _lists.equals(todo, other.todo) &&
      _lists.equals(done, other.done) &&
      _lists.equals(ignored, other.ignored);

  @override
  int get hashCode =>
      Object.hash(_lists.hash(todo), _lists.hash(done), _lists.hash(ignored));
}

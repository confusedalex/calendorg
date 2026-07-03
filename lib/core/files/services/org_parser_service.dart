import 'dart:isolate';

import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:org_parser/org_parser.dart';

class OrgParserService {
  late OrgTodoStatesWithIgnored _currentTodoStates;

  OrgParserService([OrgTodoStatesWithIgnored? todoStates]) {
    _currentTodoStates =
        todoStates ??
        OrgTodoStatesWithIgnored(todo: ["TODO"], done: ["DONE"], ignored: []);
  }

  Future<OrgDocument> parseContentInBackground(String content) {
    final todoStates = _currentTodoStates.todoStates;
    return Isolate.run(
      () => _parseOrgDocument(content, todoStates.todo, todoStates.done),
    );
  }

  void invalidateCache(OrgTodoStatesWithIgnored newStates) {
    _currentTodoStates = newStates;
  }
}

OrgDocument _parseOrgDocument(
  String content,
  List<String> todoStates,
  List<String> doneStates,
) {
  final parser = OrgParserDefinition(
    todoStates: [OrgTodoStates(todo: todoStates, done: doneStates)],
  ).build();
  final parseResult = parser.parse(content);
  return parseResult.value as OrgDocument;
}

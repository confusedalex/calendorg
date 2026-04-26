import 'package:calendorg/core/todo_states_cubit.dart';
import 'package:org_parser/org_parser.dart';
import 'package:petitparser/petitparser.dart';

class OrgParserService {
  Parser? _parser;
  late OrgTodoStatesWithIgnored _currentTodoStates;

  OrgParserService([OrgTodoStatesWithIgnored? todoStates]) {
    _currentTodoStates = todoStates ??
        OrgTodoStatesWithIgnored(
          todo: ["TODO"],
          done: ["DONE"],
          ignored: [],
        );
  }

  Parser getParser() {
    return _parser ??= OrgParserDefinition(
      todoStates: [_currentTodoStates.todoStates],
    ).build();
  }

  void invalidateCache(OrgTodoStatesWithIgnored newStates) {
    _currentTodoStates = newStates;
    _parser = null;
  }
}

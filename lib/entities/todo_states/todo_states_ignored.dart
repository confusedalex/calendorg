import 'package:org_parser/org_parser.dart';

class OrgTodoStatesWithIgnored {
  final List<String> todo;
  final List<String> done;
  final List<String> ignored;
  OrgTodoStates get todoStates =>
      OrgTodoStates(todo: [...todo, ...ignored], done: done);

  OrgTodoStatesWithIgnored({
    required this.todo,
    required this.done,
    required this.ignored,
  });
}

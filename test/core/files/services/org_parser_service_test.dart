import 'package:calendorg/core/files/services/org_parser_service.dart';
import 'package:calendorg/entities/todo_states/todo_states_ignored.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses with the current todo states', () async {
    final service = await OrgParserService.spawn();
    service.todoStates = const OrgTodoStatesWithIgnored(
      todo: ['NEXT'],
      done: ['DONE'],
      ignored: [],
    );

    final document = await service.parseContentInBackground('* NEXT Call');

    expect(document.sections.single.headline.keyword?.value, 'NEXT');
  });
}

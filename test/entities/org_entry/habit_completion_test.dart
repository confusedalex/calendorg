import 'package:calendorg/entities/org_entry/habit_completion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

final _parser = OrgParserDefinition(
  todoStates: [
    OrgTodoStates(todo: ['TODO', 'NEXT'], done: ['DONE']),
  ],
).build();

String complete(String markup, {DateTime? now}) {
  final document = _parser.parse(markup).value as OrgDocument;
  final section = document.sections.first;
  final done = completeHabit(
    section,
    doneKeyword: 'DONE',
    now: now ?? DateTime(2026, 10, 7, 8, 12),
  );
  return (document.editNode(section)!.replace(done).commit() as OrgDocument)
      .toMarkup();
}

void main() {
  group('completeHabit', () {
    test('adds the note to the LOGBOOK drawer and moves the schedule', () {
      expect(
        complete('''
* TODO Run
SCHEDULED: <2026-10-06 Tue .+1d/3d>
:PROPERTIES:
:STYLE:    habit
:LAST_REPEAT: [2026-10-05 Mon 09:00]
:END:
:LOGBOOK:
- State "DONE"       from "TODO"       [2026-10-05 Mon 09:00]
:END:
Some text
** Child
'''),
        '''
* TODO Run
SCHEDULED: <2026-10-08 Thu .+1d/3d>
:PROPERTIES:
:STYLE:    habit
:LAST_REPEAT: [2026-10-07 Wed 08:12]
:END:
:LOGBOOK:
- State "DONE"       from "TODO"       [2026-10-07 Wed 08:12]
- State "DONE"       from "TODO"       [2026-10-05 Mon 09:00]
:END:
Some text
** Child
''',
      );
    });

    test('adds a note list after the drawer without a LOGBOOK drawer', () {
      expect(
        complete('''
* TODO Read
  SCHEDULED: <2026-10-01 Thu +1w>
  :PROPERTIES:
  :STYLE: habit
  :END:
'''),
        '''
* TODO Read
  SCHEDULED: <2026-10-08 Thu +1w>
  :PROPERTIES:
  :STYLE: habit
  :LAST_REPEAT: [2026-10-07 Wed 08:12]
  :END:
  - State "DONE"       from "TODO"       [2026-10-07 Wed 08:12]
''',
      );
    });

    test('moves a ++ repeater past today', () {
      expect(
        complete('''
* TODO Stretch
SCHEDULED: <2026-10-01 Thu ++1d>
:PROPERTIES:
:STYLE: habit
:END:
'''),
        contains('SCHEDULED: <2026-10-08 Thu ++1d>'),
      );
    });

    test('keeps the keyword of the headline', () {
      expect(
        complete('''
* NEXT Stretch
SCHEDULED: <2026-10-01 Thu .+1d>
:PROPERTIES:
:STYLE: habit
:END:
'''),
        allOf(startsWith('* NEXT Stretch'), contains('from "NEXT"')),
      );
    });
  });
}

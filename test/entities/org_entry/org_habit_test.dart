import 'package:calendorg/entities/occurrence/occurrence_generator.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

import '../../helpers/entries.dart';

OrgEntry entryOf(String markup, {Set<String> done = const {'DONE'}}) =>
    parseEntries(OrgDocument.parse(markup), done: done).single;

OrgHabit habit(String repeater, List<String> doneDays, {String next = ''}) =>
    entryOf('''
* TODO Habit
SCHEDULED: <${next.isEmpty ? '2026-10-08 Thu' : next} $repeater>
:PROPERTIES:
:STYLE: habit
:END:
${doneDays.map((day) => '- State "DONE" from "TODO" [$day]').join('\n')}
''')
        as OrgHabit;

void main() {
  group('parsing', () {
    test('a section with STYLE habit and a repeater is a habit', () {
      expect(habit('.+1d', []), isA<OrgHabit>());
    });

    test('a section without a repeater is no habit', () {
      final entry = entryOf('''
* TODO Habit
SCHEDULED: <2026-10-08 Thu>
:PROPERTIES:
:STYLE: habit
:END:
''');
      expect(entry, isNot(isA<OrgHabit>()));
    });

    test('a section without STYLE habit is no habit', () {
      final entry = entryOf('''
* TODO Rent
SCHEDULED: <2026-10-08 Thu +1m>
''');
      expect(entry, isNot(isA<OrgHabit>()));
    });

    test('reads completions from the LOGBOOK drawer and the body', () {
      final entry =
          entryOf('''
* TODO Habit
SCHEDULED: <2026-10-08 Thu .+1d>
:PROPERTIES:
:STYLE: habit
:END:
:LOGBOOK:
- State "DONE"       from "TODO"       [2026-10-06 Tue 09:00]
- State "DONE"       from "TODO"       [2026-10-04 Sun]
- Note taken on [2026-10-03 Sat 10:00]
:END:
- State "DONE"       from "TODO"       [2026-10-01 Thu 08:00]
- State "DONE"       from "TODO"       [2026-10-01 Thu 20:00]
** Child
- State "DONE"       from "TODO"       [2026-09-01 Tue 08:00]
''')
              as OrgHabit;

      expect(entry.completions, [20261001, 20261004, 20261006]);
    });

    test('counts only done states', () {
      final entry =
          entryOf(
                '''
* TODO Habit
SCHEDULED: <2026-10-08 Thu .+1d>
:PROPERTIES:
:STYLE: habit
:END:
- State "SKIP"       from "TODO"       [2026-10-06 Tue 09:00]
- State "FINISHED"   from "TODO"       [2026-10-05 Mon 09:00]
- State "DONE"       from "TODO"       [2026-10-04 Sun 09:00]
''',
                done: {'FINISHED'},
              )
              as OrgHabit;

      expect(entry.completions, [20261005]);
    });
  });

  group('intervals', () {
    test('without a maximum, both intervals are the repeater', () {
      final entry = habit('.+2d', []);
      expect((entry.minDays, entry.maxDays), (2, 2));
    });

    test('reads the maximum after the slash', () {
      final entry = habit('.+1d/3d', []);
      expect((entry.minDays, entry.maxDays), (1, 3));
    });

    test('converts weeks to days', () {
      final entry = habit('.+1w/2w', []);
      expect((entry.minDays, entry.maxDays), (7, 14));
    });
  });

  group('statusOn', () {
    // Done on Oct 1 and Oct 3. Next on Oct 4.
    final entry = habit('.+1d/3d', [
      '2026-10-01 Thu',
      '2026-10-03 Sat',
    ], next: '2026-10-04 Sun');

    test('is early before the first completion', () {
      expect(entry.statusOn(20260930), HabitStatus.early);
      expect(entry.statusOn(20261001), HabitStatus.early);
    });

    test('uses the completion before the day', () {
      expect(entry.statusOn(20261002), HabitStatus.due);
      expect(entry.statusOn(20261003), HabitStatus.due);
    });

    test('uses the schedule after the last completion', () {
      expect(entry.statusOn(20261004), HabitStatus.due);
      expect(entry.statusOn(20261005), HabitStatus.due);
      expect(entry.statusOn(20261006), HabitStatus.lastDay);
      expect(entry.statusOn(20261007), HabitStatus.overdue);
    });

    test('uses the schedule without completions', () {
      final fresh = habit('.+2d', [], next: '2026-10-04 Sun');
      expect(fresh.statusOn(20261003), HabitStatus.early);
      expect(fresh.statusOn(20261004), HabitStatus.lastDay);
      expect(fresh.statusOn(20261005), HabitStatus.overdue);
    });
  });

  group('streak', () {
    test('counts the completions in a row', () {
      final entry = habit('.+1d', [
        '2026-10-01 Thu',
        '2026-10-03 Sat',
        '2026-10-04 Sun',
        '2026-10-05 Mon',
      ]);
      expect(entry.streak(20261005), 3);
      expect(entry.streak(20261006), 3);
    });

    test('is 0 when the habit is overdue', () {
      final entry = habit('.+1d', ['2026-10-04 Sun', '2026-10-05 Mon']);
      expect(entry.streak(20261007), 0);
    });

    test('allows gaps up to the maximum interval', () {
      final entry = habit('.+1d/3d', [
        '2026-10-01 Thu',
        '2026-10-04 Sun',
        '2026-10-06 Tue',
      ]);
      expect(entry.streak(20261008), 3);
    });

    test('ignores completions after the day', () {
      final entry = habit('.+1d', ['2026-10-04 Sun', '2026-10-05 Mon']);
      expect(entry.streak(20261004), 1);
    });
  });

  test('isDue is true from the next day until a completion', () {
    final entry = habit('.+1d', ['2026-10-05 Mon'], next: '2026-10-06 Tue');
    expect(entry.isDue(20261005), isFalse);
    expect(entry.isDue(20261006), isTrue);
    expect(entry.isDue(20261009), isTrue);
  });

  test('the calendar shows a habit only on its next day', () {
    final entry = habit('.+1d', [], next: '2026-10-06 Tue');
    final days = occurrencesFor(
      entry,
      DateTimeRange(start: DateTime(2026, 10), end: DateTime(2026, 10, 31)),
    ).map((occurrence) => occurrence.date);

    expect(days, [DateTime(2026, 10, 6)]);
  });
}

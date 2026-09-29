import 'package:calendorg/entities/occurrence/occurrence.dart';
import 'package:calendorg/entities/occurrence/occurrence_generator.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

import '../../helpers/entries.dart';

OrgEntry _entry(String markup) => parseEntries(OrgDocument.parse(markup)).first;

List<DateTime> _dates(OrgEntry entry, DateTime start, DateTime end) =>
    occurrencesFor(
      entry,
      DateTimeRange(start: start, end: end),
    ).map((occurrence) => occurrence.date).toList();

void main() {
  const markup = '''
* Heading 1
** orgmode meetup <2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
''';
  final entry = _entry(markup);

  group('occurrencesFor', () {
    test('gives one occurrence per day of every timestamp', () {
      expect(_dates(entry, DateTime(2025, 5), DateTime(2025, 5, 31)), [
        DateTime(2025, 5),
        DateTime(2025, 5, 2),
        DateTime(2025, 5, 3),
        DateTime(2025, 5, 5),
        DateTime(2025, 5, 6),
        DateTime(2025, 5, 8),
        DateTime(2025, 5, 15),
        DateTime(2025, 5, 28),
      ]);
    });

    test('gives nothing for days without a timestamp', () {
      for (final day in [
        DateTime(2015, 5, 5),
        DateTime(2024, 4, 30),
        DateTime(2024, 5, 8),
        DateTime(2025),
        DateTime(2025, 5, 4),
        DateTime(2025, 5, 25),
      ]) {
        expect(_dates(entry, day, day), isEmpty, reason: '$day');
      }
    });

    test('matches a day for any time of that day', () {
      expect(
        _dates(entry, DateTime(2025, 5, 3, 23, 59, 59), DateTime(2025, 5, 4)),
        [DateTime(2025, 5, 3)],
      );
    });

    test('clips a date range to the window', () {
      expect(_dates(entry, DateTime(2025, 5, 2), DateTime(2025, 5, 2)), [
        DateTime(2025, 5, 2),
      ]);
    });

    test('keeps the timestamp and kind of each occurrence', () {
      final occurrences = occurrencesFor(
        entry,
        DateTimeRange(start: DateTime(2025, 5, 8), end: DateTime(2025, 5, 8)),
      );
      expect(occurrences, hasLength(1));
      expect(occurrences.single.kind, OccurrenceKind.timestamp);
      expect(occurrences.single.timestamp, isA<OrgTimeRangeTimestamp>());
    });

    test('marks scheduled and deadline occurrences', () {
      final planned = _entry('''
* TODO Task
SCHEDULED: <2025-05-02> DEADLINE: <2025-05-04>
''');
      final occurrences = occurrencesFor(
        planned,
        DateTimeRange(start: DateTime(2025, 5), end: DateTime(2025, 5, 31)),
      );
      expect(
        occurrences.map((occurrence) => (occurrence.date, occurrence.kind)),
        [
          (DateTime(2025, 5, 2), OccurrenceKind.scheduled),
          (DateTime(2025, 5, 4), OccurrenceKind.deadline),
        ],
      );
    });
  });
}

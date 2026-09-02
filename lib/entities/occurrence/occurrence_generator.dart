import 'package:flutter/material.dart' show DateTimeRange;
import 'package:org_parser/org_parser.dart';

import '../org_entry/org_entry.dart';
import 'occurrence.dart';

typedef DayKey = int;

DayKey dayKeyOf(DateTime date) =>
    date.year * 10000 + date.month * 100 + date.day;

DayKey _dayKeyOfOrgDate(OrgDate date) =>
    int.parse(date.year) * 10000 +
    int.parse(date.month) * 100 +
    int.parse(date.day);

DateTime _dateOfDayKey(DayKey key) =>
    DateTime(key ~/ 10000, key ~/ 100 % 100, key % 100);

/// The day of a timestamp that is not a date range.
DayKey? _dayKeyOfTimestamp(OrgTimestamp timestamp) => switch (timestamp) {
  OrgSimpleTimestamp() => _dayKeyOfOrgDate(timestamp.date),
  OrgTimeRangeTimestamp() => _dayKeyOfOrgDate(timestamp.date),
  OrgDateRangeTimestamp() => null,
};

List<Occurrence> occurrencesFor(OrgEntry entry, DateTimeRange window) =>
    occurrencesForInDays(entry, dayKeyOf(window.start), dayKeyOf(window.end));

/// Same as [occurrencesFor], but with the window already reduced to day keys.
/// The caller does that once for all entries.
List<Occurrence> occurrencesForInDays(
  OrgEntry entry,
  DayKey windowStart,
  DayKey windowEnd,
) {
  final occurrences = <Occurrence>[];

  void addOccurrences(OrgTimestamp? timestamp, OccurrenceKind kind) {
    if (timestamp == null) return;
    for (final key in _daysInWindow(timestamp, windowStart, windowEnd)) {
      occurrences.add(
        Occurrence(
          entry: entry,
          date: _dateOfDayKey(key),
          kind: kind,
          timestamp: timestamp,
        ),
      );
    }
  }

  for (final timestamp in entry.timestamps) {
    addOccurrences(timestamp, OccurrenceKind.timestamp);
  }
  addOccurrences(
    entry.scheduled?.value as OrgTimestamp?,
    OccurrenceKind.scheduled,
  );
  addOccurrences(
    entry.deadline?.value as OrgTimestamp?,
    OccurrenceKind.deadline,
  );

  occurrences.sort((a, b) => a.date.compareTo(b.date));
  return occurrences;
}

List<DayKey> _daysInWindow(
  OrgTimestamp timestamp,
  DayKey windowStart,
  DayKey windowEnd,
) {
  if (timestamp is! OrgDateRangeTimestamp) {
    final key = _dayKeyOfTimestamp(timestamp)!;
    if (key < windowStart || key > windowEnd) return const [];
    return [key];
  }

  final startDateKey = _dayKeyOfTimestamp(timestamp.start);
  final endDateKey = _dayKeyOfTimestamp(timestamp.end);
  if (startDateKey == null || endDateKey == null) return const [];

  final rangeStart = startDateKey < endDateKey ? startDateKey : endDateKey;
  final rangeEnd = startDateKey < endDateKey ? endDateKey : startDateKey;
  if (rangeEnd < windowStart || rangeStart > windowEnd) return const [];

  var current = _dateOfDayKey(
    rangeStart < windowStart ? windowStart : rangeStart,
  );
  final last = rangeEnd > windowEnd ? windowEnd : rangeEnd;

  final days = <DayKey>[];
  for (var key = dayKeyOf(current); key <= last; key = dayKeyOf(current)) {
    days.add(key);
    current = DateTime(current.year, current.month, current.day + 1);
  }
  return days;
}

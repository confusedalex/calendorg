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

DayKey? _dayKeyOfTimestamp(OrgTimestamp timestamp) => switch (timestamp) {
  OrgSimpleTimestamp() => _dayKeyOfOrgDate(timestamp.date),
  OrgTimeRangeTimestamp() => _dayKeyOfOrgDate(timestamp.date),
  OrgDateRangeTimestamp() => null,
};

OrgTimestampModifier? _repeaterOf(OrgTimestamp timestamp) {
  final modifiers = switch (timestamp) {
    OrgSimpleTimestamp() => timestamp.modifiers,
    OrgTimeRangeTimestamp() => timestamp.modifiers,
    // Org mode doesn't use modifiers on range timestamps
    OrgDateRangeTimestamp() => const <OrgTimestampModifier>[],
  };
  return modifiers.where((modifier) => modifier.isRepeater).firstOrNull;
}

List<Occurrence> occurrencesFor(OrgEntry entry, DateTimeRange window) =>
    occurrencesForInDays(entry, dayKeyOf(window.start), dayKeyOf(window.end));

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
    final repeater = _repeaterOf(timestamp);
    final step = int.tryParse(repeater?.value ?? '') ?? 0;
    if (repeater == null || step <= 0) {
      if (key < windowStart || key > windowEnd) return const [];
      return [key];
    }

    final base = _dateOfDayKey(key);
    final days = <DayKey>[];
    for (var n = 0; ; n++) {
      final day = dayKeyOf(base.addModifier(n * step, repeater.unit));
      if (day > windowEnd) break;
      if (day >= windowStart && (days.isEmpty || days.last != day)) {
        days.add(day);
      }
    }
    return days;
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

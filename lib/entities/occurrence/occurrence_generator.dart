import 'package:flutter/material.dart' show DateTimeRange;
import 'package:org_parser/org_parser.dart';

import '../day_key.dart';
import '../org_entry/org_entry.dart';
import 'occurrence.dart';

export '../day_key.dart';

DayKey? _dayKeyOfTimestamp(OrgTimestamp timestamp) => switch (timestamp) {
  OrgSimpleTimestamp() => dayKeyOfOrgDate(timestamp.date),
  OrgTimeRangeTimestamp() => dayKeyOfOrgDate(timestamp.date),
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

  void addOccurrences(
    OrgTimestamp? timestamp,
    OccurrenceKind kind, {
    bool repeat = true,
  }) {
    if (timestamp == null) return;
    for (final key in _daysInWindow(
      timestamp,
      windowStart,
      windowEnd,
      repeat: repeat,
    )) {
      occurrences.add(
        Occurrence(
          entry: entry,
          date: dateOfDayKey(key),
          kind: kind,
          timestamp: timestamp,
        ),
      );
    }
  }

  for (final timestamp in entry.timestamps) {
    addOccurrences(timestamp, OccurrenceKind.timestamp);
  }
  // A habit repeats too often for the calendar. Like the org agenda, show
  // only the next repetition.
  addOccurrences(
    entry.scheduled?.value as OrgTimestamp?,
    OccurrenceKind.scheduled,
    repeat: entry is! OrgHabit,
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
  DayKey windowEnd, {
  required bool repeat,
}) {
  if (timestamp is! OrgDateRangeTimestamp) {
    final key = _dayKeyOfTimestamp(timestamp)!;
    final repeater = repeat ? _repeaterOf(timestamp) : null;
    final step = int.tryParse(repeater?.value ?? '') ?? 0;
    if (repeater == null || step <= 0) {
      if (key < windowStart || key > windowEnd) return const [];
      return [key];
    }

    final base = dateOfDayKey(key);
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

  var current = dateOfDayKey(
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

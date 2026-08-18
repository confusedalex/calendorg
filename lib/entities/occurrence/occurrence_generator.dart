import 'package:flutter/material.dart' show DateTimeRange;
import 'package:org_parser/org_parser.dart';

import '../../util.dart';
import '../org_entry/org_entry.dart';
import 'occurrence.dart';

List<Occurrence> occurrencesFor(OrgEntry entry, DateTimeRange window) {
  final occurrences = <Occurrence>[];

  void addOccurrences(OrgTimestamp? timestamp, OccurrenceKind kind) {
    if (timestamp == null) return;
    for (final date in _datesInWindow(timestamp, window)) {
      occurrences.add(
        Occurrence(entry: entry, date: date, kind: kind, timestamp: timestamp),
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

List<DateTime> _datesInWindow(OrgTimestamp timestamp, DateTimeRange window) {
  final candidateDates = switch (timestamp) {
    OrgSimpleTimestamp() => [timestamp.startDateTime],
    OrgTimeRangeTimestamp() => [timestamp.startDateTime],
    OrgDateRangeTimestamp() => timestamp.datetimes,
  };

  return candidateDates
      .map((dt) => DateTime(dt.year, dt.month, dt.day))
      .where((date) => _isInWindow(date, window))
      .toList();
}

bool _isInWindow(DateTime date, DateTimeRange window) {
  final start = DateTime(
    window.start.year,
    window.start.month,
    window.start.day,
  );
  final end = DateTime(window.end.year, window.end.month, window.end.day);
  return !date.isBefore(start) && !date.isAfter(end);
}

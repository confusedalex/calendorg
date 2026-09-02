import 'package:flutter/material.dart';

import '../org_entry/org_entry.dart';
import 'occurrence.dart';
import 'occurrence_generator.dart';

List<Occurrence> occurrencesInRange(
  List<OrgEntry> entries,
  DateTimeRange window,
) {
  final start = dayKeyOf(window.start);
  final end = dayKeyOf(window.end);

  return entries
      .expand<Occurrence>((entry) => occurrencesForInDays(entry, start, end))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

String dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

Map<String, List<Occurrence>> occurrencesByDateInRange(
  List<OrgEntry> entries,
  DateTimeRange window,
) {
  final map = <String, List<Occurrence>>{};
  for (final occurrence in occurrencesInRange(entries, window)) {
    (map[dateKey(occurrence.date)] ??= []).add(occurrence);
  }
  return map;
}

import 'package:flutter/material.dart';

import '../org_entry/org_entry.dart';
import 'occurrence.dart';
import 'occurrence_generator.dart';

List<Occurrence> occurrencesInRange(
  List<OrgEntry> entries,
  DateTimeRange window,
) =>
    entries
        .expand<Occurrence>((entry) => occurrencesFor(entry, window))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

Map<String, List<Occurrence>> occurrencesByDateInRange(
  List<OrgEntry> entries,
  DateTimeRange window,
) {
  final map = <String, List<Occurrence>>{};
  for (final occurrence in occurrencesInRange(entries, window)) {
    final key = occurrence.date.toIso8601String().split('T')[0];
    (map[key] ??= []).add(occurrence);
  }
  return map;
}

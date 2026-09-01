import 'package:org_parser/org_parser.dart';

import '../org_entry/org_entry.dart';

enum OccurrenceKind { timestamp, scheduled, deadline }

class Occurrence {
  final OrgEntry entry;
  final DateTime date;
  final OccurrenceKind kind;
  final OrgTimestamp timestamp;

  Occurrence({
    required this.entry,
    required this.date,
    required this.kind,
    required this.timestamp,
  });

  @override
  String toString() =>
      'Occurrence(date: $date, kind: $kind, entry: ${entry.title})';
}

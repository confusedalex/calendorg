import '../org_entry/org_entry.dart';
import 'package:org_parser/org_parser.dart';

enum OccurrenceKind { timestamp, scheduled, deadline }

class Occurrence {
  final OrgEntry entry;
  final DateTime date;
  final OccurrenceKind kind;
  final OrgTimestamp timestamp;
  final bool isRepeaterInstance; // true if generated, not literally in the file

  Occurrence({
    required this.entry,
    required this.date,
    required this.kind,
    required this.timestamp,
    this.isRepeaterInstance = false,
  });

  @override
  String toString() =>
      'Occurrence(date: $date, kind: $kind, entry: ${entry.title})';
}

import 'package:dart_mappable/dart_mappable.dart';
import 'package:org_parser/org_parser.dart';

import '../planning_entry.dart';
import '../timestamp.dart';
import 'org_entry_locator.dart';

part 'org_entry.mapper.dart';

@MappableClass(
  includeCustomMappers: [OrgTimestampMapper(), OrgPlanningEntryMapper()],
)
class OrgEntry with OrgEntryMappable {
  final OrgEntryLocator locator;
  final String filePath;
  final String fileHash;
  final String? todoKeyword;
  final bool containsTimestampInHeadline;
  final String title;
  final List<String> tags;
  final List<OrgTimestamp> timestamps;
  final OrgPlanningEntry? scheduled;
  final OrgPlanningEntry? deadline;

  List<OrgTimestamp> get unifiedTimestamps => [
    ...timestamps,
    if (scheduled?.value != null) scheduled!.value as OrgTimestamp,
    if (deadline?.value != null) deadline!.value as OrgTimestamp,
  ];

  OrgEntry({
    required this.locator,
    required this.todoKeyword,
    required this.containsTimestampInHeadline,
    required this.title,
    required this.tags,
    required this.timestamps,
    this.scheduled,
    this.deadline,
    required this.filePath,
    required this.fileHash,
  });
}

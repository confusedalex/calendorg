import 'package:dart_mappable/dart_mappable.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../util.dart';
import '../planning_entry.dart';
import '../timestamp.dart';

part 'org_entry.mapper.dart';

@MappableClass(
  discriminatorKey: 'type',
  includeCustomMappers: [OrgTimestampMapper(), OrgPlanningEntryMapper()],
)
sealed class OrgEntry with OrgEntryMappable {
  String? todoKeyword;
  bool containsTimestampInHeadline;
  String title;
  List<String> tags = [];
  List<OrgTimestamp> timestamps;
  OrgPlanningEntry? scheduled;
  OrgPlanningEntry? deadline;

  List<OrgTimestamp> get unifiedTimestamps => [
    ...timestamps,
    if (scheduled?.value != null) scheduled!.value as OrgTimestamp,
    if (deadline?.value != null) deadline!.value as OrgTimestamp,
  ];

  List<OrgTimestamp> timestampsByDateTime(
    DateTime date, {
    bool? includeInactive = false,
  }) => unifiedTimestamps
      .where(
        (timestamp) => switch (timestamp) {
          OrgSimpleTimestamp() =>
            isSameDay(date, timestamp.dateTime) &&
                timestamp.isActive != includeInactive,
          OrgDateRangeTimestamp() =>
            date.isAfter(beforeMidnight(timestamp.startDateTime)) &&
                date.isBefore(afterMidnight(timestamp.endDateTime)),
          OrgTimeRangeTimestamp() => isSameDay(date, timestamp.startDateTime),
        },
      )
      .toList();

  OrgEntry({
    required this.todoKeyword,
    required this.containsTimestampInHeadline,
    required this.title,
    required this.tags,
    required this.timestamps,
    this.scheduled,
    this.deadline,
  });
}

@MappableClass(discriminatorValue: 'cached')
class OrgEntryCached extends OrgEntry with OrgEntryCachedMappable {
  OrgEntryCached({
    required super.todoKeyword,
    required super.containsTimestampInHeadline,
    required super.title,
    required super.tags,
    required super.timestamps,
    required super.deadline,
    required super.scheduled,
  });

  factory OrgEntryCached.fromLoaded(OrgEntryLoaded entry) {
    return OrgEntryCached(
      todoKeyword: entry.todoKeyword,
      containsTimestampInHeadline: entry.containsTimestampInHeadline,
      title: entry.title,
      tags: entry.tags,
      timestamps: entry.timestamps,
      deadline: entry.deadline,
      scheduled: entry.scheduled,
    );
  }
}

@MappableClass(discriminatorValue: 'loaded')
class OrgEntryLoaded extends OrgEntry with OrgEntryLoadedMappable {
  final OrgSection section;
  final FileInfo fileInfo;

  OrgEntryLoaded({
    required super.todoKeyword,
    required super.containsTimestampInHeadline,
    required super.title,
    required super.tags,
    required super.timestamps,
    required super.deadline,
    required super.scheduled,
    required this.section,
    required this.fileInfo,
  });
}

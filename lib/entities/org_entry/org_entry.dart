import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../util.dart';

class OrgEntry {
  String? todoKeyword;
  bool containsTimestampInHeadline;
  OrgSection section;
  String title;
  FileInfo fileInfo;
  List<String> tags = [];
  List<OrgTimestamp> timestamps;
  OrgPlanningEntry? scheduled;
  OrgPlanningEntry? deadline;
  late String? description;

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
    required this.section,
    required this.title,
    required this.fileInfo,
    required this.tags,
    required this.timestamps,
    this.scheduled,
    this.deadline,
    this.description,
  });

  OrgEntry copyWith({
    ValueGetter<String?>? todoKeyword,
    bool? containsTimestampInHeadline,
    OrgSection? section,
    String? title,
    FileInfo? fileInfo,
    List<String>? tags,
    List<OrgTimestamp>? timestamps,
    ValueGetter<OrgPlanningEntry?>? scheduled,
    ValueGetter<OrgPlanningEntry?>? deadline,
    ValueGetter<String?>? description,
  }) {
    return OrgEntry(
      todoKeyword: todoKeyword != null ? todoKeyword() : this.todoKeyword,
      containsTimestampInHeadline:
          containsTimestampInHeadline ?? this.containsTimestampInHeadline,
      section: section ?? this.section,
      title: title ?? this.title,
      fileInfo: fileInfo ?? this.fileInfo,
      tags: tags ?? this.tags,
      timestamps: timestamps ?? this.timestamps,
      scheduled: scheduled != null ? scheduled() : this.scheduled,
      deadline: deadline != null ? deadline() : this.deadline,
      description: description != null ? description() : this.description,
    );
  }

  @override
  String toString() {
    return 'Event{title=$title, tags=$tags}';
  }
}

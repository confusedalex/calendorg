import 'package:flutter/material.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  bool containsTimestampInHeadline;
  OrgSection section;
  String title;
  FileInfo fileInfo;
  List<String> tags = [];
  List<OrgTimestamp> timestamps;
  OrgPlanningEntry? scheduled;
  OrgPlanningEntry? deadline;
  late String? description;

  DateTime beforeMidnight(DateTime date) => date
      .subtract(Duration(days: 1))
      .copyWith(hour: 23, minute: 59, second: 59);
  DateTime afterMidnight(DateTime date) =>
      date.add(Duration(days: 1)).copyWith(hour: 00, minute: 00, second: 00);

  List<OrgTimestamp> timestampsByDateTime(DateTime date,
          {bool? includeInactive = false}) =>
      timestamps
          .where((timestamp) => switch (timestamp) {
                OrgSimpleTimestamp() => isSameDay(date, timestamp.dateTime) &&
                    timestamp.isActive != includeInactive,
                OrgDateRangeTimestamp() =>
                  date.isAfter(beforeMidnight(timestamp.start.dateTime)) &&
                      date.isBefore(afterMidnight(timestamp.end.dateTime)),
                OrgTimeRangeTimestamp() =>
                  isSameDay(date, timestamp.startDateTime),
              })
          .toList();

  Event(
      {required this.containsTimestampInHeadline,
      required this.section,
      required this.title,
      required this.fileInfo,
      required this.tags,
      required this.timestamps,
      this.scheduled,
      this.deadline,
      this.description});

  Event copyWith(
      {bool? containsTimestampInHeadline,
      OrgSection? section,
      String? title,
      FileInfo? fileInfo,
      List<String>? tags,
      List<OrgTimestamp>? timestamps,
      ValueGetter<OrgPlanningEntry?>? scheduled,
      ValueGetter<OrgPlanningEntry?>? deadline,
      ValueGetter<String?>? description}) {
    return Event(
        containsTimestampInHeadline:
            containsTimestampInHeadline ?? this.containsTimestampInHeadline,
        section: section ?? this.section,
        title: title ?? this.title,
        fileInfo: fileInfo ?? this.fileInfo,
        tags: tags ?? this.tags,
        timestamps: timestamps ?? this.timestamps,
        scheduled: scheduled != null ? scheduled() : this.scheduled,
        deadline: deadline != null ? deadline() : this.deadline,
        description: description != null ? description() : this.description);
  }
}

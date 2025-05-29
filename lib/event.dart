import 'dart:collection';

import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  late String? description;
  List<String> tags = [];
  Map timestamps;

  List<DateTime> dateTimeList() => timestamps.entries.map((entry) {
        if (entry.key is OrgSimpleTimestamp) {
          return (entry.key as OrgSimpleTimestamp).dateTime;
        } else if (entry.key is DateTime) {
          return (entry.key as DateTime);
        }
        return DateTime(0);
      }).toList();

  Map timestampsFilteredByDateTime(DateTime date) =>
      {...timestamps}..removeWhere((k, v) => k.runtimeType is OrgSimpleTimestamp
          ? isSameDay((k as OrgSimpleTimestamp).dateTime, date)
          : false);

  // DateTime get earliestDateTime =>
  //     timestamps.fold(DateTime.fromMillisecondsSinceEpoch(0), (acc, cur) {
  //       return acc.microsecond == 0
  //           ? cur.dateTime
  //           : acc.isBefore(cur.dateTime)
  //               ? acc
  //               : cur.dateTime;
  //     });

  // List<OrgSimpleTimestamp> timestampsByDateTime(DateTime date) => timestamps
  //     .where((timestamp) => isSameDay(date, timestamp.dateTime))
  //     .toList();

  Event(this.title, this.tags, this.timestamps, this.description);
}

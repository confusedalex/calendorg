import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  late String? description;
  List<String> tags = [];
  List<OrgGenericTimestamp> timestamps;

  DateTime beforeMidnight(DateTime date) => date
      .subtract(Duration(days: 1))
      .copyWith(hour: 23, minute: 59, second: 59);
  DateTime afterMidnight(DateTime date) =>
      date.add(Duration(days: 1)).copyWith(hour: 00, minute: 00, second: 00);

  List<OrgGenericTimestamp> timestampsByDateTime(DateTime date,
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

  Event(this.title, this.tags, this.timestamps, this.description);
}

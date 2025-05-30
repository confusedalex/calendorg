import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  late String? description;
  List<String> tags = [];
  List timestamps;

  DateTime beforeMidnight(DateTime date) => date
      .subtract(Duration(days: 1))
      .copyWith(hour: 23, minute: 59, second: 59);
  DateTime afterMidnight(DateTime date) =>
      date.add(Duration(days: 1)).copyWith(hour: 00, minute: 00, second: 00);

  List timestampsByDateTime(DateTime date, {bool? includeInactive = false}) =>
      timestamps.where((timestamp) {
        if (timestamp is OrgSimpleTimestamp &&
            timestamp.isActive != includeInactive) {
          return isSameDay(date, timestamp.dateTime);
        }
        if (timestamp is OrgDateRangeTimestamp &&
            timestamp.isActive != includeInactive) {
          return date.isAfter(beforeMidnight(timestamp.start.dateTime)) &&
              date.isBefore(afterMidnight(timestamp.end.dateTime));
        }
        if (timestamp is OrgTimeRangeTimestamp &&
            timestamp.isActive != includeInactive) {
          return isSameDay(timestamp.startDateTime, date);
        }

        return false;
      }).toList();

  String? rawTimeStampsFromTimeStamp(dynamic timestamp) {
    if (timestamp is OrgSimpleTimestamp) {
      return timestamp.toMarkup();
    }
    if (timestamp is OrgDateRangeTimestamp) {
      return timestamp.toMarkup();
    }
    if (timestamp is OrgTimeRangeTimestamp) {
      return timestamp.toMarkup();
    }
    return null;
  }

  Event(this.title, this.tags, this.timestamps, this.description);
}

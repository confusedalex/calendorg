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

  List timestampsByDateTime(DateTime date) => timestamps.where((timestamp) {
        if (timestamp is OrgSimpleTimestamp) {
          return isSameDay(date, timestamp.dateTime);
        }
        if (timestamp is OrgDateRangeTimestamp) {
          return date.isAfter(beforeMidnight(timestamp.start.dateTime)) &&
              date.isBefore(afterMidnight(timestamp.end.dateTime));
        }
        return false;
      }).toList();

  Event(this.title, this.tags, this.timestamps, this.description);
}

import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

String? validate(String? value, String object, {Iterable<String>? notIn}) {
  if (value == null || value.trim().isEmpty) return "$object can't be empty!";
  if (notIn != null && notIn.contains(value)) return '$object already exists!';

  return null;
}

void sendError(BuildContext context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        error,
      ),
      backgroundColor: Colors.red,
    ),
  );
}

OrgDate dateTimeToOrgDate(DateTime dateTime) {
  final isoDate = dateTime.toIso8601String().split('T')[0].split('-');
  return (year: isoDate[0], month: isoDate[1], day: isoDate[2], dayName: null);
}

OrgTime dateTimeToOrgTime(DateTime dateTime) {
  final isoTime = dateTime.toIso8601String().split('T')[1].split(':');
  return (hour: isoTime[0], minute: isoTime[1]);
}

(String, String) prefixAndSuffixFromBool(bool isActive) {
  final prefix = isActive ? '<' : '[';
  final suffix = isActive ? '>' : ']';
  return (prefix, suffix);
}

OrgSimpleTimestamp dateTimeToSimpleTimestamp(
  DateTime dateTime,
  bool includeTime,
  bool isActive,
) {
  final OrgDate date = dateTimeToOrgDate(dateTime);
  final OrgTime? time = includeTime ? dateTimeToOrgTime(dateTime) : null;
  final (prefix, suffix) = prefixAndSuffixFromBool(isActive);
  return OrgSimpleTimestamp(prefix, date, time, [], suffix);
}

OrgTimestamp dateTimeToTimeRangeTimestamp(
  DateTime startDateTime,
  DateTime endDateTime,
  bool isActive,
  bool includeStartTime,
  bool includeEndTime,
) {
  if (includeStartTime &&
      includeEndTime &&
      isSameDay(startDateTime, endDateTime)) {
    final OrgDate date = dateTimeToOrgDate(startDateTime);
    final OrgTime timeStart = dateTimeToOrgTime(startDateTime);
    final OrgTime timeEnd = dateTimeToOrgTime(endDateTime);
    final (prefix, suffix) = prefixAndSuffixFromBool(isActive);
    return OrgTimeRangeTimestamp(prefix, date, timeStart, timeEnd, [], suffix);
  } else {
    final OrgSimpleTimestamp start = dateTimeToSimpleTimestamp(
      startDateTime,
      includeStartTime,
      isActive,
    );
    final OrgSimpleTimestamp end = dateTimeToSimpleTimestamp(
      endDateTime,
      includeEndTime,
      isActive,
    );
    return OrgDateRangeTimestamp(start, '--', end);
  }
}

List<DateTime> dateTimesFromOrgDateRange(
  OrgDateRangeTimestamp timestamp,
  List<DateTime> list,
  DateTime? date,
) {
  if (date != null &&
      isSameDay(timestamp.endDateTime.add(const Duration(days: 1)), date)) {
    return list;
  }
  if (date == null) {
    final next = timestamp.startDateTime.add(const Duration(days: 1));
    return dateTimesFromOrgDateRange(timestamp, [
      timestamp.startDateTime,
    ], next);
  }
  return dateTimesFromOrgDateRange(timestamp, [
    ...list,
    date,
  ], date.add(const Duration(days: 1)));
}

DateTime beforeMidnight(DateTime date) => date
    .subtract(const Duration(days: 1))
    .copyWith(hour: 23, minute: 59, second: 59);
DateTime afterMidnight(DateTime date) => date
    .add(const Duration(days: 1))
    .copyWith(hour: 00, minute: 00, second: 00);

extension GetTimeOfDay on OrgTime {
  TimeOfDay get timeOfDay =>
      TimeOfDay(hour: int.parse(this.hour), minute: int.parse(this.minute));
}

extension StartDateTime on OrgTimestamp {
  DateTime get startDateTime => switch (this) {
    OrgSimpleTimestamp() => (this as OrgSimpleTimestamp).dateTime,
    OrgDateRangeTimestamp() => (this as OrgDateRangeTimestamp).startDateTime,
    OrgTimeRangeTimestamp() => (this as OrgTimeRangeTimestamp).startDateTime,
  };
}

extension DateTimesFromRange on OrgDateRangeTimestamp {
  List<DateTime> get datetimes => dateTimesFromOrgDateRange(this, [], null);
}

List<DateTime> dateRange(DateTime start, DateTime end) {
  final dates = <DateTime>[];
  var current = start;
  while (current.isBefore(end) || isSameDay(current, end)) {
    dates.add(current);
    current = current.add(const Duration(days: 1));
  }
  return dates;
}

import 'package:calendorg/event.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

Map<String, List<Event>> parseEvents(FileInfo fileInfo, OrgDocument document) {
  final timestampRegEx = RegExp(r"[\s]?[<][0-9]{4}-[0-9]{2}-[0-9]{2}.*[>]");
  final Map<String, List<Event>> eventMap = {};

  document.visitSections(((section) {
    final List<OrgTimestamp> foundTimestamps = [];
    OrgPlanningEntry? scheduled;
    OrgPlanningEntry? deadline;
    bool returnIfSectionFound = false;
    int ignoreNTimestamps = 0;

    final containsTimestamp =
        section.headline.rawTitle?.contains(timestampRegEx) ?? false;

    var headline = section.headline.rawTitle?.replaceAll(
          timestampRegEx,
          "",
        ) ??
        '';

    if (section.tags.isNotEmpty) {
      headline = headline.substring(0, headline.length - 1);
    }

    final tags = section.tagsWithInheritance(document);

    section.visit((node) {
      switch (node) {
        case OrgSection():
          return returnIfSectionFound ? false : returnIfSectionFound = true;

        case OrgPlanningEntry():
          switch (node.keyword.content) {
            case "SCHEDULED:":
              scheduled = node;
              break;
            case "DEADLINE:":
              deadline = node;
              break;
          }
          break;

        case OrgDateRangeTimestamp():
          // ignore the next 2 timestamps, because they will
          // be just part of this range
          ignoreNTimestamps = 2;

          foundTimestamps.add(node);
          break;

        case OrgSimpleTimestamp():
          if (ignoreNTimestamps > 0) break;
          foundTimestamps.add(node);

          break;

        case OrgTimeRangeTimestamp():
          foundTimestamps.add(node);
          break;
      }
      return true;
    });

    if (foundTimestamps.isNotEmpty) {
      final event = Event(
          section: section,
          containsTimestampInHeadline: containsTimestamp,
          fileInfo: fileInfo,
          title: headline,
          tags: tags,
          timestamps: foundTimestamps,
          scheduled: scheduled,
          deadline: deadline,
          description: null);
      for (final timestamp in foundTimestamps) {
        if (timestamp is OrgDateRangeTimestamp) {
          for (final datetime in timestamp.datetimes) {
            eventMap[datetime.toIso8601String().split("T")[0]] = [
              ...?eventMap[datetime.toIso8601String().split("T")[0]],
              event
            ];
          }
        } else {
          final dateTime = timestamp.startDateTime;
          eventMap[dateTime.toIso8601String().split("T")[0]] = [
            ...?eventMap[dateTime.toIso8601String().split("T")[0]],
            event
          ];
        }
      }
    }

    return true;
  }));
  return eventMap;
}

String? validate(String? value, String object, {Iterable<String>? notIn}) {
  if (value == null || value.trim().isEmpty) return "$object can't be empty!";
  if (notIn != null && notIn.contains(value)) return "$object already exists!";

  return null;
}

OrgDate dateTimeToOrgDate(DateTime dateTime) {
  final isoDate = dateTime.toIso8601String().split("T")[0].split("-");
  return (year: isoDate[0], month: isoDate[1], day: isoDate[2], dayName: null);
}

OrgTime dateTimeToOrgTime(DateTime dateTime) {
  final isoTime = dateTime.toIso8601String().split("T")[1].split(":");
  return (hour: isoTime[0], minute: isoTime[1]);
}

(String, String) prefixAndSuffixFromBool(bool isActive) {
  final prefix = isActive ? "<" : "[";
  final suffix = isActive ? ">" : "]";
  return (prefix, suffix);
}

OrgSimpleTimestamp dateTimeToSimpleTimestamp(
    DateTime dateTime, bool includeTime, bool isActive) {
  final repeaterOrDelay = <String>[];
  final OrgDate date = dateTimeToOrgDate(dateTime);
  final OrgTime? time = includeTime ? dateTimeToOrgTime(dateTime) : null;
  final (prefix, suffix) = prefixAndSuffixFromBool(isActive);
  return OrgSimpleTimestamp(prefix, date, time, repeaterOrDelay, suffix);
}

OrgTimestamp dateTimeToTimeRangeTimestamp(
    DateTime startDateTime,
    DateTime endDateTime,
    bool isActive,
    bool includeStartTime,
    bool includeEndTime) {
  if (includeStartTime &&
      includeEndTime &&
      isSameDay(startDateTime, endDateTime)) {
    final repeaterOrDelay = <String>[];
    final OrgDate date = dateTimeToOrgDate(startDateTime);
    final OrgTime timeStart = dateTimeToOrgTime(startDateTime);
    final OrgTime timeEnd = dateTimeToOrgTime(endDateTime);
    final (prefix, suffix) = prefixAndSuffixFromBool(isActive);
    return OrgTimeRangeTimestamp(
        prefix, date, timeStart, timeEnd, repeaterOrDelay, suffix);
  } else {
    final OrgSimpleTimestamp start =
        dateTimeToSimpleTimestamp(startDateTime, includeStartTime, isActive);
    final OrgSimpleTimestamp end =
        dateTimeToSimpleTimestamp(endDateTime, includeEndTime, isActive);
    return OrgDateRangeTimestamp(start, "--", end);
  }
}

List<DateTime> dateTimesFromOrgDateRange(
    OrgDateRangeTimestamp timestamp, List<DateTime> list, DateTime? date) {
  if (date != null &&
      isSameDay(timestamp.end.dateTime.add(Duration(days: 1)), date)) {
    return list;
  }
  if (date == null) {
    final next = timestamp.startDateTime.add(Duration(days: 1));
    return dateTimesFromOrgDateRange(
        timestamp, [timestamp.startDateTime], next);
  }
  return dateTimesFromOrgDateRange(
      timestamp, [...list, date], date.add(Duration(days: 1)));
}

DateTime beforeMidnight(DateTime date) =>
    date.subtract(Duration(days: 1)).copyWith(hour: 23, minute: 59, second: 59);
DateTime afterMidnight(DateTime date) =>
    date.add(Duration(days: 1)).copyWith(hour: 00, minute: 00, second: 00);

extension GetTimeOfDay on OrgTime {
  TimeOfDay get timeOfDay =>
      TimeOfDay(hour: int.parse(this.hour), minute: int.parse(this.minute));
}

extension StartDateTime on OrgTimestamp {
  DateTime get startDateTime => switch (this) {
        OrgSimpleTimestamp() => (this as OrgSimpleTimestamp).dateTime,
        OrgDateRangeTimestamp() =>
          (this as OrgDateRangeTimestamp).start.dateTime,
        OrgTimeRangeTimestamp() => (this as OrgTimeRangeTimestamp).startDateTime
      };
}

extension DateTimesFromRange on OrgDateRangeTimestamp {
  List<DateTime> get datetimes => dateTimesFromOrgDateRange(this, [], null);
}

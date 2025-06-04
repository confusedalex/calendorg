import 'package:calendorg/event.dart';
import 'package:org_parser/org_parser.dart';
import 'package:table_calendar/table_calendar.dart';

List<Event> parseEvents(OrgDocument document) {
  final List<Event> eventList = [];

  document.visitSections(((section) {
    bool returnIfSectionFound = false;
    var ignoreNTimestamps = 0;
    final List<OrgTimestamp> foundTimestamps = [];

    final headline = section.headline.rawTitle?.replaceAll(
          RegExp(r"[\s]?[<][0-9]{4}-[0-9]{2}-[0-9]{2}.*[>]"),
          "",
        ) ??
        '';
    final tags = section.tagsWithInheritance(document);

    section.visit((node) {
      switch (node) {
        case OrgSection():
          return returnIfSectionFound ? false : returnIfSectionFound = true;

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
      eventList.add(Event(section, headline, tags, foundTimestamps, null));
    }

    return true;
  }));

  return eventList;
}

OrgSection changeSectionTitle(OrgSection section, String title) =>
    section.copyWith(
        headline: section.headline.fromChildren([
      OrgContent([OrgPlainText(title)])
    ]));

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

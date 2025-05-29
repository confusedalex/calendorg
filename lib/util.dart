import 'dart:collection';

import 'package:calendorg/event.dart';
import 'package:org_parser/org_parser.dart';

DateTime orgSimpleTimestampToDateTime(OrgSimpleTimestamp timestamp) {
  return DateTime(
    int.parse(timestamp.date.year),
    int.parse(timestamp.date.month),
    int.parse(timestamp.date.day),
    int.parse(timestamp.time?.hour ?? "00"),
    int.parse(timestamp.time?.minute ?? "00"),
  );
}

Map<DateTime, int> generateDateTimesForRange(
        DateTime start, int hash, Duration dur, Map<DateTime, int> cur) =>
    dur.inDays == 0
        ? cur
        : generateDateTimesForRange(start, hash, Duration(days: dur.inDays - 1),
            {...cur, start.add(dur): hash});

List<Event> parseEvents(OrgDocument document) {
  List<Event> eventList = [];

  document.visitSections(((section) {
    var foundSections = 0;
    var ignoreNTimestamps = 0;
    final Map<dynamic, int> foundTimestamps = HashMap();

    var headline = section.headline.rawTitle?.replaceAll(
          RegExp(r"[\s]?[<][0-9]{4}-[0-9]{2}-[0-9]{2}.*[>]"),
          "",
        ) ??
        '';
    var tags = section.tagsWithInheritance(document);

    section.visit((node) {
      switch (node.runtimeType) {
        // If more than the current section is found break
        case const (OrgSection):
          foundSections++;
          return foundSections > 1 ? false : true;

        case const (OrgDateRangeTimestamp):
          var rangeTimeStamp = node as OrgDateRangeTimestamp;
          ignoreNTimestamps = 2;

          var hash = rangeTimeStamp.hashCode;
          var startTimeStamp = rangeTimeStamp.start;
          var endTimeStamp = rangeTimeStamp.end;

          foundTimestamps.addAll({startTimeStamp: hash});
          foundTimestamps.addAll({endTimeStamp: hash});
          foundTimestamps.addEntries(generateDateTimesForRange(
              startTimeStamp.dateTime,
              hash,
              endTimeStamp.dateTime.difference(startTimeStamp.dateTime),
              {}).entries);

          break;

        case const (OrgSimpleTimestamp):
          if (ignoreNTimestamps > 0) break;
          var timestamp = node as OrgSimpleTimestamp;
          foundTimestamps.addAll({timestamp: timestamp.hashCode});

          break;
      }
      return true;
    });

    eventList.add(Event(headline, tags, foundTimestamps, null));

    return true;
  }));

  for (var event in eventList) {
    print("======");
    print("Title: ${event.title}");
    print(event.timestamps);
    // print("Start: ${event.start}");
    // if (event.end != null) print("Ende: ${event.end}");
  }

  return eventList;
}

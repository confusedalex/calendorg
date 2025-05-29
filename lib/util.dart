import 'package:calendorg/event.dart';
import 'package:flutter/scheduler.dart';
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

List<Event> parseEvents(OrgDocument document) {
  var foundHashes = [];
  List<String> foundTags = [];
  List<Event> eventList = [];
  String currentHeadline = '';

  document.visit<OrgNode>((node) {
    var hash = node.hashCode;

    if (foundHashes.contains(hash)) return true;
    foundHashes.add(hash);

    switch (node.runtimeType) {
      case const (OrgSection):
        foundTags = (node as OrgSection).tagsWithInheritance(document);
        break;

      case const (OrgHeadline):
        var headline = node as OrgHeadline;

        // Remove timestamp from headline if it exists
        currentHeadline = headline.rawTitle!
            .replaceAll(
              RegExp(r"[\s]?[<][0-9]{4}-[0-9]{2}-[0-9]{2}.*[>]"),
              "",
            )
            .trim();

      case const (OrgDateRangeTimestamp):
        var rangeTimeStamp = node as OrgDateRangeTimestamp;

        foundHashes.add(rangeTimeStamp.start.hashCode);
        foundHashes.add(rangeTimeStamp.end.hashCode);

        eventList.add(
          Event(
            rangeTimeStamp.toMarkup(),
            rangeTimeStamp.isActive,
            orgSimpleTimestampToDateTime(rangeTimeStamp.start),
            currentHeadline,
            hash.toString(),
            foundTags,
            null,
            orgSimpleTimestampToDateTime(rangeTimeStamp.end),
          ),
        );
        break;
      case const (OrgSimpleTimestamp):
        var timestamp = node as OrgSimpleTimestamp;
        eventList.add(
          Event(
              timestamp.toMarkup(),
              timestamp.isActive,
              orgSimpleTimestampToDateTime(timestamp),
              currentHeadline,
              node.hashCode.toString(),
              foundTags,
              null,
              null),
        );
        break;
    }
    return true;
  });

  // for (var event in eventList) {
  //   print("======");
  //   print("Title: ${event.title}");
  //   print("Start: ${event.start}");
  //   if (event.end != null) print("Ende: ${event.end}");
  //   print("id: ${event.id}");
  // }

  return eventList;
}

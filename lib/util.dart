import 'package:calendorg/event.dart';
import 'package:org_parser/org_parser.dart';

DateTime orgSimpleTimestampToDateTime(OrgSimpleTimestamp timestamp) {
  return DateTime(
    int.parse(timestamp.date.year),
    int.parse(timestamp.date.month),
    int.parse(timestamp.date.day),
  );
}

List<Event> parseEvents(OrgDocument document) {
  var foundHashes = [];
  List<Event> eventList = [];
  String currentHeadline = '';

  document.visit<OrgNode>((node) {
    var hash = node.hashCode;

    if (foundHashes.contains(hash)) return true;
    foundHashes.add(hash);

    switch (node.runtimeType) {
      case const (OrgHeadline):
        var headline = node as OrgHeadline;

        // Remove timestamp from headline if it exists
        currentHeadline =
            headline.rawTitle!
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
            orgSimpleTimestampToDateTime(rangeTimeStamp.start),
            currentHeadline,
            hash.toString(),
            null,
            orgSimpleTimestampToDateTime(rangeTimeStamp.end),
          ),
        );
        break;
      case const (OrgSimpleTimestamp):
        var timestamp = node as OrgSimpleTimestamp;
        eventList.add(
          Event(
            orgSimpleTimestampToDateTime(timestamp),
            currentHeadline,
            node.hashCode.toString(),
            null,
            null,
          ),
        );
        break;
    }
    return true;
  });

  for (var event in eventList) {
    print("======");
    print("Title: ${event.title}");
    print("Start: ${event.start}");
    if (event.end != null) print("Ende: ${event.end}");
    print("id: ${event.id}");
  }

  return eventList;
}

import 'package:calendorg/event.dart';
import 'package:org_parser/org_parser.dart';

List<Event> parseEvents(OrgDocument document) {
  List<Event> eventList = [];

  document.visitSections(((section) {
    var foundSections = 0;
    var ignoreNTimestamps = 0;
    var foundTimestamps = [];

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
          // ignore the next 2 timestamps, because they will
          // be just part of this range
          ignoreNTimestamps = 2;

          foundTimestamps.add(node);
          break;

        case const (OrgSimpleTimestamp):
          if (ignoreNTimestamps > 0) break;
          foundTimestamps.add(node);

          break;

        case const (OrgTimeRangeTimestamp):
          foundTimestamps.add(node);
          break;
      }
      return true;
    });

    if (foundTimestamps.isNotEmpty) {
      eventList.add(Event(headline, tags, foundTimestamps, null));
    }

    return true;
  }));

  return eventList;
}

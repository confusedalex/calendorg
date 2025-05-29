import 'package:calendorg/event.dart';
import 'package:calendorg/util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  final markup = """
* Heading 1
** orgmode meetup
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
""";
  late final document;
  late final List<Event> events;
  late final Event event;

  setUp(() {
    document = OrgDocument.parse(markup);
    events = parseEvents(document);
    event = events.first;
  });

  test("Events lenth should be 1", () {
    expect(events.length, 1);
  });

  test("6 OrgNodes expected in event", () {
    expect(event.timestamps.length, 6);
  });

  test("8 DateTimes expected from event", () {
    expect(event.timestamps.length, 8);
  });
}

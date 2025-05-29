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
  late final OrgDocument document;
  late final List<Event> events;
  late final Event event;

  setUp(() {
    document = OrgDocument.parse(markup);
    events = parseEvents(document);
    event = events.first;
  });

  test("All DateTimes found from event", () {
    expect(
        [
          DateTime(2025, 05, 05),
          DateTime(2025, 05, 06),
          DateTime(2025, 05, 08),
          DateTime(2025, 05, 28),
          DateTime(2025, 05, 15),
          DateTime(2025, 05, 1),
          DateTime(2025, 05, 2),
          DateTime(2025, 05, 3)
        ].map((date) => event.timestampsByDateTime(date).length),
        everyElement(1));

    expect(
        [
          DateTime(2015, 05, 05),
          DateTime(2025, 05, 25),
          DateTime(2024, 05, 08),
          DateTime(2025),
        ].map((date) => event.timestampsByDateTime(date).length),
        everyElement(0));
  });
}

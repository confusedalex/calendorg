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
  final document = OrgDocument.parse(markup);
  final events = parseEvents(document);
  final event = events.first;
  group(
    'Util',
    () {
      test("Events lenth should be 1", () {
        expect(events.length, 1);
      });

      test("6 OrgNodes expected in event", () {
        expect(event.timestamps.length, 6);
      });

      group(
        'DateTime to OrgSimpleTimestamp',
        () {
          test(
              "DateTime without Time and month under 10 should return correct OrgSimpleTimestamp",
              () {
            final dateTime = DateTime(2025, 05, 15);

            var timestamp = dateTimeToSimpleTimestamp(dateTime, false, true);

            expect(timestamp.toMarkup(), "<2025-05-15>");
            timestamp = dateTimeToSimpleTimestamp(dateTime, false, false);
            expect(timestamp.toMarkup(), "[2025-05-15]");
          });
          test(
              "DateTime without Time and month above 10 should return correct OrgSimpleTimestamp",
              () {
            final dateTime = DateTime(2025, 12, 31);

            final timestamp = dateTimeToSimpleTimestamp(dateTime, false, true);

            expect(timestamp.toMarkup(), "<2025-12-31>");
          });
          test("DateTime Time should return correct OrgSimpleTimestamp", () {
            final dateTime = DateTime(2025, 12, 31, 15, 00);

            final timestamp = dateTimeToSimpleTimestamp(dateTime, true, true);

            expect(timestamp.toMarkup(), "<2025-12-31 15:00>");
          });
        },
      );
      group(
        'DateTime to OrgTimeRangeTimestamp',
        () {
          test(
              "Two Datetimes with times should return correct OrgTimeRangeTimestamp",
              () {
            final start = DateTime(2025, 05, 15, 11, 0);
            final end = DateTime(2025, 05, 15, 17, 0);

            final timestamp =
                dateTimeToTimeRangeTimestamp(start, end, true, true, true);

            expect(timestamp.toMarkup(), "<2025-05-15 11:00-17:00>");
          });
          test(
              "Datimes spanning von 00:00 to 23:59 should still return correct OrgTimeRangeTimestamp",
              () {
            final start = DateTime(2025, 12, 31, 0, 0);
            final end = DateTime(2025, 12, 31, 23, 59);

            final timestamp =
                dateTimeToTimeRangeTimestamp(start, end, true, true, true);

            expect(timestamp.toMarkup(), "<2025-12-31 00:00-23:59>");
          });
        },
      );
      group(
        'DateTime to OrgDateRangeTimestamp',
        () {
          test(
              "Two Datetimes with times should return correct OrgDateRangeTimestamp",
              () {
            final start = DateTime(2025, 05, 15, 11, 0);
            final end = DateTime(2025, 05, 16, 17, 0);

            var timestamp =
                dateTimeToTimeRangeTimestamp(start, end, true, true, true);

            expect(
                timestamp.toMarkup(), "<2025-05-15 11:00>--<2025-05-16 17:00>");
            timestamp =
                dateTimeToTimeRangeTimestamp(start, end, false, true, true);
            expect(
                timestamp.toMarkup(), "[2025-05-15 11:00]--[2025-05-16 17:00]");
            timestamp =
                dateTimeToTimeRangeTimestamp(start, end, false, false, true);
            expect(timestamp.toMarkup(), "[2025-05-15]--[2025-05-16 17:00]");
            timestamp =
                dateTimeToTimeRangeTimestamp(start, end, false, false, false);
            expect(timestamp.toMarkup(), "[2025-05-15]--[2025-05-16]");
          });
          test(
              "Datimes spanning von 00:00 to 23:59 should still return correct OrgTimeRangeTimestamp",
              () {
            final start = DateTime(2025, 12, 31, 0, 0);
            final end = DateTime(2025, 12, 31, 23, 59);

            final timestamp =
                dateTimeToTimeRangeTimestamp(start, end, true, true, true);

            expect(timestamp.toMarkup(), "<2025-12-31 00:00-23:59>");
          });
        },
      );
    },
  );
}

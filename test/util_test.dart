import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/util.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:org_parser/org_parser.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  final markup = """
* Heading 1
** orgmode meetup
<2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
** TODO uninstall vim
SCHEDULED: <2025-05-05>
** TODO install emacs
DEADLINE: <2025-05-04>
** DONE Call mom
CLOSED: [2025-05-02 10:00]
** Weight
  - 70kg [2025-05-01]
* Heading with properties 
:PROPERTIES:
:CREATED: [2026-01-06 Tue 23:59]
:END:
Just some text.
** DONE Buy Notebook                               :@computer:@shopping:
CLOSED: [2026-04-24 Fri 11:25]
:LOGBOOK:
- State "TODO"       from "WAIT"       [2026-04-14 Tue 12:59]
- State "WAIT"       from "TODO"       [2026-04-07 Tue 22:58] \\
  Waiting on answer
:END:
""";
  final document = OrgDocument.parse(markup);
  final entries = EventParserService().parseEntriesFromDocument(
    MockFileInfo(),
    document,
    {},
  );
  final meetupEntry = entries.first;

  group('Util', () {
    test("6 timestamps found in meetup entry", () {
      expect(meetupEntry.timestamps.length, 6);
    });

    test("Scheduled entry gets parsed correctly", () {
      final uninstallVimEvent = entries.take(2).last;
      expect(uninstallVimEvent.scheduled, isNotNull);
    });

    test("Deadline entry gets parsed correctly", () {
      final markup = """
** TODO install emacs
DEADLINE: <2025-05-04>
""";
      final document = OrgDocument.parse(markup);
      final events = EventParserService().parseEntriesFromDocument(
        MockFileInfo(),
        document,
        {},
      );

      expect(events.entries.first.value.first.deadline, isNotNull);
    });

    test("Parsing single TODO works", () {
      final markup = """
** TODO install emacs
DEADLINE: <2025-05-04>
""";
      final document = OrgDocument.parse(markup);
      final events = EventParserService().parseEntriesFromDocument(
        MockFileInfo(),
        document,
        {},
      );

      expect(events.entries, hasLength(1));
    });

    group('DateTime to OrgSimpleTimestamp', () {
      test(
        "DateTime without Time and month under 10 should return correct OrgSimpleTimestamp",
        () {
          final dateTime = DateTime(2025, 05, 15);

          var timestamp = dateTimeToSimpleTimestamp(dateTime, false, true);

          expect(timestamp.toMarkup(), "<2025-05-15>");
          timestamp = dateTimeToSimpleTimestamp(dateTime, false, false);
          expect(timestamp.toMarkup(), "[2025-05-15]");
        },
      );
      test(
        "DateTime without Time and month above 10 should return correct OrgSimpleTimestamp",
        () {
          final dateTime = DateTime(2025, 12, 31);

          final timestamp = dateTimeToSimpleTimestamp(dateTime, false, true);

          expect(timestamp.toMarkup(), "<2025-12-31>");
        },
      );
      test("DateTime Time should return correct OrgSimpleTimestamp", () {
        final dateTime = DateTime(2025, 12, 31, 15, 00);

        final timestamp = dateTimeToSimpleTimestamp(dateTime, true, true);

        expect(timestamp.toMarkup(), "<2025-12-31 15:00>");
      });
    });
    group('DateTime to OrgTimeRangeTimestamp', () {
      test(
        "Two Datetimes with times should return correct OrgTimeRangeTimestamp",
        () {
          final start = DateTime(2025, 05, 15, 11, 0);
          final end = DateTime(2025, 05, 15, 17, 0);

          final timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            true,
            true,
            true,
          );

          expect(timestamp.toMarkup(), "<2025-05-15 11:00-17:00>");
        },
      );
      test(
        "Datimes spanning von 00:00 to 23:59 should still return correct OrgTimeRangeTimestamp",
        () {
          final start = DateTime(2025, 12, 31, 0, 0);
          final end = DateTime(2025, 12, 31, 23, 59);

          final timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            true,
            true,
            true,
          );

          expect(timestamp.toMarkup(), "<2025-12-31 00:00-23:59>");
        },
      );
    });
    group('DateTime to OrgDateRangeTimestamp', () {
      test(
        "Two Datetimes with times should return correct OrgDateRangeTimestamp",
        () {
          final start = DateTime(2025, 05, 15, 11, 0);
          final end = DateTime(2025, 05, 16, 17, 0);

          var timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            true,
            true,
            true,
          );

          expect(
            timestamp.toMarkup(),
            "<2025-05-15 11:00>--<2025-05-16 17:00>",
          );
          timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            false,
            true,
            true,
          );
          expect(
            timestamp.toMarkup(),
            "[2025-05-15 11:00]--[2025-05-16 17:00]",
          );
          timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            false,
            false,
            true,
          );
          expect(timestamp.toMarkup(), "[2025-05-15]--[2025-05-16 17:00]");
          timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            false,
            false,
            false,
          );
          expect(timestamp.toMarkup(), "[2025-05-15]--[2025-05-16]");
        },
      );
      test(
        "Datimes spanning von 00:00 to 23:59 should still return correct OrgTimeRangeTimestamp",
        () {
          final start = DateTime(2025, 12, 31, 0, 0);
          final end = DateTime(2025, 12, 31, 23, 59);

          final timestamp = dateTimeToTimeRangeTimestamp(
            start,
            end,
            true,
            true,
            true,
          );

          expect(timestamp.toMarkup(), "<2025-12-31 00:00-23:59>");
        },
      );
    });
    group("dateTimesFromOrgDateRange", () {
      test("Parse OrgDateRangeTimestamp", () {
        final dateTimes = dateTimesFromOrgDateRange(
          meetupEntry.timestamps.last as OrgDateRangeTimestamp,
          [],
          null,
        );
        expect(dateTimes, containsOnce(DateTime(2025, 05, 01)));
        expect(dateTimes, containsOnce(DateTime(2025, 05, 02)));
        expect(dateTimes, containsOnce(DateTime(2025, 05, 03)));
      });
    });
    group("validator", () {
      test("validator should return string when null", () {
        final result = validate(null, "Placeholder");

        expect(result, isA<String>());
      });
      test("validator should return string when string is empty", () {
        final result = validate("", "Placeholder");

        expect(result, isA<String>());
      });
      test("validator should return string when string is just spaces", () {
        final result = validate("                           ", "Placeholder");

        expect(result, isA<String>());
      });
      test("validator should return string when string is in set", () {
        final result = validate(
          "alreadyExists",
          "Placeholder",
          notIn: ["alreadyExists"],
        );

        expect(result, isA<String>());
      });
      test(
        "validator should return null when string not in set and not empty",
        () {
          final result = validate(
            "doesntAlreadyExists",
            "Placeholder",
            notIn: ["alreadyExists"],
          );

          expect(result, isNull);
        },
      );
    });
    group("ignored todo states", () {
      test("OTHER will be ignored", () {
        final markup = """
* TODO install emacs
<2025-01-01>
* OTHER install emacs
<2025-01-02>
""";

        final Parser parser = OrgParserDefinition(
          todoStates: [
            OrgTodoStates(todo: ["TODO", "OTHER"], done: ["DONE"]),
          ],
        ).build();
        final document = parser.parse(markup).value as OrgDocument;
        final events = EventParserService().parseEntriesFromDocument(
          MockFileInfo(),
          document,
          {"OTHER"},
        );

        expect(events.length, equals(1));
      });
      test("Nested TODOs of OTHER are still valid", () {
        final markup = """
* TODO install emacs
<2025-01-01>
* OTHER install emacs
<2025-01-02>
** TODO nested todo
<2025-01-03>
** OTHER another other
<2025-01-04>
*** TODO nested nested todo
<2025-01-05>
""";

        final Parser parser = OrgParserDefinition(
          todoStates: [
            OrgTodoStates(todo: ["TODO", "OTHER"], done: ["DONE"]),
          ],
        ).build();
        final document = parser.parse(markup).value as OrgDocument;
        final events = EventParserService().parseEntriesFromDocument(
          MockFileInfo(),
          document,
          {"OTHER"},
        );

        expect(events.length, equals(3));
      });
    });
  });
}

class MockFileInfo extends Mock implements FileInfo {}

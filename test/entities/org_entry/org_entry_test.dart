import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  final markup = '''
* Heading 1
** orgmode meetup <2025-05-05>
<2025-05-06 11:00>
<2025-05-08 11:00-13:00>
<2025-05-28> <2025-05-15>
<2025-05-01>--<2025-05-03>
''';
  final document = OrgDocument.parse(markup);
  final entry = EventParserService()
      .parseEntriesFromDocument(MockFileInfo(), document, {})
      .first;

  group('Events', () {
    test('All DateTimes found from event', () {
      expect(
        [
          DateTime(2025, 05, 05),
          DateTime(2025, 05, 06),
          DateTime(2025, 05, 08),
          DateTime(2025, 05, 28),
          DateTime(2025, 05, 15),
          DateTime(2025, 05),
          DateTime(2025, 05, 2),
          DateTime(2025, 05, 3),
        ].map((date) => entry.timestampsByDateTime(date).length),
        everyElement(1),
      );

      expect(
        [
          DateTime(2015, 05, 05),
          DateTime(2025, 05, 25),
          DateTime(2024, 05, 08),
          DateTime(2025),
        ].map((date) => entry.timestampsByDateTime(date).length),
        everyElement(0),
      );
    });

    test('Only DateTimes at the same date should match', () {
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05)).length,
        equals(1),
      );
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05, 01, 23, 59, 59)).length,
        equals(1),
      );
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05, 02)).length,
        equals(1),
      );
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05, 02, 23, 59, 59)).length,
        equals(1),
      );
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05, 03)).length,
        equals(1),
      );
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05, 03, 23, 59, 59)).length,
        equals(1),
      );

      expect(
        entry.timestampsByDateTime(DateTime(2024, 04, 30, 23, 59, 59)).length,
        equals(0),
      );
      expect(
        entry.timestampsByDateTime(DateTime(2025, 05, 04)).length,
        equals(0),
      );
    });
  });
}

class MockFileInfo extends Mock implements FileInfo {}

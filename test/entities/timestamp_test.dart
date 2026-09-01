import 'package:calendorg/entities/timestamp.dart';
import 'package:org_parser/org_parser.dart';
import 'package:test/test.dart';

void main() {
  group('timestamp', () {
    test('should round trip date for simple timestamp', () {
      final modifiers = [OrgTimestampModifier('+', '1', 'd', null)];
      final timestamp = OrgSimpleTimestamp(
        '<',
        (year: '2005', month: '10', day: '28', dayName: null),
        null,
        modifiers,
        '>',
      );

      final parsed = fromJson(timestamp.toJson());

      expect(parsed.toJson(), equals(timestamp.toJson()));
    });
    test('should round trip date range timestamps', () {
      final timestamp = OrgDocument.parse(
        '<2025-05-01>--<2025-05-03>',
      ).find<OrgDateRangeTimestamp>((node) => true)!.node;

      final parsed = dateRangeFromJson(timestamp.toJson());

      expect(parsed.toJson(), equals(timestamp.toJson()));
    });
    test('should round trip time range timestamps', () {
      final timestamp = OrgDocument.parse(
        '<2025-05-01 11:00-13:00>',
      ).find<OrgTimeRangeTimestamp>((node) => true)!.node;

      final parsed = timeRangeFromJson(timestamp.toJson());

      expect(parsed.toJson(), equals(timestamp.toJson()));
    });
  });
}

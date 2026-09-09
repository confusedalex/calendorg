import 'package:calendorg/entities/org_entry/entry_edit.dart';
import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/entities/org_entry/org_entry_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

import '../../helpers/entries.dart';

void main() {
  final service = EventParserService();

  OrgSimpleTimestamp stamp(String day) => OrgSimpleTimestamp(
    '<',
    (year: '2025', month: '05', day: day, dayName: null),
    null,
    [],
    '>',
  );

  String applied(String markup, EntryEdit Function(OrgEntry entry) buildEdit) {
    final entry = parseEntries(OrgDocument.parse(markup)).first;
    final document = OrgDocument.parse(markup);
    final section = locateSection(document, entry.locator)!;

    final replacements = service.replacementsFor(
      section,
      entry,
      buildEdit(entry),
    );

    return (replacements
                .fold<OrgZipper>(
                  document.edit(),
                  (builder, nodes) => builder.find(nodes.$1)!.replace(nodes.$2),
                )
                .commit()
            as OrgDocument)
        .toMarkup();
  }

  group('locateTimestamp', () {
    test('finds the timestamp again in a new parse', () {
      const markup = '* Exam\n<2025-05-15>\n';
      final entry = parseEntries(OrgDocument.parse(markup)).first;
      final section = OrgDocument.parse(markup).sections.first;

      final found = service.locateTimestamp(
        section,
        entry,
        entry.timestamps.first,
      );

      expect(found, isNotNull);
      expect(found!.toMarkup(), equals('<2025-05-15>'));
    });

    test('tells two identical timestamps apart by their position', () {
      const markup = '* Exam\n<2025-05-15> and again <2025-05-15>\n';
      final entry = parseEntries(OrgDocument.parse(markup)).first;
      final section = OrgDocument.parse(markup).sections.first;

      final first = service.locateTimestamp(
        section,
        entry,
        entry.timestamps.first,
      );
      final second = service.locateTimestamp(
        section,
        entry,
        entry.timestamps[1],
      );

      expect(identical(first, second), isFalse);
      expect(identical(second, service.allTimestampsOf(section)[1]), isTrue);
    });

    test('returns null when the timestamp is gone', () {
      const markup = '* Exam\n<2025-05-15>\n';
      final entry = parseEntries(OrgDocument.parse(markup)).first;
      final section = OrgDocument.parse(
        '* Exam\n<2025-06-01>\n',
      ).sections.first;

      expect(
        service.locateTimestamp(section, entry, entry.timestamps.first),
        isNull,
      );
    });
  });

  group('replacementsFor', () {
    test('replaces a timestamp in the body', () {
      final markup = applied(
        '* Exam\n<2025-05-15>\n',
        (entry) => EntryEdit(
          oldTimestamp: entry.timestamps.first,
          newTimestamp: stamp('16'),
        ),
      );

      expect(markup, equals('* Exam\n<2025-05-16>\n'));
    });

    test('replaces the scheduled timestamp', () {
      final markup = applied(
        '* Exam\nSCHEDULED: <2025-05-15>\n',
        (entry) => EntryEdit(
          oldTimestamp: entry.scheduled!.value as OrgTimestamp,
          newTimestamp: stamp('16'),
        ),
      );

      expect(markup, equals('* Exam\nSCHEDULED: <2025-05-16>\n'));
    });

    test('replaces the title', () {
      final markup = applied(
        '* Exam\n<2025-05-15>\n',
        (entry) => const EntryEdit(newTitle: 'History exam'),
      );

      expect(markup, equals('* History exam\n<2025-05-15>\n'));
    });

    test('replaces title and timestamp together in the headline', () {
      final markup = applied(
        '* Exam <2025-05-15>\n',
        (entry) => EntryEdit(
          newTitle: 'History exam',
          oldTimestamp: entry.timestamps.first,
          newTimestamp: stamp('16'),
        ),
      );

      expect(markup, equals('* History exam<2025-05-16>\n'));
    });

    test('keeps the old timestamp when only the headline title changes', () {
      final markup = applied(
        '* Exam <2025-05-15>\n',
        (entry) => EntryEdit(
          newTitle: 'History exam',
          oldTimestamp: entry.timestamps.first,
        ),
      );

      expect(markup, equals('* History exam<2025-05-15>\n'));
    });

    test('changes nothing when the old timestamp is gone', () {
      final entry = parseEntries(
        OrgDocument.parse('* Exam\n<2025-05-15>\n'),
      ).first;
      final section = OrgDocument.parse(
        '* Exam\n<2025-06-01>\n',
      ).sections.first;

      final replacements = service.replacementsFor(
        section,
        entry,
        EntryEdit(
          oldTimestamp: entry.timestamps.first,
          newTimestamp: stamp('16'),
        ),
      );

      expect(replacements, isEmpty);
    });
  });
}

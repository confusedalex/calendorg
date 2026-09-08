import 'package:calendorg/entities/org_entry/org_entry_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  List<OrgEntryLocator> locatorsOf(String markup) {
    final locators = <OrgEntryLocator>[];
    visitSections(
      OrgDocument.parse(markup),
      (section, ancestors, locator) => locators.add(locator),
    );
    return locators;
  }

  String? titleOf(String markup, OrgEntryLocator locator) =>
      locateSection(OrgDocument.parse(markup), locator)?.headline.rawTitle;

  group('visitSections', () {
    test('reports the raw headline of every ancestor, own headline last', () {
      const markup = '''
* Parent
** Child
*** Grandchild
* Second root
''';

      expect(
        locatorsOf(markup).map((locator) => locator.titlePath),
        equals([
          ['Parent'],
          ['Parent', 'Child'],
          ['Parent', 'Child', 'Grandchild'],
          ['Second root'],
        ]),
      );
    });

    test('counts sections that share a path, in document order', () {
      const markup = '''
* Task
* Task
* Task
''';

      expect(
        locatorsOf(markup).map((locator) => locator.occurrence),
        equals([0, 1, 2]),
      );
    });

    test('a repeated title under a different parent starts again at zero', () {
      const markup = '''
* Work
** Review
* Home
** Review
''';

      final locators = locatorsOf(markup);
      expect(locators[1].titlePath, equals(['Work', 'Review']));
      expect(locators[1].occurrence, isZero);
      expect(locators[3].titlePath, equals(['Home', 'Review']));
      expect(locators[3].occurrence, isZero);
    });
  });

  group('locateSection', () {
    test('finds the section again in a new parse of the same markup', () {
      const markup = '''
* Parent
** Child :a:
''';

      expect(titleOf(markup, locatorsOf(markup)[1]), equals('Child '));
    });

    test('tells duplicate siblings apart', () {
      const markup = '''
* Task
:PROPERTIES:
:N: 1
:END:
* Task
:PROPERTIES:
:N: 2
:END:
''';

      final second = locateSection(
        OrgDocument.parse(markup),
        locatorsOf(markup)[1],
      );
      expect(second?.toMarkup(), contains(':N: 2'));
    });

    test('returns null when the headline changed', () {
      const before = '* Old title\n';
      const after = '* New title\n';

      expect(titleOf(after, locatorsOf(before).single), isNull);
    });

    test('returns null when a parent headline changed', () {
      const before = '* Parent\n** Child\n';
      const after = '* Renamed\n** Child\n';

      expect(titleOf(after, locatorsOf(before)[1]), isNull);
    });

    test('returns null when the duplicate it points at is gone', () {
      const before = '* Task\n* Task\n';
      const after = '* Task\n';

      expect(titleOf(after, locatorsOf(before)[1]), isNull);
    });
  });
}

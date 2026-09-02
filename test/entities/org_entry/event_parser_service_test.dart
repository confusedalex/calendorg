import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  final fileInfo = FileInfo(
    identifier: 'x',
    persistable: false,
    uri: 'file:///x.org',
  );

  Map<String, List<String>> tagsByTitle(String markup, {Set<String>? ignored}) {
    final entries = EventParserService().parseEntriesFromDocument(
      fileInfo,
      OrgDocument.parse(markup),
      ignored ?? {},
    );
    return {for (final entry in entries) entry.title.trim(): entry.tags};
  }

  group('EventParserService tag inheritance', () {
    test('a section inherits the tags of every parent section', () {
      const markup = '''
* Parent :a:b:
<2025-05-05>
** Child :c:
<2025-05-06>
*** Grandchild :d:
<2025-05-07>
** Other child
<2025-05-08>
* Second root :z:
<2025-05-09>
''';

      expect(tagsByTitle(markup), {
        'Parent': ['a', 'b'],
        'Child': ['a', 'b', 'c'],
        'Grandchild': ['a', 'b', 'c', 'd'],
        'Other child': ['a', 'b'],
        'Second root': ['z'],
      });
    });

    test('a tag repeated by a child stays in the list twice', () {
      const markup = '''
* Parent :a:
<2025-05-05>
** Child :a:
<2025-05-06>
''';

      expect(tagsByTitle(markup)['Child'], equals(['a', 'a']));
    });

    test('children of an ignored section keep their inherited tags', () {
      const markup = '''
* OTHER Parent :a:
<2025-05-05>
** Child :b:
<2025-05-06>
''';

      final tags = tagsByTitle(markup, ignored: {'OTHER'});
      expect(tags.containsKey('Parent'), isFalse);
      expect(tags['Child'], equals(['a', 'b']));
    });
  });
}

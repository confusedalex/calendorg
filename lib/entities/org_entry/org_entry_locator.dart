import 'package:dart_mappable/dart_mappable.dart';
import 'package:org_parser/org_parser.dart';

part 'org_entry_locator.mapper.dart';

@MappableClass()
class OrgEntryLocator with OrgEntryLocatorMappable {
  final List<String> titlePath;
  final int occurrence;

  const OrgEntryLocator({required this.titlePath, required this.occurrence});
}

typedef SectionVisitor =
    void Function(
      OrgSection section,
      List<OrgSection> ancestors,
      OrgEntryLocator locator,
    );

void visitSections(OrgDocument document, SectionVisitor visitor) {
  final counts = <String, int>{};

  void visit(OrgSection section, List<OrgSection> ancestors) {
    final titlePath = [...ancestors.map(_rawTitle), _rawTitle(section)];
    final key = titlePath.join('\n');

    visitor(
      section,
      ancestors,
      OrgEntryLocator(
        titlePath: titlePath,
        occurrence: counts.update(key, (n) => n + 1, ifAbsent: () => 0),
      ),
    );

    for (final child in section.sections) {
      visit(child, [...ancestors, section]);
    }
  }

  for (final section in document.sections) {
    visit(section, const []);
  }
}

OrgSection? locateSection(OrgDocument document, OrgEntryLocator locator) {
  OrgSection? found;
  visitSections(document, (section, _, candidate) {
    if (found == null && candidate == locator) found = section;
  });
  return found;
}

String _rawTitle(OrgSection section) => section.headline.rawTitle ?? '';

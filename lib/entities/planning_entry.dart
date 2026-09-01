import 'package:dart_mappable/dart_mappable.dart';
import 'package:org_parser/org_parser.dart';

class OrgPlanningEntryMapper extends SimpleMapper<OrgPlanningEntry> {
  const OrgPlanningEntryMapper();

  @override
  OrgPlanningEntry decode(dynamic value) {
    final markup = value as String;
    final wrapped = OrgDocument.parse('* x\n$markup');
    final node = wrapped.find<OrgPlanningEntry>((_) => true)?.node;

    if (node == null) {
      throw FormatException('Cannot parse OrgPlanningEntry from "$markup"');
    }

    return node;
  }

  @override
  dynamic encode(OrgPlanningEntry self) => self.toMarkup();
}

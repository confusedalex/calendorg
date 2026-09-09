import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:org_parser/org_parser.dart';

List<OrgEntry> parseEntries(
  OrgDocument document, {
  Set<String> ignored = const {},
  String filePath = 'test.org',
  String fileHash = 'hash',
}) => EventParserService().parseEntriesFromDocument(
  filePath,
  fileHash,
  document,
  ignored,
);

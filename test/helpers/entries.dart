import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/entities/org_entry/org_entry_parser.dart';
import 'package:org_parser/org_parser.dart';

List<OrgEntry> parseEntries(
  OrgDocument document, {
  Set<String> ignored = const {},
  Set<String> done = const {'DONE'},
  String filePath = 'test.org',
  String fileHash = 'hash',
}) => parseEntriesFromDocument(filePath, fileHash, document, ignored, done);

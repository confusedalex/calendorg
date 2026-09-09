import 'package:calendorg/entities/org_entry/event_parser_service.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:org_parser/org_parser.dart';

final _fileInfo = FileInfo(
  identifier: 'test-identifier',
  persistable: false,
  uri: 'file:///test.org',
  fileName: 'test.org',
);

List<OrgEntryLoaded> parseEntries(
  OrgDocument document, {
  Set<String> ignored = const {},
}) => EventParserService().parseEntriesFromDocument(
  _fileInfo,
  document,
  ignored,
);

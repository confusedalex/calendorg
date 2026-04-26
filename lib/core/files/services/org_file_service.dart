import 'dart:io';

import 'package:calendorg/core/files/services/org_parser_service.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:org_parser/org_parser.dart';

class OrgFileService {
  final OrgParserService _parserService;
  final FilePickerWritable _filePicker = FilePickerWritable();

  OrgFileService(this._parserService);

  Future<OrgDocument> documentByIdentifier(String identifier) async {
    try {
      final content = await FilePickerWritable().readFile(
        identifier: identifier,
        reader: (fileInfo, file) => file.readAsString(),
      );
      final parseResult = _parserService.getParser().parse(content);
      return parseResult.value;
    } catch (e) {
      debugPrint('Error parsing document with identifier $identifier: $e');
      rethrow;
    }
  }

  Future<void> saveDocument(String fileIdentifier, OrgDocument document) async {
    try {
      await _filePicker.writeFile(
        identifier: fileIdentifier,
        writer: (file) async =>
            file.writeAsString(document.toMarkup(), mode: FileMode.writeOnly),
      );
    } catch (e) {
      debugPrint('Error saving document: $e');
      rethrow;
    }
  }

  Future<OrgDocument> replaceNodesAndSave(
    String fileIdentifier,
    OrgDocument oldDocument,
    List<(OrgNode, OrgNode)> replacements,
  ) async {
    final newDoc = replacements
        .fold<OrgZipper>(
          oldDocument.edit(),
          (builder, nodes) =>
              builder.find(nodes.$1)?.replace(nodes.$2) as OrgZipper,
        )
        .commit();

    await saveDocument(fileIdentifier, newDoc as OrgDocument);

    final parseResult = _parserService.getParser().parse(newDoc.toMarkup());
    return parseResult.value;
  }
}

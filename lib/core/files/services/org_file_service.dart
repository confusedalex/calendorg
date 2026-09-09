import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

import '../../../shared/org_text_hash.dart';
import '../../../util.dart';
import 'org_parser_service.dart';

class ParsedFile {
  final OrgDocument document;
  final String hash;

  const ParsedFile({required this.document, required this.hash});
}

class OrgFileService {
  final OrgParserService _parserService;
  final filePicker = FilePickerWritable();

  OrgFileService(this._parserService);

  Future<String> readText(String identifier) => filePicker.readFile(
    identifier: identifier,
    reader: (_, file) => file.readAsString(),
  );

  Future<ParsedFile> documentByIdentifier(String identifier) async {
    try {
      final content = await readText(identifier);
      return ParsedFile(
        document: await _parserService.parseContentInBackground(content),
        hash: orgTextHash(content),
      );
    } on Exception catch (e) {
      debugPrint('Error parsing document with identifier $identifier: $e');
      rethrow;
    }
  }

  Future<void> saveDocument(String fileIdentifier, OrgDocument document) async {
    try {
      await filePicker.writeFile(
        identifier: fileIdentifier,
        writer: (file) =>
            file.writeAsString(document.toMarkup(), mode: FileMode.writeOnly),
      );
    } on Exception catch (e) {
      debugPrint('Error saving document: $e');
      rethrow;
    }
  }

  Future<OrgDocument> replaceNodesAndSave(
    String fileIdentifier,
    OrgDocument oldDocument,
    List<(OrgNode, OrgNode)> replacements,
  ) async {
    final newDoc =
        replacements
                .fold<OrgZipper>(
                  oldDocument.edit(),
                  (builder, nodes) => builder.find(nodes.$1)!.replace(nodes.$2),
                )
                .commit()
            as OrgDocument;

    await saveDocument(fileIdentifier, newDoc);
    return newDoc;
  }

  Future<bool> validateFileDirectory(
    BuildContext context,
    FileInfo? fileInfo,
    DirectoryInfo? dirInfo,
  ) async {
    if (fileInfo == null || dirInfo == null) return false;
    if (fileInfo.fileName == null) return false;

    void sendErr() => sendError(
      context,
      'File is not in org folder!\nPlease select a file that lies in your in org folder or change your org folder.',
    );

    try {
      late final EntityInfo relative;

      try {
        relative = await filePicker.resolveRelativePath(
          directoryIdentifier: dirInfo.identifier,
          relativePath: fileInfo.fileName!,
        );
      } on Exception {
        sendErr();
        return false;
      }

      final relativeSize = await filePicker.readFile(
        identifier: relative.identifier,
        reader: (_, file) => file.length(),
      );
      final pickedSize = await filePicker.readFile(
        identifier: fileInfo.identifier,
        reader: (_, file) => file.length(),
      );

      final isSameFile = relativeSize == pickedSize;

      if (!isSameFile) {
        sendErr();
      }

      return isSameFile;
    } on Exception {
      return false;
    }
  }
}

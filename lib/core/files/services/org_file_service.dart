import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/widgets.dart';
import 'package:org_parser/org_parser.dart';

import '../../../util.dart';
import 'org_parser_service.dart';

class OrgFileService {
  final OrgParserService _parserService;
  final filePicker = FilePickerWritable();

  OrgFileService(this._parserService);

  Future<OrgDocument> documentByIdentifier(String identifier) async {
    try {
      final content = await filePicker.readFile(
        identifier: identifier,
        reader: (fileInfo, file) => file.readAsString(),
      );
      return _parserService.parseContentInBackground(content);
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

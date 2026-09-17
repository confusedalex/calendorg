import 'dart:io';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
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

  Future<ParsedFile> parseText(String content) async => ParsedFile(
    document: await _parserService.parseContentInBackground(content),
    hash: orgTextHash(content),
  );

  Future<FileInfo> resolveFileInfo(
    DirectoryInfo dirInfo,
    String fileName,
  ) async {
    final entity = await filePicker.resolveRelativePath(
      directoryIdentifier: dirInfo.identifier,
      relativePath: fileName,
    );
    return entity as FileInfo;
  }

  Future<ParsedFile> documentByIdentifier(String identifier) async {
    try {
      return await parseText(await readText(identifier));
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

  Future<ParsedFile?> appendToFile(FileInfo fileInfo, String markup) async {
    try {
      final oldText = await readText(fileInfo.identifier);
      final newText = '$oldText\n$markup';

      await filePicker.writeFile(
        identifier: fileInfo.identifier,
        writer: (file) => file.writeAsString(newText, mode: FileMode.writeOnly),
      );

      return parseText(newText);
    } on Exception catch (e) {
      sendError('Error saving section: $e');
      debugPrint('$e');
      return null;
    }
  }

  Future<bool> validateFileDirectory(
    BuildContext context,
    FileInfo? fileInfo,
    DirectoryInfo? dirInfo,
  ) async {
    if (fileInfo == null || dirInfo == null) return false;
    if (fileInfo.fileName == null) return false;

    void sendErr() => sendError(
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

      final relativeHash = await filePicker.readFile(
        identifier: relative.identifier,
        reader: (_, file) async => orgTextHash(await file.readAsString()),
      );
      final pickedHash = await filePicker.readFile(
        identifier: fileInfo.identifier,
        reader: (_, file) async => orgTextHash(await file.readAsString()),
      );

      final isSameFile = relativeHash == pickedHash;

      if (!isSameFile) {
        sendErr();
      }

      return isSameFile;
    } on Exception {
      sendError('Error while reading file!');
      return false;
    }
  }
}

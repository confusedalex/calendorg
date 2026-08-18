import 'dart:convert';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrgFilePersistenceService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<void> saveDirectory(DirectoryInfo directoryInfo) async {
    try {
      await _prefs.setString('agendaDirectory', jsonEncode(directoryInfo));
    } catch (e) {
      debugPrint('Error saving file list: $e');
      rethrow;
    }
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) async {
    try {
      await _prefs.setStringList(
        'agendaFiles',
        fileInfos.map((e) => e.fileName).whereType<String>().toList(),
      );
    } catch (e) {
      debugPrint('Error saving file list: $e');
      rethrow;
    }
  }

  Future<void> saveInboxFile(FileInfo fileInfo) async {
    try {
      await _prefs.setString('inboxFile', fileInfo.fileName ?? 'null');
    } catch (e) {
      debugPrint('Error saving inbox file: $e');
      rethrow;
    }
  }

  Future<(Set<FileInfo>, FileInfo?, DirectoryInfo?)>
  loadFilePreferences() async {
    try {
      final filesString = await _prefs.getStringList('agendaFiles');
      final inboxFileString = await _prefs.getString('inboxFile');
      final directoryString = await _prefs.getString('agendaDirectory');

      final inboxName =
          (inboxFileString == null ||
              inboxFileString == 'null' ||
              inboxFileString == '')
          ? null
          : inboxFileString;

      final dirInfo = (directoryString == null || directoryString == 'null')
          ? null
          : DirectoryInfo.fromJsonString(directoryString);

      if (dirInfo == null) {
        return (<FileInfo>{}, null, null);
      }

      final FileInfo? inboxFile = inboxName != null
          ? (await FilePickerWritable().resolveRelativePath(
                  directoryIdentifier: dirInfo.identifier,
                  relativePath: inboxName,
                ))
                as FileInfo
          : null;

      final Set<FileInfo> fileInfos = filesString != null
          ? (await Future.wait(
              filesString.whereType<String>().map(
                (s) => FilePickerWritable().resolveRelativePath(
                  directoryIdentifier: dirInfo.identifier,
                  relativePath: s,
                ),
              ),
            )).cast<FileInfo>().toSet()
          : {};

      return (fileInfos, inboxFile, dirInfo);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      return (<FileInfo>{}, null, null);
    }
  }
}

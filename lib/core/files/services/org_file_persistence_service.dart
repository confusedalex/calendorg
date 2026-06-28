import 'dart:convert';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrgFilePersistenceService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<void> saveDirectory(DirectoryInfo directoryInfo) async {
    try {
      await _prefs.setString("agendaDirectory", jsonEncode(directoryInfo));
    } catch (e) {
      debugPrint('Error saving file list: $e');
      rethrow;
    }
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) async {
    try {
      await _prefs.setString("agendaFiles", jsonEncode(fileInfos.toList()));
    } catch (e) {
      debugPrint('Error saving file list: $e');
      rethrow;
    }
  }

  Future<void> saveInboxFile(FileInfo fileInfo) async {
    try {
      await _prefs.setString("inboxFile", jsonEncode(fileInfo));
    } catch (e) {
      debugPrint('Error saving inbox file: $e');
      rethrow;
    }
  }

  Future<(Set<FileInfo>, FileInfo?, DirectoryInfo?)>
  loadFilePreferences() async {
    try {
      final filesString = await _prefs.getString("agendaFiles");
      final inboxFileString = await _prefs.getString("inboxFile");
      final directoryString = await _prefs.getString("agendaDirectory");

      final fileInfos = filesString == null
          ? <FileInfo>{}
          : (jsonDecode(filesString) as List<dynamic>)
                .map((info) => FileInfo.fromJson(info))
                .toSet();

      final inboxFile = (inboxFileString == null || inboxFileString == "null")
          ? null
          : FileInfo.fromJson(jsonDecode(inboxFileString));

      final dirInfo = (directoryString == null || directoryString == "null")
          ? null
          : DirectoryInfo.fromJsonString(directoryString);

      return (fileInfos, inboxFile, dirInfo);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      return (<FileInfo>{}, null, null);
    }
  }
}

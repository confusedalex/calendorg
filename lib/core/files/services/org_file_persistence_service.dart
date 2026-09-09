import 'dart:convert';
import 'dart:isolate';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/foundation.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../shared/config/preferences_service.dart';
import 'org_file_service.dart';

class OrgFilePersistenceService {
  OrgFilePersistenceService(this._prefs, this._fileService);
  final PreferencesService _prefs;
  final OrgFileService _fileService;

  Future<void> saveDirectory(DirectoryInfo directoryInfo) async {
    try {
      await _prefs.setString(
        PrefKeys.agendaDirectory,
        jsonEncode(directoryInfo),
      );
    } on Exception catch (e) {
      debugPrint('Error saving file list: $e');
      rethrow;
    }
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) async {
    try {
      await _prefs.setStringList(
        PrefKeys.agendaFiles,
        fileInfos.map((e) => e.fileName).whereType<String>().toList(),
      );
    } on Exception catch (e) {
      debugPrint('Error saving file list: $e');
      rethrow;
    }
  }

  Future<void> saveInboxFile(FileInfo fileInfo) async {
    try {
      await _prefs.setString(PrefKeys.inboxFile, fileInfo.fileName ?? 'null');
    } on Exception catch (e) {
      debugPrint('Error saving inbox file: $e');
      rethrow;
    }
  }

  Future<void> saveEntriesCache(List<OrgEntry> entries, String cacheKey) async {
    try {
      final json = await Isolate.run(
        () => entries.map((e) => e.toJson()).toList(),
      );

      await _prefs.setStringList(PrefKeys.entriesCache, json);
      await _prefs.setString(PrefKeys.entriesCacheKey, cacheKey);
    } on Exception catch (e) {
      debugPrint('Error saving entries cache: $e');
      rethrow;
    }
  }

  Future<List<OrgEntry>?>? loadCachedOrgEntries(String cacheKey) async {
    if (await _prefs.getString(PrefKeys.entriesCacheKey) != cacheKey) {
      return null;
    }

    final entriesCacheString = await _prefs.getStringList(
      PrefKeys.entriesCache,
    );
    if (entriesCacheString == null) return null;

    return Isolate.run(
      () => entriesCacheString.map(OrgEntryMapper.fromJson).toList(),
    );
  }

  Future<(Set<FileInfo>, FileInfo?, DirectoryInfo?)>
  loadFilePreferences() async {
    try {
      final filesString = await _prefs.getStringList(PrefKeys.agendaFiles);
      final inboxFileString = await _prefs.getString(PrefKeys.inboxFile);
      final directoryString = await _prefs.getString(PrefKeys.agendaDirectory);

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
          ? (await _fileService.filePicker.resolveRelativePath(
                  directoryIdentifier: dirInfo.identifier,
                  relativePath: inboxName,
                ))
                as FileInfo
          : null;

      final Set<FileInfo> fileInfos = filesString != null
          ? (await Future.wait(
              filesString.whereType<String>().map(
                (s) => _fileService.filePicker.resolveRelativePath(
                  directoryIdentifier: dirInfo.identifier,
                  relativePath: s,
                ),
              ),
            )).cast<FileInfo>().toSet()
          : {};

      return (fileInfos, inboxFile, dirInfo);
    } on Exception catch (e) {
      debugPrint('Error loading preferences: $e');
      return (<FileInfo>{}, null, null);
    }
  }
}

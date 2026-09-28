import 'dart:convert';
import 'dart:isolate';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:logging/logging.dart';
import '../../../entities/org_entry/org_entry.dart';
import '../../../shared/config/preferences_service.dart';
import '../../../util.dart';

final _log = Logger('OrgFilePersistenceService');

class OrgFilePersistenceService {
  OrgFilePersistenceService(this._prefs, this._filePicker);
  final PreferencesService _prefs;
  final FilePickerWritable _filePicker;

  Future<void> saveDirectory(DirectoryInfo directoryInfo) async {
    try {
      await _prefs.setString(
        PrefKeys.agendaDirectory,
        jsonEncode(directoryInfo),
      );
    } on Exception catch (e, stack) {
      _log.warning('Error saving file list', e, stack);
      rethrow;
    }
  }

  Future<void> saveFileList(Set<FileInfo> fileInfos) async {
    try {
      await _prefs.setStringList(
        PrefKeys.agendaFiles,
        fileInfos.map((e) => e.fileName).whereType<String>().toList(),
      );
    } on Exception catch (e, stack) {
      _log.warning('Error saving file list', e, stack);
      rethrow;
    }
  }

  Future<void> saveInboxFile(FileInfo fileInfo) async {
    try {
      await _prefs.setString(PrefKeys.inboxFile, fileInfo.fileName!);
    } on Exception catch (e, stack) {
      _log.warning('Error saving inbox file', e, stack);
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
    } on Exception catch (e, stack) {
      _log.warning('Error saving entries cache', e, stack);
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

      final inboxName = (inboxFileString == null || inboxFileString == '')
          ? null
          : inboxFileString;

      final dirInfo = (directoryString == null)
          ? null
          : DirectoryInfo.fromJsonString(directoryString);

      if (dirInfo == null) {
        return (<FileInfo>{}, null, null);
      }

      final missing = <String>[];
      Future<FileInfo?> resolve(String name) async {
        final file = await _resolveFile(dirInfo, name);
        if (file == null) missing.add(name);
        return file;
      }

      final inboxFile = inboxName != null ? await resolve(inboxName) : null;
      final fileInfos = (await Future.wait(
        (filesString ?? const <String>[]).map(resolve),
      )).nonNulls.toSet();

      if (missing.isNotEmpty) {
        sendError(
          globalL10n.error_files_not_found(missing.length, missing.join(', ')),
        );
      }

      return (fileInfos, inboxFile, dirInfo);
    } on Exception catch (e, stack) {
      _log.warning('Error loading preferences', e, stack);
      return (<FileInfo>{}, null, null);
    }
  }

  Future<FileInfo?> _resolveFile(DirectoryInfo dirInfo, String name) async {
    try {
      final entity = await _filePicker.resolveRelativePath(
        directoryIdentifier: dirInfo.identifier,
        relativePath: name,
      );
      if (entity is FileInfo) return entity;
      _log.warning('$name is not a file');
    } on Exception catch (e, stack) {
      _log.warning('Error resolving file $name', e, stack);
    }
    return null;
  }
}

import 'package:calendorg/core/files/services/org_file_persistence_service.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late OrgFilePersistenceService service;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    service = OrgFilePersistenceService();
  });

  group('saveFileList()', () {
    test('should write fileInfos to agendaFiles preference', () async {
      final Set<FileInfo> fileInfos = {
        fakeFileInfo('notes'),
        fakeFileInfo('work'),
      };

      service.saveFileList(fileInfos);

      expect(
        await SharedPreferencesAsync().getStringList('agendaFiles'),
        equals(fileInfos.map((e) => e.fileName).toList()),
      );
    });
    test('should throw error when fails', () {});
  });
}

FileInfo fakeFileInfo(String name) => FileInfo(
  identifier: '$name-identifier',
  persistable: true,
  uri: '$name-uri',
  fileName: '$name.org',
);

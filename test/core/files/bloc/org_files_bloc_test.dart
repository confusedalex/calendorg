import 'package:bloc_test/bloc_test.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  group(
    "OrgFilesBloc",
    () {
      setUp(() {
        WidgetsFlutterBinding.ensureInitialized();
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.empty();
        SharedPreferences.setMockInitialValues({});

        when(FilePickerWritable().readFile(
                identifier: MockFileInfo().identifier,
                reader: (fileInfo, file) => file.readAsString()))
            .thenAnswer((_) => Future(() => "* Heading 1"));
      });

      blocTest("File gets added to FileInfo Array",
          build: () => OrgFilesBloc()..add(OrgFilesInit()),
          act: (bloc) => bloc.add(OrgFilesAddFilePath(MockFileInfo())),
          expect: () => [
                TypeMatcher<OrgFilesState>()
                    .having(
                        (state) => state.filePaths, "filePaths", hasLength(1))
                    .having((state) => state.documentsMap.values,
                        "documentsMap", hasLength(1))
              ]);

      blocTest("File gets removed ",
          build: () => OrgFilesBloc()..add(OrgFilesInit()),
          act: (bloc) => bloc
            ..add(OrgFilesAddFilePath(MockFileInfo()))
            ..add(OrgFilesRemoveFilePath(MockFileInfo())),
          skip: 1,
          expect: () => [
                TypeMatcher<OrgFilesState>().having(
                    (state) => state.filePaths, "filePaths", hasLength(0))
              ]);
    },
  skip: true);
}

class MockFileInfo extends Mock implements FileInfo {
  @override
  String get identifier => "MockIdentifier";
}

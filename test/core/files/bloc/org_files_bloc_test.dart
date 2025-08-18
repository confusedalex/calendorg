import 'dart:convert';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:flutter/material.dart';
import 'package:org_parser/src/org/model.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:test/test.dart';
import 'package:calendorg/core/files/bloc/org_files_bloc.dart';

void main() {
  group("OrgFilesBloc", () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();

      WidgetsFlutterBinding.ensureInitialized();
    });
    test('adding file works', () async {
      final bloc = FakeOrgFilesBloc()..add(OrgFilesInit());

      bloc.add(OrgFilesAddFilePath(FileInfo(
          identifier: "file-identifier", persistable: true, uri: "file-uri")));

      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state.filePaths, isNotEmpty);
    });
    test('removing file works', () async {
      final file = FileInfo(
          identifier: "file-identifier", persistable: true, uri: "file-uri");
      final bloc = FakeOrgFilesBloc();

      bloc.add(OrgFilesAddFilePath(file));

      await Future.delayed(Duration(milliseconds: 10));

      bloc.add(OrgFilesRemoveFilePath(file));

      await Future.delayed(Duration(milliseconds: 10));

      expect(bloc.state.filePaths, isEmpty);
    });
    test('changing inboxFile works', () async {
      final file = FileInfo(
          identifier: "file-identifier", persistable: true, uri: "file-uri");
      final bloc = FakeOrgFilesBloc();

      bloc.add(OrgFilesChangeInboxFileEvent(file));

      await Future.delayed(Duration(milliseconds: 10));

      expect(bloc.state.inboxFile, equals(file));
    });
    group("loading from sharedPreferences", () {
      test('loading agendaFiles and inboxFile from sharedPreferences works',
          () async {
        final inboxFile = FileInfo(
            identifier: "inboxFile-identifier",
            persistable: true,
            uri: "inboxFile-uri");
        final agendaFileOne = FileInfo(
            identifier: "agendaFileOne-identifier",
            persistable: true,
            uri: "agendaFileOne-uri");
        final agendaFileTwo = FileInfo(
            identifier: "agendaFileTwo-identifier",
            persistable: true,
            uri: "agendaFileTwo-uri");
        final agendaFilesArray = [agendaFileTwo, agendaFileOne];

        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
          "inboxFile": inboxFile.toJsonString(),
          "agendaFiles": jsonEncode(agendaFilesArray)
        });

        final bloc = FakeOrgFilesBloc()..add(OrgFilesInit());

        await Future.delayed(Duration(milliseconds: 10));

        expect(bloc.state.inboxFile!.identifier, equals(inboxFile.identifier));
        expect(bloc.state.filePaths.map((e) => e.identifier),
            equals(agendaFilesArray.map((e) => e.identifier)));
      });
      test('loading only inboxFile from sharedPreferences works', () async {
        final inboxFile = FileInfo(
            identifier: "inboxFile-identifier",
            persistable: true,
            uri: "inboxFile-uri");

        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
          "inboxFile": inboxFile.toJsonString(),
        });

        final bloc = FakeOrgFilesBloc()..add(OrgFilesInit());

        await Future.delayed(Duration(milliseconds: 10));

        expect(bloc.state.inboxFile!.identifier, equals(inboxFile.identifier));
        expect(bloc.state.filePaths, isEmpty);
      });
      test('loading only agendaFiles from sharedPreferences works', () async {
        final agendaFileOne = FileInfo(
            identifier: "agendaFileOne-identifier",
            persistable: true,
            uri: "agendaFileOne-uri");
        final agendaFileTwo = FileInfo(
            identifier: "agendaFileTwo-identifier",
            persistable: true,
            uri: "agendaFileTwo-uri");
        final agendaFilesArray = [agendaFileTwo, agendaFileOne];

        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData(
                {"agendaFiles": jsonEncode(agendaFilesArray)});

        final bloc = FakeOrgFilesBloc()..add(OrgFilesInit());

        await Future.delayed(Duration(milliseconds: 10));

        expect(bloc.state.inboxFile, isNull);
        expect(bloc.state.filePaths.map((e) => e.identifier),
            equals(agendaFilesArray.map((e) => e.identifier)));
      });
    });
  });
}

class FakeOrgFilesBloc extends OrgFilesBloc {
  @override
  Future<OrgDocument> documentByIdentifier(String identifier) =>
      Future.value(OrgDocument.parse("* Heading 1"));
}

import 'dart:convert';

import 'package:calendorg/core/settings/app_settings.dart';
import 'package:calendorg/core/settings/settings_cubit.dart';
import 'package:calendorg/core/tag_colors/tag_color.dart';
import 'package:calendorg/entities/org_entry/org_entry.dart';
import 'package:calendorg/entities/todo_states/todo_states.dart';
import 'package:calendorg/shared/config/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helpers/preferences.dart';

const schoolTagColor = TagColor('school', Colors.orange);
const homeTagColor = TagColor('@home', Colors.green);

void main() {
  group('loading', () {
    test('uses the defaults without saved settings', () async {
      final cubit = await SettingsCubit.load(inMemoryPreferences());

      expect(cubit.state.themeMode, ThemeMode.system);
      expect(cubit.state.startingDay, StartingDayOfWeek.monday);
      expect(cubit.state.tagColors, isEmpty);
      expect(cubit.state.todoStates.todo, ['TODO']);
      expect(cubit.state.todoStates.done, ['DONE']);
    });

    test('reads the saved settings', () async {
      final cubit = await SettingsCubit.load(
        inMemoryPreferences({
          'themeMode': 'dark',
          'startingDay': 4,
          'tagColors': jsonEncode([schoolTagColor]),
          'todoStates': '["TOREAD"]',
          'doneStates': '["COMPLETED"]',
        }),
      );

      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.state.startingDay, StartingDayOfWeek.friday);
      expect(cubit.state.tagColors, [schoolTagColor]);
      expect(cubit.state.todoStates.todo, ['TOREAD']);
      expect(cubit.state.todoStates.done, ['COMPLETED']);
    });

    test('ignores a starting day out of range', () async {
      final cubit = await SettingsCubit.load(
        inMemoryPreferences({'startingDay': 9}),
      );

      expect(cubit.state.startingDay, StartingDayOfWeek.monday);
    });
  });

  group('saving', () {
    late PreferencesService prefs;
    late SettingsCubit cubit;

    setUp(() {
      prefs = inMemoryPreferences();
      cubit = SettingsCubit(prefs, const AppSettings());
    });

    Future<AppSettings> reloaded() async =>
        (await SettingsCubit.load(prefs)).state;

    test('saves the theme', () async {
      await cubit.setThemeMode(ThemeMode.light);

      expect(cubit.state.themeMode, ThemeMode.light);
      expect((await reloaded()).themeMode, ThemeMode.light);
    });

    test('saves the starting day', () async {
      await cubit.setStartingDay(StartingDayOfWeek.sunday);

      expect(cubit.state.startingDay, StartingDayOfWeek.sunday);
      expect((await reloaded()).startingDay, StartingDayOfWeek.sunday);
    });

    test('saves todo states', () async {
      await cubit.addTodoState(TodoStatus.todo, 'TOCALL');
      await cubit.addTodoState(TodoStatus.done, 'KILL');
      await cubit.removeTodoState(TodoStatus.todo, 'TODO');

      expect(cubit.state.todoStates.todo, ['TOCALL']);
      expect(cubit.state.todoStates.done, ['DONE', 'KILL']);
      expect((await reloaded()).todoStates, cubit.state.todoStates);
    });
  });

  group('tag colors', () {
    late PreferencesService prefs;
    late SettingsCubit cubit;

    setUp(() {
      prefs = inMemoryPreferences();
      cubit = SettingsCubit(
        prefs,
        const AppSettings(tagColors: [schoolTagColor]),
      );
    });

    test('adding a tag saves it', () async {
      await cubit.addTagColor(homeTagColor);

      expect(cubit.state.tagColors, [schoolTagColor, homeTagColor]);
      expect((await SettingsCubit.load(prefs)).state.tagColors, [
        schoolTagColor,
        homeTagColor,
      ]);
    });

    test('adding a tag with the same name replaces it', () async {
      const newSchoolTag = TagColor('school', Colors.green);

      await cubit.addTagColor(newSchoolTag);

      expect(cubit.state.tagColors, [newSchoolTag]);
    });

    test('removing a tag works', () async {
      await cubit.removeTagColor(schoolTagColor.tag);

      expect(cubit.state.tagColors, isEmpty);
    });

    test('reordering works', () async {
      await cubit.addTagColor(homeTagColor);
      await cubit.reorderTagColors(0, 1);

      expect(cubit.state.tagColors, [homeTagColor, schoolTagColor]);
    });
  });

  group('tagColorOf', () {
    const settings = AppSettings(tagColors: [schoolTagColor, homeTagColor]);

    test('returns the color of the tag', () {
      expect(
        settings.tagColorOf(FakeEntry(['school'])),
        isSameColorAs(schoolTagColor.color),
      );
    });

    test('returns blue when no tag matches', () {
      expect(
        settings.tagColorOf(FakeEntry(['work'])),
        isSameColorAs(Colors.blue),
      );
    });

    test('prefers the first tag color in the list', () {
      expect(
        settings.tagColorOf(FakeEntry(['@home', 'school'])),
        isSameColorAs(schoolTagColor.color),
      );
    });
  });
}

class FakeEntry extends Fake implements OrgEntry {
  @override
  List<String> tags;

  FakeEntry(this.tags);
}

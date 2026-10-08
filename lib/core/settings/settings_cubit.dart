import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../entities/todo_states/todo_states.dart';
import '../../entities/todo_states/todo_states_ignored.dart';
import '../../shared/config/preferences_service.dart';
import '../tag_colors/tag_color.dart';
import 'app_settings.dart';

final _log = Logger('SettingsCubit');

class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._prefs, super.initialState);

  final PreferencesService _prefs;

  static Future<SettingsCubit> load(PreferencesService prefs) async =>
      SettingsCubit(
        prefs,
        AppSettings(
          themeMode: await _loadThemeMode(prefs),
          startingDay: await _loadStartingDay(prefs),
          tagColors: await _loadTagColors(prefs),
          todoStates: await _loadTodoStates(prefs),
        ),
      );

  Future<void> setThemeMode(ThemeMode themeMode) async {
    emit(state.copyWith(themeMode: themeMode));
    await _prefs.setString(PrefKeys.themeMode, themeMode.name);
  }

  Future<void> setStartingDay(StartingDayOfWeek startingDay) async {
    emit(state.copyWith(startingDay: startingDay));
    await _prefs.setInt(PrefKeys.startingDay, startingDay.index);
  }

  Future<void> addTagColor(TagColor tagColor) => _setTagColors([
    ...state.tagColors.where((t) => t.tag != tagColor.tag),
    tagColor,
  ]);

  Future<void> removeTagColor(String tag) =>
      _setTagColors([...state.tagColors.where((t) => t.tag != tag)]);

  Future<void> reorderTagColors(int oldIndex, int newIndex) {
    final tagColors = [...state.tagColors];
    tagColors.insert(newIndex, tagColors.removeAt(oldIndex));
    return _setTagColors(tagColors);
  }

  Future<void> addTodoState(TodoStatus status, String keyword) =>
      _setTodoStates(
        state.todoStates.withStates(status, [
          ...state.todoStates.statesOf(status),
          keyword,
        ]),
      );

  Future<void> removeTodoState(TodoStatus status, String keyword) =>
      _setTodoStates(
        state.todoStates.withStates(
          status,
          state.todoStates.statesOf(status).where((e) => e != keyword).toList(),
        ),
      );

  Future<void> _setTagColors(List<TagColor> tagColors) async {
    emit(state.copyWith(tagColors: tagColors));
    await _prefs.setString(PrefKeys.tagColors, jsonEncode(tagColors));
  }

  Future<void> _setTodoStates(OrgTodoStatesWithIgnored todoStates) async {
    emit(state.copyWith(todoStates: todoStates));
    try {
      await _prefs.setString(PrefKeys.todoStates, jsonEncode(todoStates.todo));
      await _prefs.setString(PrefKeys.doneStates, jsonEncode(todoStates.done));
      await _prefs.setString(
        PrefKeys.ignoredStates,
        jsonEncode(todoStates.ignored),
      );
    } on Exception catch (e, stack) {
      _log.warning('Error saving todo states', e, stack);
    }
  }

  static Future<ThemeMode> _loadThemeMode(PreferencesService prefs) async {
    try {
      final name = await prefs.getString(PrefKeys.themeMode);
      return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
    } on Exception {
      return ThemeMode.system;
    }
  }

  static Future<StartingDayOfWeek> _loadStartingDay(
    PreferencesService prefs,
  ) async {
    try {
      final index = await prefs.getInt(PrefKeys.startingDay) ?? 0;
      return StartingDayOfWeek.values.asMap()[index] ??
          StartingDayOfWeek.monday;
    } on Exception {
      return StartingDayOfWeek.monday;
    }
  }

  static Future<List<TagColor>> _loadTagColors(PreferencesService prefs) async {
    try {
      final stored = await prefs.getString(PrefKeys.tagColors) ?? '[]';
      return (jsonDecode(stored) as List)
          .map((tagColor) => TagColor.fromJson(tagColor))
          .toList();
    } on Exception {
      return [];
    }
  }

  static Future<OrgTodoStatesWithIgnored> _loadTodoStates(
    PreferencesService prefs,
  ) async {
    try {
      final List<String> todo = List.from(
        jsonDecode(await prefs.getString(PrefKeys.todoStates) ?? '[]'),
      );
      final List<String> done = List.from(
        jsonDecode(await prefs.getString(PrefKeys.doneStates) ?? '[]'),
      );
      final List<String> ignored = List.from(
        jsonDecode(await prefs.getString(PrefKeys.ignoredStates) ?? '[]'),
      );

      return todo.isEmpty && done.isEmpty
          ? OrgTodoStatesWithIgnored.defaults
          : OrgTodoStatesWithIgnored(todo: todo, done: done, ignored: ignored);
    } on Exception {
      return OrgTodoStatesWithIgnored.defaults;
    }
  }
}
